import 'package:flutter/foundation.dart';

/// Wake Window Calculator for predicting optimal sleep times
/// Based on age-appropriate wake windows
class WakeWindowCalculator {
  /// Calculate next sweet spot time based on last wake time and baby's age
  ///
  /// For 72-day-old babies (2-3 months), standard wake window is 80-90 minutes
  static WakeWindowPrediction calculateNextSleepTime({
    required DateTime lastWakeTime,
    required int ageInDays,
  }) {
    // Age-based wake window standards (in minutes)
    final int standardWakeWindow = _getStandardWakeWindow(ageInDays);

    // Calculate next sweet spot
    final nextSweetSpot = lastWakeTime.add(Duration(minutes: standardWakeWindow));

    // Calculate time until sweet spot
    final now = DateTime.now();
    final minutesUntil = nextSweetSpot.difference(now).inMinutes;

    // Determine urgency level
    final urgency = _calculateUrgency(minutesUntil, standardWakeWindow);

    // Calculate confidence (higher when closer to expected pattern)
    final confidence = _calculateConfidence(minutesUntil, standardWakeWindow);

    return WakeWindowPrediction(
      nextSweetSpot: nextSweetSpot,
      minutesUntilSweetSpot: minutesUntil,
      urgencyLevel: urgency,
      confidence: confidence,
      standardWakeWindow: standardWakeWindow,
    );
  }

  /// Get standard wake window in minutes based on baby's age
  static int _getStandardWakeWindow(int ageInDays) {
    if (ageInDays < 30) {
      // 0-1 month: 45-60 minutes
      return 50;
    } else if (ageInDays < 90) {
      // 1-3 months (including 72 days): 80-90 minutes
      return 80;
    } else if (ageInDays < 180) {
      // 3-6 months: 90-120 minutes
      return 105;
    } else if (ageInDays < 270) {
      // 6-9 months: 120-180 minutes
      return 150;
    } else if (ageInDays < 365) {
      // 9-12 months: 150-240 minutes
      return 195;
    } else {
      // 12+ months: 180-300 minutes
      return 240;
    }
  }

  /// Calculate urgency level based on time until sweet spot
  static SleepUrgency _calculateUrgency(int minutesUntil, int standardWindow) {
    if (minutesUntil < -15) {
      // More than 15 minutes past sweet spot
      return SleepUrgency.critical;
    } else if (minutesUntil < 0) {
      // Past sweet spot but within 15 minutes
      return SleepUrgency.high;
    } else if (minutesUntil < 15) {
      // Within 15 minutes of sweet spot
      return SleepUrgency.medium;
    } else {
      // More than 15 minutes away
      return SleepUrgency.low;
    }
  }

  /// Calculate confidence level (0.0 to 1.0)
  static double _calculateConfidence(int minutesUntil, int standardWindow) {
    // Confidence is highest around the sweet spot and decreases over time
    final minutesFromIdeal = minutesUntil.abs();

    if (minutesFromIdeal < 5) {
      return 0.95;
    } else if (minutesFromIdeal < 15) {
      return 0.85;
    } else if (minutesFromIdeal < 30) {
      return 0.70;
    } else {
      return 0.50;
    }
  }
}

/// Wake Window Prediction Result
class WakeWindowPrediction {
  final DateTime nextSweetSpot;
  final int minutesUntilSweetSpot;
  final SleepUrgency urgencyLevel;
  final double confidence;
  final int standardWakeWindow;

  const WakeWindowPrediction({
    required this.nextSweetSpot,
    required this.minutesUntilSweetSpot,
    required this.urgencyLevel,
    required this.confidence,
    required this.standardWakeWindow,
  });

  bool get isUrgent => urgencyLevel == SleepUrgency.high || urgencyLevel == SleepUrgency.critical;
  bool get isPastSweetSpot => minutesUntilSweetSpot < 0;
}

/// Sleep Urgency Levels
enum SleepUrgency {
  low,      // More than 15 minutes until sweet spot
  medium,   // Within 15 minutes of sweet spot
  high,     // Past sweet spot but within 15 minutes
  critical, // More than 15 minutes past sweet spot
}
