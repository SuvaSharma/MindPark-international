import 'package:flutter/material.dart';

class RegisterFormField extends StatelessWidget {
  const RegisterFormField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.validator,
    this.onChanged,
    this.autofocus = false,
    this.filled,
    this.fillColor,
    this.suffixIcon,
    this.obscureText = false,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
    this.keyboardType,
    this.readOnly = false,
    this.borderColor = const Color(0xff309092),
  });

  final TextEditingController? controller;
  final String? hintText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool autofocus;
  final bool? filled;
  final Color? fillColor;
  final String? labelText;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextCapitalization textCapitalization;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final bool readOnly;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return TextFormField(
      key: key,
      controller: controller,
      autofocus: autofocus,
      readOnly: readOnly,
      enabled: !readOnly,
      cursorColor: borderColor,
      style: TextStyle(fontSize: screenWidth * 0.04),
      decoration: InputDecoration(
          floatingLabelBehavior: FloatingLabelBehavior.always,
          hintText: hintText,
          hintStyle: TextStyle(fontSize: screenWidth * 0.04),
          labelText: labelText,
          errorStyle: TextStyle(fontSize: screenWidth * 0.04),
          labelStyle: TextStyle(
            fontSize: screenWidth * 0.04,
            color: borderColor,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.02,
            vertical: screenHeight * 0.02,
          ),
          isDense: true,
          filled: filled,
          fillColor: fillColor,
          suffixIcon: suffixIcon,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide(color: borderColor),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: const BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: const BorderSide(color: Colors.red),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: const BorderSide(color: Colors.grey),
          )),
      validator: validator,
      onChanged: onChanged,
      obscureText: obscureText,
      textCapitalization: textCapitalization,
      textInputAction: textInputAction,
      keyboardType: keyboardType,
    );
  }
}
