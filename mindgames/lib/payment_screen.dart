// import 'package:flutter/material.dart';
// import 'package:mindgames/services/stripe_service.dart';

// class PaymentScreen extends StatefulWidget {
//   const PaymentScreen({super.key});

//   @override
//   State<PaymentScreen> createState() => _PaymentScreenState();
// }

// class _PaymentScreenState extends State<PaymentScreen> {
//   String selectedPlan = ''; // Store the selected plan
//   String amount = '900'; // Default to monthly subscription amount (NPR 900)
//   String currency = 'NPR'; // Change currency to NPR for your context

//   // Subscription plans
//   final Map<String, String> subscriptionPlans = {
//     'Monthly Subscription': '900', // Amount in your currency
//     '6-Month Subscription': '4500',
//     'Yearly Subscription': '8500',
//   };

//   void selectPlan(String plan) {
//     setState(() {
//       selectedPlan = plan;
//       amount =
//           subscriptionPlans[plan] ?? '900'; // Update amount based on selection
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final Size screenSize = MediaQuery.of(context).size;
//     final double screenHeight = screenSize.height;
//     final double screenWidth = screenSize.width;
//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           image: DecorationImage(
//             image: AssetImage("assets/images/levelscreen.png"),
//             fit: BoxFit.cover,
//           ),
//         ),
//         child: SafeArea(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               SizedBox(
//                 height: 100,
//               ),
//               Align(
//                   alignment: Alignment.topCenter,
//                   child: Text(
//                     'Your First 7 days are free!',
//                     style: TextStyle(
//                       fontSize: screenWidth * 0.07,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   )),
//               SizedBox(
//                 height: 5,
//               ),
//               Align(
//                   alignment: Alignment.topCenter,
//                   child: Text(
//                     'No Commitment, Cancel Anytime.',
//                     style: TextStyle(
//                       fontSize: screenWidth * 0.05,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   )),
//               SizedBox(
//                 height: 20,
//               ),
//               Expanded(
//                 child: ListView.builder(
//                   itemCount: subscriptionPlans.keys.length,
//                   itemBuilder: (context, index) {
//                     String plan = subscriptionPlans.keys.elementAt(index);
//                     return ListTile(
//                       title: Text(plan),
//                       subtitle: Text('Price: NPR ${subscriptionPlans[plan]}'),
//                       trailing: selectedPlan == plan
//                           ? const Icon(Icons.check, color: Colors.green)
//                           : null,
//                       onTap: () => selectPlan(plan),
//                     );
//                   },
//                 ),
//               ),
//               // Payment button
//               Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: ElevatedButton(
//                   onPressed: () async {
//                     if (selectedPlan.isNotEmpty) {
//                       try {
//                         await StripeService.initPaymentSheet(amount, currency);
//                         await StripeService.presentPaymentSheet();
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(content: Text('Payment successful!')),
//                         );
//                       } catch (e) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(content: Text("Error: ${e.toString()}")),
//                         );
//                       }
//                     } else {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(content: Text("Please select a plan")),
//                       );
//                     }
//                   },
//                   child: const Text('Pay Now'),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
