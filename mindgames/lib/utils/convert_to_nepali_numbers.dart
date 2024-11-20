import 'package:get/get.dart';

String convertToNepaliNumbers(String input) {
  // Convert each character in the input string
  String result = input.split('').map((char) {
    // If the character is a digit, replace it with the corresponding Nepali numeral
    // Otherwise, keep the character as is
    return char.tr;
  }).join('');

  return result;
}
