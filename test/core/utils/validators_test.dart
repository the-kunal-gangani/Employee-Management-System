import 'package:flutter_test/flutter_test.dart';

import 'package:employee_management_system/core/utils/validators.dart';

void main() {
  group('Validators.email', () {
    test('returns error when null', () {
      expect(Validators.email(null), isNotNull);
    });

    test('returns error when empty', () {
      expect(Validators.email(''), isNotNull);
    });

    test('returns error for malformed email', () {
      expect(Validators.email('not-an-email'), isNotNull);
      expect(Validators.email('missing@domain'), isNotNull);
      expect(Validators.email('@nodomain.com'), isNotNull);
    });

    test('returns null for valid email', () {
      expect(Validators.email('user@example.com'), isNull);
      expect(Validators.email('first.last+tag@sub.example.co'), isNull);
    });
  });

  group('Validators.password', () {
    test('returns error when empty', () {
      expect(Validators.password(''), isNotNull);
    });

    test('returns error when shorter than 6 characters', () {
      expect(Validators.password('12345'), isNotNull);
    });

    test('returns null for 6+ characters', () {
      expect(Validators.password('123456'), isNull);
    });
  });

  group('Validators.confirmPassword', () {
    test('returns error when empty', () {
      expect(Validators.confirmPassword('', 'password123'), isNotNull);
    });

    test('returns error when mismatched', () {
      expect(Validators.confirmPassword('different', 'password123'), isNotNull);
    });

    test('returns null when matching', () {
      expect(Validators.confirmPassword('password123', 'password123'), isNull);
    });
  });

  group('Validators.required', () {
    test('returns error when null or blank', () {
      expect(Validators.required(null), isNotNull);
      expect(Validators.required('   '), isNotNull);
    });

    test('returns null when non-empty', () {
      expect(Validators.required('value'), isNull);
    });
  });

  group('Validators.mobile', () {
    test('returns error when empty', () {
      expect(Validators.mobile(''), isNotNull);
    });

    test('returns error when too short', () {
      expect(Validators.mobile('12345'), isNotNull);
    });

    test('returns null for valid length', () {
      expect(Validators.mobile('9876543210'), isNull);
      expect(Validators.mobile('+1 (987) 654-3210'), isNull);
    });
  });
}
