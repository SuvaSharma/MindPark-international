import 'package:flutter/material.dart';

class ContainerData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Function(BuildContext) onTap;

  ContainerData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });
}
