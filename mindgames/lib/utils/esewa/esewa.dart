// import 'package:esewa_flutter_sdk/esewa_config.dart';
// import 'package:esewa_flutter_sdk/esewa_flutter_sdk.dart';
// import 'package:esewa_flutter_sdk/esewa_payment.dart';
// import 'package:esewa_flutter_sdk/esewa_payment_success_result.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:mindgames/utils/esewa/esewaid.dart';
// import 'package:mindgames/utils/handle_payment.dart';

// class Esewa {
//   final Function(String, String) showSnackbar;

//   Esewa({required this.showSnackbar});

//   pay() {
//     try {
//       EsewaFlutterSdk.initPayment(
//         esewaConfig: EsewaConfig(
//           environment: Environment.test,
//           clientId: kEsewaClientId,
//           secretId: kEsewaSecretKey,
//         ),
//         esewaPayment: EsewaPayment(
//           productId: "1d71jd81",
//           productName: "Product One",
//           productPrice: "1000",
//           callbackUrl: '',
//         ),
//         onPaymentSuccess: (EsewaPaymentSuccessResult result) {
//           debugPrint('SUCCESS');
//           showSnackbar('Success'.tr, 'Payment successful!'.tr);
//           verify(result);
//         },
//         onPaymentFailure: () {
//           debugPrint('FAILURE');
//           showSnackbar('Failure'.tr, 'Payment failed!'.tr);
//         },
//         onPaymentCancellation: () {
//           debugPrint('CANCEL');
//           showSnackbar('Failure'.tr, 'Payment cancelled!'.tr);
//         },
//       );
//     } catch (e) {
//       debugPrint('EXCEPTION');
//       showSnackbar(
//           'Failure'.tr, 'An error occurred during payment processing.'.tr);
//     }
//   }

//   void verify(EsewaPaymentSuccessResult result) async {
//     if (result.status == 'COMPLETE') {
//       handlePaymentAction();
//     }
//   }
// }
