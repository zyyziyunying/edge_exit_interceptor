import 'package:edge_exit_interceptor/edge_exit_interceptor.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget _buildHarness({required EdgeExitInterceptor interceptor}) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Center(
        child: SizedBox(width: 300, height: 200, child: interceptor),
      ),
    );
  }

  double _childTranslationX(WidgetTester tester) {
    final Transform transform = tester.widget<Transform>(
      find.byKey(const Key('edge_exit_interceptor.child_transform')),
    );
    return transform.transform.storage[12];
  }

  testWidgets('drag from edge drives feedback and animates back on release', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildHarness(
        interceptor: const EdgeExitInterceptor(child: SizedBox.expand()),
      ),
    );

    final Offset topLeft = tester.getTopLeft(find.byType(EdgeExitInterceptor));
    final TestGesture gesture = await tester.startGesture(
      topLeft + const Offset(2, 100),
    );
    await gesture.moveBy(const Offset(24, 0));
    await tester.pump();

    expect(_childTranslationX(tester), greaterThan(0));
    expect(
      find.byKey(const Key('edge_exit_interceptor.indicator')),
      findsOneWidget,
    );

    await gesture.up();
    await tester.pumpAndSettle();

    expect(_childTranslationX(tester), closeTo(0, 0.01));
  });

  testWidgets('trigger callback fires once when threshold is reached', (
    tester,
  ) async {
    int triggerCount = 0;
    EdgeExitTriggerDetails? callbackDetails;

    await tester.pumpWidget(
      _buildHarness(
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
      _buildHarness(
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
      _buildHarness(
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
      _buildHarness(
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
}
