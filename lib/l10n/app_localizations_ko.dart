// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appName => '루루';

  @override
  String get appTagline => 'AI 기반 아기 수면 동반자';

  @override
  String get tabHome => '홈';

  @override
  String get tabSleep => '수면';

  @override
  String get tabAnalytics => '분석';

  @override
  String get tabChat => 'AI 채팅';

  @override
  String get tabSettings => '설정';

  @override
  String get navHome => '홈';

  @override
  String get navRecords => '기록';

  @override
  String get navInsights => '인사이트';

  @override
  String get navSettings => '설정';

  @override
  String get navStats => '통계';

  @override
  String get homeTitle => '다시 오셨네요!';

  @override
  String get homeSubtitle => '아기의 일상 활동을 기록하세요';

  @override
  String get todaySummary => '오늘의 요약';

  @override
  String get sleepsToday => '수면';

  @override
  String get feedingsToday => '수유';

  @override
  String get diapersToday => '기저귀';

  @override
  String get quickActions => '빠른 작업';

  @override
  String get recentActivities => '최근 활동';

  @override
  String get seeAll => '모두 보기';

  @override
  String get sleep => '수면';

  @override
  String get feeding => '수유';

  @override
  String get diaper => '기저귀';

  @override
  String get health => '건강';

  @override
  String get play => '놀이';

  @override
  String get noRecords => '아직 기록이 없습니다';

  @override
  String get activityHistory => '활동 기록';

  @override
  String get viewAllRecordedActivities => '모든 기록된 활동 보기';

  @override
  String get settings => '설정';

  @override
  String get language => '언어';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageEnglishUS => '영어 (미국)';

  @override
  String get languageKorean => '한국어';

  @override
  String get languageKoreanKR => '한국어';

  @override
  String get units => '단위';

  @override
  String get temperature => '온도';

  @override
  String get weight => '무게';

  @override
  String get volume => '용량';

  @override
  String get unitCelsius => '℃';

  @override
  String get unitFahrenheit => '℉';

  @override
  String get unitKg => 'kg';

  @override
  String get unitLb => 'lb';

  @override
  String get unitMl => 'ml';

  @override
  String get unitOz => 'oz';

  @override
  String get notifications => '알림';

  @override
  String get sweetSpotAlerts => '스위트 스팟 알림';

  @override
  String notifyMeMinutesBefore(int minutes) {
    return '최적 수면 시간 $minutes분 전에 알림';
  }

  @override
  String get appUpdatesAndTips => '앱 업데이트 & 팁';

  @override
  String get receiveHelpfulTips => '유용한 육아 팁과 기능 업데이트 받기';

  @override
  String get markAllRead => '모두 읽음으로 표시';

  @override
  String get allNotificationsMarkedAsRead => '모든 알림을 읽음으로 표시했습니다';

  @override
  String get dataManagement => '데이터 관리';

  @override
  String get exportData => '데이터 내보내기';

  @override
  String get importData => '데이터 가져오기';

  @override
  String get exportToCSV => 'CSV 파일로 데이터 내보내기';

  @override
  String get importFromCSV => 'CSV 파일에서 데이터 가져오기';

  @override
  String get sweetSpotDemo => '스위트 스팟 데모';

  @override
  String get tryAISleepPredictionDemo => 'AI 수면 예측 데모 사용해보기';

  @override
  String get insights => '인사이트';

  @override
  String get week => '주간';

  @override
  String get month => '월간';

  @override
  String error(String message) {
    return '오류: $message';
  }

  @override
  String get aiCoachingTitle => 'AI 코칭 인사이트';

  @override
  String get aiCoachingAnalyzing => 'AI가 분석 중입니다...';

  @override
  String get aiCoachingEmpathy => '공감 메시지';

  @override
  String get aiCoachingInsight => '데이터 통찰';

  @override
  String get aiCoachingAction => '행동 지침';

  @override
  String get aiCoachingExpert => '전문가 조언';

  @override
  String get aiCoachingFeedbackQuestion => '도움이 되었나요?';

  @override
  String get aiCoachingFeedbackPositive => '도움됨';

  @override
  String get aiCoachingFeedbackNegative => '별로';

  @override
  String get aiCoachingFeedbackThanks => '피드백 감사합니다! 더 나은 조언을 위해 활용하겠습니다.';

  @override
  String get aiAnalysisAvailable => 'AI 분석 가능';

  @override
  String get tapChartForAnalysis => '차트를 탭하면 AI가 그 시간의 패턴을 분석해줍니다';

  @override
  String get criticalAlertTitle => '전문가 상담 권고';

  @override
  String get criticalAlertMessage =>
      '아기의 상태가 면밀한 관찰이 필요해 보입니다. 소아과 방문을 권장하며, 의사에게 보여줄 오늘의 리포트를 생성할 수 있습니다.';

  @override
  String get generatePDFReport => 'PDF 리포트 생성';

  @override
  String get longestSleepStretch => '가장 긴 수면 시간';

  @override
  String get hours => '시간';

  @override
  String get save => '저장';

  @override
  String get cancel => '취소';

  @override
  String get close => '닫기';

  @override
  String get confirm => '확인';

  @override
  String get edit => '수정';

  @override
  String get delete => '삭제';

  @override
  String get loading => '로딩 중...';

  @override
  String get retry => '다시 시도';
}
