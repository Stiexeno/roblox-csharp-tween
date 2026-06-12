local Native = require(script.Parent.Native)
local Stepper = require(script.Parent.Stepper)
local Registry = require(script.Parent.Registry)

local Tween = {}
Tween.__index = Tween

setmetatable(Tween, { __tostring = function() return "Tween" end })

Tween.__ctorParams = {}
Tween.__interfaces = {}

local function safeCall(cb)
    if not cb then return end
    local ok, err = pcall(cb)
    if not ok then warn("Tween callback error: " .. tostring(err)) end
end

function Tween.new(kind, params)
    local self = setmetatable({}, Tween)
    return self:constructor(kind, params) or self
end

function Tween:constructor(kind, params)
    self._kind = kind or "noop"
    self._params = params or {}
    self._ease = 0
    self._delay = 0
    self._loops = 0
    self._loopType = 0
    self._cb = {}
    self._state = "pending"
    self._impl = nil
    self._claimed = false -- set by Sequence; suppresses auto-play
    self._captured = false
    self._initial = nil
    Registry.add(self)
    task.defer(function()
        if self._state == "pending" and not self._claimed then self:_start() end
    end)
end

function Tween:SetEase(ease) self._ease = ease; return self end
function Tween:SetDelay(d) self._delay = d; return self end
function Tween:SetLoops(loops, ltype)
    self._loops = loops or 0 -- -1 = infinite (DOTween convention)
    self._loopType = ltype or 0
    return self
end

function Tween:OnStart(cb) self._cb.start = cb; return self end
function Tween:OnUpdate(cb) self._cb.update = cb; return self end
function Tween:OnComplete(cb) self._cb.complete = cb; return self end
function Tween:OnKill(cb) self._cb.kill = cb; return self end

-- Capture the value at first start so Restart / sequence replays can rewind.
function Tween:_captureInitial()
    if self._captured then return end
    self._captured = true
    local p = self._params
    local ok, v
    if self._kind == "property" then
        ok, v = pcall(function() return p.target[p.property] end)
    elseif self._kind == "custom" and p.getter then
        ok, v = pcall(p.getter)
    end
    if ok then self._initial = v end
end

function Tween:_rewind()
    if not self._captured or self._initial == nil then return end
    local p = self._params
    if self._kind == "property" then
        pcall(function() p.target[p.property] = self._initial end)
    elseif self._kind == "custom" and p.setter then
        pcall(p.setter, self._initial)
    end
end

function Tween:_start()
    if self._state ~= "pending" and self._state ~= "paused" then return end
    self._state = "playing"
    self:_captureInitial()
    safeCall(self._cb.start)
    if self._kind == "property" then
        if self._loopType == 2 then
            -- Native TweenInfo has no Incremental concept; run property
            -- tweens with Incremental loops through the stepper instead.
            local p = self._params
            p.getter = p.getter or function() return p.target[p.property] end
            p.setter = p.setter or function(v) p.target[p.property] = v end
            self._impl = Stepper.start(self)
        else
            self._impl = Native.start(self)
        end
    elseif self._kind == "custom" then
        self._impl = Stepper.start(self)
    end
end

function Tween:_finish(reason)
    if self._state == "completed" or self._state == "killed" then return end
    self._state = reason
    if self._impl and self._impl.stop then self._impl.stop() end
    self._impl = nil
    Registry.remove(self)
    if reason == "completed" then safeCall(self._cb.complete) end
    if reason == "killed" then safeCall(self._cb.kill) end
end

-- Stop any running impl and return to "pending" so the tween can be
-- (re)started. Killed tweens stay dead. Used by Restart and by Sequence
-- when replaying segments on loops/Restart.
function Tween:_reset()
    if self._state == "killed" then return end
    if self._impl and self._impl.stop then self._impl.stop() end
    self._impl = nil
    self:_rewind()
    self._state = "pending"
    Registry.add(self)
end

function Tween:Play()
    if self._state == "paused" then
        if self._impl then
            self._state = "playing"
            if self._impl.resume then self._impl.resume() end
        else
            self:_start()
        end
    elseif self._state == "pending" then
        self:_start()
    end
end

function Tween:Pause()
    if self._state ~= "playing" then return end
    self._state = "paused"
    if self._impl and self._impl.pause then self._impl.pause() end
end

function Tween:Resume() self:Play() end
function Tween:Kill() self:_finish("killed") end

function Tween:Restart()
    self:_reset()
    task.defer(function() if self._state == "pending" then self:_start() end end)
end

function Tween:Complete()
    if self._state == "completed" or self._state == "killed" then return end
    if self._impl and self._impl.complete then
        self._impl.complete()
    else
        -- Never started (e.g. claimed by a sequence): apply the end value directly.
        local p = self._params
        if self._kind == "property" then
            pcall(function() p.target[p.property] = p.endValue end)
        elseif self._kind == "custom" and p.setter then
            pcall(p.setter, p.endValue)
        end
    end
    self:_finish("completed")
end

function Tween:IsPlaying() return self._state == "playing" end
function Tween:IsCompleted() return self._state == "completed" end
function Tween:Elapsed() return self._impl and self._impl.elapsed and self._impl.elapsed() or 0 end

return Tween
