# Why This Package Exists

## Background

Flutter's `PopScope` behaves differently across Android and iOS for back
navigation gestures.

On Android, the system recognizes the back gesture first and Flutter can still
observe a blocked pop attempt.

On iOS, the common edge-swipe back interaction for `Cupertino` routes is driven
inside Flutter's route transition layer. When `canPop` is false, the gesture
may not start at all, which means application code cannot rely on `PopScope`
to observe the blocked attempt and run business logic at that moment.

## Practical consequence

For pages that must intercept exit with custom logic such as:

- confirmation dialogs
- unsaved draft handling
- async validation
- logging or business gating

the app needs an explicit, app-controlled edge gesture instead of depending on
the native-feeling iOS route-pop gesture.

## Product direction

This package intentionally does not try to fake the Cupertino back transition.
It should provide:

- a shorter-range sticky feedback animation
- a clear "gesture was accepted" signal
- a controlled callback boundary before any route pop happens
