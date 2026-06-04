namespace Tweening;

public class Tween
{
    public extern Tween SetEase(Ease ease);
    public extern Tween SetDelay(float delay);
    public extern Tween SetLoops(int loops);
    public extern Tween SetLoops(int loops, LoopType type);

    public extern Tween OnStart(Action callback);
    public extern Tween OnUpdate(Action callback);
    public extern Tween OnComplete(Action callback);
    public extern Tween OnKill(Action callback);

    public extern void Play();
    public extern void Pause();
    public extern void Resume();
    public extern void Kill();
    public extern void Restart();
    public extern void Complete();

    public extern bool IsPlaying();
    public extern bool IsCompleted();
    public extern float Elapsed();
}
