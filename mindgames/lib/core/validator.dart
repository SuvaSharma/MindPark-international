import 'package:get/get.dart';

class Validator {
  Validator._();

  static String? nameValidator(String? name) {
    name = name?.trim() ?? '';

    return name.isEmpty ? 'No name provided!'.tr : null;
  }

  static String? feedbackValidator(String? feedback) {
    feedback = feedback?.trim() ?? '';
    return feedback.isEmpty ? 'No feedback provided!'.tr : null;
  }

  static const String _emailPattern =
      r"(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'"
      r'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-'
      r'\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*'
      r'[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4]'
      r'[0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9]'
      r'[0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\'
      r'x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])';

  static String? emailValidator(String? email) {
    email = email?.trim() ?? '';

    return email.isEmpty
        ? 'No email provided!'.tr
        : !RegExp(_emailPattern).hasMatch(email)
            ? 'Email is not in a valid format!'.tr
            : null;
  }

  static String? passwordValidator(String? password) {
    password = password ?? '';

    String errorMessage = '';
    if (password.isEmpty) {
      errorMessage = 'No password provided!'.tr;
    } else {
      if (password.length < 6) {
        errorMessage = 'Must be at least 6 characters long!'.tr;
      } else if (!password.contains(RegExp(r'[a-z]'))) {
        errorMessage = 'Must contain at least one lowercase letter'.tr;
      } else if (!password.contains(RegExp(r'[A-Z]'))) {
        errorMessage = 'Must contain at least one uppercase letter'.tr;
      } else if (!password.contains(RegExp(r'[0-9]'))) {
        errorMessage = 'Must contain at least one number'.tr;
      }
    }
    return errorMessage.isNotEmpty ? errorMessage.trim() : null;
  }

  static String? ageValidator(String? age) {
    if (age == null || age.isEmpty) {
      return 'No age provided!'.tr;
    }

    final ageInt = int.tryParse(age);
    if (ageInt == null) {
      return 'Age must be a number!'.tr;
    }

    if (ageInt < 0 || ageInt > 15) {
      return 'Age must be between 0 and 15!'.tr;
    }

    return null;
  }

  static String? genderValidator(String? gender) {
    gender = gender?.trim() ?? '';

    if (gender.isEmpty) {
      return 'No gender provided!'.tr;
    }

    const validGenders = ['Male', 'Female', 'Others'];
    if (!validGenders.contains(gender)) {
      return 'Gender must be one of: ${validGenders.join(', ')}'.tr;
    }

    return null;
  }
}
