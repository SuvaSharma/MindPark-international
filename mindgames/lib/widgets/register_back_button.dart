import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'register_icon_button_outlined.dart';

class RegisterBackButton extends StatelessWidget {
  const RegisterBackButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: RegisterIconButtonOutlined(
        icon: FontAwesomeIcons.chevronLeft,
        onPressed: () {
          Navigator.maybePop(context);
        },
      ),
    );
  }
}
