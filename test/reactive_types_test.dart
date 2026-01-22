import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valenty/valenty.dart';

void main() {
  group('Reactive Types Limitations Test', () {
    testWidgets('RxList notifies on item add', (WidgetTester tester) async {
      final list = <String>[].obs;
      int buildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Obx(() {
            buildCount++;
            // Access list length to track changes
            return Text('Count: ${list.length}');
          }),
        ),
      );

      expect(buildCount, 1);
      expect(find.text('Count: 0'), findsOneWidget);

      // Mutate list
      list.add('New Item');

      await tester.pump();

      // Should now be 2
      expect(buildCount, 2);
      expect(find.text('Count: 1'), findsOneWidget);
    });

    testWidgets('RxMap notifies on key update', (WidgetTester tester) async {
      final map = <String, int>{}.obs;
      int buildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Obx(() {
            buildCount++;
            // Access specific key or length
            return Text('Val: ${map['key']}');
          }),
        ),
      );

      expect(buildCount, 1);

      map['key'] = 1;

      await tester.pump();

      // Expect rebuild
      expect(buildCount, 2);
    });

    testWidgets('Rx<Model> works when instance is replaced', (
      WidgetTester tester,
    ) async {
      final user = Rx(User('Alice', 25));
      int buildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Obx(() {
            buildCount++;
            return Text('${user.value.name}: ${user.value.age}');
          }),
        ),
      );

      expect(buildCount, 1);
      expect(find.text('Alice: 25'), findsOneWidget);

      // Mutating field directly DOES NOT trigger rebuild unless field is Rx (which it isn't here)
      // user.value.name = 'Bob'; // No effect on UI

      // Replacing instance triggers rebuild
      user.value = User('Bob', 30);

      await tester.pump();

      expect(buildCount, 2);
      expect(find.text('Bob: 30'), findsOneWidget);
    });
  });
}

class User {
  String name;
  int age;
  User(this.name, this.age);
}
