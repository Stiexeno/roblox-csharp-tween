local Native = require(script.Parent.Native)
local Stepper = require(script.Parent.Stepper)
local Registry = require(script.Parent.Registry)

local Tween = {}
Tween.__index = Tween

setmetatable(Tween, { __tostring = function() return "Tween" end })

Tween.__ctorParams = {}
Tween.__interfaces = {}

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
    Registry.add(self)
    task.defer(function()
        if self._state == "pending" then self:_start() end
    end)
end

function Tween:SetEase(ease) self._ease = ease; return self end
function Tween:SetDelay(d) self._delay = d; return self end
function Tween:SetLoops(loops, ltype)
    self._loops = loops or 0
    self._loopType = ltype or 0
    return self
end

function Tween:OnStart(cb) self._cb.start = cb; return self end
function Tween:OnUpdate(cb) self._cb.update = cb; return self end
function Tween:OnComplete(cb) self._cb.complete = cb; return self end
function Tween:OnKill(cb) self._cb.kill = cb; return self end

function Tween:_start()
    if self._state ~= "pending" and self._state ~= "paused" then return end
    self._state = "playing"
    if self._cb.start then self._cb.start() end
    if self._kind == "property" then
        self._impl = Native.start(self)
    elseif self._kind == "custom" then
        self._impl = Stepper.start(self)
    end
end

function Tween:_finish(reason)
    if self._state == "completed" or self._state == "killed" then return end
    self._state = reason
    if self._impl and self._impl.stop then self._impl.stop() end
    self._impl = nil
    if reason == "completed" and self._cb.complete then self._cb.complete() end
    if reason == "killed" and self._cb.kill then self._cb.kill() end
    Registry.remove(self)
end

function Tween:Play()
    if self._state == "paused" then
        self._state = "playing"
        if self._impl and self._impl.resume then self._impl.resume() end
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
    if self._impl and self._impl.stop then self._impl.stop() end
    self._impl = nil
    self._state = "pending"
    Registry.add(self)
    task.defer(function() if self._state == "pending" then self:_start() end end)
end

function Tween:Complete()
    if self._impl and self._impl.complete then self._impl.complete() end
    self:_finish("completed")
end

function Tween:IsPlaying() return self._state == "playing" end
function Tween:IsCompleted() return self._state == "completed" end
function Tween:Elapsed() return self._impl and self._impl.elapsed and self._impl.elapsed() or 0 end

return Tween
