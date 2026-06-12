local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local EaseMap = require(script.Parent.EaseMap)

local Native = {}

function Native.start(tween)
    local p = tween._params
    local style, direction = EaseMap.resolve(tween._ease)
    local loops = tween._loops or 0
    if loops < 0 then loops = -1 end -- RepeatCount -1 = infinite
    local info = TweenInfo.new(
        p.duration,
        style,
        direction,
        loops,
        tween._loopType == 1,
        tween._delay or 0
    )
    local native = TweenService:Create(p.target, info, { [p.property] = p.endValue })
    local handle = {}
    local hb

    -- Elapsed bookkeeping (TweenService exposes no playback position).
    local acc = 0
    local playStart = os.clock()

    local conn = native.Completed:Connect(function(state)
        if state == Enum.PlaybackState.Completed then
            tween:_finish("completed")
        elseif state == Enum.PlaybackState.Cancelled then
            -- Target destroyed (or tween cancelled externally): auto-kill so
            -- the Registry entry and Heartbeat connection are cleaned up.
            tween:Kill()
        end
    end)

    if tween._cb.update then
        hb = RunService.Heartbeat:Connect(function()
            if tween._state == "playing" then tween._cb.update() end
        end)
    end

    function handle.pause()
        if playStart then acc = acc + (os.clock() - playStart); playStart = nil end
        native:Pause()
    end
    function handle.resume()
        playStart = playStart or os.clock()
        native:Play()
    end
    function handle.stop()
        conn:Disconnect()
        if hb then hb:Disconnect() end
        native:Cancel()
    end
    function handle.complete()
        native:Cancel()
        pcall(function() p.target[p.property] = p.endValue end)
    end
    function handle.elapsed()
        local total = acc + (playStart and os.clock() - playStart or 0)
        return math.max(total - (tween._delay or 0), 0)
    end

    native:Play()
    return handle
end

return Native
