# roblox-csharp-tween

DOTween-style fluent tweening for [roblox-csharp](https://github.com/Stiexeno/roblox-csharp). Property tweens delegate to Roblox `TweenService`; getter/setter tweens (`DOTween.To`) run on a per-tween `RunService.Heartbeat` connection.

## Install

```sh
roblox-csharp plugin add Stiexeno/roblox-csharp-tween
```

Requires roblox-csharp `0.1.0-alpha.52+`. No bootstrap — everything is lazy, nothing runs until you create a tween.

## Quick start

```csharp
// Property tween via extension method
part.DOMove(new Vector3(0, 50, 0), 1.5f)
    .SetEase(Ease.OutBack)
    .OnComplete(() => print("at the top"));

// Arbitrary value
float health = 100;
DOTween.To(() => health, v => health = v, 0, 2f)
    .SetEase(Ease.OutCubic);

// Sequence
var seq = DOTween.Sequence();
seq.Append(part.DOMove(a, 1f))
   .AppendInterval(0.25f)
   .Join(part.DOColor(Color3.fromRGB(255, 0, 0), 0.5f))
   .OnComplete(() => print("done"));
```

Tweens auto-play on the next frame (`task.defer`), so the whole chain applies before playback starts. Appending a tween to a sequence claims it — the sequence schedules it instead.

## API

- `DOTween.To(getter, setter, end, duration)` — `float`, `Vector3`, `Vector2`, `Color3`, `CFrame`, `UDim2`
- `DOTween.Property(instance, propertyName, end, duration)` — generic property tween
- `DOTween.Sequence()` — `Append` / `Join` / `Insert` / `AppendInterval` / `AppendCallback` / `PrependInterval`
- `DOTween.KillAll()` / `PauseAll()` / `ResumeAll()`

`Tween` chainables: `SetEase(Ease)` (31 styles, full DOTween-flat enum), `SetDelay`, `SetLoops(count, LoopType)`, `OnStart`, `OnUpdate`, `OnComplete`, `OnKill`.
`Tween` control: `Play` / `Pause` / `Resume` / `Kill` / `Restart` / `Complete` / `IsPlaying` / `IsCompleted` / `Elapsed`.

`Sequence` chainables: `SetLoops` (Restart only), `OnComplete`, `OnKill` (no per-sequence ease/delay).
`Sequence` control: same as `Tween` minus `Elapsed`. `Pause`/`Resume` propagate to child tweens; segment timing includes each child's `SetDelay`.

Extension methods:
- `BasePart` — `DOMove`, `DOMoveCFrame`, `DOSize`, `DOOrientation`, `DOColor`, `DOTransparency`, `DOReflectance`
- `GuiObject` — `DOPosition`, `DOSize`, `DOAnchorPoint`, `DORotation`, `DOBackgroundColor`, `DOBackgroundTransparency`
- `TextLabel`/`TextButton` — `DOTextColor`, `DOTextTransparency`; `TextBox` — `DOTextColor`
- `ImageLabel`/`ImageButton` — `DOImageColor`, `DOImageTransparency`
- `Camera` — `DOFieldOfView`, `DOCFrame`
- `PointLight` — `DOLightColor`; `Light` — `DOBrightness`

## Tweenable types

`number`/`float`, `Vector3`, `Vector2`, `Color3`, `CFrame`, `UDim2`. Anything else errors with `Tween: no lerp for <type>` on the `To` path; the property path takes whatever `TweenService` accepts.

## Loops

`SetLoops(n)` plays `n + 1` times; `SetLoops(-1)` loops forever (DOTween convention). `LoopType.Restart`, `Yoyo`, and `Incremental` are all supported on tweens. Property tweens with `Incremental` run on the stepper (native `TweenInfo` has no incremental mode); `Incremental` extrapolates past the end value via `Lerp`, which is exact for numbers/vectors and approximate for `CFrame`/`Color3`. Sequence loops are `Restart` only — passing another `LoopType` warns and falls back.

## Caveats

- All 31 `Ease` values map onto native `Enum.EasingStyle`/`EasingDirection` for property tweens (except `Incremental` loops, which use the stepper's easing functions).
- A destroyed Instance auto-kills its tweens: the native path reacts to `PlaybackState.Cancelled`, the stepper kills on the first setter error (with a `warn`).
- Callbacks are error-isolated — a throwing `OnComplete`/`OnKill` is reported via `warn` and never blocks teardown.
