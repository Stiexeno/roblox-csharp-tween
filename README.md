# roblox-csharp-tween

DOTween-style fluent tweening for [roblox-csharp](https://github.com/Stiexeno/roblox-csharp). Wraps Roblox `TweenService` for property tweens and falls back to a `Heartbeat` stepper for arbitrary getter/setter values and easings outside `Enum.EasingStyle`.

## Install

```sh
roblox-csharp plugin add Stiexeno/roblox-csharp-tween
```

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
   .Append(part.DOMove(b, 1f))
   .OnComplete(() => print("done"));
```

## API surface

- `DOTween.To(getter, setter, end, duration)` — `float`, `Vector3`, `Vector2`, `Color3`, `CFrame`, `UDim2`
- `DOTween.Property(instance, propertyName, end, duration)` — generic property tween
- `DOTween.Sequence()` — `Append` / `Join` / `Insert` / `AppendInterval` / `AppendCallback` / `PrependInterval`
- `DOTween.KillAll() / PauseAll() / ResumeAll()`

Chainables on `Tween` and `Sequence`:
- `SetEase(Ease)` — full DOTween-flat `Ease` enum (31 styles, including Elastic/Back/Bounce)
- `SetDelay(seconds)`, `SetLoops(count, LoopType)`
- `OnStart`, `OnUpdate`, `OnComplete`, `OnKill`

Extension methods:
- `BasePart` — `DOMove`, `DOMoveCFrame`, `DOSize`, `DOOrientation`, `DOColor`, `DOTransparency`, `DOReflectance`
- `GuiObject` — `DOPosition`, `DOSize`, `DOAnchorPoint`, `DORotation`, `DOBackgroundColor`, `DOBackgroundTransparency`
- `TextLabel`/`TextButton`/`TextBox` — `DOTextColor`, `DOTextTransparency`
- `ImageLabel`/`ImageButton` — `DOImageColor`, `DOImageTransparency`
- `Camera` — `DOFieldOfView`, `DOCFrame`
- `PointLight`/`Light` — `DOLightColor`, `DOBrightness`

## How it works

Two execution paths, one surface:

- **Native path** — used by `DOTween.Property` and the `DOMove`/`DOColor`/etc. extensions. Builds a `TweenInfo` and delegates to `TweenService:Create`. Free interpolation, server-replicable, supports the 11 Roblox-native easing styles.
- **Stepper path** — used by `DOTween.To(getter, setter, ...)` and for any custom-only easing. Runs on `RunService.Heartbeat`, calls the setter every frame with the interpolated value.

Both paths share the same `Tween` class — chainable setters apply during the same frame; the kick-off is deferred via `task.defer` so the whole chain is in place before the tween actually starts.

## Requires

`roblox-csharp 0.1.0-alpha.32+`.
