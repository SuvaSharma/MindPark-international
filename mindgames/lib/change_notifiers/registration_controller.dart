import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mindgames/language_screen.dart';
import '../core/constants.dart';
import '../core/dialogs.dart';
import '../services/auth_service.dart';

class RegistrationController extends ChangeNotifier {
  bool _isRegisterMode = false;
  bool get isRegisterMode => _isRegisterMode;
  set isRegisterMode(bool value) {
    _isRegisterMode = value;
    notifyListeners();
  }

  bool _isPasswordHidden = true;
  bool get isPasswordHidden => _isPasswordHidden;
  set isPasswordHidden(bool value) {
    _isPasswordHidden = value;
    notifyListeners();
  }

  String _fullName = '';
  set fullName(String value) {
    _fullName = value;
    notifyListeners();
  }

  String get fullName => _fullName.trim();

  String _email = '';
  set email(String value) {
    _email = value;
    notifyListeners();
  }

  String get email => _email.trim();

  String _password = '';
  set password(String value) {
    _password = value;
    notifyListeners();
  }

  String get password => _password;

  String _gender = '';
  set gender(String value) {
    _gender = value;
    notifyListeners();
  }

  String get gender => _gender;

  String _age = '';
  set age(String value) {
    _age = value;
    notifyListeners();
  }

  String get age => _age;

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> authenticateWithEmailAndPassword(
      {required BuildContext context}) async {
    isLoading = true;
    try {
      if (_isRegisterMode) {
        // Register the user
        await AuthService.register(
          fullName: fullName,
          email: email,
          password: password,
          age: age,
          gender: gender,
        );

        if (!context.mounted) return;
        showMessageDialog(
          context: context,
          message:
              'A verification email was sent to the provided email address. Please confirm your email to proceed to the app.',
        );

        // Check for email verification
        while (!AuthService.isEmailVerified) {
          await Future.delayed(
            const Duration(seconds: 5),
            () => AuthService.user?.reload(),
          );
        }

        if (AuthService.isEmailVerified) {
          isRegisterMode = false;
          // Navigate to language screen after email verification
          if (!context.mounted) return;
          Get.off(() => LanguageScreen());
        }
      } else {
        // Sign in the user
        await AuthService.login(email: email, password: password);

        // Reload the user to get updated info
        await AuthService.user?.reload();

        // Check if the email is verified
        if (AuthService.isEmailVerified) {
          // Navigate to language screen if email is verified
          if (!context.mounted) return;
          Get.off(() => LanguageScreen());
        } else {
          // If not verified, send verification email and show a message
          await AuthService.user?.sendEmailVerification();
          if (!context.mounted) return;
          showMessageDialog(
            context: context,
            message:
                'Your email is not verified. A verification email has been sent. Please verify your email before logging in.',
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;
      showMessageDialog(
        context: context,
        message: authExceptionMapper[e.code] ?? 'An unknown error occurred!',
      );
    } catch (e) {
      if (!context.mounted) return;
      showMessageDialog(
        context: context,
        message: 'An unknown error occurred!',
      );
    } finally {
      isLoading = false;
    }
  }

  Future<void> authenticateWithGoogle({required BuildContext context}) async {
    try {
      await AuthService.signInWithGoogle();

      // Navigate to language screen after Google sign-in
      if (!context.mounted) return;
      Get.off(() => LanguageScreen());
    } on NoGoogleAccountChosenException {
      return;
    } catch (e) {
      if (!context.mounted) return;
      showMessageDialog(
        context: context,
        message: 'An unknown error occurred!',
      );
    }
  }

  Future<void> resetPassword({
    required BuildContext context,
    required String email,
  }) async {
    isLoading = true;
    try {
      await AuthService.resetPassword(email: email);
      if (!context.mounted) return;
      showMessageDialog(
          context: context,
          message:
              'A reset password link has been sent to $email. Open the link to reset your password.');
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;
      showMessageDialog(
        context: context,
        message: authExceptionMapper[e.code] ?? 'An unknown error occurred!',
      );
    } catch (e) {
      if (!context.mounted) return;
      showMessageDialog(
        context: context,
        message: 'An unknown error occurred!',
      );
    } finally {
      isLoading = false;
    }
  }
}

class NoGoogleAccountChosenException implements Exception {
  const NoGoogleAccountChosenException();
}
