import 'dart:io';

import 'package:flutter/material.dart';
import 'package:rate_my_app/rate_my_app.dart';

class RateMyAppPage extends StatefulWidget {
  const RateMyAppPage({super.key});

  @override
  State<RateMyAppPage> createState() => _RateMyAppPageState();
}

class _RateMyAppPageState extends State<RateMyAppPage> {
  final RateMyApp rateMyApp = RateMyApp(
    minDays: 0,
    minLaunches: 1,

    remindDays: 3,
    remindLaunches: 2,

    googlePlayIdentifier: "com.whatsapp",
    //appStoreIdentifier: will use it when i implement mindpark in mac
  );

  @override
  void initState() {
    rateMyApp.init().then((_) {
      rateMyApp.conditions.forEach((condition) {
        if (condition is DebuggableCondition) {
          print(condition.toString());
        }
      });
      if (rateMyApp.shouldOpenDialog) {
        rateMyApp.showRateDialog(
          context,
          title: 'Rate Our App!',
          message: 'Like our app? Rate US!',
          rateButton: 'RATE',
          noButton: 'NO THANKS',
          laterButton: 'MAYBE LATER',
          dialogStyle: DialogStyle(titleStyle: TextStyle(color: Colors.green)),
          listener: (button) {
            switch (button) {
              case RateMyAppDialogButton.rate:
                print('Clicked on Rate');
                break;

              case RateMyAppDialogButton.later:
                print('Clicked on maybe later');
                break;

              case RateMyAppDialogButton.no:
                print('Clicked on No Thanks');
                break;
            }
            return true;
          },

          ignoreNativeDialog: true, // usually in default
          onDismissed: () =>
              rateMyApp.callEvent(RateMyAppEventType.laterButtonPressed),
        );
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
