import 'dart:async';
import 'dart:math' as math;

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
    this.minFlingVelocity = 700,
    this.resetDuration = const Duration(milliseconds: 180),
  }) : assert(edgeHitWidth > 0),
       assert(triggerOffset > 0),
       assert(maxVisualOffset > 0),
       assert(minFlingVelocity >= 0);

  /// Width of the active leading-edge gesture region.
  final double edgeHitWidth;

  /// Drag distance required to trigger the guarded exit callback.
  final double triggerOffset;

  /// Maximum distance used by the sticky visual feedback animation.
  final double maxVisualOffset;

  /// Horizontal velocity in logical pixels per second required for fling trigger.
  final double minFlingVelocity;

  /// Duration used to animate feedback back to the resting state.
  final Duration resetDuration;
}

/// Package entry widget for guarded edge-exit interactions.
class EdgeExitInterceptor extends StatefulWidget {
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
  State<EdgeExitInterceptor> createState() => _EdgeExitInterceptorState();
}

class _EdgeExitInterceptorState extends State<EdgeExitInterceptor>
    with SingleTickerProviderStateMixin {
  static const Key _childTransformKey = Key(
    'edge_exit_interceptor.child_transform',
  );
  static const Key _indicatorKey = Key('edge_exit_interceptor.indicator');

  late final AnimationController _resetController;
  Animation<double>? _offsetAnimation;
  double _dragOffset = 0;
  bool _isTriggerInFlight = false;

  @override
  void initState() {
    super.initState();
    _resetController = AnimationController(
      vsync: this,
      duration: widget.config.resetDuration,
    )..addListener(_handleResetTick);
  }

  @override
  void didUpdateWidget(covariant EdgeExitInterceptor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.config.resetDuration != widget.config.resetDuration) {
      _resetController.duration = widget.config.resetDuration;
    }
    if (!widget.enabled && _dragOffset != 0) {
      _animateBackToRest();
    }
  }

  @override
  void dispose() {
    _resetController
      ..removeListener(_handleResetTick)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool shouldRenderInteractiveShell =
        widget.enabled ||
        _dragOffset != 0 ||
        _resetController.isAnimating ||
        _isTriggerInFlight;
    if (!shouldRenderInteractiveShell) {
      return widget.child;
    }

    final bool canHandleGesture = widget.enabled && !_isTriggerInFlight;
    final bool isLtr = _isLtr(context);
    final double triggerProgress = _progressFor(_dragOffset);
    final double visualOffset = _visualOffsetFor(_dragOffset, widget.config);
    final double directionalOffset = isLtr ? visualOffset : -visualOffset;

    return Stack(
      fit: StackFit.passthrough,
      children: <Widget>[
        Transform.translate(
          key: _childTransformKey,
          offset: Offset(directionalOffset, 0),
          child: widget.child,
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: _EdgeGestureIndicator(
              key: _indicatorKey,
              progress: triggerProgress,
              isLtr: isLtr,
              maxVisualOffset: widget.config.maxVisualOffset,
            ),
          ),
        ),
        Positioned.fill(
          child: Align(
            alignment: isLtr ? Alignment.centerLeft : Alignment.centerRight,
            child: SizedBox(
              width: widget.config.edgeHitWidth,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onHorizontalDragStart: canHandleGesture
                    ? _onHorizontalDragStart
                    : null,
                onHorizontalDragUpdate: canHandleGesture
                    ? _onHorizontalDragUpdate
                    : null,
                onHorizontalDragEnd: canHandleGesture
                    ? _onHorizontalDragEnd
                    : null,
                onHorizontalDragCancel: canHandleGesture
                    ? _onHorizontalDragCancel
                    : null,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _handleResetTick() {
    final Animation<double>? animation = _offsetAnimation;
    if (animation == null) {
      return;
    }
    setState(() {
      _dragOffset = animation.value;
    });
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    _resetController.stop();
    _offsetAnimation = null;
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    final double sign = _isLtr(context) ? 1 : -1;
    final double logicalDelta = (details.primaryDelta ?? 0) * sign;
    if (logicalDelta == 0) {
      return;
    }

    setState(() {
      _dragOffset = math.max(0, _dragOffset + logicalDelta);
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (!widget.enabled) {
      _animateBackToRest();
      return;
    }

    final double sign = _isLtr(context) ? 1 : -1;
    final double velocity = details.velocity.pixelsPerSecond.dx * sign;
    final double dragOffsetSnapshot = _dragOffset;
    final double progressSnapshot = _progressFor(dragOffsetSnapshot);

    final bool meetsThreshold =
        dragOffsetSnapshot >= widget.config.triggerOffset;
    final bool meetsVelocity = velocity >= widget.config.minFlingVelocity;

    if ((meetsThreshold || meetsVelocity) &&
        widget.onTrigger != null &&
        !_isTriggerInFlight) {
      _invokeTriggerGuarded(
        EdgeExitTriggerDetails(
          dragOffset: dragOffsetSnapshot,
          dragProgress: progressSnapshot,
          velocity: velocity,
        ),
      );
    }

    _animateBackToRest();
  }

  void _onHorizontalDragCancel() {
    _animateBackToRest();
  }

  void _invokeTriggerGuarded(EdgeExitTriggerDetails details) {
    final EdgeExitTrigger? onTrigger = widget.onTrigger;
    if (onTrigger == null || _isTriggerInFlight) {
      return;
    }

    setState(() {
      _isTriggerInFlight = true;
    });
    unawaited(_runTrigger(onTrigger, details));
  }

  Future<void> _runTrigger(
    EdgeExitTrigger onTrigger,
    EdgeExitTriggerDetails details,
  ) async {
    try {
      await Future<void>.sync(() => onTrigger(details));
    } catch (_) {
      // Keep gesture state stable even if the app callback fails.
    } finally {
      if (mounted) {
        setState(() {
          _isTriggerInFlight = false;
        });
      }
    }
  }

  void _animateBackToRest() {
    if (_dragOffset == 0) {
      return;
    }
    _resetController.stop();
    _offsetAnimation = Tween<double>(begin: _dragOffset, end: 0).animate(
      CurvedAnimation(parent: _resetController, curve: Curves.easeOutCubic),
    );
    _resetController
      ..value = 0
      ..forward();
  }

  bool _isLtr(BuildContext context) {
    return Directionality.of(context) == TextDirection.ltr;
  }

  double _progressFor(double dragOffset) {
    return (dragOffset / widget.config.triggerOffset).clamp(0.0, 1.0);
  }

  static double _visualOffsetFor(
    double dragOffset,
    EdgeExitInterceptorConfig config,
  ) {
    final double normalized = (dragOffset / config.triggerOffset).clamp(
      0.0,
      1.0,
    );
    return config.maxVisualOffset * Curves.easeOut.transform(normalized);
  }
}

class _EdgeGestureIndicator extends StatelessWidget {
  const _EdgeGestureIndicator({
    super.key,
    required this.progress,
    required this.isLtr,
    required this.maxVisualOffset,
  });

  final double progress;
  final bool isLtr;
  final double maxVisualOffset;

  @override
  Widget build(BuildContext context) {
    final double easedProgress = Curves.easeOut.transform(progress);
    final double travel = maxVisualOffset * 0.4 * easedProgress;
    final double directionalTravel = isLtr ? travel : -travel;

    return Align(
      alignment: isLtr ? Alignment.centerLeft : Alignment.centerRight,
      child: Transform.translate(
        offset: Offset(directionalTravel, 0),
        child: Opacity(
          opacity: easedProgress,
          child: SizedBox(
            width: 26,
            height: 46,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0x22111111),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: SizedBox(
                  width: 8,
                  height: 8,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0xAA111111),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
