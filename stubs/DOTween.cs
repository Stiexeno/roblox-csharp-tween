namespace Tweening;

public static class DOTween
{
    public static extern Tween To(Func<float> getter, Action<float> setter, float endValue, float duration);
    public static extern Tween To(Func<Vector3> getter, Action<Vector3> setter, Vector3 endValue, float duration);
    public static extern Tween To(Func<Vector2> getter, Action<Vector2> setter, Vector2 endValue, float duration);
    public static extern Tween To(Func<Color3> getter, Action<Color3> setter, Color3 endValue, float duration);
    public static extern Tween To(Func<CFrame> getter, Action<CFrame> setter, CFrame endValue, float duration);
    public static extern Tween To(Func<UDim2> getter, Action<UDim2> setter, UDim2 endValue, float duration);

    public static extern Tween Property(Instance target, string property, object endValue, float duration);

    public static extern Sequence Sequence();

    public static extern void KillAll();
    public static extern void PauseAll();
    public static extern void ResumeAll();
}
