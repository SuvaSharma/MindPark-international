import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:mindgames/change_notifiers/registration_controller.dart';
import 'package:mindgames/core/validator.dart';
import 'package:mindgames/widgets/register_button.dart';
import 'package:mindgames/widgets/register_form_field.dart';
import 'package:mindgames/widgets/snackbar_widget.dart';
import 'package:provider/provider.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});
  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  late final RegistrationController registrationController;
  String oldPassword = '';
  String newPassword = '';
  String confirmPassword = '';

  late final TextEditingController oldPasswordController;
  late final TextEditingController newPasswordController;
  late final TextEditingController confirmPasswordController;
  bool isSubmitting = false;

  @override
  void initState() {
    oldPasswordController = TextEditingController();
    newPasswordController = TextEditingController();
    confirmPasswordController = TextEditingController();
    registrationController = context.read<RegistrationController>();
    super.initState();
  }

  @override
  void dispose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _changePassword() async {
    setState(() {
      isSubmitting = true;
    });

    try {
      User? user = _auth.currentUser;
      if (user == null) {
        showCustomSnackbar(
            context, 'Error'.tr, 'No user is currently signed in.'.tr);
        return;
      }

      // Reauthenticate the user with the old password
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: oldPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // Now update to the new password
      await user.updatePassword(newPassword);

      if (!context.mounted) {
        return;
      }

      showCustomSnackbar(
          context, 'Success'.tr, 'Password updated successfully!'.tr);
    } catch (e) {
      if (!context.mounted) {
        return;
      }
      showCustomSnackbar(
          context, 'Error'.tr, 'Failed to update password: '.tr + e.toString());
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/homepage2.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Update Password'.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: screenWidth * 0.1,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF309092),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  Selector<RegistrationController, bool>(
                    selector: (_, controller) => controller.isPasswordHidden,
                    builder: (_, isPasswordHidden, __) => Column(
                      children: [
                        RegisterFormField(
                          controller: oldPasswordController,
                          labelText: 'Old Password'.tr,
                          fillColor: Colors.white,
                          filled: true,
                          obscureText: isPasswordHidden,
                          suffixIcon: GestureDetector(
                            onTap: () {
                              registrationController.isPasswordHidden =
                                  !isPasswordHidden;
                            },
                            child: Padding(
                              padding:
                                  EdgeInsets.only(right: screenWidth * 0.03),
                              child: Icon(
                                isPasswordHidden
                                    ? FontAwesomeIcons.eye
                                    : FontAwesomeIcons.eyeSlash,
                                size: screenWidth * 0.05,
                              ),
                            ),
                          ),
                          onChanged: (value) {
                            oldPassword = value;
                          },
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        RegisterFormField(
                          controller: newPasswordController,
                          labelText: 'New Password'.tr,
                          fillColor: Colors.white,
                          filled: true,
                          obscureText: isPasswordHidden,
                          suffixIcon: GestureDetector(
                            onTap: () {
                              registrationController.isPasswordHidden =
                                  !isPasswordHidden;
                            },
                            child: Padding(
                              padding:
                                  EdgeInsets.only(right: screenWidth * 0.03),
                              child: Icon(
                                isPasswordHidden
                                    ? FontAwesomeIcons.eye
                                    : FontAwesomeIcons.eyeSlash,
                                size: screenWidth * 0.05,
                              ),
                            ),
                          ),
                          validator: Validator.passwordValidator,
                          onChanged: (value) {
                            newPassword = value;
                          },
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        RegisterFormField(
                          controller: confirmPasswordController,
                          labelText: 'Confirm Password'.tr,
                          fillColor: Colors.white,
                          filled: true,
                          obscureText: isPasswordHidden,
                          suffixIcon: GestureDetector(
                            onTap: () {
                              registrationController.isPasswordHidden =
                                  !isPasswordHidden;
                            },
                            child: Padding(
                              padding:
                                  EdgeInsets.only(right: screenWidth * 0.03),
                              child: Icon(
                                isPasswordHidden
                                    ? FontAwesomeIcons.eye
                                    : FontAwesomeIcons.eyeSlash,
                                size: screenWidth * 0.05,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your password'.tr;
                            }
                            if (value != newPassword) {
                              return 'Passwords do not match'.tr;
                            }
                            return null;
                          },
                          onChanged: (value) {
                            confirmPassword = value;
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  SizedBox(
                    height: screenHeight * 0.07,
                    child: RegisterButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          if (!isSubmitting) {
                            _changePassword();
                          }
                        }
                      },
                      child: isSubmitting
                          ? CircularProgressIndicator(
                              backgroundColor: Colors.black.withOpacity(0.2),
                              color: const Color(0xFF309092),
                            )
                          : Text('Update'.tr,
                              style: TextStyle(fontSize: screenWidth * 0.06)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
