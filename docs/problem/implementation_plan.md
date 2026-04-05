# Implementation Plan

## Delivery strategy

Build this package in small, testable steps.
The first target is a page-level MVP that can be embedded into an app and used
to trigger guarded exit logic without taking over route management.

## Phase 1: MVP interaction

Status: completed

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

Status: completed for the first stability pass

Completed:

- guard against repeated trigger calls while `onTrigger` is in flight
- recover cleanly if `onTrigger` throws
- keep reset behavior stable while the trigger callback completes later

Scope:

- refine animation timing and curve choices
- improve the quality of the feedback motion itself
- reassess disabled and busy-state visual behavior only if UX requires it
- keep tests aligned with final trigger semantics

Acceptance:

- repeated gestures do not double-trigger callbacks
- callback failures do not leave the widget visually stuck
- later animation tuning does not regress trigger stability

## Phase 3: Gesture conflict handling

Status: next implementation target

Scope:

- interactions with horizontal scrolling content
- interactions with nested gesture detectors
- optional guardrails for opt-in pages that host `PageView` or carousels

Acceptance:

- conflict rules are explicit
- default behavior stays predictable
- unsupported cases are documented instead of silently handled badly

## Current iteration plan

This iteration should move the package from "functional MVP" to "ready for
limited real-page trials".

### Track A: Interaction feel

Goals:

- reshape the drag response to feel sticky instead of simply translational
- tune threshold, damping, and reset timing as one motion system
- make the leading indicator feel like part of the same gesture response
- keep the effect clearly distinct from Cupertino route-pop animation

Acceptance:

- drag has noticeable front-loaded follow and stronger later resistance
- release feels intentional instead of abrupt
- the indicator and page motion read as one interaction

### Track B: Gesture boundary rules

Goals:

- define how the interceptor behaves around horizontal scrollables
- support predictable behavior for at least `ListView` and `PageView` cases
- keep edge-only activation strict enough to avoid accidental interception

Acceptance:

- non-edge horizontal gestures stay with page content
- edge-origin gestures behave predictably on trial pages
- unsupported conflict cases are documented explicitly

### Track C: API review

Goals:

- keep the public API minimal while the gesture model is still settling
- decide whether custom indicator entry points are needed yet
- avoid turning `config` into an unbounded bag of parameters

Acceptance:

- default usage remains simple
- new API surface is added only for repeated real needs
- future extension paths stay open without forcing a redesign

### Track D: Documentation and examples

Goals:

- keep package docs synchronized with the current implementation stage
- expand guidance about when this package should and should not be used
- add or evolve examples toward realistic guarded-exit flows

Acceptance:

- README and docs reflect the current implementation truthfully
- example code demonstrates intended business usage
- known limitations are easy to find

## Suggested parallel ownership

- Worker A: interaction feel and animation tuning
- Worker B: gesture conflict rules and minimal conflict handling
- Main thread: API review, docs synchronization, and final integration

## Deferred items

These are intentionally out of scope until the MVP is proven useful:

- custom `PageRoute` integration
- Cupertino-style route transition imitation
- platform-channel hooks into native gesture systems
- broad animation customization surface
