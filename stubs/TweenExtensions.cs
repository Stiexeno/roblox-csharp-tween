namespace Tweening;

public static class TweenExtensions
{
    public static extern Tween DOMove(this BasePart part, Vector3 target, float duration);
    public static extern Tween DOMoveCFrame(this BasePart part, CFrame target, float duration);
    public static extern Tween DOSize(this BasePart part, Vector3 target, float duration);
    public static extern Tween DOOrientation(this BasePart part, Vector3 target, float duration);
    public static extern Tween DOColor(this BasePart part, Color3 target, float duration);
    public static extern Tween DOTransparency(this BasePart part, float target, float duration);
    public static extern Tween DOReflectance(this BasePart part, float target, float duration);

    public static extern Tween DOPosition(this GuiObject obj, UDim2 target, float duration);
    public static extern Tween DOSize(this GuiObject obj, UDim2 target, float duration);
    public static extern Tween DOAnchorPoint(this GuiObject obj, Vector2 target, float duration);
    public static extern Tween DORotation(this GuiObject obj, float target, float duration);
    public static extern Tween DOBackgroundColor(this GuiObject obj, Color3 target, float duration);
    public static extern Tween DOBackgroundTransparency(this GuiObject obj, float target, float duration);

    public static extern Tween DOTextColor(this TextLabel label, Color3 target, float duration);
    public static extern Tween DOTextTransparency(this TextLabel label, float target, float duration);
    public static extern Tween DOTextColor(this TextButton button, Color3 target, float duration);
    public static extern Tween DOTextTransparency(this TextButton button, float target, float duration);
    public static extern Tween DOTextColor(this TextBox box, Color3 target, float duration);

    public static extern Tween DOImageColor(this ImageLabel img, Color3 target, float duration);
    public static extern Tween DOImageTransparency(this ImageLabel img, float target, float duration);
    public static extern Tween DOImageColor(this ImageButton btn, Color3 target, float duration);
    public static extern Tween DOImageTransparency(this ImageButton btn, float target, float duration);

    public static extern Tween DOFieldOfView(this Camera cam, float target, float duration);
    public static extern Tween DOCFrame(this Camera cam, CFrame target, float duration);

    public static extern Tween DOLightColor(this PointLight light, Color3 target, float duration);
    public static extern Tween DOBrightness(this Light light, float target, float duration);
}
