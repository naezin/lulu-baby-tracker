import '../models/timeline_item.dart';
import '../../core/utils/sweet_spot_calculator.dart';

/// 예측 엔진 - AI 기반 다음 활동 예측
class PredictionEngine {
  /// 오늘 남은 예측 생성
  Future<List<TimelineItem>> generatePredictions({
    required int ageInMonths,
    required DateTime? lastWakeUpTime,
    required DateTime? lastFeedingTime,
    required List<TimelineItem> pastActivities,
  }) async {
    final predictions = <TimelineItem>[];
    final now = DateTime.now();
    final ageInDays = ageInMonths * 30;

    // 1. Sweet Spot 예측 (수면)
    if (lastWakeUpTime != null) {
      final sweetSpot = SweetSpotCalculator.calculate(
        ageInMonths: ageInMonths,
        lastWakeUpTime: lastWakeUpTime,
        napNumber: _estimateNapNumber(now.hour),
      );

      if (sweetSpot != null && sweetSpot.sweetSpotStart.isAfter(now)) {
        predictions.add(TimelineItem(
          id: 'pred_sleep_${sweetSpot.sweetSpotStart.millisecondsSinceEpoch}',
          time: sweetSpot.sweetSpotStart,
          type: TimelineItemType.predicted,
          category: ActivityCategory.sleep,
          title: _isBedtime(sweetSpot.sweetSpotStart) ? '밤잠' : '낮잠',
          subtitle: '${((sweetSpot.wakeWindowData.minMinutes + sweetSpot.wakeWindowData.maxMinutes) / 2).round()}분 Wake Window',
          hasAlert: true,
        ));
      }
    }

    // 2. 수유 예측
    if (lastFeedingTime != null) {
      final feedingInterval = _getFeedingInterval(ageInDays);
      var nextFeedingTime = lastFeedingTime.add(Duration(minutes: feedingInterval));

      // 오늘 자정까지 수유 예측 추가
      while (nextFeedingTime.isBefore(_endOfDay(now)) &&
             nextFeedingTime.isAfter(now)) {
        predictions.add(TimelineItem(
          id: 'pred_feed_${nextFeedingTime.millisecondsSinceEpoch}',
          time: nextFeedingTime,
          type: TimelineItemType.predicted,
          category: ActivityCategory.feeding,
          title: '수유',
          subtitle: _getFeedingSubtitle(ageInDays),
          hasAlert: true,
        ));

        nextFeedingTime = nextFeedingTime.add(Duration(minutes: feedingInterval));
      }
    }

    // 3. 추가 낮잠 예측 (첫 낮잠 이후)
    final completedNaps = pastActivities
        .where((a) => a.category == ActivityCategory.sleep && a.isCompleted)
        .length;

    final targetNaps = _getTargetNaps(ageInDays);

    if (completedNaps < targetNaps && predictions.isNotEmpty) {
      final lastSleepPrediction = predictions
          .where((p) => p.category == ActivityCategory.sleep)
          .lastOrNull;

      if (lastSleepPrediction != null) {
        // 다음 낮잠 예측 (현재 낮잠 + 깨어있는 시간 + 낮잠 시간)
        final wakeWindow = ((ageInMonths * 30) < 90) ? 90 : (ageInMonths * 30 < 180) ? 120 : 150;
        final napDuration = _getAverageNapDuration(ageInDays);

        var nextNapTime = lastSleepPrediction.time
            .add(Duration(minutes: napDuration + wakeWindow));

        while (nextNapTime.hour < 18 &&
               predictions.where((p) => p.category == ActivityCategory.sleep).length < targetNaps) {
          predictions.add(TimelineItem(
            id: 'pred_nap_${nextNapTime.millisecondsSinceEpoch}',
            time: nextNapTime,
            type: TimelineItemType.predicted,
            category: ActivityCategory.sleep,
            title: '낮잠',
            hasAlert: true,
          ));

          nextNapTime = nextNapTime.add(Duration(minutes: napDuration + wakeWindow));
        }
      }
    }

    // 시간순 정렬
    predictions.sort((a, b) => a.time.compareTo(b.time));

    return predictions;
  }

  /// 월령별 수유 간격 (분)
  int _getFeedingInterval(int ageInDays) {
    if (ageInDays < 30) return 150;       // 0-1개월: 2.5시간
    if (ageInDays < 90) return 180;       // 1-3개월: 3시간
    if (ageInDays < 180) return 210;      // 3-6개월: 3.5시간
    return 240;                            // 6개월+: 4시간
  }

  /// 월령별 목표 낮잠 횟수
  int _getTargetNaps(int ageInDays) {
    if (ageInDays < 90) return 4;         // 0-3개월: 4회
    if (ageInDays < 180) return 3;        // 3-6개월: 3회
    if (ageInDays < 270) return 2;        // 6-9개월: 2회
    if (ageInDays < 540) return 2;        // 9-18개월: 1-2회
    return 1;                              // 18개월+: 1회
  }

  /// 월령별 평균 낮잠 시간 (분)
  int _getAverageNapDuration(int ageInDays) {
    if (ageInDays < 90) return 45;        // 0-3개월: 45분
    if (ageInDays < 180) return 60;       // 3-6개월: 1시간
    if (ageInDays < 360) return 75;       // 6-12개월: 1시간 15분
    return 90;                             // 12개월+: 1시간 30분
  }

  /// 수유 서브타이틀
  String _getFeedingSubtitle(int ageInDays) {
    if (ageInDays < 30) return '60-90ml 예상';
    if (ageInDays < 90) return '120-150ml 예상';
    if (ageInDays < 180) return '150-180ml 예상';
    return '180-210ml 예상';
  }

  /// 밤잠 여부 (오후 6시 이후)
  bool _isBedtime(DateTime time) => time.hour >= 18;

  /// 오늘 자정
  DateTime _endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }

  /// 낮잠 번호 추정 (시간대 기반)
  int _estimateNapNumber(int hour) {
    if (hour < 10) return 1;
    if (hour < 13) return 2;
    if (hour < 16) return 3;
    return 4;
  }
}
