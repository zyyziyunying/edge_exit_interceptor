# edge_exit_interceptor

`edge_exit_interceptor` is a focused Flutter package for one job:
replace iOS-style route-pop side swipe on selected pages with a custom
edge gesture that provides visual feedback and then hands off to guarded
business logic such as confirmation dialogs, draft saving, or async exit checks.

## Status

This package is intentionally bootstrapped first. The current code defines:

- a dedicated package boundary
- a minimal public API skeleton
- package-local docs for scope and constraints

The gesture effect itself is not implemented yet.

## Package goal

This package is for pages where `PopScope` and native-feeling iOS back swipe
do not provide enough control because the page must react before an exit is
allowed to complete.

The intended interaction is:

1. User drags from the leading edge.
2. The page shows a small, clearly non-native sticky feedback animation.
3. Releasing the gesture triggers guarded business logic.
4. Only after business logic approves should the route actually pop.

## Current API skeleton

```dart
EdgeExitInterceptor(
  onTrigger: (details) async {
    // Show dialog or run save logic here.
  },
  child: const Placeholder(),
)
```

The widget is currently a pass-through shell so the package can evolve
without mixing early implementation experiments into app code.

## Docs

- [Docs index](docs/README.md)
- [MVP scope](docs/problem/mvp_scope.md)
- [Why iOS `PopScope` is not enough](docs/knowledge/ios_popscope_limitations.md)

## Development direction

The first implementation milestone should cover:

- left-edge drag detection for selected pages
- small-range sticky visual feedback instead of route-pop animation
- trigger threshold and velocity handling
- a single guarded callback for intercept logic
- clean opt-in behavior without affecting normal app routes
