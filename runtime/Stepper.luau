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
    local loopsLeft = tween._loops or 0 -- -1 = infinite
    local loopIndex = 0
    local incremental = tween._loopType == 2
    local handle = {}
    local conn

    local function apply(t)
        local eased = easeFn(t)
        if incremental then
            -- Incremental: each pass extends the range by the original
            -- delta — lerp extrapolates for t > 1.
            eased = eased + loopIndex
        end
        p.setter(lerp(startVal, endVal, eased))
    end

    local function step(dt)
        if tween._state ~= "playing" then return end
        elapsed = elapsed + dt
        if elapsed < 0 then return end
        local t = math.min(elapsed / p.duration, 1)
        local ok, err = pcall(apply, t)
        if not ok then
            warn("Tween: setter failed, killing tween: " .. tostring(err))
            tween:Kill() -- disconnects via handle.stop and cleans the Registry
            return
        end
        if tween._cb.update then tween._cb.update() end
        if t >= 1 then
            if loopsLeft ~= 0 then
                if loopsLeft > 0 then loopsLeft = loopsLeft - 1 end
                elapsed = 0
                if tween._loopType == 1 then
                    startVal, endVal = endVal, startVal
                elseif incremental then
                    loopIndex = loopIndex + 1
                end
                return
            end
            tween:_finish("completed")
        end
    end

    conn = RunService.Heartbeat:Connect(step)
    function handle.pause() end
    function handle.resume() end
    function handle.stop() conn:Disconnect() end
    function handle.complete() pcall(p.setter, p.endValue) end
    function handle.elapsed() return math.max(elapsed, 0) end
    return handle
end

return Stepper
