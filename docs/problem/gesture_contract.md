# Gesture Contract

## Purpose

Define the first stable interaction rules for `EdgeExitInterceptor` so the
package can evolve without ambiguity about what counts as correct behavior.

## Start conditions

- the gesture is opt-in and page-local
- the gesture may start only from the leading edge hit area
- the gesture should prefer horizontal intent over vertical movement
- when disabled, the widget should not start new interactions or invoke callbacks
- if the widget is disabled during an active drag, it may finish a reset
  animation before fully returning to a plain child
- if native or Cupertino route back gestures still exist on the page, the app
  must disable or avoid them separately

## Drag behavior

- drag progress is based on horizontal distance from the start point
- visual movement stays short-range and clearly distinct from route-pop motion
- visual feedback may include both content offset and a leading indicator
- visual feedback must clamp to a maximum distance

## Release behavior

- release always returns the widget to its rest state
- release may trigger `onTrigger` exactly once for that gesture
- trigger conditions may include distance threshold or fling velocity
- callback invocation must happen before any app-level pop decision
- callback failures must not leave the widget in a broken gesture state

## Explicit non-goals for v1

- no attempt to keep the page partially open like a native route transition
- no direct navigation side effects inside the widget
- no promise yet for complex horizontal gesture conflict resolution

## Business integration contract

The package owns gesture recognition and feedback.
The app owns exit decisions.
The app also owns any native-route back-gesture suppression required for a page.

Typical usage:

1. user performs the edge gesture
2. widget reports the trigger
3. app shows dialog or runs async guard logic
4. app decides whether to pop the route
