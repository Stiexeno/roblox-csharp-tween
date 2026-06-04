local RunService = game:GetService("RunService")

local EaseFn = require(script.Parent.EaseFn)
local Lerp = require(script.Parent.Lerp)

local Stepper = {}

function Stepper.start(tween)
    local p = tween._params
    local startVal = p.getter()
    local endVal = p.endValue
    local easeFn = EaseFn.resolve(tween._ease)
    local lerp = Lerp.resolve(startVal)

    local elapsed = -(tween._delay or 0)
    local loopsLeft = tween._loops or 0
    local handle = {}
    local conn

    local function step(dt)
        if tween._state ~= "playing" then return end
        elapsed = elapsed + dt
        if elapsed < 0 then return end
        local t = math.min(elapsed / p.duration, 1)
        p.setter(lerp(startVal, endVal, easeFn(t)))
        if tween._cb.update then tween._cb.update() end
        if t >= 1 then
            if loopsLeft > 0 then
                loopsLeft = loopsLeft - 1
                elapsed = 0
                if tween._loopType == 1 then
                    startVal, endVal = endVal, startVal
                end
                return
            end
            conn:Disconnect()
            tween:_finish("completed")
        end
    end

    conn = RunService.Heartbeat:Connect(step)
    function handle.pause() end
    function handle.resume() end
    function handle.stop() conn:Disconnect() end
    function handle.complete() p.setter(p.endValue) end
    return handle
end

return Stepper
