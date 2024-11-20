import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mindgames/adhdform.dart';
import 'package:mindgames/autismform.dart';
import 'package:mindgames/widgets/wrapper_widget.dart';

class FormPage extends StatefulWidget {
  const FormPage({super.key, Key? superkey});

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _leftAnimation;
  late Animation<Offset> _rightAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _leftAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _rightAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    final double containerWidth = screenSize.width * 0.5;
    final double containerHeight = screenSize.height * 0.25;
    final double topPadding = screenSize.height * 0.15;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainWrapper()),
        );
        return false;
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/levelscreen.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: screenSize.height * 0.01,
                  ),
                  child: Text('Choose a questionnaire'.tr,
                      style: TextStyle(
                        fontSize: screenSize.width * 0.07,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF309092),
                      )),
                ),
                SlideTransition(
                  position: _leftAnimation,
                  child: Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: EdgeInsets.only(top: topPadding),
                      child: Material(
                        elevation: 15,
                        borderRadius: BorderRadius.circular(25),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Autism(),
                              ),
                            );
                          },
                          child: Container(
                            width: containerWidth,
                            // height: containerHeight,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF37B197),
                                  Color(0xFF309092),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: const Color(0xFF309092),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 10,
                                  offset: Offset(0.5, -5),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(25),
                                    topRight: Radius.circular(25),
                                  ),
                                  child: Image.asset(
                                    'assets/images/asd.png',
                                    height: containerHeight * 0.7,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Text(
                                  "Autism".tr,
                                  style: TextStyle(
                                    fontSize: screenSize.width * 0.055,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: containerWidth * 0.025),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Icon(
                                        Icons.watch_later,
                                        color: Colors.white,
                                        size: screenSize.width * 0.05,
                                      ),
                                      Text(
                                        "5 mins".tr,
                                        style: TextStyle(
                                          fontSize: screenSize.width * 0.05,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenSize.height * 0.05),
                SlideTransition(
                  position: _rightAnimation,
                  child: Align(
                    alignment: Alignment.center,
                    child: Material(
                      elevation: 15,
                      borderRadius: BorderRadius.circular(25),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const ADHD()));
                        },
                        child: Container(
                          width: containerWidth,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF37B197),
                                Color(0xFF309092),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: Color(0xFF309092),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 10,
                                offset: Offset(0.5, -5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(25),
                                  topRight: Radius.circular(25),
                                ),
                                child: Image.asset(
                                  'assets/images/adhd.jpg',
                                  height: containerHeight * 0.7,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Text(
                                "ADHD".tr,
                                style: TextStyle(
                                  fontSize: screenSize.width * 0.055,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: containerWidth * 0.025),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Icon(
                                      Icons.watch_later,
                                      color: Colors.white,
                                      size: screenSize.width * 0.05,
                                    ),
                                    Text(
                                      "5 mins".tr,
                                      style: TextStyle(
                                        fontSize: screenSize.width * 0.05,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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
