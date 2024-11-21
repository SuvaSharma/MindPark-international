import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:mindgames/change_notifiers/registration_controller.dart';
import 'package:mindgames/child.dart';
import 'package:mindgames/cloud_store_service.dart';
import 'package:mindgames/core/validator.dart';
import 'package:mindgames/providers.dart';
import 'package:mindgames/services/auth_service.dart';
import 'package:mindgames/widgets/register_button.dart';
import 'package:mindgames/widgets/register_form_field.dart';
import 'package:mindgames/widgets/snackbar_widget.dart';
import 'package:mindgames/widgets/wrapper_widget.dart';
import 'package:provider/provider.dart';

enum Menu { edit, delete }

class ChildProfileList extends ConsumerStatefulWidget {
  final String shownWhen;
  const ChildProfileList({super.key, required this.shownWhen});

  @override
  ConsumerState<ChildProfileList> createState() => _ChildProfileListState();
}

class _ChildProfileListState extends ConsumerState<ChildProfileList> {
  final currentUser = AuthService.user?.uid;

  CloudStoreService cloudStoreService = CloudStoreService();
  late final TextEditingController nameController;
  late final TextEditingController ageController;
  final formKey = GlobalKey<FormState>();
  String? selectedGender;
  List<Map<String, dynamic>> profileList = [];
  bool isLoading = true;

  Future<void> getData() async {
    profileList = await cloudStoreService.getChildren(currentUser);
    setState(() {
      isLoading = false;
    });
    print(
        'child profile $profileList'); // Ensure the UI updates after fetching the data
  }

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    ageController = TextEditingController();
    getData().then((_) {
      if (widget.shownWhen == 'launch') {
        if (profileList.length == 1) {
          print('Only one child');
          final child = profileList[0];
          Map<String, dynamic> childData = {
            'childId': child['childId'],
            'age': int.parse(child['age']),
            'name': child['name'],
            'gender': child['gender'],
          };

          ref.read(selectedChildDataProvider.notifier).state =
              Child.fromJson(childData);

          // showCustomSnackbar(
          //     context, 'Success'.tr, '${child['name']} selected');

          //Navigate to Homepage
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MainWrapper()),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    super.dispose();
  }

  void showAddProfileDialog() {
    final registrationController = context.read<RegistrationController>();
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    nameController.clear();
    ageController.clear();
    selectedGender = null;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Dialog(
            child: Container(
              height: screenHeight * 0.6,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(screenWidth * 0.1),
              ),
              child: Form(
                key: formKey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        'Add a child'.tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: screenWidth * 0.08,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFF88379),
                        ),
                      ),
                      RegisterFormField(
                        controller: nameController,
                        labelText: 'Full name'.tr,
                        fillColor: Colors.white,
                        borderColor: const Color(0xFFF88379),
                        filled: true,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.next,
                        validator: Validator.nameValidator,
                        onChanged: (newValue) {
                          registrationController.fullName = newValue;
                        },
                      ),
                      RegisterFormField(
                        controller: ageController,
                        labelText: 'Age'.tr,
                        fillColor: Colors.white,
                        borderColor: const Color(0xFFF88379),
                        filled: true,
                        keyboardType: TextInputType.number,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.next,
                        validator: Validator.ageValidator,
                        onChanged: (newValue) {
                          registrationController.age = newValue;
                        },
                      ),
                      DropdownButtonFormField<String>(
                        value: selectedGender,
                        style: TextStyle(
                          fontFamily: 'ShantellSans',
                          color: Colors.black,
                          fontSize: screenWidth * 0.04,
                        ),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.02,
                            vertical: screenHeight * 0.025,
                          ),
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          errorStyle: TextStyle(fontSize: screenWidth * 0.04),
                          labelStyle: TextStyle(
                              fontSize: screenWidth * 0.04,
                              color: const Color(0xFFF88379)),
                          filled: true,
                          fillColor: Colors.white,
                          labelText: 'Gender'.tr,
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color(0xFFF88379),
                            ),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color(0xFFF88379),
                            ),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color(0xFFF88379),
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        items: <String>['Male', 'Female', 'Others']
                            .map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value.tr,
                                style: TextStyle(fontSize: screenWidth * 0.04)),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedGender = newValue;
                            registrationController.gender = newValue!;
                          });
                        },
                        validator: Validator.genderValidator,
                      ),
                      SizedBox(
                        height: screenHeight * 0.07,
                        child: RegisterButton(
                          color: const Color(0xFFF88379),
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              try {
                                await cloudStoreService.addChildren(
                                  userId: currentUser,
                                  name: nameController.text,
                                  age: ageController.text,
                                  gender: selectedGender!,
                                  createdDate: DateTime.now(),
                                );

                                if (!context.mounted) {
                                  return;
                                }
                                Navigator.of(context).pop();

                                showCustomSnackbar(context, 'Success'.tr,
                                    'Child added successfully'.tr);
                                getData(); // Fetch data again after adding a child
                              } catch (e) {
                                if (!context.mounted) {
                                  return;
                                }
                                showCustomSnackbar(context, 'Error'.tr,
                                    'Error adding child'.tr);
                              }
                            }
                          },
                          child: Text('Add Child'.tr,
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
      },
    );
  }

  void showUpdateProfileDialog(
      String childId, String name, String age, String gender) {
    final registrationController = context.read<RegistrationController>();
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    nameController.text = name;
    ageController.text = age;
    selectedGender = gender;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Dialog(
            child: Container(
              height: screenHeight * 0.6,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(screenWidth * 0.1),
              ),
              child: Form(
                key: formKey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        'Update child info'.tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: screenWidth * 0.08,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFF88379),
                        ),
                      ),
                      RegisterFormField(
                        controller: nameController,
                        labelText: 'Full name'.tr,
                        fillColor: Colors.white,
                        borderColor: const Color(0xFFF88379),
                        filled: true,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.next,
                        validator: Validator.nameValidator,
                        onChanged: (newValue) {
                          registrationController.fullName = newValue;
                        },
                      ),
                      RegisterFormField(
                        controller: ageController,
                        labelText: 'Age'.tr,
                        fillColor: Colors.white,
                        borderColor: const Color(0xFFF88379),
                        filled: true,
                        keyboardType: TextInputType.number,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.next,
                        validator: Validator.ageValidator,
                        onChanged: (newValue) {
                          registrationController.age = newValue;
                        },
                      ),
                      DropdownButtonFormField<String>(
                        value: selectedGender,
                        style: TextStyle(
                          fontFamily: 'ShantellSans',
                          color: Colors.black,
                          fontSize: screenWidth * 0.04,
                        ),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.02,
                            vertical: screenHeight * 0.025,
                          ),
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          errorStyle: TextStyle(fontSize: screenWidth * 0.04),
                          labelStyle: TextStyle(
                              fontSize: screenWidth * 0.04,
                              color: const Color(0xFFF88379)),
                          filled: true,
                          fillColor: Colors.white,
                          labelText: 'Gender'.tr,
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color(0xFFF88379),
                            ),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color(0xFFF88379),
                            ),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color(0xFFF88379),
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        items: <String>['Male', 'Female', 'Others']
                            .map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value,
                                style: TextStyle(fontSize: screenWidth * 0.04)),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedGender = newValue;
                            registrationController.gender = newValue!;
                          });
                        },
                        validator: Validator.genderValidator,
                      ),
                      SizedBox(
                        height: screenHeight * 0.07,
                        child: RegisterButton(
                          color: const Color(0xFFF88379),
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              try {
                                await cloudStoreService.updateChild(
                                  userId: currentUser!,
                                  childId: childId,
                                  name: nameController.text,
                                  age: ageController.text,
                                  gender: selectedGender!,
                                );

                                if (!context.mounted) {
                                  return;
                                }
                                Navigator.of(context).pop();

                                showCustomSnackbar(context, 'Success'.tr,
                                    'Child info updated successfully'.tr);
                                getData(); // Fetch data again after updating a child
                              } catch (e) {
                                if (!context.mounted) {
                                  return;
                                }
                                showCustomSnackbar(context, 'Error'.tr,
                                    'Error updating child info'.tr);
                              }
                            }
                          },
                          child: Text('Update Child'.tr,
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
      },
    );
  }

  void showDeleteConfirmationDialog(
      String childId, String name, VoidCallback onConfirm) {
    double screenWidth = MediaQuery.of(context).size.width;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Child'.tr,
              style: TextStyle(
                  color: const Color.fromARGB(255, 245, 123, 115),
                  fontSize: screenWidth * 0.06)),
          content: Text(
              'Are you sure you want to delete child: {name}?'
                  .tr
                  .replaceFirst('{name}', name),
              style: TextStyle(
                fontSize: screenWidth * 0.04,
              )),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                  foregroundColor: const Color.fromARGB(255, 245, 123, 115)),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'.tr,
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                  )),
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 245, 123, 115),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
              child: Text('Delete'.tr,
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                  )),
            ),
          ],
        );
      },
    );
  }

  SizedBox buildProfileList(
      String childId, String name, String gender, String age) {
    double screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      height: screenWidth * 0.25,
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              print('Selecting profile $name $childId $gender $age');
              // Update the provider with the selected child's data
              Map<String, dynamic> childData = {
                'childId': childId,
                'age': int.parse(age),
                'name': name,
                'gender': gender,
              };

              ref.read(selectedChildDataProvider.notifier).state =
                  Child.fromJson(childData);

              showCustomSnackbar(context, 'Success'.tr, name + ' selected'.tr);

              // Navigate to Homepage
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const MainWrapper()),
              );
            },
            child: Stack(
              children: [
                Container(
                  height: screenWidth * 0.2,
                  width: screenWidth * 0.2,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7CBC8),
                    borderRadius: BorderRadius.circular(screenWidth * 0.1),
                  ),
                  child: Center(
                    child: Text(
                      name.substring(0, 1),
                      style: TextStyle(
                        fontSize: screenWidth * 0.07,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                Positioned(
                  top: screenWidth * 0.0025,
                  right: screenWidth * 0.0025,
                  child: Container(
                    height: screenWidth * 0.08,
                    width: screenWidth * 0.08,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: PopupMenuButton<Menu>(
                      icon: Icon(
                        Icons.edit,
                        size: screenWidth * 0.05,
                      ),
                      onSelected: (Menu item) {
                        if (item == Menu.edit) {
                          showUpdateProfileDialog(
                            childId,
                            name,
                            age,
                            gender,
                          );
                        }
                        if (item == Menu.delete) {
                          showDeleteConfirmationDialog(childId, name, () async {
                            await cloudStoreService.deleteChild(
                                userId: currentUser!, childId: childId);

                            if (!context.mounted) {
                              return;
                            }
                            showCustomSnackbar(context, 'Success'.tr,
                                'Child added successfully'.tr);
                            getData();
                          });
                        }
                      },
                      itemBuilder: (context) => <PopupMenuEntry<Menu>>[
                        PopupMenuItem<Menu>(
                          value: Menu.edit,
                          child: ListTile(
                            leading: Icon(Icons.edit, size: screenWidth * 0.03),
                            title: Text(
                              'Edit'.tr,
                              style: TextStyle(
                                fontSize: screenWidth * 0.03,
                              ),
                            ),
                          ),
                        ),
                        PopupMenuItem<Menu>(
                          value: Menu.delete,
                          child: ListTile(
                            leading:
                                Icon(Icons.delete, size: screenWidth * 0.03),
                            title: Text(
                              'Delete'.tr,
                              style: TextStyle(
                                fontSize: screenWidth * 0.03,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: Text(
              name,
              style: TextStyle(
                color: Colors.black,
                fontSize: screenWidth * 0.05,
              ),
              overflow: TextOverflow.ellipsis, // Handle overflow
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double fabSize =
        screenWidth * 0.15; // Adjust the FAB size based on screen width

    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButton: SizedBox(
        width: fabSize,
        height: fabSize,
        child: FloatingActionButton(
          onPressed: () {
            showAddProfileDialog();
          },
          backgroundColor: const Color(0xFFF7CBC8),
          shape: const CircleBorder(),
          splashColor: const Color(0xFFF7CBEF),
          child: Icon(Icons.person_add, size: fabSize * 0.5),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Stack(
        children: [
          Image.asset(
            'assets/images/homepage2.png',
            height: double.infinity,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Choose Profile'.tr,
                    style: TextStyle(
                      color: const Color(0xff309092),
                      fontSize: screenWidth * 0.1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            backgroundColor: Colors.black.withOpacity(0.2),
                            color: const Color(0xFFF7CBC8),
                          ),
                        )
                      : profileList.isEmpty
                          ? Center(
                              child: Text('Create your child profile!'.tr,
                                  style:
                                      TextStyle(fontSize: screenWidth * 0.05)),
                            )
                          : Expanded(
                              child: GridView.count(
                                crossAxisCount: 3,
                                crossAxisSpacing: screenWidth * 0.05,
                                mainAxisSpacing: screenWidth * 0.05,
                                children: profileList
                                    .map((e) => buildProfileList(e['childId'],
                                        e['name'], e['gender'], e['age']))
                                    .toList(),
                              ),
                            ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
