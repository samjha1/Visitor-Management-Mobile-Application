import 'package:flutter_test/flutter_test.dart';
import 'package:visitor_management/core/utils/validators.dart';

void main() {
  group('Validators Unit Tests', () {
    group('Name Validator', () {
      test('Rejects null, empty, and whitespace names', () {
        expect(Validators.validateName(null), isNotNull);
        expect(Validators.validateName(''), isNotNull);
        expect(Validators.validateName('   '), isNotNull);
      });

      test('Rejects name with less than 2 characters', () {
        expect(Validators.validateName('A'), isNotNull);
      });

      test('Accepts valid trimmed names', () {
        expect(Validators.validateName('John Doe'), isNull);
        expect(Validators.validateName('  Jane Smith  '), isNull);
      });
    });

    group('Mobile Validator', () {
      test('Rejects null, empty, and blank strings', () {
        expect(Validators.validateMobile(null), isNotNull);
        expect(Validators.validateMobile(''), isNotNull);
        expect(Validators.validateMobile('     '), isNotNull);
      });

      test('Rejects non-numeric characters', () {
        expect(Validators.validateMobile('98765abcde'), isNotNull);
        expect(Validators.validateMobile('98765-43210'), isNotNull);
      });

      test('Rejects fewer than 10 digits', () {
        expect(Validators.validateMobile('123456789'), isNotNull);
      });

      test('Rejects more than 10 digits', () {
        expect(Validators.validateMobile('12345678901'), isNotNull);
      });

      test('Accepts exactly 10 numeric digits and preserves leading zeroes', () {
        expect(Validators.validateMobile('0123456789'), isNull);
        expect(Validators.validateMobile('9876543210'), isNull);
        expect(Validators.validateMobile(' 9876543210 '), isNull);
      });
    });

    group('Email Validator', () {
      test('Accepts null, empty, or whitespace email since it is optional', () {
        expect(Validators.validateEmail(null), isNull);
        expect(Validators.validateEmail(''), isNull);
        expect(Validators.validateEmail('   '), isNull);
      });

      test('Rejects invalid email formats when entered', () {
        expect(Validators.validateEmail('notanemail'), isNotNull);
        expect(Validators.validateEmail('missingdomain@'), isNotNull);
        expect(Validators.validateEmail('@missingusername.com'), isNotNull);
        expect(Validators.validateEmail('missing@tld'), isNotNull);
      });

      test('Accepts standard valid email addresses', () {
        expect(Validators.validateEmail('user@example.com'), isNull);
        expect(Validators.validateEmail('john.doe@company.org'), isNull);
        expect(Validators.validateEmail('staff+test@sub.domain.co'), isNull);
      });
    });

    group('Purpose Validator', () {
      test('Rejects empty or less than 3 character purposes', () {
        expect(Validators.validatePurpose(null), isNotNull);
        expect(Validators.validatePurpose(''), isNotNull);
        expect(Validators.validatePurpose('ab'), isNotNull);
      });

      test('Accepts descriptive purpose of visit', () {
        expect(Validators.validatePurpose('Site inspection'), isNull);
      });
    });

    group('QR Payload Validator', () {
      test('Rejects null, empty, or blank QR code payload', () {
        expect(Validators.validateQrPayload(null), isNotNull);
        expect(Validators.validateQrPayload(''), isNotNull);
        expect(Validators.validateQrPayload('   '), isNotNull);
      });

      test('Accepts non-empty payload containing visitor ID', () {
        expect(Validators.validateQrPayload('101'), isNull);
        expect(Validators.validateQrPayload('6600abc123'), isNull);
      });
    });
  });
}
