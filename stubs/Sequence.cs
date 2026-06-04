namespace Tweening;

public class Sequence
{
    public extern Sequence Append(Tween tween);
    public extern Sequence Join(Tween tween);
    public extern Sequence AppendInterval(float duration);
    public extern Sequence AppendCallback(Action callback);
    public extern Sequence Insert(float at, Tween tween);
    public extern Sequence PrependInterval(float duration);

    public extern Sequence SetLoops(int loops);
    public extern Sequence SetLoops(int loops, LoopType type);
    public extern Sequence OnComplete(Action callback);
    public extern Sequence OnKill(Action callback);

    public extern void Play();
    public extern void Pause();
    public extern void Resume();
    public extern void Kill();
    public extern void Restart();
    public extern void Complete();

    public extern bool IsPlaying();
    public extern bool IsCompleted();
}
