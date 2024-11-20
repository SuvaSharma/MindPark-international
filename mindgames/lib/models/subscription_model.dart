import 'package:cloud_firestore/cloud_firestore.dart';

class SubscriptionModel {
  String userId;
  String email;
  String name;
  String? billingAddress;

  String? planId;
  String? planName;
  String? planType;
  double? planPrice;
  int? planDuration;

  String? status;
  DateTime? startDate;
  DateTime? endDate;
  DateTime? nextBillingDate;
  bool? renewal;

  PaymentMethod? paymentMethod;
  List<Transaction>? transactionHistory;

  bool isTrial;
  DateTime? trialStartDate;
  DateTime? trialEndDate;

  String? discountCode;
  double? discountAmount;

  DateTime? cancellationDate;
  String? cancellationReason;

  SubscriptionModel({
    required this.userId,
    required this.email,
    required this.name,
    this.billingAddress,
    this.planId,
    this.planName,
    this.planType,
    this.planPrice,
    this.planDuration,
    this.status,
    this.startDate,
    this.endDate,
    this.nextBillingDate,
    this.renewal,
    this.paymentMethod,
    this.transactionHistory,
    this.isTrial = false,
    this.trialStartDate,
    this.trialEndDate,
    this.discountCode,
    this.discountAmount,
    this.cancellationDate,
    this.cancellationReason,
  });

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'email': email,
        'name': name,
        'billingAddress': billingAddress,
        'planId': planId,
        'planName': planName,
        'planType': planType,
        'planPrice': planPrice,
        'planDuration': planDuration,
        'status': status,
        'startDate': startDate,
        'endDate': endDate,
        'nextBillingDate': nextBillingDate,
        'renewal': renewal,
        'paymentMethod': paymentMethod?.toMap(), // Use `?.` to avoid null error
        'transactionHistory': transactionHistory
            ?.map((item) => item.toMap())
            .toList(), // Handle null
        'isTrial': isTrial,
        'trialStartDate': trialStartDate,
        'trialEndDate': trialEndDate,
        'discountCode': discountCode,
        'discountAmount': discountAmount,
        'cancellationDate': cancellationDate,
        'cancellationReason': cancellationReason,
      };

  factory SubscriptionModel.fromMap(Map<String, dynamic> map) {
    return SubscriptionModel(
      userId: map['userId'],
      email: map['email'],
      name: map['name'],
      billingAddress: map['billingAddress'],
      planId: map['planId'],
      planName: map['planName'],
      planType: map['planType'],
      planPrice: map['planPrice'],
      planDuration: map['planDuration'],
      status: map['status'],
      startDate: (map['startDate'] as Timestamp?)?.toDate(),
      endDate: (map['endDate'] as Timestamp?)?.toDate(),
      nextBillingDate: (map['nextBillingDate'] as Timestamp?)?.toDate(),
      renewal: map['renewal'],
      paymentMethod: map['paymentMethod'] != null
          ? PaymentMethod.fromMap(map['paymentMethod'] as Map<String, dynamic>)
          : null, // Handle null paymentMethod
      transactionHistory: (map['transactionHistory'] as List<dynamic>?)
          ?.map((item) => Transaction.fromMap(item as Map<String, dynamic>))
          .toList(), // Handle null transactionHistory
      isTrial: map['isTrial'],
      trialStartDate: (map['trialStartDate'] as Timestamp?)?.toDate(),
      trialEndDate: (map['trialEndDate'] as Timestamp?)?.toDate(),
      discountCode: map['discountCode'],
      discountAmount: map['discountAmount'],
      cancellationDate: (map['cancellationDate'] as Timestamp?)?.toDate(),
      cancellationReason: map['cancellationReason'],
    );
  }
}

class PaymentMethod {
  String methodType;
  String paymentStatus;
  String? transactionId;

  PaymentMethod({
    required this.methodType,
    required this.paymentStatus,
    this.transactionId,
  });

  Map<String, dynamic> toMap() => {
        'methodType': methodType,
        'paymentStatus': paymentStatus,
        'transactionId': transactionId,
      };

  factory PaymentMethod.fromMap(Map<String, dynamic> map) => PaymentMethod(
        methodType: map['methodType'],
        paymentStatus: map['paymentStatus'],
        transactionId: map['transactionId'],
      );
}

class Transaction {
  String invoiceId;
  DateTime invoiceDate;
  double amount;
  DateTime dueDate;

  Transaction({
    required this.invoiceId,
    required this.invoiceDate,
    required this.amount,
    required this.dueDate,
  });

  Map<String, dynamic> toMap() => {
        'invoiceId': invoiceId,
        'invoiceDate': invoiceDate,
        'amount': amount,
        'dueDate': dueDate,
      };

  factory Transaction.fromMap(Map<String, dynamic> map) => Transaction(
        invoiceId: map['invoiceId'],
        invoiceDate: (map['invoiceDate'] as Timestamp).toDate(),
        amount: map['amount'],
        dueDate: (map['dueDate'] as Timestamp).toDate(),
      );
}
