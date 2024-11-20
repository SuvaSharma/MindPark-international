import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../core/constants.dart';

class RegisterIconButtonOutlined extends StatelessWidget {
  const RegisterIconButtonOutlined({
    required this.icon,
    required this.onPressed,
    super.key,
  });

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: FaIcon(icon),
      style: IconButton.styleFrom(
        backgroundColor: white,
        foregroundColor: black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(
            color: black,
          ),
        ),
      ),
    );
  }
}
