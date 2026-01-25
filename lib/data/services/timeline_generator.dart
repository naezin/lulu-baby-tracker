import '../models/timeline_item.dart';
import '../../domain/entities/activity_entity.dart';
import '../../domain/repositories/i_activity_repository.dart';
import '../../di/injection_container.dart' as di;

/// 타임라인 생성기 - 과거 활동을 타임라인 형태로 변환
class TimelineGenerator {
  final IActivityRepository _activityRepository = di.sl<IActivityRepository>();

  /// 오늘의 과거 활동 가져오기
  Future<List<TimelineItem>> getPastActivities({
    required String userId,
    required DateTime date,
  }) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    try {
      // 활동 기록 조회
      final activities = await _activityRepository.getActivities(
        babyId: userId,
        startDate: startOfDay,
        endDate: endOfDay,
      );

      // TimelineItem으로 변환
      return activities.map((activity) {
        return TimelineItem(
          id: activity.id,
          time: activity.timestamp,
          type: TimelineItemType.past,
          category: _mapActivityType(activity.type),
          title: _getActivityTitle(activity),
          subtitle: _getActivitySubtitle(activity),
          duration: activity.durationMinutes != null
              ? '${activity.durationMinutes}분'
              : null,
          isCompleted: true,
          metadata: {
            'activityId': activity.id,
            'isWakeUp': activity.type == ActivityType.sleep &&
                        activity.endTime != null,
          },
        );
      }).toList();
    } catch (e) {
      print('⚠️ [TimelineGenerator] Error getting past activities: $e');
      return [];
    }
  }

  /// ActivityType → ActivityCategory 변환
  ActivityCategory _mapActivityType(ActivityType type) {
    switch (type) {
      case ActivityType.sleep:
        return ActivityCategory.sleep;
      case ActivityType.feeding:
        return ActivityCategory.feeding;
      case ActivityType.diaper:
        return ActivityCategory.diaper;
      case ActivityType.play:
        return ActivityCategory.play;
      case ActivityType.health:
        return ActivityCategory.health;
      default:
        return ActivityCategory.other;
    }
  }

  /// 활동 제목 생성
  String _getActivityTitle(ActivityEntity activity) {
    switch (activity.type) {
      case ActivityType.sleep:
        if (activity.endTime != null) {
          return '기상';
        }
        return activity.timestamp.hour >= 18 ? '밤잠' : '낮잠';
      case ActivityType.feeding:
        return '수유';
      case ActivityType.diaper:
        return '기저귀';
      case ActivityType.play:
        return '놀이';
      case ActivityType.health:
        return '건강';
      default:
        return '기타';
    }
  }

  /// 활동 서브타이틀 생성
  String? _getActivitySubtitle(ActivityEntity activity) {
    switch (activity.type) {
      case ActivityType.sleep:
        if (activity.durationMinutes != null) {
          return '${activity.durationMinutes}분 수면';
        }
        return null;
      case ActivityType.feeding:
        if (activity.amountMl != null) {
          return '${activity.amountMl}ml';
        }
        return activity.feedingType;
      case ActivityType.diaper:
        return activity.diaperType;
      default:
        return null;
    }
  }
}
