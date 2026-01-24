
/// Feeding Interval Calculator for predicting next feeding time
/// Uses last feeding amount to calculate variable intervals
class FeedingIntervalCalculator {
  /// Calculate next feeding time based on last feeding details
  ///
  /// For 72-day-old babies:
  /// - Small feeding (< 100ml): 3 hours interval
  /// - Medium feeding (100-150ml): 3.5 hours interval
  /// - Large feeding (> 150ml): 4 hours interval
  static FeedingPrediction calculateNextFeedingTime({
    required DateTime lastFeedingTime,
    required double lastFeedingAmountMl,
    required int ageInDays,
  }) {
    // Calculate base interval based on feeding amount
    final intervalHours = _calculateInterval(lastFeedingAmountMl, ageInDays);

    // Calculate next feeding time
    final nextFeedingTime = lastFeedingTime.add(
      Duration(minutes: (intervalHours * 60).round()),
    );

    // Calculate time until next feeding
    final now = DateTime.now();
    final minutesUntil = nextFeedingTime.difference(now).inMinutes;

    // Determine urgency
    final urgency = _calculateUrgency(minutesUntil);

    // Recommend next amount (based on age and pattern)
    final recommendedAmount = _getRecommendedAmount(ageInDays);

    return FeedingPrediction(
      nextFeedingTime: nextFeedingTime,
      minutesUntilFeeding: minutesUntil,
      urgencyLevel: urgency,
      recommendedAmountMl: recommendedAmount,
      intervalHours: intervalHours,
    );
  }

  /// Calculate feeding interval based on last amount
  static double _calculateInterval(double amountMl, int ageInDays) {
    if (ageInDays < 90) {
      // 0-3 months (including 72 days)
      if (amountMl < 100) {
        return 3.0; // Small feeding: 3 hours
      } else if (amountMl < 150) {
        return 3.5; // Medium feeding: 3.5 hours
      } else {
        return 4.0; // Large feeding: 4 hours
      }
    } else if (ageInDays < 180) {
      // 3-6 months
      if (amountMl < 150) {
        return 3.5;
      } else if (amountMl < 200) {
        return 4.0;
      } else {
        return 4.5;
      }
    } else {
      // 6+ months (with solids)
      return 4.0;
    }
  }

  /// Calculate urgency level
  static FeedingUrgency _calculateUrgency(int minutesUntil) {
    if (minutesUntil < -30) {
      // More than 30 minutes overdue
      return FeedingUrgency.critical;
    } else if (minutesUntil < 0) {
      // Overdue but within 30 minutes
      return FeedingUrgency.high;
    } else if (minutesUntil < 15) {
      // Within 15 minutes
      return FeedingUrgency.medium;
    } else if (minutesUntil < 30) {
      // Within 30 minutes
      return FeedingUrgency.low;
    } else {
      // More than 30 minutes away
      return FeedingUrgency.none;
    }
  }

  /// Get recommended feeding amount based on age
  static double _getRecommendedAmount(int ageInDays) {
    if (ageInDays < 30) {
      // 0-1 month: 60-90ml per feeding
      return 75.0;
    } else if (ageInDays < 90) {
      // 1-3 months (including 72 days): 120-150ml per feeding
      return 135.0;
    } else if (ageInDays < 180) {
      // 3-6 months: 150-180ml per feeding
      return 165.0;
    } else if (ageInDays < 270) {
      // 6-9 months: 180-210ml per feeding
      return 195.0;
    } else {
      // 9+ months: 210-240ml per feeding
      return 225.0;
    }
  }

  /// Convert ml to oz
  static double mlToOz(double ml) {
    return ml / 29.5735;
  }

  /// Convert oz to ml
  static double ozToMl(double oz) {
    return oz * 29.5735;
  }
}

/// Feeding Prediction Result
class FeedingPrediction {
  final DateTime nextFeedingTime;
  final int minutesUntilFeeding;
  final FeedingUrgency urgencyLevel;
  final double recommendedAmountMl;
  final double intervalHours;

  const FeedingPrediction({
    required this.nextFeedingTime,
    required this.minutesUntilFeeding,
    required this.urgencyLevel,
    required this.recommendedAmountMl,
    required this.intervalHours,
  });

  bool get isUrgent => urgencyLevel == FeedingUrgency.high || urgencyLevel == FeedingUrgency.critical;
  bool get isOverdue => minutesUntilFeeding < 0;

  /// Get recommended amount in oz
  double get recommendedAmountOz => FeedingIntervalCalculator.mlToOz(recommendedAmountMl);
}

/// Feeding Urgency Levels
enum FeedingUrgency {
  none,     // More than 30 minutes away
  low,      // Within 30 minutes
  medium,   // Within 15 minutes
  high,     // Overdue but within 30 minutes
  critical, // More than 30 minutes overdue
}
