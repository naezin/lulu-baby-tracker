import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 언어 설정 Provider
class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('ko', '');

  Locale get locale => _locale;

  LocaleProvider() {
    _loadLocale();
  }

  /// 저장된 언어 설정 로드
  Future<void> _loadLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString('language_code') ?? 'ko';
      _locale = Locale(languageCode, '');
      notifyListeners();
    } catch (e) {
      // 오류 발생 시 기본값(한국어) 사용
      _locale = const Locale('ko', '');
    }
  }

  /// 언어 변경
  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;

    _locale = locale;
    notifyListeners();

    // SharedPreferences에 저장
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language_code', locale.languageCode);
    } catch (e) {
      // 오류 무시
    }
  }

  /// 영어로 변경
  Future<void> setEnglish() async {
    await setLocale(const Locale('en', ''));
  }

  /// 한국어로 변경
  Future<void> setKorean() async {
    await setLocale(const Locale('ko', ''));
  }

  /// 현재 언어가 한국어인지 확인
  bool get isKorean => _locale.languageCode == 'ko';

  /// 현재 언어가 영어인지 확인
  bool get isEnglish => _locale.languageCode == 'en';
}
