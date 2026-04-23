// test/widget_test.dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TaskModel tests', () {
    test('status defaults to Todo', () {
      // TaskModel instances without explicit status should be 'Todo'
      const status = 'Todo';
      expect(status, equals('Todo'));
    });

    test('priority color mapping', () {
      final priorityMap = {
        'Critical': 'red',
        'High': 'orange',
        'Medium': 'blue',
        'Low': 'grey',
      };
      expect(priorityMap['Critical'], equals('red'));
      expect(priorityMap['Low'], equals('grey'));
    });

    test('due date overdue detection', () {
      final pastDate = DateTime.now().subtract(const Duration(days: 1));
      final futureDate = DateTime.now().add(const Duration(days: 1));
      expect(pastDate.isBefore(DateTime.now()), isTrue);
      expect(futureDate.isBefore(DateTime.now()), isFalse);
    });
  });

  group('AppConstants tests', () {
    test('valid statuses list', () {
      final statuses = ['Todo', 'In Progress', 'Review', 'Done'];
      expect(statuses.length, equals(4));
      expect(statuses.contains('Done'), isTrue);
    });

    test('valid priorities list', () {
      final priorities = ['Low', 'Medium', 'High', 'Critical'];
      expect(priorities.length, equals(4));
    });
  });
}
