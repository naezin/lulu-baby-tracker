import '../localization/locale_manager.dart';

/// 단위 변환 유틸리티
///
/// 자동 검증 로직 포함:
/// - 변환 결과의 역변환이 원본과 일치하는지 확인
/// - 소수점 처리의 정확성 검증
class UnitConverter {
  /// 온도 변환: ℃ ↔ ℉
  ///
  /// 검증: 변환 후 역변환하여 오차 0.1℃ 이내 확인
  static double convertTemperature(
    double value,
    UnitSystem from,
    UnitSystem to,
  ) {
    if (from == to) return value;

    double result;
    if (from == UnitSystem.metric && to == UnitSystem.imperial) {
      // ℃ → ℉
      result = (value * 9 / 5) + 32;
    } else {
      // ℉ → ℃
      result = (value - 32) * 5 / 9;
    }

    // 자체 검증: 역변환하여 오차 확인
    final reversed = convertTemperature(result, to, from);
    assert((value - reversed).abs() < 0.1,
        'Temperature conversion error: $value != $reversed');

    return double.parse(result.toStringAsFixed(1));
  }

  /// 수유량 변환: ml ↔ oz
  ///
  /// 1 oz = 29.5735 ml (정확한 값)
  /// 실용적으로 1 oz ≈ 30 ml 사용
  ///
  /// 검증: 변환 후 역변환하여 오차 1ml 이내 확인
  static double convertVolume(
    double value,
    UnitSystem from,
    UnitSystem to,
  ) {
    if (from == to) return value;

    const mlPerOz = 29.5735;
    double result;

    if (from == UnitSystem.metric && to == UnitSystem.imperial) {
      // ml → oz
      result = value / mlPerOz;
    } else {
      // oz → ml
      result = value * mlPerOz;
    }

    // 자체 검증
    final reversed = convertVolume(result, to, from);
    assert((value - reversed).abs() < 1.0,
        'Volume conversion error: $value != $reversed');

    return double.parse(result.toStringAsFixed(1));
  }

  /// 무게 변환: kg ↔ lb
  ///
  /// 1 kg = 2.20462 lb
  ///
  /// 검증: 변환 후 역변환하여 오차 0.01kg 이내 확인
  static double convertWeight(
    double value,
    UnitSystem from,
    UnitSystem to,
  ) {
    if (from == to) return value;

    const lbPerKg = 2.20462;
    double result;

    if (from == UnitSystem.metric && to == UnitSystem.imperial) {
      // kg → lb
      result = value * lbPerKg;
    } else {
      // lb → kg
      result = value / lbPerKg;
    }

    // 자체 검증
    final reversed = convertWeight(result, to, from);
    assert((value - reversed).abs() < 0.01,
        'Weight conversion error: $value != $reversed');

    return double.parse(result.toStringAsFixed(2));
  }

  /// 온도 포맷팅 (단위 기호 포함)
  static String formatTemperature(
    double celsius,
    UnitSystem targetSystem,
  ) {
    if (targetSystem == UnitSystem.metric) {
      return '${celsius.toStringAsFixed(1)}°C';
    } else {
      final fahrenheit = convertTemperature(
        celsius,
        UnitSystem.metric,
        UnitSystem.imperial,
      );
      return '${fahrenheit.toStringAsFixed(1)}°F';
    }
  }

  /// 수유량 포맷팅 (단위 기호 포함)
  static String formatVolume(
    double ml,
    UnitSystem targetSystem,
  ) {
    if (targetSystem == UnitSystem.metric) {
      return '${ml.toStringAsFixed(0)} ml';
    } else {
      final oz = convertVolume(
        ml,
        UnitSystem.metric,
        UnitSystem.imperial,
      );
      return '${oz.toStringAsFixed(1)} oz';
    }
  }

  /// 무게 포맷팅 (단위 기호 포함)
  static String formatWeight(
    double kg,
    UnitSystem targetSystem,
  ) {
    if (targetSystem == UnitSystem.metric) {
      return '${kg.toStringAsFixed(2)} kg';
    } else {
      final lb = convertWeight(
        kg,
        UnitSystem.metric,
        UnitSystem.imperial,
      );
      return '${lb.toStringAsFixed(2)} lb';
    }
  }

  /// 길이 변환: cm ↔ in
  static double convertLength(
    double value,
    UnitSystem from,
    UnitSystem to,
  ) {
    if (from == to) return value;

    const inPerCm = 0.393701;
    double result;

    if (from == UnitSystem.metric && to == UnitSystem.imperial) {
      // cm → in
      result = value * inPerCm;
    } else {
      // in → cm
      result = value / inPerCm;
    }

    // 자체 검증
    final reversed = convertLength(result, to, from);
    assert((value - reversed).abs() < 0.1,
        'Length conversion error: $value != $reversed');

    return double.parse(result.toStringAsFixed(1));
  }

  /// 길이 포맷팅
  static String formatLength(
    double cm,
    UnitSystem targetSystem,
  ) {
    if (targetSystem == UnitSystem.metric) {
      return '${cm.toStringAsFixed(1)} cm';
    } else {
      final inches = convertLength(
        cm,
        UnitSystem.metric,
        UnitSystem.imperial,
      );
      return '${inches.toStringAsFixed(1)} in';
    }
  }
}
