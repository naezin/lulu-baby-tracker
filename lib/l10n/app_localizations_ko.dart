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

  @override
  String get actionZoneCardTitle => '지금 뭘 하면 좋을까요?';

  @override
  String get actionZoneNoDataMessage => '수면을 기록하면 추천을 받을 수 있어요';

  @override
  String get actionZoneSweetSpotPassedMessage => '스위트 스팟 지났어요 - 지금 재우세요!';

  @override
  String get actionZoneSweetSpotNowMessage => '지금이 재우기 딱 좋은 시간이에요!';

  @override
  String get actionZoneSweetSpotUpcomingMessage => '이 시간까지 재우면 좋아요';

  @override
  String get actionZoneSleepNowButton => '지금 재우기';

  @override
  String get actionZoneSetAlarmButton => '알림 설정';

  @override
  String get todaysSnapshotTitle => '오늘의 스냅샷';

  @override
  String get todaysSnapshotSleep => '수면';

  @override
  String get todaysSnapshotTotalTime => '총 시간';

  @override
  String get todaysSnapshotFeeding => '수유';

  @override
  String get smartAlertsTitle => '스마트 알림';

  @override
  String get smartAlertsViewAll => '전체 보기';

  @override
  String get alertSleepUrgentTitle => '아기가 너무 오래 깨어있어요!';

  @override
  String alertSleepUrgentMessage(int minutes) {
    return '$minutes분 초과했습니다. 지금 재우는 것을 권장해요.';
  }

  @override
  String get alertSleepWarningTitle => '곧 재울 시간이에요';

  @override
  String alertSleepWarningMessage(int minutes) {
    return '$minutes분 후에 재우는 것이 좋아요.';
  }

  @override
  String get alertFeedingUrgentTitle => '수유 시간이 지났어요!';

  @override
  String alertFeedingUrgentMessage(int minutes) {
    return '$minutes분 지연되었습니다.';
  }

  @override
  String get alertFeedingWarningTitle => '곧 수유 시간이에요';

  @override
  String alertFeedingWarningMessage(int minutes) {
    return '$minutes분 후 수유 예정입니다.';
  }

  @override
  String get alertDiaperWarningTitle => '기저귀를 확인해주세요';

  @override
  String alertDiaperWarningMessage(int hours) {
    return '마지막 교체 후 $hours시간이 지났어요.';
  }

  @override
  String get recordsFilterAllPeriod => '전체 기간';

  @override
  String get recordsFilterSearch => '검색';

  @override
  String get insightPositive => '좋음';

  @override
  String get insightWarning => '주의';

  @override
  String get insightConcern => '우려';

  @override
  String get insightNeutral => '정보';

  @override
  String get weeklyInsightsTitle => '이번 주 인사이트';

  @override
  String get weeklyInsightsNoData => '데이터를 기록하면 주간 인사이트를 볼 수 있어요';

  @override
  String get trendImproving => '개선';

  @override
  String get trendDeclining => '주의';

  @override
  String get trendStable => '안정';

  @override
  String get viewDetails => '자세히 보기';

  @override
  String get averageSleep => '평균 수면';

  @override
  String get sleepCount => '수면 횟수';

  @override
  String get averageFeeding => '평균 수유량';

  @override
  String get dailyAverage => '하루 평균';

  @override
  String get log_sleep => '수면 기록';

  @override
  String get track_sleep_patterns => '수면 패턴을 기록하세요';

  @override
  String get start_sleep_timer => '수면 타이머 시작';

  @override
  String get save_sleep_record => '수면 기록 저장';

  @override
  String sleep_last_sleep(String time, int duration) {
    return '마지막 수면: $time ($duration분간)';
  }

  @override
  String get sleep_recommended_wake_time => '권장 깨어있는 시간: 1시간 30분';

  @override
  String get sleep_first_record => '첫 수면 기록이에요! 시작 시간을 선택해주세요.';

  @override
  String sleep_time_ago_minutes(int minutes) {
    return '$minutes분 전';
  }

  @override
  String sleep_time_ago_hours(int hours, int minutes) {
    return '$hours시간 $minutes분 전';
  }

  @override
  String get sleep_status => '수면 상태';

  @override
  String get record_past_sleep => '과거 수면 기록';

  @override
  String get sleep_in_progress => '진행 중';

  @override
  String get start_time => '시작 시간';

  @override
  String get end_time_wake_up => '종료 시간 (기상)';

  @override
  String get sleep_location => '수면 장소';

  @override
  String get sleep_crib => '아기침대';

  @override
  String get sleep_bed => '침대';

  @override
  String get sleep_stroller => '유모차';

  @override
  String get sleep_car => '차량';

  @override
  String get sleep_arms => '품';

  @override
  String get sleep_quality => '수면 품질';

  @override
  String get sleep_quality_good => '좋음';

  @override
  String get sleep_quality_fair => '보통';

  @override
  String get sleep_quality_poor => '나쁨';

  @override
  String get notes_optional => '메모 (선택사항)';

  @override
  String get observations_hint_sleep => '관찰 사항이 있나요? (예: 울면서 깸, 깊이 잠)';

  @override
  String sleep_total_duration(int hours, int minutes) {
    return '총 수면 시간: $hours시간 $minutes분';
  }

  @override
  String get sleep_record_complete => '수면 기록 완료! 😴';

  @override
  String sleep_save_failed(String error) {
    return '저장 실패: $error';
  }

  @override
  String sleep_today_total(int hours, int minutes) {
    return '⏱️ 오늘 총 수면: $hours시간 $minutes분';
  }

  @override
  String sleep_yesterday_diff_plus(int diff) {
    return '📈 어제보다 +$diff분';
  }

  @override
  String sleep_yesterday_diff_minus(int diff) {
    return '📉 어제보다 $diff분';
  }

  @override
  String sleep_this_record(int minutes) {
    return '🎯 방금 기록한 수면: $minutes분';
  }

  @override
  String get sleep_in_progress_label => '진행 중';

  @override
  String get log_feeding => '수유 기록';

  @override
  String get track_feeding_types => '다양한 수유 방법을 기록하세요';

  @override
  String get save_feeding_record => '수유 기록 저장';

  @override
  String feeding_last_time(String time) {
    return '마지막 수유: $time 전';
  }

  @override
  String get feeding_recommended_interval => '권장 수유 간격: 2-3시간';

  @override
  String get feeding_first_record => '첫 수유 기록이에요! 수유 정보를 입력해주세요.';

  @override
  String get feeding_time => '수유 시간';

  @override
  String get feeding_type => '수유 유형';

  @override
  String get bottle => '젖병';

  @override
  String get breast => '모유';

  @override
  String get solid_food => '이유식';

  @override
  String get amount => '양';

  @override
  String get breast_side => '수유 방향';

  @override
  String get left => '왼쪽';

  @override
  String get right => '오른쪽';

  @override
  String get both => '양쪽';

  @override
  String get observations_hint_feeding => '관찰 사항이 있나요? (예: 잘 먹음, 거부함)';

  @override
  String get feeding_record_complete => '수유 기록 완료! 🍼';

  @override
  String feeding_today_count(int count) {
    return '🍼 오늘 수유 횟수: $count회';
  }

  @override
  String feeding_bottle_amount(int ml, String oz) {
    return '📊 ${ml}ml (${oz}oz)';
  }

  @override
  String get feeding_breast_both => '🤱 양쪽';

  @override
  String get feeding_breast_left => '🤱 왼쪽';

  @override
  String get feeding_breast_right => '🤱 오른쪽';

  @override
  String get log_diaper => '기저귀 기록';

  @override
  String get track_diaper_types => '기저귀 유형을 기록하세요';

  @override
  String get save_diaper_record => '기저귀 기록 저장';

  @override
  String diaper_last_change(String time) {
    return '마지막 기저귀 교체: $time 전';
  }

  @override
  String get diaper_recommended_interval => '권장 교체 간격: 2-3시간';

  @override
  String get diaper_first_record => '첫 기저귀 기록이에요! 기저귀 상태를 선택해주세요.';

  @override
  String get diaper_change_time => '기저귀 교체 시간';

  @override
  String get diaper_type => '기저귀 유형';

  @override
  String get wet_desc => '젖음';

  @override
  String get urineOnly => '소변만';

  @override
  String get dirty_desc => '배변';

  @override
  String get bowelMovement => '대변';

  @override
  String get both_desc => '둘 다';

  @override
  String get wet_and_dirty => '소변과 대변';

  @override
  String get observations_hint_diaper => '관찰 사항이 있나요? (예: 색상, 농도)';

  @override
  String get diaper_record_complete => '기저귀 기록 완료!';

  @override
  String diaper_today_count(int count) {
    return '🧷 오늘 기저귀 교체: $count회';
  }

  @override
  String get diaper_wet_only => '💧 소변만';

  @override
  String get diaper_dirty_only => '💩 대변';

  @override
  String get diaper_both => '💧💩 소변과 대변';

  @override
  String get health_record => '건강 기록';

  @override
  String get medication => '투약';

  @override
  String get temperature_unit => '온도 단위';

  @override
  String get celsius => '섭씨 (°C)';

  @override
  String get fahrenheit => '화씨 (°F)';

  @override
  String get time => '시간';

  @override
  String get highFever => '⚠️ 고열 - 소아과 상담을 권장합니다';

  @override
  String get additionalObservationsHint => '추가 관찰 사항이 있나요?';

  @override
  String get saveTemperature => '체온 저장';

  @override
  String get enterValidTemperature => '유효한 체온을 입력해주세요';

  @override
  String errorWithMessage(String message) {
    return '오류: $message';
  }

  @override
  String get temperature_record_baby => '아기의 체온을 기록하세요';

  @override
  String get temperature_normal_range =>
      '정상 체온: 36.5-37.5°C (97.7-99.5°F)\n38°C 이상은 발열로 간주됩니다.';

  @override
  String get temperature_fever_status => '⚠️ 발열 상태';

  @override
  String get temperature_normal_status => '✅ 정상 체온';

  @override
  String get temperature_record_complete => '체온 기록 완료!';

  @override
  String get medication_type => '투약 유형';

  @override
  String get feverReducer => '해열제';

  @override
  String get antibiotic => '항생제';

  @override
  String get medicationOther => '기타';

  @override
  String get dosage => '용량';

  @override
  String get reasonForMedicationHint => '투약 이유를 입력하세요';

  @override
  String get saveMedication => '투약 기록 저장';

  @override
  String get medication_record_info => '투약 정보를 기록하세요';

  @override
  String get medication_record_complete => '투약 기록 완료!';

  @override
  String get growth_record_title => '성장 기록';

  @override
  String get growth_record_subtitle => '아기의 키, 체중, 머리둘레를 기록하세요';

  @override
  String get growth_track_progress => '정기적으로 기록하면 성장 추이를 확인할 수 있어요';

  @override
  String get growth_weight_kg => '체중 (kg)';

  @override
  String get growth_height_cm => '키 (cm)';

  @override
  String get growth_head_cm => '머리둘레 (cm)';

  @override
  String get growth_save_record => '성장 기록 저장';

  @override
  String get growth_min_one_value => '최소 하나 이상의 측정값을 입력해주세요';

  @override
  String get growth_record_complete => '성장 기록 완료!';

  @override
  String get log_play_activity => '놀이 활동';

  @override
  String get play_track_developmental => '발달에 도움이 되는 놀이를 기록하세요';

  @override
  String get save_activity => '활동 저장';

  @override
  String get play_context_hint =>
      '아기의 발달 단계에 맞는 놀이를 선택하고 기록해보세요.\n규칙적인 놀이는 아기의 신체/인지 발달에 도움이 됩니다.';

  @override
  String get select_activity => '활동 선택';

  @override
  String get duration => '시간';

  @override
  String get activity_notes_hint => '활동 메모 추가...';

  @override
  String get development_benefits => '발달 효과:';

  @override
  String get play_select_time => '활동과 시간을 선택해주세요';

  @override
  String get play_record_complete => '놀이 활동 기록 완료! 🎉';

  @override
  String play_today_count(int count) {
    return '🎯 오늘 놀이 횟수: $count회';
  }

  @override
  String play_duration_minutes(int minutes) {
    return '⏱️ $minutes분간';
  }
}
