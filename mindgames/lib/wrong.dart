import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WrongAns extends StatelessWidget {
  const WrongAns({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 365,
        height: 350,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black, width: 3),
        ),
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
          Text(
            'Wrong Answer'.tr,
            style: const TextStyle(
              fontSize: 30,
              color: Colors.orange,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              'Guess Again'.tr,
              style: const TextStyle(
                fontSize: 20,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Image.asset(
            'assets/images/cryingbrain.png',
            height: 80,
          ),
          const SizedBox(
            height: 25,
          ),
          MaterialButton(
            elevation: 5,
            height: 50,
            minWidth: 150,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
              side: const BorderSide(color: Colors.black, width: 3),
            ),
            color: Colors.orange,
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'Try Again'.tr,
              style: const TextStyle(
                fontSize: 26,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
