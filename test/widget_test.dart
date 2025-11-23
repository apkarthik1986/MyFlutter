import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myflutter/main.dart';

void main() {
  testWidgets('Jewel Calc app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const JewelCalcApp());

    // Verify that our app has the correct title
    expect(find.text('💎 Jewel Calc 💎'), findsOneWidget);

    // Verify that Customer Information section exists
    expect(find.text('Customer Information'), findsOneWidget);

    // Verify that Item Calculation section exists
    expect(find.text('Item Calculation'), findsOneWidget);

    // Verify that Amount Calculation section exists
    expect(find.text('Amount Calculation'), findsOneWidget);

    // Verify that settings icon exists
    expect(find.byIcon(Icons.settings), findsOneWidget);

    // Verify that refresh icon exists
    expect(find.byIcon(Icons.refresh), findsOneWidget);
  });

  testWidgets('Settings dialog opens', (WidgetTester tester) async {
    await tester.pumpWidget(const JewelCalcApp());

    // Tap the settings icon
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    // Verify that settings dialog is displayed
    expect(find.text('⚙️ Base Values Configuration'), findsOneWidget);
    expect(find.text('Metal Rates (₹ per gram)'), findsOneWidget);
    expect(find.text('Wastage Settings'), findsOneWidget);
    expect(find.text('Making Charges'), findsOneWidget);
  });
}
