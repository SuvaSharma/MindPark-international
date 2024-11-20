import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindgames/models/subscription_model.dart';
import 'child.dart';

final selectedChildDataProvider = StateProvider<Child?>((ref) => null);

final selectedSubscriptionDataProvider =
    StateProvider<SubscriptionModel?>((ref) => null);
