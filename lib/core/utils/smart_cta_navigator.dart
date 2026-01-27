import 'package:flutter/material.dart';
import '../../data/models/activity_model.dart';
import '../../presentation/screens/activities/log_feeding_screen.dart';
import '../../presentation/screens/activities/log_diaper_screen.dart';
import '../../presentation/screens/activities/log_play_screen.dart';
import '../../presentation/screens/analysis/analysis_screen.dart';

/// 🎯 SmartCTANavigator - Smart CTA 버튼 내비게이션 로직
///
/// **목적**: CelebrationFeedback의 Smart CTA 버튼 클릭 시
/// 활동 타입에 따라 다음 권장 화면으로 내비게이션
///
/// **사용 예시**:
/// ```dart
/// SmartCTANavigator.navigateToNext(
///   context: context,
///   currentActivityType: ActivityType.sleep,
/// );
/// ```
class SmartCTANavigator {
  /// 🎯 다음 권장 화면으로 내비게이션
  ///
  /// **내비게이션 규칙**:
  /// - sleep → feeding (깨어난 후 배고픔)
  /// - feeding → diaper (수유 후 배변)
  /// - diaper → play (기저귀 갈고 활동)
  /// - play → feeding (활동 후 배고픔)
  /// - health → analysis (건강 기록 후 분석 보기)
  ///
  /// pushReplacement 사용하여 백 버튼으로 CelebrationFeedback으로 돌아가지 않도록 함
  static void navigateToNext({
    required BuildContext context,
    required ActivityType currentActivityType,
  }) {
    final nextScreen = _getNextScreen(currentActivityType);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => nextScreen),
    );
  }

  /// 🗺️ 다음 화면 위젯 반환
  static Widget _getNextScreen(ActivityType currentType) {
    switch (currentType) {
      case ActivityType.sleep:
        // 수면 → 수유 (깨어난 후 배고플 수 있음)
        return const LogFeedingScreen();

      case ActivityType.feeding:
        // 수유 → 기저귀 (수유 후 배변 확인)
        return const LogDiaperScreen();

      case ActivityType.diaper:
        // 기저귀 → 놀이 (기저귀 갈고 즐거운 시간)
        return const LogPlayScreen();

      case ActivityType.play:
        // 놀이 → 수유 (활동 후 배고플 수 있음)
        return const LogFeedingScreen();

      case ActivityType.health:
        // 건강 → 분석 화면 (기록 확인)
        return const AnalysisScreen();
    }
  }

  /// 📝 다음 액션 설명 텍스트 반환 (디버깅용)
  static String getNextActionDescription({
    required ActivityType currentType,
    required bool isKorean,
  }) {
    switch (currentType) {
      case ActivityType.sleep:
        return isKorean ? '수유 기록하기' : 'Log Feeding';

      case ActivityType.feeding:
        return isKorean ? '기저귀 확인하기' : 'Check Diaper';

      case ActivityType.diaper:
        return isKorean ? '놀이 시간 기록하기' : 'Log Play Time';

      case ActivityType.play:
        return isKorean ? '수유 기록하기' : 'Log Feeding';

      case ActivityType.health:
        return isKorean ? '분석 화면 보기' : 'View Analysis';
    }
  }

  /// 💡 다음 액션 이유 설명 반환 (CelebrationFeedback에서 사용)
  static String getNextActionReason({
    required ActivityType currentType,
    required bool isKorean,
  }) {
    switch (currentType) {
      case ActivityType.sleep:
        return isKorean ? '방금 일어났으니 배가 고플 수 있어요' : 'Baby might be hungry after waking up';

      case ActivityType.feeding:
        return isKorean ? '수유 후에는 기저귀를 확인해주세요' : 'Check diaper after feeding';

      case ActivityType.diaper:
        return isKorean ? '기저귀를 갈고 즐거운 시간을 보내세요' : 'Enjoy playtime after diaper change';

      case ActivityType.play:
        return isKorean ? '활동 후에는 배가 고플 수 있어요' : 'Baby might be hungry after playing';

      case ActivityType.health:
        return isKorean ? '오늘의 기록을 한눈에 확인해보세요' : 'Check today\'s records at a glance';
    }
  }
}
