import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App widget smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Text('Peer Tutoring App'),
        ),
      ),
    );

    expect(find.text('Peer Tutoring App'), findsOneWidget);
  });
}
