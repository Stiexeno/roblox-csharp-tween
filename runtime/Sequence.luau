local RunService = game:GetService("RunService")
local Registry = require(script.Parent.Registry)

local Sequence = {}
Sequence.__index = Sequence

setmetatable(Sequence, { __tostring = function() return "Sequence" end })

Sequence.__ctorParams = {}
Sequence.__interfaces = {}

local function safeCall(cb)
    if not cb then return end
    local ok, err = pcall(cb)
    if not ok then warn("Sequence callback error: " .. tostring(err)) end
end

function Sequence.new(...)
    local self = setmetatable({}, Sequence)
    return self:constructor(...) or self
end

function Sequence:constructor()
    self._segments = {}
    self._duration = 0
    self._lastAt = 0
    self._lastDur = 0
    self._elapsed = 0
    self._loops = 0
    self._loopsLeft = 0
    self._cb = {}
    self._state = "pending"
    Registry.add(self)
    task.defer(function()
        if self._state == "pending" then self:_start() end
    end)
end

-- Claim the tween: suppress its auto-play defer and stop it if it already
-- started. The sequence owns its scheduling from here on.
local function addTween(self, at, tween)
    tween._claimed = true
    if tween._state == "playing" then tween:_reset() end
    local dur = (tween._params.duration or 0) + (tween._delay or 0)
    table.insert(self._segments, { kind = "tween", at = at, dur = dur, tween = tween })
    return dur
end

function Sequence:Append(tween)
    local dur = addTween(self, self._duration, tween)
    self._lastAt = self._duration
    self._lastDur = dur
    self._duration = self._duration + dur
    return self
end

function Sequence:Join(tween)
    local dur = addTween(self, self._lastAt, tween)
    local endAt = self._lastAt + dur
    if endAt > self._duration then self._duration = endAt end
    return self
end

function Sequence:AppendInterval(d)
    table.insert(self._segments, { kind = "interval", at = self._duration, dur = d })
    self._lastAt = self._duration
    self._lastDur = d
    self._duration = self._duration + d
    return self
end

function Sequence:AppendCallback(cb)
    table.insert(self._segments, { kind = "callback", at = self._duration, cb = cb })
    return self
end

function Sequence:Insert(at, tween)
    local dur = addTween(self, at, tween)
    if at + dur > self._duration then self._duration = at + dur end
    return self
end

function Sequence:PrependInterval(d)
    for _, seg in ipairs(self._segments) do seg.at = seg.at + d end
    self._duration = self._duration + d
    self._lastAt = self._lastAt + d
    return self
end

function Sequence:SetLoops(loops, ltype)
    self._loops = loops or 0 -- -1 = infinite
    if ltype and ltype ~= 0 then
        -- Child tweens (native path) cannot be reverse/offset-played, so
        -- Yoyo/Incremental are not implementable at the sequence level.
        warn("Sequence:SetLoops: only LoopType.Restart is supported for sequences; using Restart")
    end
    return self
end
function Sequence:OnComplete(cb) self._cb.complete = cb; return self end
function Sequence:OnKill(cb) self._cb.kill = cb; return self end

local function fireSegment(seg)
    if seg.kind == "tween" then
        local t = seg.tween
        if t._state ~= "killed" then
            if t._state ~= "pending" then t:_reset() end
            t:Play()
        end
    elseif seg.kind == "callback" then
        safeCall(seg.cb)
    end
end

function Sequence:_step(dt)
    if self._state ~= "playing" then return end
    self._elapsed = self._elapsed + dt
    for _, seg in ipairs(self._segments) do
        if not seg._fired and self._elapsed >= seg.at then
            seg._fired = true
            fireSegment(seg)
        end
    end
    if self._elapsed >= self._duration then
        if self._loopsLeft ~= 0 then
            if self._loopsLeft > 0 then self._loopsLeft = self._loopsLeft - 1 end
            self._elapsed = 0
            for _, seg in ipairs(self._segments) do seg._fired = nil end
        else
            self:_finish("completed")
        end
    end
end

function Sequence:_start()
    if self._state ~= "pending" then return end
    self._state = "playing"
    self._loopsLeft = self._loops
    self._conn = RunService.Heartbeat:Connect(function(dt) self:_step(dt) end)
end

function Sequence:_finish(reason)
    if self._state == "completed" or self._state == "killed" then return end
    self._state = reason
    if self._conn then self._conn:Disconnect(); self._conn = nil end
    Registry.remove(self)
    if reason == "completed" then safeCall(self._cb.complete) end
    if reason == "killed" then safeCall(self._cb.kill) end
end

function Sequence:Play()
    if self._state == "paused" then
        self._state = "playing"
        for _, seg in ipairs(self._segments) do
            if seg.kind == "tween" and seg.tween._state == "paused" then
                seg.tween:Resume()
            end
        end
    elseif self._state == "pending" then
        self:_start()
    end
end

function Sequence:Pause()
    if self._state ~= "playing" then return end
    self._state = "paused"
    for _, seg in ipairs(self._segments) do
        if seg.kind == "tween" then seg.tween:Pause() end
    end
end

function Sequence:Resume() self:Play() end

function Sequence:Kill()
    for _, seg in ipairs(self._segments) do
        if seg.kind == "tween" then seg.tween:Kill() end
    end
    self:_finish("killed")
end

function Sequence:Restart()
    if self._state == "killed" then return end
    if self._conn then self._conn:Disconnect(); self._conn = nil end
    self._elapsed = 0
    for _, seg in ipairs(self._segments) do
        seg._fired = nil
        if seg.kind == "tween" then seg.tween:_reset() end
    end
    self._state = "pending"
    Registry.add(self)
    task.defer(function() if self._state == "pending" then self:_start() end end)
end

function Sequence:Complete()
    for _, seg in ipairs(self._segments) do
        if seg.kind == "tween" then seg.tween:Complete()
        elseif seg.kind == "callback" and not seg._fired then seg._fired = true; safeCall(seg.cb) end
    end
    self:_finish("completed")
end

function Sequence:IsPlaying() return self._state == "playing" end
function Sequence:IsCompleted() return self._state == "completed" end

return Sequence
