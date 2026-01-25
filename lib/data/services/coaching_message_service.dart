import '../models/coaching_message.dart';
import '../models/daily_timeline.dart';
import '../models/timeline_item.dart';

/// 코칭 메시지 서비스 - 상황별 맞춤 메시지 생성
class CoachingMessageService {
  /// 상황별 코칭 메시지 생성
  CoachingMessage? generateContextualMessage({
    required DailyTimeline timeline,
    required String babyName,
    required bool isKorean,
  }) {
    final now = DateTime.now();
    final nextItem = timeline.nextItem;

    // 1. Sweet Spot 놓침 체크
    final missedSweetSpot = _checkMissedSweetSpot(timeline, now);
    if (missedSweetSpot) {
      return CoachingMessage.missedSweetSpot(isKorean: isKorean);
    }

    // 2. 낮잠 성공 축하
    final completedNaps = timeline.completedNapsCount;
    if (completedNaps >= 2 && _shouldShowEncouragement(timeline)) {
      return CoachingMessage.encouragement(
        babyName: babyName,
        isKorean: isKorean,
        completedNaps: completedNaps,
      );
    }

    // 3. 밤잠 시간 근접 시 팁
    if (now.hour >= 17 && now.hour < 20) {
      return _generateBedtimeTip(babyName, isKorean);
    }

    // 4. 아침 인사
    if (now.hour >= 6 && now.hour < 9 && timeline.pastItems.isEmpty) {
      return _generateMorningGreeting(babyName, isKorean);
    }

    // 5. 다음 액션 안내
    if (nextItem != null) {
      final minutesUntil = nextItem.time.difference(now).inMinutes;
      if (minutesUntil > 0 && minutesUntil <= 60) {
        return _generateNextActionTip(nextItem, babyName, isKorean);
      }
    }

    return null;
  }

  /// Sweet Spot 놓침 체크
  bool _checkMissedSweetSpot(DailyTimeline timeline, DateTime now) {
    // 예측된 수면 중 현재 시간보다 30분 이상 지난 것이 있는지
    final missedSleep = timeline.upcomingItems.where((item) {
      if (item.category != ActivityCategory.sleep) return false;
      final diff = now.difference(item.time).inMinutes;
      return diff > 30 && diff < 60;  // 30-60분 지난 경우
    });

    return missedSleep.isNotEmpty;
  }

  /// 격려 메시지 표시 여부
  bool _shouldShowEncouragement(DailyTimeline timeline) {
    // 마지막 격려 메시지 이후 2시간 경과했는지 체크
    // (실제로는 로컬 저장소에서 체크)
    return true;
  }

  /// 밤잠 팁 생성
  CoachingMessage _generateBedtimeTip(String babyName, bool isKorean) {
    return CoachingMessage(
      id: 'tip_bedtime_${DateTime.now().millisecondsSinceEpoch}',
      type: CoachingMessageType.tip,
      title: isKorean ? '🌙 밤잠 준비 팁' : '🌙 Bedtime Tip',
      body: isKorean
          ? '밤잠 1시간 전부터 조명을 어둡게 하면 멜라토닌 분비가 촉진돼요!'
          : 'Dimming lights 1 hour before bedtime helps melatonin production!',
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(hours: 3)),
    );
  }

  /// 아침 인사 생성
  CoachingMessage _generateMorningGreeting(String babyName, bool isKorean) {
    return CoachingMessage(
      id: 'greet_morning_${DateTime.now().millisecondsSinceEpoch}',
      type: CoachingMessageType.tip,
      title: isKorean ? '☀️ 좋은 아침이에요!' : '☀️ Good Morning!',
      body: isKorean
          ? '$babyName이의 기상 시간을 기록하면 오늘의 Sweet Spot을 예측해드릴게요!'
          : 'Log $babyName\'s wake time and I\'ll predict today\'s Sweet Spots!',
      actionLabel: isKorean ? '기상 기록하기' : 'Log Wake Time',
      actionRoute: '/log/sleep',
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(hours: 3)),
    );
  }

  /// 다음 액션 팁 생성
  CoachingMessage _generateNextActionTip(
    TimelineItem nextItem,
    String babyName,
    bool isKorean,
  ) {
    final minutesUntil = nextItem.time.difference(DateTime.now()).inMinutes;

    String body;
    if (nextItem.category == ActivityCategory.sleep) {
      body = isKorean
          ? '$minutesUntil분 후 Sweet Spot이에요. 미리 준비해두세요!'
          : 'Sweet Spot in $minutesUntil minutes. Get ready!';
    } else if (nextItem.category == ActivityCategory.feeding) {
      body = isKorean
          ? '$minutesUntil분 후 수유 시간이에요.'
          : 'Feeding time in $minutesUntil minutes.';
    } else {
      body = isKorean
          ? '$minutesUntil분 후 ${nextItem.title} 예정이에요.'
          : '${nextItem.title} in $minutesUntil minutes.';
    }

    return CoachingMessage(
      id: 'tip_next_${DateTime.now().millisecondsSinceEpoch}',
      type: CoachingMessageType.reminder,
      title: '${nextItem.categoryEmoji} ${nextItem.title}',
      body: body,
      createdAt: DateTime.now(),
      expiresAt: nextItem.time,
    );
  }
}
