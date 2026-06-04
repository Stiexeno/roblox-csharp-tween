local DOTween = require(script.Parent.DOTween)

local function prop(target, property, value, duration)
    return DOTween.Property(target, property, value, duration)
end

local TweenExtensions = {}

function TweenExtensions.DOMove(part, target, duration) return prop(part, "Position", target, duration) end
function TweenExtensions.DOMoveCFrame(part, target, duration) return prop(part, "CFrame", target, duration) end
function TweenExtensions.DOSize(target, value, duration) return prop(target, "Size", value, duration) end
function TweenExtensions.DOOrientation(part, target, duration) return prop(part, "Orientation", target, duration) end
function TweenExtensions.DOColor(part, target, duration) return prop(part, "Color", target, duration) end
function TweenExtensions.DOTransparency(part, target, duration) return prop(part, "Transparency", target, duration) end
function TweenExtensions.DOReflectance(part, target, duration) return prop(part, "Reflectance", target, duration) end

function TweenExtensions.DOPosition(obj, target, duration) return prop(obj, "Position", target, duration) end
function TweenExtensions.DOAnchorPoint(obj, target, duration) return prop(obj, "AnchorPoint", target, duration) end
function TweenExtensions.DORotation(obj, target, duration) return prop(obj, "Rotation", target, duration) end
function TweenExtensions.DOBackgroundColor(obj, target, duration) return prop(obj, "BackgroundColor3", target, duration) end
function TweenExtensions.DOBackgroundTransparency(obj, target, duration) return prop(obj, "BackgroundTransparency", target, duration) end

function TweenExtensions.DOTextColor(obj, target, duration) return prop(obj, "TextColor3", target, duration) end
function TweenExtensions.DOTextTransparency(obj, target, duration) return prop(obj, "TextTransparency", target, duration) end

function TweenExtensions.DOImageColor(obj, target, duration) return prop(obj, "ImageColor3", target, duration) end
function TweenExtensions.DOImageTransparency(obj, target, duration) return prop(obj, "ImageTransparency", target, duration) end

function TweenExtensions.DOFieldOfView(cam, target, duration) return prop(cam, "FieldOfView", target, duration) end
function TweenExtensions.DOCFrame(cam, target, duration) return prop(cam, "CFrame", target, duration) end

function TweenExtensions.DOLightColor(light, target, duration) return prop(light, "Color", target, duration) end
function TweenExtensions.DOBrightness(light, target, duration) return prop(light, "Brightness", target, duration) end

return TweenExtensions
