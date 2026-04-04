import 'package:edge_exit_interceptor/edge_exit_interceptor.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('passes child through while package is in bootstrap stage', (
    tester,
  ) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: EdgeExitInterceptor(child: Text('child')),
      ),
    );

    expect(find.text('child'), findsOneWidget);
  });
}
