import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 타임라인 아이템 타입
enum TimelineItemType {
  past,       // 완료된 활동
  current,    // 현재 진행 중
  predicted,  // AI 예측
}

/// 활동 카테고리
enum ActivityCategory {
  sleep,      // 수면
  feeding,    // 수유
  diaper,     // 기저귀
  play,       // 놀이
  health,     // 건강
  other,      // 기타
}

/// 타임라인 아이템 모델
@immutable
class TimelineItem {
  final String id;
  final DateTime time;
  final TimelineItemType type;
  final ActivityCategory category;
  final String title;
  final String? subtitle;
  final String? duration;           // 소요 시간 (예: "45분")
  final bool hasAlert;              // 알림 연동 여부
  final String? linkedChainId;      // 연결된 알림 체인 ID
  final bool isCompleted;           // 완료 여부
  final Map<String, dynamic>? metadata;  // 추가 데이터

  const TimelineItem({
    required this.id,
    required this.time,
    required this.type,
    required this.category,
    required this.title,
    this.subtitle,
    this.duration,
    this.hasAlert = false,
    this.linkedChainId,
    this.isCompleted = false,
    this.metadata,
  });

  /// 카테고리별 색상
  Color get categoryColor {
    switch (category) {
      case ActivityCategory.sleep:
        return const Color(0xFF9D8CFF);  // 라벤더
      case ActivityCategory.feeding:
        return const Color(0xFFD4AF6A);  // 샴페인 골드
      case ActivityCategory.diaper:
        return const Color(0xFF7ECEC3);  // 민트
      case ActivityCategory.play:
        return const Color(0xFF7ED321);  // 그린
      case ActivityCategory.health:
        return const Color(0xFFFF6B6B);  // 코랄
      case ActivityCategory.other:
        return const Color(0xFF8E8E93);  // 그레이
    }
  }

  /// 카테고리별 아이콘
  IconData get categoryIcon {
    switch (category) {
      case ActivityCategory.sleep:
        return Icons.bedtime;
      case ActivityCategory.feeding:
        return Icons.restaurant;
      case ActivityCategory.diaper:
        return Icons.baby_changing_station;
      case ActivityCategory.play:
        return Icons.toys;
      case ActivityCategory.health:
        return Icons.favorite;
      case ActivityCategory.other:
        return Icons.more_horiz;
    }
  }

  /// 카테고리별 이모지
  String get categoryEmoji {
    switch (category) {
      case ActivityCategory.sleep:
        return '💤';
      case ActivityCategory.feeding:
        return '🍼';
      case ActivityCategory.diaper:
        return '🧷';
      case ActivityCategory.play:
        return '🎮';
      case ActivityCategory.health:
        return '❤️';
      case ActivityCategory.other:
        return '📝';
    }
  }

  /// 시간 포맷 (예: "오전 7:00", "7:00 AM")
  String getFormattedTime({required bool isKorean}) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');

    if (isKorean) {
      final period = hour < 12 ? '오전' : '오후';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$period $displayHour:$minute';
    } else {
      final period = hour < 12 ? 'AM' : 'PM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$displayHour:$minute $period';
    }
  }

  TimelineItem copyWith({
    String? id,
    DateTime? time,
    TimelineItemType? type,
    ActivityCategory? category,
    String? title,
    String? subtitle,
    String? duration,
    bool? hasAlert,
    String? linkedChainId,
    bool? isCompleted,
    Map<String, dynamic>? metadata,
  }) {
    return TimelineItem(
      id: id ?? this.id,
      time: time ?? this.time,
      type: type ?? this.type,
      category: category ?? this.category,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      duration: duration ?? this.duration,
      hasAlert: hasAlert ?? this.hasAlert,
      linkedChainId: linkedChainId ?? this.linkedChainId,
      isCompleted: isCompleted ?? this.isCompleted,
      metadata: metadata ?? this.metadata,
    );
  }
}
