import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @searchCity.
  ///
  /// In en, this message translates to:
  /// **'Search City...'**
  String get searchCity;

  /// No description provided for @enterCity.
  ///
  /// In en, this message translates to:
  /// **'Enter a city to discover the weather'**
  String get enterCity;

  /// No description provided for @feelsLike.
  ///
  /// In en, this message translates to:
  /// **'Feels like'**
  String get feelsLike;

  /// No description provided for @humidity.
  ///
  /// In en, this message translates to:
  /// **'Humidity'**
  String get humidity;

  /// No description provided for @wind.
  ///
  /// In en, this message translates to:
  /// **'Wind'**
  String get wind;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @savedLocations.
  ///
  /// In en, this message translates to:
  /// **'Saved Locations'**
  String get savedLocations;

  /// No description provided for @noSavedLocations.
  ///
  /// In en, this message translates to:
  /// **'No saved locations'**
  String get noSavedLocations;

  /// No description provided for @temperatureUnit.
  ///
  /// In en, this message translates to:
  /// **'Temperature Unit'**
  String get temperatureUnit;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get error;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @noConnection.
  ///
  /// In en, this message translates to:
  /// **'No Connection'**
  String get noConnection;

  /// No description provided for @pleaseEnterCity.
  ///
  /// In en, this message translates to:
  /// **'Please enter a city name'**
  String get pleaseEnterCity;

  /// No description provided for @map.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get map;

  /// No description provided for @layers.
  ///
  /// In en, this message translates to:
  /// **'Layers'**
  String get layers;

  /// No description provided for @precipitation.
  ///
  /// In en, this message translates to:
  /// **'Precipitation'**
  String get precipitation;

  /// No description provided for @temperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get temperature;

  /// No description provided for @weatherInsights.
  ///
  /// In en, this message translates to:
  /// **'Weather Insights'**
  String get weatherInsights;

  /// No description provided for @whatToWear.
  ///
  /// In en, this message translates to:
  /// **'What to Wear'**
  String get whatToWear;

  /// No description provided for @tShirt.
  ///
  /// In en, this message translates to:
  /// **'T-shirt'**
  String get tShirt;

  /// No description provided for @hat.
  ///
  /// In en, this message translates to:
  /// **'Hat'**
  String get hat;

  /// No description provided for @airQuality.
  ///
  /// In en, this message translates to:
  /// **'Air Quality'**
  String get airQuality;

  /// No description provided for @good.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get good;

  /// No description provided for @airQualityGoodDesc.
  ///
  /// In en, this message translates to:
  /// **'Air quality is good. Ideal for outdoor activities.'**
  String get airQualityGoodDesc;

  /// No description provided for @chanceOfRain.
  ///
  /// In en, this message translates to:
  /// **'Chance of rain'**
  String get chanceOfRain;

  /// No description provided for @radar.
  ///
  /// In en, this message translates to:
  /// **'Radar'**
  String get radar;

  /// No description provided for @hourlyForecast.
  ///
  /// In en, this message translates to:
  /// **'Hourly Forecast'**
  String get hourlyForecast;

  /// No description provided for @sevenDays.
  ///
  /// In en, this message translates to:
  /// **'7 days'**
  String get sevenDays;

  /// No description provided for @overcastClouds.
  ///
  /// In en, this message translates to:
  /// **'Overcast Clouds'**
  String get overcastClouds;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get sunday;

  /// No description provided for @uvIndex.
  ///
  /// In en, this message translates to:
  /// **'UV Index'**
  String get uvIndex;

  /// No description provided for @uvLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get uvLow;

  /// No description provided for @uvModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get uvModerate;

  /// No description provided for @uvHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get uvHigh;

  /// No description provided for @uvVeryHigh.
  ///
  /// In en, this message translates to:
  /// **'Very High'**
  String get uvVeryHigh;

  /// No description provided for @uvExtreme.
  ///
  /// In en, this message translates to:
  /// **'Extreme'**
  String get uvExtreme;

  /// No description provided for @uvRecLow.
  ///
  /// In en, this message translates to:
  /// **'No protection needed'**
  String get uvRecLow;

  /// No description provided for @uvRecModerate.
  ///
  /// In en, this message translates to:
  /// **'Wear sunscreen SPF 30+'**
  String get uvRecModerate;

  /// No description provided for @uvRecHigh.
  ///
  /// In en, this message translates to:
  /// **'SPF 30+, hat, sunglasses'**
  String get uvRecHigh;

  /// No description provided for @uvRecVeryHigh.
  ///
  /// In en, this message translates to:
  /// **'Extra protection required'**
  String get uvRecVeryHigh;

  /// No description provided for @uvRecExtreme.
  ///
  /// In en, this message translates to:
  /// **'Avoid sun exposure 10AM-4PM'**
  String get uvRecExtreme;

  /// No description provided for @heavyCoat.
  ///
  /// In en, this message translates to:
  /// **'Heavy coat'**
  String get heavyCoat;

  /// No description provided for @gloves.
  ///
  /// In en, this message translates to:
  /// **'Gloves'**
  String get gloves;

  /// No description provided for @scarf.
  ///
  /// In en, this message translates to:
  /// **'Scarf'**
  String get scarf;

  /// No description provided for @jacket.
  ///
  /// In en, this message translates to:
  /// **'Jacket'**
  String get jacket;

  /// No description provided for @longSleeves.
  ///
  /// In en, this message translates to:
  /// **'Long sleeves'**
  String get longSleeves;

  /// No description provided for @lightClothes.
  ///
  /// In en, this message translates to:
  /// **'Light clothes'**
  String get lightClothes;

  /// No description provided for @umbrella.
  ///
  /// In en, this message translates to:
  /// **'Umbrella'**
  String get umbrella;

  /// No description provided for @boots.
  ///
  /// In en, this message translates to:
  /// **'Boots'**
  String get boots;

  /// No description provided for @sunglasses.
  ///
  /// In en, this message translates to:
  /// **'Sunglasses'**
  String get sunglasses;

  /// No description provided for @windbreaker.
  ///
  /// In en, this message translates to:
  /// **'Windbreaker'**
  String get windbreaker;

  /// No description provided for @aqiGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get aqiGood;

  /// No description provided for @aqiFair.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get aqiFair;

  /// No description provided for @aqiModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get aqiModerate;

  /// No description provided for @aqiPoor.
  ///
  /// In en, this message translates to:
  /// **'Poor'**
  String get aqiPoor;

  /// No description provided for @aqiVeryPoor.
  ///
  /// In en, this message translates to:
  /// **'Very Poor'**
  String get aqiVeryPoor;

  /// No description provided for @aqiRecGood.
  ///
  /// In en, this message translates to:
  /// **'Air quality is good. Ideal for outdoor activities.'**
  String get aqiRecGood;

  /// No description provided for @aqiRecFair.
  ///
  /// In en, this message translates to:
  /// **'Air quality is acceptable. Sensitive groups should limit outdoor exposure.'**
  String get aqiRecFair;

  /// No description provided for @aqiRecModerate.
  ///
  /// In en, this message translates to:
  /// **'Reduce prolonged outdoor exertion. Sensitive groups should avoid outdoor activities.'**
  String get aqiRecModerate;

  /// No description provided for @aqiRecPoor.
  ///
  /// In en, this message translates to:
  /// **'Avoid outdoor activities. Everyone may experience health effects.'**
  String get aqiRecPoor;

  /// No description provided for @aqiRecVeryPoor.
  ///
  /// In en, this message translates to:
  /// **'Stay indoors. Air quality is hazardous to health.'**
  String get aqiRecVeryPoor;

  /// No description provided for @precipLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get precipLight;

  /// No description provided for @precipMod.
  ///
  /// In en, this message translates to:
  /// **'Mod'**
  String get precipMod;

  /// No description provided for @precipHeavy.
  ///
  /// In en, this message translates to:
  /// **'Heavy'**
  String get precipHeavy;

  /// No description provided for @precipStorm.
  ///
  /// In en, this message translates to:
  /// **'Storm'**
  String get precipStorm;

  /// No description provided for @advancedAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Advanced Analytics'**
  String get advancedAnalytics;

  /// No description provided for @multiParameterAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Multi-Parameter Analysis'**
  String get multiParameterAnalysis;

  /// No description provided for @noDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noDataAvailable;

  /// No description provided for @avgTemp.
  ///
  /// In en, this message translates to:
  /// **'Avg Temp'**
  String get avgTemp;

  /// No description provided for @avgHumidity.
  ///
  /// In en, this message translates to:
  /// **'Avg Humidity'**
  String get avgHumidity;

  /// No description provided for @avgWind.
  ///
  /// In en, this message translates to:
  /// **'Avg Wind'**
  String get avgWind;

  /// No description provided for @weatherRadar.
  ///
  /// In en, this message translates to:
  /// **'Weather Conditions Radar'**
  String get weatherRadar;

  /// No description provided for @pressure.
  ///
  /// In en, this message translates to:
  /// **'Pressure'**
  String get pressure;

  /// No description provided for @clouds.
  ///
  /// In en, this message translates to:
  /// **'Clouds'**
  String get clouds;

  /// No description provided for @dayVsNight.
  ///
  /// In en, this message translates to:
  /// **'Day vs Night Comparison'**
  String get dayVsNight;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get day;

  /// No description provided for @night.
  ///
  /// In en, this message translates to:
  /// **'Night'**
  String get night;

  /// No description provided for @precipitationForecast.
  ///
  /// In en, this message translates to:
  /// **'Precipitation Forecast'**
  String get precipitationForecast;

  /// No description provided for @likely.
  ///
  /// In en, this message translates to:
  /// **'Likely'**
  String get likely;

  /// No description provided for @veryLikely.
  ///
  /// In en, this message translates to:
  /// **'Very Likely'**
  String get veryLikely;

  /// No description provided for @temperatureHeatmap.
  ///
  /// In en, this message translates to:
  /// **'Temperature Heatmap (7 Days)'**
  String get temperatureHeatmap;

  /// No description provided for @temperatureScale.
  ///
  /// In en, this message translates to:
  /// **'Temperature Scale:'**
  String get temperatureScale;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @enableNotifications.
  ///
  /// In en, this message translates to:
  /// **'Enable Notifications'**
  String get enableNotifications;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
