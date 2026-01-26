import '../../domain/repositories/i_activity_repository.dart';
import '../../domain/entities/activity_entity.dart';
import '../../core/localization/app_localizations.dart';
import './local_storage_service.dart';
import '../models/activity_model.dart' as model;

/// Service to calculate daily summary statistics
/// 🔧 TEMPORARY: LocalStorageService 직접 사용 (Repository와 Storage 불일치 해결)
class DailySummaryService {
  final IActivityRepository? _activityRepository;
  final LocalStorageService _storage;

  DailySummaryService({
    IActivityRepository? activityRepository,
  })  : _activityRepository = activityRepository,
        _storage = LocalStorageService();

  /// Get today's summary for a specific baby
  Future<DailySummary> getTodaysSummary(String babyId) async {
    // Use local time for "today" but convert to UTC for consistent comparison
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    print('📊 [DailySummaryService] getTodaysSummary called');
    print('   babyId: $babyId');
    print('   startOfDay: $startOfDay');
    print('   endOfDay: $endOfDay');

    try {
      // 🔧 TEMPORARY: LocalStorage에서 직접 가져오기
      final allActivities = await _storage.getActivities();
      print('   📦 Fetched ${allActivities.length} total activities from LocalStorage');

      // ✅ babyId와 오늘 날짜로 필터링
      final todayActivities = allActivities.where((model) {
        // babyId 확인
        if (model.babyId != babyId) return false;

        // 오늘 날짜 확인
        final activityDate = DateTime.parse(model.timestamp);
        final activityLocal = activityDate.isUtc ? activityDate.toLocal() : activityDate;
        return activityLocal.isAfter(startOfDay.subtract(const Duration(seconds: 1))) &&
               activityLocal.isBefore(endOfDay);
      }).toList();

      print('   ✅ Filtered to ${todayActivities.length} activities for babyId=$babyId, today: $startOfDay');

      final summary = _calculateSummaryFromModels(todayActivities);
      print('   📈 Summary: sleep=${summary.totalSleepMinutes}min, feeding=${summary.feedingCount}, diaper=${summary.diaperCount}');

      return summary;
    } catch (e, stackTrace) {
      print('   ❌ Error: $e');
      print('   Stack trace: $stackTrace');
      // Return empty summary on error
      return DailySummary.empty();
    }
  }

  /// Calculate summary from ActivityModel (LocalStorage)
  DailySummary _calculateSummaryFromModels(List<model.ActivityModel> activities) {
    int totalSleepMinutes = 0;
    double totalFeedingMl = 0;
    int feedingCount = 0;
    int diaperCount = 0;
    double? lastTemperature;
    DateTime? lastTempTime;

    // Previous day stats for comparison (mock data for now)
    const prevSleepMinutes = 600.0; // 10 hours average
    const prevFeedingMl = 800.0;
    const prevDiaperCount = 8.0;

    for (final activity in activities) {
      switch (activity.type) {
        case model.ActivityType.sleep:
          if (activity.durationMinutes != null) {
            totalSleepMinutes += activity.durationMinutes!;
          }
          break;
        case model.ActivityType.feeding:
          feedingCount++;
          if (activity.amountMl != null) {
            totalFeedingMl += activity.amountMl!;
          }
          break;
        case model.ActivityType.diaper:
          diaperCount++;
          break;
        case model.ActivityType.health:
          if (activity.temperatureCelsius != null) {
            final activityTime = DateTime.parse(activity.timestamp);
            if (lastTempTime == null || activityTime.isAfter(lastTempTime)) {
              lastTemperature = activity.temperatureCelsius;
              lastTempTime = activityTime;
            }
          }
          break;
        default:
          break;
      }
    }

    return DailySummary(
      totalSleepMinutes: totalSleepMinutes,
      totalFeedingMl: totalFeedingMl,
      feedingCount: feedingCount,
      diaperCount: diaperCount,
      lastTemperature: lastTemperature,
      sleepTrend: _calculateTrend(totalSleepMinutes.toDouble(), prevSleepMinutes),
      feedingTrend: _calculateTrend(totalFeedingMl, prevFeedingMl),
      diaperTrend: _calculateTrend(diaperCount.toDouble(), prevDiaperCount),
      insightMessage: _generateInsight(
        totalSleepMinutes,
        totalFeedingMl,
        diaperCount,
        lastTemperature,
      ),
    );
  }

  DailySummary _calculateSummary(List<ActivityEntity> activities) {
    int totalSleepMinutes = 0;
    double totalFeedingMl = 0;
    int feedingCount = 0; // 🆕 추가
    int diaperCount = 0;
    double? lastTemperature;
    DateTime? lastTempTime;

    // Previous day stats for comparison (mock data for now)
    const prevSleepMinutes = 600.0; // 10 hours average
    const prevFeedingMl = 800.0;
    const prevDiaperCount = 8.0;

    for (final activity in activities) {
      switch (activity.type) {
        case ActivityType.sleep:
          if (activity.durationMinutes != null) {
            totalSleepMinutes += activity.durationMinutes!;
          }
          break;
        case ActivityType.feeding:
          feedingCount++; // 🆕 추가
          if (activity.amountMl != null) {
            totalFeedingMl += activity.amountMl!;
          }
          break;
        case ActivityType.diaper:
          diaperCount++;
          break;
        case ActivityType.health:
          if (activity.temperatureCelsius != null) {
            final activityTime = activity.timestamp;
            if (lastTempTime == null || activityTime.isAfter(lastTempTime)) {
              lastTemperature = activity.temperatureCelsius;
              lastTempTime = activityTime;
            }
          }
          break;
        default:
          break;
      }
    }

    return DailySummary(
      totalSleepMinutes: totalSleepMinutes,
      totalFeedingMl: totalFeedingMl,
      feedingCount: feedingCount, // 🆕 추가
      diaperCount: diaperCount,
      lastTemperature: lastTemperature,
      sleepTrend: _calculateTrend(totalSleepMinutes.toDouble(), prevSleepMinutes),
      feedingTrend: _calculateTrend(totalFeedingMl, prevFeedingMl),
      diaperTrend: _calculateTrend(diaperCount.toDouble(), prevDiaperCount),
      insightMessage: _generateInsight(
        totalSleepMinutes,
        totalFeedingMl,
        diaperCount,
        lastTemperature,
      ),
    );
  }

  Trend _calculateTrend(double current, double previous) {
    if (current > previous * 1.1) return Trend.up;
    if (current < previous * 0.9) return Trend.down;
    return Trend.stable;
  }

  String _generateInsight(
    int sleepMinutes,
    double feedingMl,
    int diaperCount,
    double? temperature,
  ) {
    // Generate encouraging AI-like message based on data
    if (sleepMinutes == 0 && feedingMl == 0 && diaperCount == 0) {
      return "Start tracking today's activities to see personalized insights! 📊";
    }

    if (sleepMinutes >= 600) {
      // 10+ hours
      return "Great job! Your baby is getting plenty of rest today. 🌙✨";
    } else if (sleepMinutes >= 480) {
      // 8+ hours
      return "Good progress! Keep maintaining this healthy sleep routine. 😊";
    } else if (sleepMinutes > 0 && sleepMinutes < 300) {
      // Less than 5 hours
      return "Your baby might need more rest. Try following the Sweet Spot! 💤";
    }

    if (temperature != null && temperature >= 38.0) {
      return "Monitor your baby's temperature closely and consult a doctor if needed. 🏥";
    }

    if (diaperCount >= 6) {
      return "Excellent! Your baby is well-hydrated and healthy. 💧";
    }

    return "You're doing great! Keep tracking to see more insights. 💙";
  }
}

class DailySummary {
  final int totalSleepMinutes;
  final double totalFeedingMl;
  final int feedingCount; // 🆕 추가
  final int diaperCount;
  final double? lastTemperature;
  final Trend sleepTrend;
  final Trend feedingTrend;
  final Trend diaperTrend;
  final String insightMessage;

  DailySummary({
    required this.totalSleepMinutes,
    required this.totalFeedingMl,
    required this.feedingCount, // 🆕 추가
    required this.diaperCount,
    this.lastTemperature,
    required this.sleepTrend,
    required this.feedingTrend,
    required this.diaperTrend,
    required this.insightMessage,
  });

  factory DailySummary.empty() {
    return DailySummary(
      totalSleepMinutes: 0,
      totalFeedingMl: 0,
      feedingCount: 0, // 🆕 추가
      diaperCount: 0,
      lastTemperature: null,
      sleepTrend: Trend.stable,
      feedingTrend: Trend.stable,
      diaperTrend: Trend.stable,
      insightMessage: "Start tracking today's activities! 📊",
    );
  }

  String get sleepFormatted {
    if (totalSleepMinutes == 0) return '0h 0m';
    final hours = totalSleepMinutes ~/ 60;
    final minutes = totalSleepMinutes % 60;
    if (hours == 0) return '${minutes}m';
    if (minutes == 0) return '${hours}h';
    return '${hours}h ${minutes}m';
  }

  String get feedingFormatted {
    if (totalFeedingMl == 0) return '0 ml';
    return '${totalFeedingMl.toStringAsFixed(0)} ml';
  }

  String temperatureFormatted(AppLocalizations l10n) {
    if (lastTemperature == null) return l10n.translate('summary_no_data_available');
    return '${lastTemperature!.toStringAsFixed(1)}°C';
  }
}

enum Trend {
  up,
  down,
  stable,
}
