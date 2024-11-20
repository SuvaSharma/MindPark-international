import 'package:mindgames/services/auth_service.dart';

class UserFeedback {
  UserFeedback({
    required this.text,
  }) : userEmail = AuthService.user!.email!;

  final String userEmail;
  final String text;

  @override
  String toString() {
    return 'User: $userEmail,\ntext: $text';
  }
}
