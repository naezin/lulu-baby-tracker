/// Widget State - 위젯의 3가지 상태
enum WidgetState {
  empty,    // 데이터 없음
  active,   // Sweet Spot 계산됨
  urgent,   // 지금 재워야 함
}

/// Urgency Level - 긴급도 3단계
enum UrgencyLevel {
  green,  // 30분+ 남음
  yellow, // 15-30분 남음
  red,    // 15분 미만 또는 지남
}

/// Widget Data - 위젯에 표시할 데이터
class WidgetData {
  final WidgetState state;
  final DateTime? nextSweetSpotTime;
  final int? minutesRemaining;
  final UrgencyLevel? urgencyLevel;
  final double? confidenceScore;
  final String? hintMessage;

  WidgetData({
    required this.state,
    this.nextSweetSpotTime,
    this.minutesRemaining,
    this.urgencyLevel,
    this.confidenceScore,
    this.hintMessage,
  });

  /// Empty State
  factory WidgetData.empty() => WidgetData(state: WidgetState.empty);

  /// Active State
  factory WidgetData.active({
    required DateTime sweetSpotTime,
    required int minutesRemaining,
    required UrgencyLevel urgency,
    double confidence = 0.85,
    String? hint,
  }) =>
      WidgetData(
        state: WidgetState.active,
        nextSweetSpotTime: sweetSpotTime,
        minutesRemaining: minutesRemaining,
        urgencyLevel: urgency,
        confidenceScore: confidence,
        hintMessage: hint,
      );

  /// Urgent State
  factory WidgetData.urgent({
    required DateTime sweetSpotTime,
    double confidence = 0.85,
  }) =>
      WidgetData(
        state: WidgetState.urgent,
        nextSweetSpotTime: sweetSpotTime,
        urgencyLevel: UrgencyLevel.red,
        confidenceScore: confidence,
      );

  /// Calculate urgency level from minutes remaining
  static UrgencyLevel calculateUrgency({
    required DateTime sweetSpotStart,
    required DateTime now,
  }) {
    final minutesToStart = sweetSpotStart.difference(now).inMinutes;

    if (minutesToStart <= 0) {
      // Sweet Spot 진입 또는 지남
      return UrgencyLevel.red;
    } else if (minutesToStart <= 15) {
      // 15분 이내
      return UrgencyLevel.yellow;
    } else {
      // 15분 이상
      return UrgencyLevel.green;
    }
  }

  /// Get hint message key based on urgency
  String getHintMessageKey() {
    switch (urgencyLevel) {
      case UrgencyLevel.green:
        return 'widget_hint_green';
      case UrgencyLevel.yellow:
        return 'widget_hint_yellow';
      case UrgencyLevel.red:
        return 'widget_hint_red';
      default:
        return 'widget_hint_green';
    }
  }

  /// Convert to JSON for widget storage
  Map<String, dynamic> toJson() {
    return {
      'state': state.name,
      'nextSweetSpotTime': nextSweetSpotTime?.toIso8601String(),
      'minutesRemaining': minutesRemaining,
      'urgencyLevel': urgencyLevel?.name,
      'confidenceScore': confidenceScore,
      'hintMessage': hintMessage,
    };
  }
}
