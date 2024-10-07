import 'package:duck_router/src/exception.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RouterException', () {
    test('should have a message', () {
      const exception = DuckRouterException('Test message');
      expect(exception.message, 'Test message');
    });

    test('should have a string representation', () {
      const exception = DuckRouterException('Test message');
      expect(exception.toString(), 'RouterException: Test message');
    });
  });
}
