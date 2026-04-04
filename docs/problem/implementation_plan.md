# Implementation Plan

## Delivery strategy

Build this package in small, testable steps.
The first target is a page-level MVP that can be embedded into an app and used
to trigger guarded exit logic without taking over route management.

## Phase 1: MVP interaction

Scope:

- `EdgeExitInterceptor` becomes a stateful page wrapper
- leading-edge hit testing
- horizontal drag tracking
- short-range visual feedback
- release-to-trigger callback
- automatic return-to-rest animation

Acceptance:

- gesture can start only from the configured leading edge region
- child content receives a small visual response during drag
- a leading indicator appears or reacts with drag progress
- releasing after threshold or fling velocity triggers `onTrigger`
- releasing below threshold still animates back cleanly
- the widget never calls `Navigator.pop()` by itself

## Phase 2: Stability and ergonomics

Scope:

- refine animation timing and curve choices
- handle re-entrancy while `onTrigger` is still executing
- improve disabled-state behavior
- harden tests around gesture thresholds and reset behavior

Acceptance:

- repeated gestures do not double-trigger callbacks
- disabled mode becomes a true no-op
- in-flight callbacks do not leave the widget visually stuck

## Phase 3: Gesture conflict handling

Scope:

- interactions with horizontal scrolling content
- interactions with nested gesture detectors
- optional guardrails for opt-in pages that host `PageView` or carousels

Acceptance:

- conflict rules are explicit
- default behavior stays predictable
- unsupported cases are documented instead of silently handled badly

## Deferred items

These are intentionally out of scope until the MVP is proven useful:

- custom `PageRoute` integration
- Cupertino-style route transition imitation
- platform-channel hooks into native gesture systems
- broad animation customization surface
