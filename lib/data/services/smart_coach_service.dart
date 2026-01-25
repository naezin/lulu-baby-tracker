import '../models/alert_chain.dart';
import '../models/daily_timeline.dart';
import '../models/timeline_item.dart';
import '../models/coaching_message.dart';
import 'prediction_engine.dart';
import 'alert_chain_manager.dart';
import 'timeline_generator.dart';
import 'coaching_message_service.dart';

/// 스마트 코치 서비스 - 전체 조율
class SmartCoachService {
  final PredictionEngine _predictionEngine;
  final AlertChainManager _alertChainManager;
  final TimelineGenerator _timelineGenerator;
  final CoachingMessageService _coachingMessageService;

  SmartCoachService({
    PredictionEngine? predictionEngine,
    AlertChainManager? alertChainManager,
    TimelineGenerator? timelineGenerator,
    CoachingMessageService? coachingMessageService,
  })  : _predictionEngine = predictionEngine ?? PredictionEngine(),
        _alertChainManager = alertChainManager ?? AlertChainManager(),
        _timelineGenerator = timelineGenerator ?? TimelineGenerator(),
        _coachingMessageService = coachingMessageService ?? CoachingMessageService();

  /// 오늘의 타임라인 생성
  Future<DailyTimeline> generateDailyTimeline({
    required String userId,
    required String babyName,
    required int ageInMonths,
    required DateTime? lastWakeUpTime,
    required DateTime? lastFeedingTime,
    required bool isKorean,
  }) async {
    // 1. 과거 활동 가져오기
    final pastActivities = await _timelineGenerator.getPastActivities(
      userId: userId,
      date: DateTime.now(),
    );

    // 2. 예측 생성
    final predictions = await _predictionEngine.generatePredictions(
      ageInMonths: ageInMonths,
      lastWakeUpTime: lastWakeUpTime,
      lastFeedingTime: lastFeedingTime,
      pastActivities: pastActivities,
    );

    // 3. 알림 체인 생성
    final chains = await _createAlertChains(
      predictions: predictions,
      babyName: babyName,
      isKorean: isKorean,
    );

    // 4. 타임라인 조합
    return DailyTimeline(
      date: DateTime.now(),
      items: [...pastActivities, ...predictions],
      activeChains: chains,
      generatedAt: DateTime.now(),
    );
  }

  /// 알림 체인 생성
  Future<List<AlertChain>> _createAlertChains({
    required List<TimelineItem> predictions,
    required String babyName,
    required bool isKorean,
  }) async {
    final chains = <AlertChain>[];

    for (final prediction in predictions) {
      if (prediction.category == ActivityCategory.sleep) {
        // 낮잠/밤잠 구분
        final isBedtime = prediction.time.hour >= 18;

        if (isBedtime) {
          chains.add(AlertChain.bedtime(
            sweetSpotTime: prediction.time,
            babyName: babyName,
            isKorean: isKorean,
          ));
        } else {
          final napNumber = predictions
              .where((p) => p.category == ActivityCategory.sleep)
              .toList()
              .indexOf(prediction) + 1;

          chains.add(AlertChain.nap(
            sweetSpotTime: prediction.time,
            babyName: babyName,
            isKorean: isKorean,
            napNumber: napNumber,
          ));
        }
      } else if (prediction.category == ActivityCategory.feeding) {
        chains.add(AlertChain.feeding(
          expectedFeedingTime: prediction.time,
          babyName: babyName,
          isKorean: isKorean,
        ));
      }
    }

    // 알림 스케줄링
    for (final chain in chains) {
      await _alertChainManager.scheduleChain(chain);
    }

    return chains;
  }

  /// 다음 액션 가져오기
  TimelineItem? getNextAction(DailyTimeline timeline) {
    return timeline.nextItem;
  }

  /// 현재 상황에 맞는 코칭 메시지
  CoachingMessage? getCurrentCoachingMessage({
    required DailyTimeline timeline,
    required String babyName,
    required bool isKorean,
  }) {
    return _coachingMessageService.generateContextualMessage(
      timeline: timeline,
      babyName: babyName,
      isKorean: isKorean,
    );
  }

  /// 활동 기록 후 타임라인 업데이트
  Future<DailyTimeline> onActivityLogged({
    required DailyTimeline currentTimeline,
    required TimelineItem newActivity,
    required String babyName,
    required int ageInMonths,
    required bool isKorean,
  }) async {
    // 1. 기존 예측 중 완료된 것 업데이트
    final updatedItems = currentTimeline.items.map((item) {
      if (item.id == newActivity.id ||
          (item.type == TimelineItemType.predicted &&
           item.category == newActivity.category &&
           item.time.difference(newActivity.time).abs() < const Duration(minutes: 30))) {
        return newActivity.copyWith(
          type: TimelineItemType.past,
          isCompleted: true,
        );
      }
      return item;
    }).toList();

    // 2. 새 예측 생성 (수면 종료 시)
    if (newActivity.category == ActivityCategory.sleep &&
        newActivity.metadata?['isWakeUp'] == true) {
      final newPredictions = await _predictionEngine.generatePredictions(
        ageInMonths: ageInMonths,
        lastWakeUpTime: newActivity.time,
        lastFeedingTime: null,  // 별도 조회 필요
        pastActivities: updatedItems.where((i) => i.type == TimelineItemType.past).toList(),
      );

      // 기존 예측 제거 후 새 예측 추가
      updatedItems.removeWhere((i) => i.type == TimelineItemType.predicted);
      updatedItems.addAll(newPredictions);

      // 알림 체인 재생성
      final newChains = await _createAlertChains(
        predictions: newPredictions,
        babyName: babyName,
        isKorean: isKorean,
      );

      return currentTimeline.copyWith(
        items: updatedItems,
        activeChains: newChains,
        generatedAt: DateTime.now(),
      );
    }

    return currentTimeline.copyWith(
      items: updatedItems,
      generatedAt: DateTime.now(),
    );
  }
}
