import 'package:flutter/foundation.dart';
import 'timeline_item.dart';
import 'alert_chain.dart';

/// 일일 타임라인 모델
@immutable
class DailyTimeline {
  final DateTime date;
  final List<TimelineItem> items;
  final List<AlertChain> activeChains;
  final DateTime generatedAt;

  const DailyTimeline({
    required this.date,
    required this.items,
    required this.activeChains,
    required this.generatedAt,
  });

  /// 빈 타임라인 생성
  factory DailyTimeline.empty() {
    return DailyTimeline(
      date: DateTime.now(),
      items: const [],
      activeChains: const [],
      generatedAt: DateTime.now(),
    );
  }

  /// 과거 아이템 (완료된 활동)
  List<TimelineItem> get pastItems =>
      items.where((i) => i.type == TimelineItemType.past).toList();

  /// 현재 아이템
  TimelineItem? get currentItem =>
      items.where((i) => i.type == TimelineItemType.current).firstOrNull;

  /// 예정 아이템 (AI 예측)
  List<TimelineItem> get upcomingItems =>
      items.where((i) => i.type == TimelineItemType.predicted).toList();

  /// 다음 아이템
  TimelineItem? get nextItem {
    final upcoming = upcomingItems;
    if (upcoming.isEmpty) return null;
    upcoming.sort((a, b) => a.time.compareTo(b.time));
    return upcoming.first;
  }

  /// 시간순 정렬된 전체 아이템
  List<TimelineItem> get sortedItems {
    final sorted = List<TimelineItem>.from(items);
    sorted.sort((a, b) => a.time.compareTo(b.time));
    return sorted;
  }

  /// 특정 카테고리 아이템 필터
  List<TimelineItem> itemsByCategory(ActivityCategory category) =>
      items.where((i) => i.category == category).toList();

  /// 오늘 완료된 수면 횟수
  int get completedNapsCount => pastItems
      .where((i) => i.category == ActivityCategory.sleep && i.isCompleted)
      .length;

  /// 오늘 완료된 수유 횟수
  int get completedFeedingsCount => pastItems
      .where((i) => i.category == ActivityCategory.feeding && i.isCompleted)
      .length;

  DailyTimeline copyWith({
    DateTime? date,
    List<TimelineItem>? items,
    List<AlertChain>? activeChains,
    DateTime? generatedAt,
  }) {
    return DailyTimeline(
      date: date ?? this.date,
      items: items ?? this.items,
      activeChains: activeChains ?? this.activeChains,
      generatedAt: generatedAt ?? this.generatedAt,
    );
  }
}
