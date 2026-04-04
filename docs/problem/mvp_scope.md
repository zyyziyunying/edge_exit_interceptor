# MVP Scope

## Goal

Build a Flutter package that provides a custom leading-edge swipe interaction
for selected pages and uses that interaction to trigger guarded exit logic.

## Non-goals

- Reproduce iOS native full-page back swipe animation
- Replace all app navigation gestures globally
- Depend on Flutter's `PopScope` to detect blocked iOS edge-swipe attempts

## Interaction contract

1. The gesture starts from the leading edge.
2. The UI shows a short-range, clearly non-native sticky feedback effect.
3. Releasing the gesture may trigger business interception logic.
4. The route pops only after app code explicitly approves the exit.

## First implementation milestone

- Package-level opt-in widget for page wrapping
- Configurable edge hit width
- Configurable trigger threshold
- Callback carrying drag offset, progress, and velocity
- Animation designed for feedback, not route transition mimicry

## Constraints

- Keep the effect visually distinct from Cupertino route-pop animation.
- Preserve room for later gesture-conflict handling with horizontal content.
- Keep the API focused on guarded exit flow instead of generic drag effects.
