import 'package:flutter_test/flutter_test.dart';
import 'package:valenty/valenty.dart';

class TestController extends ValentyController {
  bool isInitialized = false;
  bool isDisposed = false;
  int count = 0;

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

void main() {
  group('Valenty DI Tests', () {
    test('put registers dependency and calls onInit', () {
      final controller = TestController();
      final registered = Valenty.put(controller);

      expect(registered, controller);
      expect(controller.isInitialized, true);
      expect(Valenty.find<TestController>(), controller);

      // Cleanup
      Valenty.delete<TestController>();
    });

    test('find retrieves registered dependency', () {
      final controller = Valenty.put(TestController(), tag: 'findTest');
      expect(Valenty.find<TestController>(tag: 'findTest'), controller);

      Valenty.delete<TestController>(tag: 'findTest');
    });

    test('delete removes dependency and calls onDispose', () {
      final controller = Valenty.put(TestController(), tag: 'deleteTest');

      expect(Valenty.delete<TestController>(tag: 'deleteTest'), true);
      expect(controller.isDisposed, true);

      expect(
        () => Valenty.find<TestController>(tag: 'deleteTest'),
        throwsA(isA<String>()),
      );
    });

    test('put returns existing instance if already registered', () {
      final c1 = TestController();
      Valenty.put(c1);

      final c2 = TestController();
      final registered = Valenty.put(c2); // Should return c1

      expect(registered, c1);
      expect(registered, isNot(c2));

      Valenty.delete<TestController>();
    });
  });
}
