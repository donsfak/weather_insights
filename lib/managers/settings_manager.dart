import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsManager {
  static final SettingsManager _instance = SettingsManager._internal();
  factory SettingsManager() => _instance;
  SettingsManager._internal();

  late SharedPreferences _prefs;

  final ValueNotifier<bool> isCelsius = ValueNotifier(true);
  final ValueNotifier<bool> notificationsEnabled = ValueNotifier(true);
  final ValueNotifier<List<String>> savedLocations = ValueNotifier([]);
  final ValueNotifier<Locale> locale = ValueNotifier(const Locale('en'));

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    isCelsius.value = _prefs.getBool('isCelsius') ?? true;
    notificationsEnabled.value = _prefs.getBool('notificationsEnabled') ?? true;
    savedLocations.value = _prefs.getStringList('savedLocations') ?? [];
    final langCode = _prefs.getString('languageCode') ?? 'en';
    locale.value = Locale(langCode);
  }

  Future<void> setLocale(Locale newLocale) async {
    locale.value = newLocale;
    await _prefs.setString('languageCode', newLocale.languageCode);
  }

  Future<void> toggleUnit() async {
    isCelsius.value = !isCelsius.value;
    await _prefs.setBool('isCelsius', isCelsius.value);
  }

  Future<void> toggleNotifications() async {
    notificationsEnabled.value = !notificationsEnabled.value;
    await _prefs.setBool('notificationsEnabled', notificationsEnabled.value);
  }

  Future<void> addLocation(String city) async {
    if (city.isEmpty) return;
    final currentList = List<String>.from(savedLocations.value);
    if (!currentList.contains(city)) {
      currentList.add(city);
      savedLocations.value = currentList;
      await _prefs.setStringList('savedLocations', currentList);
    }
  }

  Future<void> removeLocation(String city) async {
    final currentList = List<String>.from(savedLocations.value);
    if (currentList.contains(city)) {
      currentList.remove(city);
      savedLocations.value = currentList;
      await _prefs.setStringList('savedLocations', currentList);
    }
  }

  double convertTemp(double tempInCelsius) {
    if (isCelsius.value) return tempInCelsius;
    return (tempInCelsius * 9 / 5) + 32;
  }

  String get tempUnit => isCelsius.value ? "°C" : "°F";
  String get speedUnit => isCelsius.value ? "m/s" : "mph";

  double convertSpeed(double speedInMps) {
    if (isCelsius.value) return speedInMps;
    return speedInMps * 2.23694; // Convert m/s to mph
  }
}
