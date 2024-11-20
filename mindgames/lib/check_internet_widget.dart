import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:mindgames/no_internet_page.dart';

class CheckInternetWidget extends StatelessWidget {
  const CheckInternetWidget({super.key, required this.onlinePage});
  final Widget onlinePage;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Connectivity().onConnectivityChanged,
      builder: (context, AsyncSnapshot<List<ConnectivityResult>> snapshot) {
        // sometimes the stream builder doesn't work with simulator so you can check this on real devices to get the right result
        print(snapshot.toString());
        if (snapshot.hasData) {
          List<ConnectivityResult>? result = snapshot.data;
          print(result);
          if (result![0] == ConnectivityResult.mobile) {
            return onlinePage;
          } else if (result[0] == ConnectivityResult.wifi) {
            return onlinePage;
          } else {
            return const NoInternetPage();
          }
        } else {
          return Center(
              child: CircularProgressIndicator(
                  backgroundColor: Colors.black.withOpacity(0.2),
                  color: const Color(0xFF309092)));
        }
      },
    );
  }
}
