import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valenty/valenty.dart';

void main() {
  group('Context-less Utilities Tests', () {
    testWidgets('ValentyApp sets up global keys', (WidgetTester tester) async {
       await tester.pumpWidget(ValentyApp(
         home: Container(),
       ));
       
       expect(Valenty().navigatorKey.currentState, isNotNull);
       // ScaffoldMessengerState might require a Scaffold or build phase to be ready, but key should be assigned.
       expect(Valenty().scaffoldMessengerKey, isNotNull);
    });

    testWidgets('Valenty.dialog shows dialog', (WidgetTester tester) async {
      await tester.pumpWidget(ValentyApp(
        home: Scaffold(body: Container()),
      ));
      
      // Trigger dialog
      Valenty.dialog(
        AlertDialog(title: Text('Test Dialog')),
      );
      
      await tester.pumpAndSettle();
      
      expect(find.text('Test Dialog'), findsOneWidget);
    });

    testWidgets('Valenty.bottomSheet shows bottom sheet', (WidgetTester tester) async {
      await tester.pumpWidget(ValentyApp(
        home: Scaffold(body: Container()),
      ));
      
      Valenty.bottomSheet(
        Container(child: Text('Test BottomSheet')),
      );
      
      await tester.pumpAndSettle();
      
      expect(find.text('Test BottomSheet'), findsOneWidget);
    });

    testWidgets('Valenty.snackbar shows snackbar', (WidgetTester tester) async {
      await tester.pumpWidget(ValentyApp(
        home: Scaffold(body: Container()),
      ));
      
      Valenty.snackbar(
        'Title',
        'Message',
      );
      
      await tester.pumpAndSettle();
      
      expect(find.text('Title'), findsOneWidget);
      expect(find.text('Message'), findsOneWidget);
    });
  });
}
