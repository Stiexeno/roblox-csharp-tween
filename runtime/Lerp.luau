local Lerp = {}

local function num(a, b, t) return a + (b - a) * t end
local function userdata(a, b, t) return a:Lerp(b, t) end

function Lerp.resolve(value)
    local kind = typeof(value)
    if kind == "number" then return num end
    if kind == "Vector3" or kind == "Vector2"
        or kind == "Color3" or kind == "CFrame"
        or kind == "UDim2" then
        return userdata
    end
    error("Tween: no lerp for " .. tostring(kind))
end

return Lerp
