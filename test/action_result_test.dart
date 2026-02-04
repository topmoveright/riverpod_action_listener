import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_action_listener/riverpod_action_listener.dart';

void main() {
  group('ActionResult', () {
    test('idle should be ActionIdle', () {
      const result = ActionResult<String>.idle();
      expect(result, isA<ActionIdle<String>>());
    });

    test('success should be ActionSuccess with data', () {
      const result = ActionResult.success('test');
      expect(result, isA<ActionSuccess<String>>());
      expect((result as ActionSuccess).data, 'test');
    });

    test('equality works', () {
      expect(
        const ActionResult<int>.success(1),
        const ActionResult<int>.success(1),
      );
      expect(
        const ActionResult<int>.success(1),
        isNot(const ActionResult<int>.success(2)),
      );
    });
  });

  group('ActionVoidResult', () {
    test('idle should be ActionVoidIdle', () {
      const result = ActionVoidResult.idle();
      expect(result, isA<ActionVoidIdle>());
    });

    test('success should be ActionVoidSuccess', () {
      const result = ActionVoidResult.success();
      expect(result, isA<ActionVoidSuccess>());
    });
  });
}
