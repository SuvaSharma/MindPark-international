import 'package:flutter_test/flutter_test.dart';
import 'package:mindgames/core/validator.dart';

void main() {
  group('Validation test', () {
    test('test_nameValidator_empty_null_valid', () {
      expect(
        Validator.nameValidator(''),
        'No name provided!',
      );
      expect(
        Validator.nameValidator(null),
        'No name provided!',
      );
      expect(
        Validator.nameValidator('John Doe'),
        null,
      );
    });

    test('test_emailValidator_empty_null_invalid_valid', () {
      expect(
        Validator.emailValidator(''),
        'No email provided!',
      );

      expect(
        Validator.emailValidator(null),
        'No email provided!',
      );

      expect(
        Validator.emailValidator('johndoe'),
        'Email is not in a valid format!',
      );

      expect(
        Validator.emailValidator('johndoe@gmail.com'),
        null,
      );
    });

    test('test_passwordValidator', () {
      expect(
        Validator.passwordValidator(''),
        'No password provided!',
      );

      expect(
        Validator.passwordValidator(null),
        'No password provided!',
      );

      expect(
        Validator.passwordValidator('short'),
        'Must be at least 6 characters long!',
      );

      expect(
        Validator.passwordValidator('ALLCAPS'),
        'Must contain at least one lowercase letter',
      );

      expect(
        Validator.passwordValidator('alllower'),
        'Must contain at least one uppercase letter',
      );

      expect(
        Validator.passwordValidator('NoNumbers'),
        'Must contain at least one number',
      );

      expect(
        Validator.passwordValidator('Shorty1'),
        null,
      );
    });

    test('test_ageValidator', () {
      expect(
        Validator.ageValidator(''),
        'No age provided!',
      );

      expect(
        Validator.ageValidator(null),
        'No age provided!',
      );

      expect(
        Validator.ageValidator('hello'),
        'Age must be a number!',
      );

      expect(
        Validator.ageValidator('-1'),
        'Age must be between 0 and 15!',
      );

      expect(
        Validator.ageValidator('16'),
        'Age must be between 0 and 15!',
      );

      expect(
        Validator.ageValidator('12'),
        null,
      );
    });
  });
}
