import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valenty/valenty.dart';

class TestController extends ValentyController {
  bool isInitialized = false;
  bool isDisposed = false;

  @override
  void onInit() {
    super.onInit();
    isInitialized = true;
  }

  @override
  void onDispose() {
    isDisposed = true;
    super.onDispose();
  }
}

class SecondPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // This is the pattern user likely uses
    Valenty.put(TestController());
    return Scaffold(body: Text('Second Page'));
  }
}

void main() {
  testWidgets('Controller usage in page should be auto-disposed on pop', (
    WidgetTester tester,
  ) async {
    // 1. Setup
    await tester.pumpWidget(ValentyApp(home: Scaffold(body: Text('Home'))));

    // 2. Navigate to Second Page
    Valenty.to(SecondPage());
    await tester.pumpAndSettle();
    expect(find.text('Second Page'), findsOneWidget);

    // Verify Controller is initialized
    expect(Valenty.find<TestController>(), isNotNull);
    final controller = Valenty.find<TestController>();
    expect(controller.isInitialized, true);

    // 3. Pop
    Valenty.back();
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);

    // 4. Verify Controller is disposed
    // This is expected to FAIL currently
    expect(
      controller.isDisposed,
      true,
      reason: 'Controller should be disposed when page is popped',
    );

    // Also verify it's removed from Valenty
    expect(() => Valenty.find<TestController>(), throwsA(isA<String>()));
  });
}
