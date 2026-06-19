import 'package:flutter_test/flutter_test.dart';

import 'package:youth_safety_app/main.dart';

void main() {
  testWidgets('App builds without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const YouthSafetyApp());
    expect(find.text('Youth Safety'), findsOneWidget);
  });
}