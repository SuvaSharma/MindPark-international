import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InternetController extends GetxController {
  Connectivity _connectivity = Connectivity();

  @override
  void onInit() {
    super.onInit();
    _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      final firstResult = result.first;
      Netstatus(firstResult);
    });
  }

  void Netstatus(ConnectivityResult cr) {
    if (cr == ConnectivityResult.none) {
      Get.rawSnackbar(
        title: 'No Internet',
        message: 'Connect to internet to proceed',
        icon: Icon(
          Icons.wifi_off,
          color: Colors.white,
        ),
        isDismissible: true,
        duration: Duration(days: 1),
        shouldIconPulse: true,
      );
    } else {
      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
      }
    }
  }
}
