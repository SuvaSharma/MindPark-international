import 'package:flutter/material.dart';

import '../core/constants.dart';

class RegisterButton extends StatelessWidget {
  const RegisterButton({
    super.key,
    required this.child,
    this.onPressed,
    this.isOutlined = false,
    this.color = const Color(0xff309092),
  });

  final Widget child;
  final VoidCallback? onPressed;
  final bool isOutlined;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            offset: const Offset(2, 2),
            color: isOutlined ? color : gray500,
          ),
        ],
        borderRadius: BorderRadius.circular(25),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isOutlined ? white : color,
          foregroundColor: isOutlined ? color : white,
          disabledBackgroundColor: gray300,
          disabledForegroundColor: gray300,
          side: BorderSide(color: isOutlined ? color : gray500),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 0,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: child,
      ),
    );
  }
}
