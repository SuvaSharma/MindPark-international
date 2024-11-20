import 'package:html/parser.dart';

String getImageURL(String content) {
  RegExp regExp = RegExp(r'data-orig-file="([^"]+)"');

  final match = regExp.firstMatch(content);

  if (match != null) {
    String imageUrl = match.group(1) ?? '';
    return imageUrl;
  } else {
    return '';
  }
}

String getNepaliContent(String text) {
  RegExp regExp = RegExp(
    r'<h1[^>]*>(.*?)<\/h1>',
    caseSensitive: false,
    dotAll: true,
  );

  var match = regExp.firstMatch(text);
  if (match != null) {
    String nepaliText = match.group(1) ?? '';
    return cleanText(nepaliText);
  } else {
    return '';
  }
}

String getEnglishTitle(String text) {
  RegExp regExp = RegExp(
    r'<h2[^>]*>(.*?)<\/h2>',
    caseSensitive: false,
    dotAll: true,
  );

  var match = regExp.firstMatch(text);
  if (match != null) {
    String englishTitle = match.group(1) ?? '';
    return cleanText(englishTitle);
  } else {
    return '';
  }
}

String getNepaliTitle(String text) {
  RegExp regExp = RegExp(
    r'<h3[^>]*>(.*?)<\/h3>',
    caseSensitive: false,
    dotAll: true,
  );

  var match = regExp.firstMatch(text);
  if (match != null) {
    String nepaliTitle = match.group(1) ?? '';
    return cleanText(nepaliTitle);
  } else {
    return '';
  }
}

String cleanText(String text) {
  final document = parse(text);
  String cleanedText = document.body?.text ?? '';
  return cleanedText.trim();
}

String removeFigureTag(String text) {
  final figureRegex =
      RegExp(r'<figure[^>]*>(<img[^>]*>).*?</figure>', multiLine: true);

  // Replace all <figure> tags with only the inner <img /> tag
  String modifiedContent = text.replaceAllMapped(figureRegex, (match) {
    return match.group(1) ?? '';
  });

  print(modifiedContent);
  return modifiedContent;
}
