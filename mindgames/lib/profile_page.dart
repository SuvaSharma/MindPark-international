import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:mindgames/change_password_screen.dart';
import 'package:mindgames/core/validator.dart';
import 'package:mindgames/profile.dart';
import 'package:mindgames/widgets/snackbar_widget.dart';
import 'widgets/register_button.dart';
import 'widgets/register_form_field.dart';
import '../services/auth_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final TextEditingController nameController;
  late final TextEditingController ageController;
  late final TextEditingController emailController;
  late final TextEditingController userIdController;

  late final GlobalKey<FormState> formKey;

  String? selectedGender;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController();
    ageController = TextEditingController();
    emailController = TextEditingController();
    userIdController = TextEditingController();

    formKey = GlobalKey();

    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final currentUser = AuthService.user?.uid;
    if (currentUser != null) {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where("userId", isEqualTo: currentUser)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userDoc = querySnapshot.docs.first;
        final userData = userDoc.data();

        setState(() {
          nameController.text = userData['name'] ?? '';
          selectedGender = userData['gender'];
          ageController.text = userData['age']?.toString() ?? '';
          emailController.text = userData['email'] ?? '';
          userIdController.text = userData['userId'] ?? '';
        });
      }
    }
  }

  Future<void> updateUserData() async {
    final currentUser = AuthService.user?.uid;
    final user = AuthService.user;
    if (currentUser != null) {
      if (formKey.currentState!.validate()) {
        setState(() {
          isSubmitting = true;
        });
        final querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where("userId", isEqualTo: currentUser)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          final userDoc = querySnapshot.docs.first;

          await FirebaseFirestore.instance
              .collection('users')
              .doc(userDoc.id)
              .update({
            'name': nameController.text,
          });

          await user!.updateDisplayName(nameController.text);
          if (!context.mounted) {
            return;
          }
          setState(() {
            isSubmitting = false;
          });
          showCustomSnackbar(
              context, 'Success'.tr, 'Profile updated successfully!'.tr);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Profile()),
          );
        } else {
          if (!context.mounted) {
            return;
          }
          setState(() {
            isSubmitting = false;
          });
          showCustomSnackbar(context, 'Error'.tr, 'User document not found'.tr);
        }
      }
    } else {
      if (!context.mounted) {
        return;
      }
      setState(() {
        isSubmitting = false;
      });
      showCustomSnackbar(context, 'Error'.tr, 'User not logged in'.tr);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    emailController.dispose();
    userIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const Profile(),
          ),
        );
        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
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
                  child: Form(
                    key: formKey,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Update'.tr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: screenWidth * 0.1,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF309092),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.03),
                          RegisterFormField(
                            controller: userIdController,
                            labelText: 'User ID'.tr,
                            fillColor: Colors.white,
                            filled: true,
                            readOnly: true,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          RegisterFormField(
                            controller: emailController,
                            labelText: 'Email'.tr,
                            fillColor: Colors.white,
                            filled: true,
                            readOnly: true,
                            suffixIcon: const Icon(Icons.email_outlined),
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          RegisterFormField(
                            controller: nameController,
                            labelText: 'Name'.tr,
                            fillColor: Colors.white,
                            filled: true,
                            validator: Validator.nameValidator,
                            // readOnly: true,
                          ),
                          SizedBox(height: screenHeight * 0.03),
                          SizedBox(
                            height: screenHeight * 0.06,
                            width: screenWidth * 0.35,
                            child: RegisterButton(
                              onPressed: isSubmitting
                                  ? null
                                  : () {
                                      if (formKey.currentState!.validate()) {
                                        updateUserData();
                                      }
                                    },
                              child: isSubmitting
                                  ? CircularProgressIndicator(
                                      backgroundColor:
                                          Colors.black.withOpacity(0.2),
                                      color: const Color(0xFF309092))
                                  : Text('Update'.tr,
                                      style: TextStyle(
                                          fontSize: screenWidth * 0.06)),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.04),
                          SizedBox(
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const ChangePasswordScreen()),
                                );
                              },
                              child: Text('Update Password'.tr,
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.06,
                                    decoration: TextDecoration.underline,
                                    decorationColor: Colors.red,
                                    color: Colors.red,
                                  )),
                            ),
                          ),
                        ]),
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
