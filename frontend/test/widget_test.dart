import 'package:flutter_test/flutter_test.dart';

import 'package:crm_marketing/app.dart';

void main() {
  testWidgets('App renders login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MarketingCRMApp());
    expect(find.text('Marketing CRM'), findsOneWidget);
  });
}
