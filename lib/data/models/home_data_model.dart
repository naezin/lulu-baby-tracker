import '../../core/utils/sweet_spot_calculator.dart';
import '../services/daily_summary_service.dart';
import 'notification_state.dart';

/// 홈 화면 통합 데이터 모델
class HomeDataModel {
  final SweetSpotResult? sweetSpot;
  final DailySummary? dailySummary;
  final NotificationState notificationState;
  final DateTime lastUpdated;

  const HomeDataModel({
    this.sweetSpot,
    this.dailySummary,
    this.notificationState = const NotificationState(),
    required this.lastUpdated,
  });

  /// 데이터 유효 여부
  bool get hasData => sweetSpot != null || dailySummary != null;

  /// Empty 상태 생성
  factory HomeDataModel.empty() => HomeDataModel(
    lastUpdated: DateTime.now(),
  );

  HomeDataModel copyWith({
    SweetSpotResult? sweetSpot,
    DailySummary? dailySummary,
    NotificationState? notificationState,
    DateTime? lastUpdated,
  }) {
    return HomeDataModel(
      sweetSpot: sweetSpot ?? this.sweetSpot,
      dailySummary: dailySummary ?? this.dailySummary,
      notificationState: notificationState ?? this.notificationState,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
