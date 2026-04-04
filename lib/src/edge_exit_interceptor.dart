import 'dart:async';

import 'package:flutter/widgets.dart';

/// Called when the custom edge-exit gesture has crossed its trigger boundary.
typedef EdgeExitTrigger =
    FutureOr<void> Function(EdgeExitTriggerDetails details);

/// Immutable payload for guarded exit callbacks.
@immutable
class EdgeExitTriggerDetails {
  const EdgeExitTriggerDetails({
    required this.dragOffset,
    required this.dragProgress,
    required this.velocity,
  });

  /// Horizontal drag distance in logical pixels.
  final double dragOffset;

  /// Normalized drag progress in the range `[0, 1]`.
  final double dragProgress;

  /// Horizontal velocity in logical pixels per second.
  final double velocity;
}

/// Visual and gesture thresholds for the custom edge-exit interaction.
@immutable
class EdgeExitInterceptorConfig {
  const EdgeExitInterceptorConfig({
    this.edgeHitWidth = 24,
    this.triggerOffset = 36,
    this.maxVisualOffset = 28,
  });

  /// Width of the active leading-edge gesture region.
  final double edgeHitWidth;

  /// Drag distance required to trigger the guarded exit callback.
  final double triggerOffset;

  /// Maximum distance used later by the sticky visual feedback animation.
  final double maxVisualOffset;
}

/// Package entry widget for guarded edge-exit interactions.
///
/// The widget currently behaves as a pass-through container so applications can
/// adopt the future API shape before the custom gesture effect lands.
class EdgeExitInterceptor extends StatelessWidget {
  const EdgeExitInterceptor({
    super.key,
    required this.child,
    this.onTrigger,
    this.enabled = true,
    this.config = const EdgeExitInterceptorConfig(),
  });

  /// Wrapped page content.
  final Widget child;

  /// Callback invoked after the gesture crosses its trigger boundary.
  final EdgeExitTrigger? onTrigger;

  /// Whether the custom edge-exit interaction is active.
  final bool enabled;

  /// Threshold and visual settings for the interaction.
  final EdgeExitInterceptorConfig config;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
