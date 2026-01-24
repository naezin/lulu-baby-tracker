import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 로케일 및 단위 설정 관리자
///
/// 사용자의 언어 및 단위 시스템 설정을 관리하며,
/// 앱 전체에서 일관된 포맷팅을 제공합니다.
class LocaleManager extends ChangeNotifier {
  static const String _localeKey = 'app_locale';
  static const String _unitSystemKey = 'unit_system';

  Locale _locale = const Locale('en', 'US');
  UnitSystem _unitSystem = UnitSystem.imperial;

  Locale get locale => _locale;
  UnitSystem get unitSystem => _unitSystem;

  /// 지원되는 로케일 목록
  static const List<Locale> supportedLocales = [
    Locale('en', 'US'), // 미국 영어
    Locale('ko', 'KR'), // 한국어
  ];

  /// 초기화
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();

    // 저장된 로케일 불러오기
    final savedLocale = prefs.getString(_localeKey);
    if (savedLocale != null) {
      final parts = savedLocale.split('_');
      if (parts.length == 2) {
        _locale = Locale(parts[0], parts[1]);
      }
    }

    // 저장된 단위 시스템 불러오기
    final savedUnit = prefs.getString(_unitSystemKey);
    if (savedUnit != null) {
      _unitSystem = UnitSystem.values.firstWhere(
        (e) => e.toString() == savedUnit,
        orElse: () => _getDefaultUnitSystem(_locale),
      );
    } else {
      // 로케일에 따라 기본 단위 시스템 설정
      _unitSystem = _getDefaultUnitSystem(_locale);
    }

    notifyListeners();
  }

  /// 로케일에 따른 기본 단위 시스템
  UnitSystem _getDefaultUnitSystem(Locale locale) {
    // 미국은 Imperial, 한국은 Metric
    if (locale.countryCode == 'US') {
      return UnitSystem.imperial;
    }
    return UnitSystem.metric;
  }

  /// 로케일 변경
  Future<void> setLocale(Locale newLocale) async {
    if (_locale == newLocale) return;

    _locale = newLocale;

    // 로케일 변경 시 기본 단위도 변경할지 확인
    // (사용자가 수동으로 설정한 적 없으면 자동 변경)
    final prefs = await SharedPreferences.getInstance();
    final hasManualUnitSetting = prefs.containsKey(_unitSystemKey);

    if (!hasManualUnitSetting) {
      _unitSystem = _getDefaultUnitSystem(newLocale);
    }

    await prefs.setString(_localeKey, '${newLocale.languageCode}_${newLocale.countryCode}');
    notifyListeners();
  }

  /// 단위 시스템 변경
  Future<void> setUnitSystem(UnitSystem newSystem) async {
    if (_unitSystem == newSystem) return;

    _unitSystem = newSystem;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_unitSystemKey, newSystem.toString());
    notifyListeners();
  }

  /// 현재 로케일이 한국어인지
  bool get isKorean => _locale.languageCode == 'ko';

  /// 현재 로케일이 영어(미국)인지
  bool get isEnglishUS => _locale.languageCode == 'en' && _locale.countryCode == 'US';

  /// 현재 단위 시스템이 Metric인지
  bool get isMetric => _unitSystem == UnitSystem.metric;

  /// 현재 단위 시스템이 Imperial인지
  bool get isImperial => _unitSystem == UnitSystem.imperial;
}

/// 단위 시스템
enum UnitSystem {
  metric,   // kg, cm, ℃, ml
  imperial, // lb, in, ℉, oz
}
