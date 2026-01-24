import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Unit preferences for temperature, weight, and volume
class UnitPreferencesProvider extends ChangeNotifier {
  // Temperature unit: 'celsius' or 'fahrenheit'
  String _temperatureUnit = 'celsius';

  // Weight unit: 'kg' or 'lb'
  String _weightUnit = 'kg';

  // Volume unit: 'ml' or 'oz'
  String _volumeUnit = 'ml';

  String get temperatureUnit => _temperatureUnit;
  String get weightUnit => _weightUnit;
  String get volumeUnit => _volumeUnit;

  bool get isCelsius => _temperatureUnit == 'celsius';
  bool get isFahrenheit => _temperatureUnit == 'fahrenheit';
  bool get isKg => _weightUnit == 'kg';
  bool get isLb => _weightUnit == 'lb';
  bool get isMl => _volumeUnit == 'ml';
  bool get isOz => _volumeUnit == 'oz';

  UnitPreferencesProvider() {
    _loadPreferences();
  }

  /// Load saved preferences
  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _temperatureUnit = prefs.getString('temperature_unit') ?? 'celsius';
      _weightUnit = prefs.getString('weight_unit') ?? 'kg';
      _volumeUnit = prefs.getString('volume_unit') ?? 'ml';
      notifyListeners();
    } catch (e) {
      // Use defaults on error
    }
  }

  /// Set temperature unit
  Future<void> setTemperatureUnit(String unit) async {
    if (_temperatureUnit == unit) return;
    _temperatureUnit = unit;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('temperature_unit', unit);
    } catch (e) {
      // Ignore error
    }
  }

  /// Set weight unit
  Future<void> setWeightUnit(String unit) async {
    if (_weightUnit == unit) return;
    _weightUnit = unit;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('weight_unit', unit);
    } catch (e) {
      // Ignore error
    }
  }

  /// Set volume unit
  Future<void> setVolumeUnit(String unit) async {
    if (_volumeUnit == unit) return;
    _volumeUnit = unit;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('volume_unit', unit);
    } catch (e) {
      // Ignore error
    }
  }

  // Conversion utilities

  /// Convert Celsius to Fahrenheit
  double celsiusToFahrenheit(double celsius) {
    return (celsius * 9 / 5) + 32;
  }

  /// Convert Fahrenheit to Celsius
  double fahrenheitToCelsius(double fahrenheit) {
    return (fahrenheit - 32) * 5 / 9;
  }

  /// Convert kg to lb
  double kgToLb(double kg) {
    return kg * 2.20462;
  }

  /// Convert lb to kg
  double lbToKg(double lb) {
    return lb / 2.20462;
  }

  /// Convert ml to oz
  double mlToOz(double ml) {
    return ml * 0.033814;
  }

  /// Convert oz to ml
  double ozToMl(double oz) {
    return oz / 0.033814;
  }

  /// Format temperature with current unit
  String formatTemperature(double tempInCelsius) {
    if (isCelsius) {
      return '${tempInCelsius.toStringAsFixed(1)}°C';
    } else {
      return '${celsiusToFahrenheit(tempInCelsius).toStringAsFixed(1)}°F';
    }
  }

  /// Format weight with current unit
  String formatWeight(double weightInKg) {
    if (isKg) {
      return '${weightInKg.toStringAsFixed(1)} kg';
    } else {
      return '${kgToLb(weightInKg).toStringAsFixed(1)} lb';
    }
  }

  /// Format volume with current unit
  String formatVolume(double volumeInMl) {
    if (isMl) {
      return '${volumeInMl.toStringAsFixed(1)} ml';
    } else {
      return '${mlToOz(volumeInMl).toStringAsFixed(1)} oz';
    }
  }
}
