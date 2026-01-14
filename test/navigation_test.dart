import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valenty/valenty.dart';

void main() {
  group('Context-less Navigation Tests', () {
    testWidgets('Valenty.to navigates to new page', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(ValentyApp(home: Scaffold(body: Text('Home'))));

      Valenty.to(Scaffold(body: Text('Second Page')));

      await tester.pumpAndSettle();

      expect(find.text('Second Page'), findsOneWidget);
    });

    testWidgets('Valenty.back pops current page', (WidgetTester tester) async {
      await tester.pumpWidget(ValentyApp(home: Scaffold(body: Text('Home'))));

      Valenty.to(Scaffold(body: Text('Second Page')));
      await tester.pumpAndSettle();
      expect(find.text('Second Page'), findsOneWidget);

      Valenty.back();
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Second Page'), findsNothing);
    });

    testWidgets('Valenty.off replaces current page', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(ValentyApp(home: Scaffold(body: Text('Home'))));

      Valenty.to(Scaffold(body: Text('Second Page')));
      await tester.pumpAndSettle();

      // Replace 'Second Page' with 'Third Page'
      Valenty.off(Scaffold(body: Text('Third Page')));
      await tester.pumpAndSettle();

      expect(find.text('Third Page'), findsOneWidget);

      // Going back should go to Home
      Valenty.back();
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('Valenty.arguments passes arguments', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(ValentyApp(home: Scaffold(body: Text('Home'))));

      Valenty.to(
        Scaffold(
          body: Builder(builder: (c) => Text('Args: ${Valenty.arguments}')),
        ),
        arguments: 'Hello Args',
      );

      await tester.pumpAndSettle();

      expect(find.text('Args: Hello Args'), findsOneWidget);
    });
  });
}
