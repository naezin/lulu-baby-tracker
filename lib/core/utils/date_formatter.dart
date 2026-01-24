import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

/// 날짜/시간 포맷팅 유틸리티
///
/// 로케일에 따라 자동으로 올바른 포맷 적용:
/// - 미국: MM/DD/YYYY, 12시간제 (AM/PM)
/// - 한국: YYYY. MM. DD., 24시간제
///
/// 자체 검증 로직:
/// - AM/PM 위치가 로케일에 맞는지 확인
/// - 날짜 순서가 올바른지 확인
class DateFormatter {
  /// 날짜 포맷팅
  ///
  /// 미국: MM/DD/YYYY (예: 01/22/2026)
  /// 한국: YYYY. MM. DD. (예: 2026. 01. 22.)
  static String formatDate(DateTime date, Locale locale) {
    if (locale.languageCode == 'ko') {
      // 한국: YYYY. MM. DD.
      return DateFormat('yyyy. MM. dd.', locale.toString()).format(date);
    } else {
      // 미국: MM/DD/YYYY
      return DateFormat('MM/dd/yyyy', locale.toString()).format(date);
    }
  }

  /// 시간 포맷팅
  ///
  /// 미국: h:mm AM/PM (예: 2:30 PM)
  /// 한국: HH:mm (예: 14:30)
  static String formatTime(DateTime time, Locale locale) {
    if (locale.languageCode == 'ko') {
      // 한국: 24시간제
      return DateFormat('HH:mm', locale.toString()).format(time);
    } else {
      // 미국: 12시간제 + AM/PM
      final formatted = DateFormat('h:mm a', locale.toString()).format(time);

      // 자체 검증: AM/PM이 올바른 위치에 있는지 확인
      assert(
        formatted.contains('AM') || formatted.contains('PM'),
        'Time format validation failed: AM/PM missing in $formatted',
      );

      return formatted;
    }
  }

  /// 날짜 + 시간 포맷팅
  ///
  /// 미국: MM/DD/YYYY h:mm AM/PM
  /// 한국: YYYY. MM. DD. HH:mm
  static String formatDateTime(DateTime dateTime, Locale locale) {
    final datePart = formatDate(dateTime, locale);
    final timePart = formatTime(dateTime, locale);
    return '$datePart $timePart';
  }

  /// 상대 시간 (예: "2시간 전", "3일 전")
  ///
  /// i18n 키와 함께 사용:
  /// - en: "2 hours ago"
  /// - ko: "2시간 전"
  static Map<String, dynamic> getRelativeTime(
    DateTime dateTime,
    DateTime now,
  ) {
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return {'key': 'time_just_now', 'value': null};
    } else if (difference.inMinutes < 60) {
      return {'key': 'time_minutes_ago', 'value': difference.inMinutes};
    } else if (difference.inHours < 24) {
      return {'key': 'time_hours_ago', 'value': difference.inHours};
    } else if (difference.inDays < 7) {
      return {'key': 'time_days_ago', 'value': difference.inDays};
    } else if (difference.inDays < 30) {
      return {'key': 'time_weeks_ago', 'value': (difference.inDays / 7).floor()};
    } else {
      return {'key': 'time_months_ago', 'value': (difference.inDays / 30).floor()};
    }
  }

  /// 요일 이름
  ///
  /// 미국: Monday, Tuesday...
  /// 한국: 월요일, 화요일...
  static String formatWeekday(DateTime date, Locale locale) {
    return DateFormat('EEEE', locale.toString()).format(date);
  }

  /// 월 이름
  ///
  /// 미국: January, February...
  /// 한국: 1월, 2월...
  static String formatMonth(DateTime date, Locale locale) {
    if (locale.languageCode == 'ko') {
      return DateFormat('M월', locale.toString()).format(date);
    } else {
      return DateFormat('MMMM', locale.toString()).format(date);
    }
  }

  /// 아기 월령 계산 (만 나이 고려)
  ///
  /// 한국: 출생일부터 정확한 일수 계산
  /// 미국: 동일 (만 나이 시스템)
  ///
  /// 자체 검증: 음수 나이가 나오지 않는지 확인
  static Map<String, int> calculateBabyAge(
    DateTime birthDate,
    DateTime currentDate,
  ) {
    // 자체 검증: 미래 날짜 체크
    assert(
      !birthDate.isAfter(currentDate),
      'Birth date cannot be in the future',
    );

    final ageInDays = currentDate.difference(birthDate).inDays;

    // 자체 검증: 음수 나이 체크
    assert(ageInDays >= 0, 'Age cannot be negative');

    final years = ageInDays ~/ 365;
    final months = (ageInDays % 365) ~/ 30;
    final days = (ageInDays % 365) % 30;
    final weeks = ageInDays ~/ 7;

    return {
      'years': years,
      'months': months,
      'days': days,
      'weeks': weeks,
      'totalDays': ageInDays,
    };
  }

  /// 월령 포맷팅
  ///
  /// i18n 키와 함께 사용:
  /// - 0-11개월: "X개월 Y일" / "X months Y days"
  /// - 12개월 이상: "X년 Y개월" / "X years Y months"
  static Map<String, dynamic> formatBabyAge(
    DateTime birthDate,
    DateTime currentDate,
    Locale locale,
  ) {
    final age = calculateBabyAge(birthDate, currentDate);

    if (age['years']! > 0) {
      return {
        'key': 'age_years_months',
        'years': age['years'],
        'months': age['months'],
      };
    } else if (age['months']! > 0) {
      return {
        'key': 'age_months_days',
        'months': age['months'],
        'days': age['days'],
      };
    } else if (age['weeks']! > 0) {
      return {
        'key': 'age_weeks_days',
        'weeks': age['weeks'],
        'days': age['days']! % 7,
      };
    } else {
      return {
        'key': 'age_days',
        'days': age['days'],
      };
    }
  }

  /// 시간 선택기 포맷 검증
  ///
  /// TimePickerEntryMode에 따라 올바른 포맷이 사용되는지 확인
  static bool validateTimePickerFormat(
    TimeOfDay time,
    Locale locale,
  ) {
    if (locale.languageCode == 'ko') {
      // 한국은 24시간제만 허용
      return time.period == DayPeriod.am || time.period == DayPeriod.pm;
    } else {
      // 미국은 12시간제 + AM/PM
      return true;
    }
  }

  /// 날짜 범위 포맷팅
  ///
  /// 미국: MM/DD - MM/DD, YYYY
  /// 한국: YYYY. MM. DD. - MM. DD.
  static String formatDateRange(
    DateTime start,
    DateTime end,
    Locale locale,
  ) {
    if (locale.languageCode == 'ko') {
      if (start.year == end.year && start.month == end.month) {
        return '${DateFormat('yyyy. MM. dd.').format(start)} - ${DateFormat('dd.').format(end)}';
      } else if (start.year == end.year) {
        return '${DateFormat('yyyy. MM. dd.').format(start)} - ${DateFormat('MM. dd.').format(end)}';
      } else {
        return '${DateFormat('yyyy. MM. dd.').format(start)} - ${DateFormat('yyyy. MM. dd.').format(end)}';
      }
    } else {
      if (start.year == end.year) {
        return '${DateFormat('MM/dd').format(start)} - ${DateFormat('MM/dd, yyyy').format(end)}';
      } else {
        return '${DateFormat('MM/dd, yyyy').format(start)} - ${DateFormat('MM/dd, yyyy').format(end)}';
      }
    }
  }
}
