import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';

/// 📊 Today's Snapshot Card
/// 오늘 하루 요약을 4칸(2x2)으로 보여주는 위젯
/// 먹-놀-잠-기저귀 핵심 사이클 완성
class TodaysSnapshotCard extends StatelessWidget {
  final TodaysSummary summary;
  final VoidCallback? onSleepTap;
  final VoidCallback? onFeedingTap;
  final VoidCallback? onDiaperTap;
  final VoidCallback? onPlayTap;
  final VoidCallback? onViewAllTap;

  const TodaysSnapshotCard({
    Key? key,
    required this.summary,
    this.onSleepTap,
    this.onFeedingTap,
    this.onDiaperTap,
    this.onPlayTap,
    this.onViewAllTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 18,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.translate('todays_snapshot_title'),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (onViewAllTap != null)
                  IconButton(
                    onPressed: onViewAllTap,
                    icon: Icon(
                      Icons.chevron_right,
                      color: Colors.grey[400],
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          ),

          // 4-Grid Cards (2x2)
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Row 1: 수면 + 수유
                IntrinsicHeight(
                  child: Row(
                    children: [
                      Expanded(
                        child: _SnapshotItem(
                          emoji: '😴',
                          label: l10n.translate('sleep'),
                          primaryValue: '${summary.sleepCount}회',
                          secondaryValue: summary.totalSleepFormatted,
                          trend: summary.sleepTrendLabel,
                          trendDirection: summary.sleepTrend,
                          onTap: onSleepTap,
                        ),
                      ),
                      Container(
                        width: 1,
                        color: Colors.grey.withOpacity(0.1),
                      ),
                      Expanded(
                        child: _SnapshotItem(
                          emoji: '🍼',
                          label: l10n.translate('feeding'),
                          primaryValue: '${summary.feedingCount}회',
                          secondaryValue: '총 ${summary.totalFeedingMl}ml',
                          trend: summary.feedingTrendLabel,
                          trendDirection: summary.feedingTrend,
                          onTap: onFeedingTap,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  height: 1,
                  color: Colors.grey.withOpacity(0.1),
                ),

                // Row 2: 기저귀 + 놀이
                IntrinsicHeight(
                  child: Row(
                    children: [
                      Expanded(
                        child: _SnapshotItem(
                          emoji: '🧷',
                          label: l10n.translate('diaper'),
                          primaryValue: '${summary.diaperCount}회',
                          secondaryValue: '대변 ${summary.poopCount}회',
                          trend: summary.diaperTrendLabel,
                          trendDirection: summary.diaperTrend,
                          onTap: onDiaperTap,
                        ),
                      ),
                      Container(
                        width: 1,
                        color: Colors.grey.withOpacity(0.1),
                      ),
                      Expanded(
                        child: _SnapshotItem(
                          emoji: '🎮',
                          label: l10n.translate('play'),
                          primaryValue: summary.playTimeFormatted,
                          secondaryValue: '터미타임 ${summary.tummyTimeMinutes}분',
                          trend: '목표 ${summary.playGoalPercent}%',
                          trendDirection: summary.playTrend,
                          onTap: onPlayTap,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 개별 스냅샷 아이템
class _SnapshotItem extends StatelessWidget {
  final String emoji;
  final String label;
  final String primaryValue;
  final String secondaryValue;
  final String trend;
  final TrendDirection trendDirection;
  final VoidCallback? onTap;

  const _SnapshotItem({
    required this.emoji,
    required this.label,
    required this.primaryValue,
    required this.secondaryValue,
    required this.trend,
    required this.trendDirection,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Emoji + Label
              Row(
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Primary Value (큰 숫자 + 단위)
              Text(
                primaryValue,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 4),

              // Secondary Value (보조 정보)
              Text(
                secondaryValue,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),

              const SizedBox(height: 8),

              // Trend Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getTrendColor(trendDirection).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getTrendIcon(trendDirection),
                      size: 12,
                      color: _getTrendColor(trendDirection),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      trend,
                      style: TextStyle(
                        fontSize: 11,
                        color: _getTrendColor(trendDirection),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTrendColor(TrendDirection direction) {
    switch (direction) {
      case TrendDirection.up:
        return Colors.green;
      case TrendDirection.down:
        return Colors.orange;
      case TrendDirection.stable:
        return Colors.grey;
    }
  }

  IconData _getTrendIcon(TrendDirection direction) {
    switch (direction) {
      case TrendDirection.up:
        return Icons.trending_up;
      case TrendDirection.down:
        return Icons.trending_down;
      case TrendDirection.stable:
        return Icons.trending_flat;
    }
  }
}

/// 트렌드 방향
enum TrendDirection { up, down, stable }

/// 오늘의 요약 데이터 모델
class TodaysSummary {
  // 수면
  final int sleepCount;           // 수면 횟수
  final int totalSleepMinutes;    // 총 수면 시간 (분)
  final int sleepDiffMinutes;     // 어제 대비 변화 (분)

  // 수유
  final int feedingCount;         // 수유 횟수
  final int totalFeedingMl;       // 총 수유량 (ml)
  final int feedingDiff;          // 어제 대비 변화

  // 기저귀
  final int diaperCount;          // 기저귀 총 횟수
  final int poopCount;            // 대변 횟수
  final int diaperDiff;           // 어제 대비 변화

  // 놀이
  final int playTimeMinutes;      // 총 놀이 시간 (분)
  final int tummyTimeMinutes;     // 터미타임 (분)
  final int playGoalMinutes;      // 놀이 목표 (분)
  final int playDiffMinutes;      // 어제 대비 변화 (분)

  TodaysSummary({
    this.sleepCount = 0,
    this.totalSleepMinutes = 0,
    this.sleepDiffMinutes = 0,
    this.feedingCount = 0,
    this.totalFeedingMl = 0,
    this.feedingDiff = 0,
    this.diaperCount = 0,
    this.poopCount = 0,
    this.diaperDiff = 0,
    this.playTimeMinutes = 0,
    this.tummyTimeMinutes = 0,
    this.playGoalMinutes = 60,
    this.playDiffMinutes = 0,
  });

  // ========== 수면 관련 ==========

  String get totalSleepFormatted {
    final hours = totalSleepMinutes ~/ 60;
    final minutes = totalSleepMinutes % 60;
    if (hours > 0 && minutes > 0) {
      return '총 ${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '총 ${hours}h';
    }
    return '총 ${minutes}m';
  }

  TrendDirection get sleepTrend {
    if (sleepDiffMinutes > 10) return TrendDirection.up;
    if (sleepDiffMinutes < -10) return TrendDirection.down;
    return TrendDirection.stable;
  }

  String get sleepTrendLabel {
    if (sleepDiffMinutes > 0) return '↑${sleepDiffMinutes}분';
    if (sleepDiffMinutes < 0) return '↓${sleepDiffMinutes.abs()}분';
    return '평균';
  }

  // ========== 수유 관련 ==========

  TrendDirection get feedingTrend {
    if (feedingDiff > 0) return TrendDirection.up;
    if (feedingDiff < 0) return TrendDirection.down;
    return TrendDirection.stable;
  }

  String get feedingTrendLabel {
    if (feedingDiff != 0) {
      return feedingDiff > 0 ? '+$feedingDiff회' : '$feedingDiff회';
    }
    return '정상';
  }

  // ========== 기저귀 관련 ==========

  TrendDirection get diaperTrend {
    if (diaperDiff > 1) return TrendDirection.up;
    if (diaperDiff < -1) return TrendDirection.down;
    return TrendDirection.stable;
  }

  String get diaperTrendLabel {
    if (diaperDiff != 0) {
      return diaperDiff > 0 ? '+$diaperDiff회' : '$diaperDiff회';
    }
    return '정상';
  }

  // ========== 놀이 관련 ==========

  String get playTimeFormatted {
    if (playTimeMinutes >= 60) {
      final hours = playTimeMinutes ~/ 60;
      final minutes = playTimeMinutes % 60;
      return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
    }
    return '${playTimeMinutes}분';
  }

  int get playGoalPercent =>
      playGoalMinutes > 0
          ? ((playTimeMinutes / playGoalMinutes) * 100).clamp(0, 100).toInt()
          : 0;

  TrendDirection get playTrend {
    if (playGoalPercent >= 80) return TrendDirection.up;
    if (playGoalPercent < 50) return TrendDirection.down;
    return TrendDirection.stable;
  }

  // ========== 팩토리 메서드 ==========

  /// 빈 데이터 (기록 없을 때)
  factory TodaysSummary.empty() => TodaysSummary();

  /// 데모 데이터
  factory TodaysSummary.demo() => TodaysSummary(
    sleepCount: 2,
    totalSleepMinutes: 150,
    sleepDiffMinutes: 30,
    feedingCount: 5,
    totalFeedingMl: 520,
    feedingDiff: 0,
    diaperCount: 6,
    poopCount: 2,
    diaperDiff: 0,
    playTimeMinutes: 45,
    tummyTimeMinutes: 15,
    playGoalMinutes: 60,
    playDiffMinutes: 10,
  );
}
