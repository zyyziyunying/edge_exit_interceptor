import 'package:flutter_test/flutter_test.dart';

import 'package:example/main.dart';

void main() {
  testWidgets('edge swipe opens dialog and cancel keeps page', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('Open Guarded Page'));
    await tester.pumpAndSettle();

    expect(find.text('Guarded Exit Page'), findsOneWidget);

    final Offset pageTopLeft = tester.getTopLeft(find.byType(GuardedExitPage));
    await tester.dragFrom(
      pageTopLeft + const Offset(2, 160),
      const Offset(70, 0),
    );
    await tester.pumpAndSettle();

    expect(find.text('Leave this page?'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Guarded Exit Page'), findsOneWidget);
  });

  testWidgets('edge swipe and confirm pops back to home page', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('Open Guarded Page'));
    await tester.pumpAndSettle();

    final Offset pageTopLeft = tester.getTopLeft(find.byType(GuardedExitPage));
    await tester.dragFrom(
      pageTopLeft + const Offset(2, 160),
      const Offset(70, 0),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    expect(find.text('Open Guarded Page'), findsOneWidget);
    expect(find.text('Guarded Exit Page'), findsNothing);
  });
}
