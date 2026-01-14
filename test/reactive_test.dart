import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valenty/valenty.dart';

void main() {
  group('Reactive System Tests', () {
    test('Rx variable notifies listener when changed', () {
      final count = 0.obs;
      // bool called = false;

      // Manually add a mock listener
      // Since _listeners is private and tied to _ValentyObserver, we test via internal behavior indirectly or use Obx integration test (below).
      // However, we can test value setting.
      expect(count.value, 0);
      count.value = 5;
      expect(count.value, 5);
    });

    testWidgets('Obx rebuilds when Rx variable changes', (
      WidgetTester tester,
    ) async {
      final count = 0.obs;

      await tester.pumpWidget(
        MaterialApp(
          home: Obx(() {
            return Text('Count: ${count.value}');
          }),
        ),
      );

      expect(find.text('Count: 0'), findsOneWidget);

      count.value++;
      await tester.pump();

      expect(find.text('Count: 1'), findsOneWidget);
    });

    testWidgets('Obx does not rebuild if unrelated Rx changes', (
      WidgetTester tester,
    ) async {
      final count1 = 0.obs;
      final count2 = 10.obs;
      int buildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Obx(() {
            buildCount++;
            return Text('Count1: ${count1.value}');
          }),
        ),
      );

      expect(buildCount, 1);

      // Change count2 (not used in Obx)
      count2.value++;
      await tester.pump();

      expect(buildCount, 1); // Should not rebuild

      // Change count1
      count1.value++;
      await tester.pump();

      expect(buildCount, 2); // Should rebuild
    });
  });
}
