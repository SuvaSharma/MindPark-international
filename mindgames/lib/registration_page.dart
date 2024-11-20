import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../change_notifiers/registration_controller.dart';
import '../core/constants.dart';
import '../core/validator.dart';
import 'widgets/register_button.dart';
import 'widgets/register_form_field.dart';
import 'recover_password_page.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  late final RegistrationController registrationController;

  late final TextEditingController nameController;
  late final TextEditingController emailController;
  late final TextEditingController passwordController;

  late final TextEditingController ageController;

  late final GlobalKey<FormState> formKey;

  String? selectedGender;

  @override
  void initState() {
    super.initState();

    registrationController = context.read();

    nameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    ageController = TextEditingController();

    formKey = GlobalKey();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();

    ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
          image: AssetImage('assets/images/homepage2.png'),
          fit: BoxFit.cover,
        )),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: SingleChildScrollView(
                child: Selector<RegistrationController, bool>(
                  selector: (_, controller) => controller.isRegisterMode,
                  builder: (_, isRegisterMode, __) => Form(
                    key: formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      //crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          isRegisterMode ? 'Register' : 'Sign In',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: screenWidth * 0.1,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF309092),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        if (isRegisterMode) ...[
                          RegisterFormField(
                            controller: nameController,
                            labelText: 'Full name',
                            fillColor: white,
                            filled: true,
                            textCapitalization: TextCapitalization.sentences,
                            textInputAction: TextInputAction.next,
                            validator: Validator.nameValidator,
                            onChanged: (newValue) {
                              registrationController.fullName = newValue;
                            },
                          ),
                          SizedBox(height: screenHeight * 0.012),
                        ],
                        RegisterFormField(
                          controller: emailController,
                          labelText: 'Email address',
                          fillColor: white,
                          filled: true,
                          suffixIcon: Padding(
                            padding: EdgeInsets.only(right: screenWidth * 0.03),
                            child: Icon(Icons.email_outlined,
                                size: screenWidth * 0.05),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: Validator.emailValidator,
                          onChanged: (newValue) {
                            registrationController.email = newValue;
                          },
                        ),
                        SizedBox(height: screenHeight * 0.012),
                        Selector<RegistrationController, bool>(
                          selector: (_, controller) =>
                              controller.isPasswordHidden,
                          builder: (_, isPasswordHidden, __) =>
                              RegisterFormField(
                            controller: passwordController,
                            labelText: 'Password',
                            fillColor: white,
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
                                    size: screenWidth * 0.05),
                              ),
                            ),
                            validator: isRegisterMode
                                ? Validator.passwordValidator
                                : null,
                            onChanged: (newValue) {
                              registrationController.password = newValue;
                            },
                          ),
                        ),
                        SizedBox(
                          height: screenHeight * 0.012,
                        ),
                        // if (isRegisterMode) ...[
                        //   RegisterFormField(
                        //     controller: ageController,
                        //     labelText: 'Age',
                        //     fillColor: white,
                        //     filled: true,
                        //     textCapitalization: TextCapitalization.sentences,
                        //     textInputAction: TextInputAction.next,
                        //     validator: Validator.ageValidator,
                        //     onChanged: (newValue) {
                        //       registrationController.age = newValue;
                        //     },
                        //   ),
                        // ],
                        // SizedBox(
                        //   height: screenHeight * 0.012,
                        // ),
                        // if (isRegisterMode) ...[
                        //   DropdownButtonFormField<String>(
                        //     value: selectedGender,
                        //     style: TextStyle(
                        //       fontFamily: 'ShantellSans',
                        //       color: Colors.black,
                        //       fontSize: screenWidth * 0.04,
                        //     ),
                        //     decoration: InputDecoration(
                        //       contentPadding: EdgeInsets.symmetric(
                        //         horizontal: screenWidth * 0.02,
                        //         vertical: screenHeight * 0.025,
                        //       ),
                        //       floatingLabelBehavior:
                        //           FloatingLabelBehavior.always,
                        //       errorStyle:
                        //           TextStyle(fontSize: screenWidth * 0.04),
                        //       labelStyle: TextStyle(
                        //         fontSize: screenWidth * 0.04,
                        //       ),
                        //       filled: true,
                        //       fillColor: Colors.white,
                        //       labelText: 'Gender',
                        //       border: OutlineInputBorder(
                        //         borderSide: BorderSide(
                        //           color:
                        //               Color(0xFF309092), // Default border color
                        //         ),
                        //         borderRadius: BorderRadius.circular(25),
                        //       ),
                        //       enabledBorder: OutlineInputBorder(
                        //         borderSide: BorderSide(
                        //           color: Color(
                        //               0xFF309092), // Border color when enabled
                        //         ),
                        //         borderRadius: BorderRadius.circular(25),
                        //       ),
                        //       focusedBorder: OutlineInputBorder(
                        //         borderSide: BorderSide(
                        //           color: Color(
                        //               0xFF309092), // Border color when focused
                        //           width: 2.0,
                        //         ),
                        //         borderRadius: BorderRadius.circular(25),
                        //       ),
                        //     ),
                        //     items: <String>['Male', 'Female', 'Others']
                        //         .map((String value) {
                        //       return DropdownMenuItem<String>(
                        //         value: value,
                        //         child: Text(value,
                        //             style: TextStyle(
                        //                 fontSize: screenWidth * 0.04)),
                        //       );
                        //     }).toList(),
                        //     onChanged: (String? newValue) {
                        //       setState(() {
                        //         selectedGender = newValue;
                        //         registrationController.gender = newValue!;
                        //       });
                        //     },
                        //     validator: Validator.genderValidator,
                        //   ),
                        //   SizedBox(height: screenHeight * 0.012),
                        // ],
                        SizedBox(height: screenHeight * 0.019),
                        if (!isRegisterMode) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const RecoverPasswordpage(),
                                    ),
                                  );
                                },
                                child: Text(
                                  textAlign: TextAlign.end,
                                  'Forgot password?',
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.04,
                                    color: Color(0xAF309092),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: screenHeight * 0.035),
                        ],
                        SizedBox(
                          height: screenHeight * 0.08,
                          width: screenWidth * 0.6,
                          child: Selector<RegistrationController, bool>(
                            selector: (_, controller) => controller.isLoading,
                            builder: (_, isLoading, __) => RegisterButton(
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      if (formKey.currentState?.validate() ??
                                          false) {
                                        registrationController
                                            .authenticateWithEmailAndPassword(
                                                context: context);
                                      }
                                    },
                              child: isLoading
                                  ? SizedBox(
                                      width: screenWidth * 0.05,
                                      height: screenWidth * 0.05,
                                      child: CircularProgressIndicator(
                                          color: white),
                                    )
                                  : Text(
                                      isRegisterMode
                                          ? 'Create my account'
                                          : 'Log me in',
                                      style: TextStyle(
                                          fontSize: screenWidth * 0.05)),
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.04),
                        Row(
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text(
                                  isRegisterMode
                                      ? 'Or register with'
                                      : 'Or sign in with',
                                  style:
                                      TextStyle(fontSize: screenWidth * 0.04)),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                registrationController.authenticateWithGoogle(
                                    context: context);
                              },
                              child: Image.asset(
                                'assets/images/google_logo.png',
                                height: screenWidth * 0.13,
                                width: screenWidth * 0.13,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        Text.rich(
                          TextSpan(
                            text: isRegisterMode
                                ? 'Already have an account? '
                                : 'Don\'t have an account? ',
                            style: TextStyle(
                                color: gray700, fontSize: screenWidth * 0.04),
                            children: [
                              TextSpan(
                                text: isRegisterMode ? 'Sign in' : 'Register',
                                style: TextStyle(
                                    color: Color(0xFF309092),
                                    fontWeight: FontWeight.bold,
                                    fontSize: screenWidth * 0.04),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    registrationController.isRegisterMode =
                                        !isRegisterMode;
                                  },
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
