// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_stripe/flutter_stripe.dart';
// import 'package:http/http.dart' as http;

// class StripeService {
//   static String apiBase = 'https://api.stripe.com/v1';
//   static String paymentApiUrl = '${StripeService.apiBase}/payment_intents';

//   // we will change this sectet key with our actual key once the account is made
//   static String secret =
//       'sk_test_51Q77eAKV8mQhJloFawwB7Q7j27rv8iWNHfEkT1DbI6uXm5n2YyBgkTQiI1HwCThsQ8Iiq8zwW834hFoDrZlDCcul00H95o3ReH';

//       //same goes with the publishable key
//   static String publishableKey =
//       'pk_test_51Q77eAKV8mQhJloFVnSuTx07Y8MpHFceGiYIj8mbsbKl2qbyBQEZ3xrYJhCUBrFzy7zemp403ChTHrVhoGVNowUy00fmssz5Si';

//   static Map<String, String> headers = {
//     "Authorization": 'Bearer ${StripeService.secret}',
//     'Content-Type': 'application/x-www-form-urlencoded'
//   };

//   // Initializing Stripe SDK with the publishable key
//   static init() {
//     Stripe.publishableKey = publishableKey;
//   }

//   // Creating payment intent on the Stripe API
//   static Future<Map<String, dynamic>> createPaymentIntent(
//       String amount, String currency) async {
//     try {
//       Map<String, dynamic> body = {
//         'amount': amount,
//         'currency': currency,
//         'payment_method_types[]': 'card',
//       };

//       var response = await http.post(
//         Uri.parse(StripeService.paymentApiUrl),
//         body: body,
//         headers: StripeService.headers,
//       );

//       return jsonDecode(response.body);
//     } catch (e) {
//       throw Exception("Failed to create payment intent");
//     }
//   }

//   // Initializing the payment sheet
//   static Future<void> initPaymentSheet(String amount, String currency) async {
//     try {
//       // Creating payment intent
//       final paymentIntent = await createPaymentIntent(amount, currency);

//       // Initializing the payment sheet but the initialization still fails (update it runs!)
//       await Stripe.instance.initPaymentSheet(
//         paymentSheetParameters: SetupPaymentSheetParameters(
//           paymentIntentClientSecret: paymentIntent['client_secret'],
//           merchantDisplayName: "MindPark Merchant Name",
//           style: ThemeMode.system,
//         ),
//       );
//     } catch (e) {
//       throw Exception("Failed to initialize payment sheet: ${e.toString()}");
//     }
//   }

//   // Presenting the payment sheet to the user 
//   static Future<void> presentPaymentSheet() async {
//     try {
//       await Stripe.instance.presentPaymentSheet();
//       print('Payment sheet presented');
//     } catch (e) {
//       throw Exception("Failed to present payment sheet: ${e.toString()}");
//     }
//   }
// }
