import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindgames/cloud_store_service.dart';
import 'package:mindgames/models/subscription_model.dart';
import 'package:mindgames/providers.dart';
import 'package:mindgames/services/auth_service.dart';

void handlePaymentAction() {
  DateTime now = DateTime.now();
  CloudStoreService cloudStoreService = CloudStoreService();

  final userId = AuthService.user?.uid;
  final email = AuthService.user?.email;
  final name = AuthService.user?.displayName;

  const planId = 'ABCDEF';
  const planName = 'Basic';
  const planType = 'Monthly';
  const planPrice = 29.99;
  const planDuration = 6;
  const status = 'Active';
  final startDate = DateTime(now.year, now.month, now.day);
  final endDate = DateTime(now.year, now.month + planDuration, now.day);
  final nextBillingDate =
      DateTime(now.year, now.month + planDuration, now.day + 1);
  const renewal = true;
  final paymentMethod = PaymentMethod(
      methodType: 'Visa', paymentStatus: 'paid', transactionId: 'ABCDE');
  List<Transaction> transactionHistory = [
    Transaction(
      invoiceId: 'INV12348',
      invoiceDate: startDate,
      amount: planPrice,
      dueDate: endDate,
    )
  ];
  cloudStoreService.addOrUpdateSubscriptionData(SubscriptionModel(
    userId: userId!,
    email: email!,
    name: name!,
    planId: planId,
    planName: planName,
    planType: planType,
    planPrice: planPrice,
    planDuration: planDuration,
    status: status,
    startDate: startDate,
    endDate: endDate,
    nextBillingDate: nextBillingDate,
    renewal: renewal,
    paymentMethod: paymentMethod,
    transactionHistory: transactionHistory,
  ));
  log("Transaction verified");
}

Future<void> handleTrialAction() async {
  DateTime now = DateTime.now();
  CloudStoreService cloudStoreService = CloudStoreService();

  final userId = AuthService.user?.uid;
  final email = AuthService.user?.email;
  final name = AuthService.user?.displayName;

  const isTrial = true;
  final trialStartDate = DateTime(now.year, now.month, now.day);
  final trialEndDate = DateTime(now.year, now.month, now.day + 7);

  await cloudStoreService.addOrUpdateSubscriptionData(SubscriptionModel(
    userId: userId!,
    email: email!,
    name: name!,
    isTrial: isTrial,
    trialStartDate: trialStartDate,
    trialEndDate: trialEndDate,
  ));
}

Future<bool> isPremium() async {
  final container = ProviderContainer();

  final count = container.read(selectedSubscriptionDataProvider);

  log('The current count is: $count');
  return true;
}
