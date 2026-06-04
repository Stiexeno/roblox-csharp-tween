local Registry = {}

local active = {}

function Registry.add(tween)
    active[tween] = true
end

function Registry.remove(tween)
    active[tween] = nil
end

function Registry.all()
    return active
end

return Registry
