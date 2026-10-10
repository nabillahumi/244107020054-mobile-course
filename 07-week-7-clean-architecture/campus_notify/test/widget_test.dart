import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Smoke test widget load', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Text('Campus Notify'),
        ),
      ),
    );

    expect(find.text('Campus Notify'), findsOneWidget);
  });
}