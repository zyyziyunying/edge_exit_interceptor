import 'dart:async';

import 'package:edge_exit_interceptor/edge_exit_interceptor.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildHarness({
    required EdgeExitInterceptor interceptor,
    TextDirection textDirection = TextDirection.ltr,
  }) {
    return Directionality(
      textDirection: textDirection,
      child: Center(
        child: SizedBox(width: 300, height: 200, child: interceptor),
      ),
    );
  }

  double childTranslationX(WidgetTester tester) {
    final Transform transform = tester.widget<Transform>(
      find.byKey(const Key('edge_exit_interceptor.child_transform')),
    );
    return transform.transform.storage[12];
  }

  testWidgets('drag from edge drives feedback and animates back on release', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildHarness(
        interceptor: const EdgeExitInterceptor(child: SizedBox.expand()),
      ),
    );

    final Offset topLeft = tester.getTopLeft(find.byType(EdgeExitInterceptor));
    final TestGesture gesture = await tester.startGesture(
      topLeft + const Offset(2, 100),
    );
    await gesture.moveBy(const Offset(24, 0));
    await tester.pump();

    expect(childTranslationX(tester), greaterThan(0));
    expect(
      find.byKey(const Key('edge_exit_interceptor.indicator')),
      findsOneWidget,
    );

    await gesture.up();
    await tester.pumpAndSettle();

    expect(childTranslationX(tester), closeTo(0, 0.01));
  });

  testWidgets('trigger callback fires once when threshold is reached', (
    tester,
  ) async {
    int triggerCount = 0;
    EdgeExitTriggerDetails? callbackDetails;

    await tester.pumpWidget(
      buildHarness(
        interceptor: EdgeExitInterceptor(
          onTrigger: (EdgeExitTriggerDetails details) {
            triggerCount += 1;
            callbackDetails = details;
          },
          config: const EdgeExitInterceptorConfig(triggerOffset: 30),
          child: const SizedBox.expand(),
        ),
      ),
    );

    final Offset topLeft = tester.getTopLeft(find.byType(EdgeExitInterceptor));
    final TestGesture gesture = await tester.startGesture(
      topLeft + const Offset(2, 100),
    );
    await gesture.moveBy(const Offset(20, 0));
    await gesture.moveBy(const Offset(18, 0));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    expect(triggerCount, 1);
    expect(callbackDetails, isNotNull);
    expect(callbackDetails!.dragOffset, greaterThanOrEqualTo(30));
    expect(callbackDetails!.dragProgress, 1);
  });

  testWidgets('velocity can trigger callback even below threshold', (
    tester,
  ) async {
    int triggerCount = 0;
    EdgeExitTriggerDetails? callbackDetails;

    await tester.pumpWidget(
      buildHarness(
        interceptor: EdgeExitInterceptor(
          onTrigger: (EdgeExitTriggerDetails details) {
            triggerCount += 1;
            callbackDetails = details;
          },
          config: const EdgeExitInterceptorConfig(
            triggerOffset: 140,
            minFlingVelocity: 300,
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );

    final Offset topLeft = tester.getTopLeft(find.byType(EdgeExitInterceptor));
    await tester.timedDragFrom(
      topLeft + const Offset(2, 100),
      const Offset(28, 0),
      const Duration(milliseconds: 40),
    );
    await tester.pumpAndSettle();

    expect(triggerCount, 1);
    expect(callbackDetails, isNotNull);
    expect(callbackDetails!.dragOffset, lessThan(140));
    expect(callbackDetails!.velocity, greaterThanOrEqualTo(300));
  });

  testWidgets('drag outside edge hit area does not trigger callback', (
    tester,
  ) async {
    int triggerCount = 0;

    await tester.pumpWidget(
      buildHarness(
        interceptor: EdgeExitInterceptor(
          onTrigger: (_) {
            triggerCount += 1;
          },
          config: const EdgeExitInterceptorConfig(triggerOffset: 20),
          child: const SizedBox.expand(),
        ),
      ),
    );

    final Offset topLeft = tester.getTopLeft(find.byType(EdgeExitInterceptor));
    await tester.dragFrom(
      topLeft + const Offset(120, 100),
      const Offset(80, 0),
    );
    await tester.pumpAndSettle();

    expect(triggerCount, 0);
  });

  testWidgets('disabled state bypasses gesture interception', (tester) async {
    int triggerCount = 0;

    await tester.pumpWidget(
      buildHarness(
        interceptor: EdgeExitInterceptor(
          enabled: false,
          onTrigger: (_) {
            triggerCount += 1;
          },
          child: const SizedBox.expand(),
        ),
      ),
    );

    final Offset topLeft = tester.getTopLeft(find.byType(EdgeExitInterceptor));
    await tester.dragFrom(topLeft + const Offset(2, 100), const Offset(80, 0));
    await tester.pumpAndSettle();

    expect(triggerCount, 0);
    expect(
      find.byKey(const Key('edge_exit_interceptor.child_transform')),
      findsNothing,
    );
  });

  testWidgets(
    'disabling mid-drag animates back before removing the interactive shell',
    (tester) async {
      int triggerCount = 0;

      await tester.pumpWidget(
        buildHarness(
          interceptor: EdgeExitInterceptor(
            enabled: true,
            onTrigger: (_) {
              triggerCount += 1;
            },
            config: const EdgeExitInterceptorConfig(
              resetDuration: Duration(milliseconds: 200),
              triggerOffset: 20,
            ),
            child: const SizedBox.expand(),
          ),
        ),
      );

      final Offset topLeft = tester.getTopLeft(
        find.byType(EdgeExitInterceptor),
      );
      final TestGesture gesture = await tester.startGesture(
        topLeft + const Offset(2, 100),
      );
      await gesture.moveBy(const Offset(24, 0));
      await tester.pump();

      expect(childTranslationX(tester), greaterThan(0));

      await tester.pumpWidget(
        buildHarness(
          interceptor: EdgeExitInterceptor(
            enabled: false,
            onTrigger: (_) {
              triggerCount += 1;
            },
            config: const EdgeExitInterceptorConfig(
              resetDuration: Duration(milliseconds: 200),
              triggerOffset: 20,
            ),
            child: const SizedBox.expand(),
          ),
        ),
      );

      expect(
        find.byKey(const Key('edge_exit_interceptor.child_transform')),
        findsOneWidget,
      );

      final double offsetBeforeDisabledMove = childTranslationX(tester);
      await gesture.moveBy(const Offset(40, 0));
      await tester.pump();
      final double offsetAfterDisabledMove = childTranslationX(tester);
      expect(
        offsetAfterDisabledMove,
        closeTo(offsetBeforeDisabledMove, 0.01),
      );

      await gesture.up();
      await tester.pump(const Duration(milliseconds: 100));
      expect(childTranslationX(tester), greaterThan(0));

      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('edge_exit_interceptor.child_transform')),
        findsNothing,
      );
      expect(triggerCount, 0);
    },
  );

  testWidgets('rtl mode activates from the right edge', (tester) async {
    int triggerCount = 0;

    await tester.pumpWidget(
      buildHarness(
        textDirection: TextDirection.rtl,
        interceptor: EdgeExitInterceptor(
          onTrigger: (_) {
            triggerCount += 1;
          },
          config: const EdgeExitInterceptorConfig(triggerOffset: 20),
          child: const SizedBox.expand(),
        ),
      ),
    );

    final Rect pageRect = tester.getRect(find.byType(EdgeExitInterceptor));
    await tester.dragFrom(
      pageRect.topRight - const Offset(2, -100),
      const Offset(-40, 0),
    );
    await tester.pumpAndSettle();

    expect(triggerCount, 1);
    expect(
      find.byKey(const Key('edge_exit_interceptor.indicator')),
      findsOneWidget,
    );
  });

  testWidgets('mostly vertical drags do not trigger the interceptor', (
    tester,
  ) async {
    int triggerCount = 0;

    await tester.pumpWidget(
      buildHarness(
        interceptor: EdgeExitInterceptor(
          onTrigger: (_) {
            triggerCount += 1;
          },
          config: const EdgeExitInterceptorConfig(triggerOffset: 20),
          child: const SizedBox.expand(),
        ),
      ),
    );

    final Offset topLeft = tester.getTopLeft(find.byType(EdgeExitInterceptor));
    await tester.dragFrom(topLeft + const Offset(2, 80), const Offset(8, 72));
    await tester.pumpAndSettle();

    expect(triggerCount, 0);
    expect(childTranslationX(tester), closeTo(0, 0.01));
  });

  testWidgets(
    'while trigger is in flight, gestures do not trigger repeatedly',
    (tester) async {
      final Completer<void> completer = Completer<void>();
      int triggerCount = 0;

      await tester.pumpWidget(
        buildHarness(
          interceptor: EdgeExitInterceptor(
            onTrigger: (_) {
              triggerCount += 1;
              return completer.future;
            },
            config: const EdgeExitInterceptorConfig(triggerOffset: 20),
            child: const SizedBox.expand(),
          ),
        ),
      );

      final Offset topLeft = tester.getTopLeft(
        find.byType(EdgeExitInterceptor),
      );
      await tester.dragFrom(
        topLeft + const Offset(2, 100),
        const Offset(40, 0),
      );
      await tester.pumpAndSettle();
      expect(triggerCount, 1);

      await tester.dragFrom(
        topLeft + const Offset(2, 100),
        const Offset(40, 0),
      );
      await tester.pumpAndSettle();
      expect(triggerCount, 1);
      expect(childTranslationX(tester), closeTo(0, 0.01));

      completer.complete();
      await tester.pump();
      await tester.pumpAndSettle();

      await tester.dragFrom(
        topLeft + const Offset(2, 100),
        const Offset(40, 0),
      );
      await tester.pumpAndSettle();
      expect(triggerCount, 2);
    },
  );

  testWidgets('trigger lock is released when callback throws', (tester) async {
    int triggerCount = 0;

    await tester.pumpWidget(
      buildHarness(
        interceptor: EdgeExitInterceptor(
          onTrigger: (_) async {
            triggerCount += 1;
            if (triggerCount == 1) {
              throw StateError('expected test error');
            }
          },
          config: const EdgeExitInterceptorConfig(triggerOffset: 20),
          child: const SizedBox.expand(),
        ),
      ),
    );

    final Offset topLeft = tester.getTopLeft(find.byType(EdgeExitInterceptor));

    await tester.dragFrom(topLeft + const Offset(2, 100), const Offset(40, 0));
    await tester.pumpAndSettle();
    expect(triggerCount, 1);

    await tester.dragFrom(topLeft + const Offset(2, 100), const Offset(40, 0));
    await tester.pumpAndSettle();
    expect(triggerCount, 2);
  });
}
