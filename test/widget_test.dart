
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timely/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(TimelyApp());

    // Verify that the app starts.
    expect(find.text('Date Reminder'), findsOneWidget);
  });
}