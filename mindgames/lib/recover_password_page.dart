import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../change_notifiers/registration_controller.dart';
import '../core/constants.dart';
import '../core/validator.dart';
import 'widgets/register_back_button.dart';
import 'widgets/register_button.dart';
import 'widgets/register_form_field.dart';

class RecoverPasswordpage extends StatefulWidget {
  const RecoverPasswordpage({super.key});

  @override
  State<RecoverPasswordpage> createState() => _RecoverPasswordpageState();
}

class _RecoverPasswordpageState extends State<RecoverPasswordpage> {
  late final TextEditingController emailController;

  GlobalKey<FormFieldState> emailKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    emailController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/homepage2.png'),
                fit: BoxFit.cover)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Recover Password',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: screenWidth * 0.1,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF309092),
                  ),
                ),
                SizedBox(height: screenHeight * 0.0025),
                Text('Don\'t worry! Happens to the best of us!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: screenWidth * 0.04)),
                const SizedBox(height: 24),
                RegisterFormField(
                  key: emailKey,
                  controller: emailController,
                  fillColor: white,
                  filled: true,
                  labelText: 'Email',
                  validator: Validator.emailValidator,
                ),
                SizedBox(height: screenHeight * 0.03),
                SizedBox(
                  height: screenHeight * 0.08,
                  child: Selector<RegistrationController, bool>(
                    selector: (_, controller) => controller.isLoading,
                    builder: (_, isLoading, __) => RegisterButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              if (emailKey.currentState?.validate() ?? false) {
                                context
                                    .read<RegistrationController>()
                                    .resetPassword(
                                      context: context,
                                      email: emailController.text.trim(),
                                    );
                              }
                            },
                      child: isLoading
                          ? SizedBox(
                              width: screenWidth * 0.05,
                              height: screenWidth * 0.05,
                              child: CircularProgressIndicator(color: white),
                            )
                          : Text('Send me a recovery link!',
                              style: TextStyle(fontSize: screenWidth * 0.05)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
