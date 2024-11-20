import 'package:mindgames/models/language_model.dart';

class AppConstants {
  static const String COUNTRY_CODE = 'country_code';
  static const String LANGUAGE_CODE = 'language_code';

  static List<LanguageModel> languages = [
    LanguageModel(
        imageURL: "en.png",
        languageName: 'English',
        countryCode: 'US',
        languageCode: 'en'),
    LanguageModel(
        imageURL: "ne.png",
        languageName: 'नेपाली',
        languageCode: 'ne',
        countryCode: 'NP')
  ];
}
