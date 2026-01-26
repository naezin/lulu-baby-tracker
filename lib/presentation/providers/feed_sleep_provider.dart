import 'package:flutter/foundation.dart';
import '../../domain/entities/feed_sleep_correlation.dart';
import '../../data/services/feed_sleep_correlation_engine.dart';
import '../../domain/repositories/i_activity_repository.dart';
import '../../di/injection_container.dart' as di;

class FeedSleepProvider extends ChangeNotifier {
  FeedSleepCorrelation? _correlation;
  bool _isLoading = false;
  String? _error;

  late final FeedSleepCorrelationEngine _engine;

  FeedSleepProvider() {
    // ✅ GetIt으로 Repository 주입
    final IActivityRepository repository = di.sl<IActivityRepository>();
    _engine = FeedSleepCorrelationEngine(repository: repository);
  }

  FeedSleepCorrelation? get correlation => _correlation;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasData => _correlation != null && _correlation!.hasEnoughData;
  bool get isReliable => _correlation != null && _correlation!.isReliable;

  Future<void> analyze({required String babyId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _correlation = await _engine.analyze(babyId: babyId);
      print(
          '📊 [FeedSleepProvider] Analysis complete: ${_correlation!.dataPoints} days, confidence: ${_correlation!.confidence}');
    } catch (e) {
      _error = e.toString();
      print('⚠️ [FeedSleepProvider] Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void useDefaultsFor(int ageInMonths) {
    _correlation = FeedSleepCorrelation.defaultFor(ageInMonths);
    notifyListeners();
  }

  DateTime? getRecommendedLastFeedingTime(DateTime plannedBedtime) {
    if (_correlation == null) return null;
    return plannedBedtime
        .subtract(Duration(minutes: _correlation!.optimalGapMinutes));
  }

  double get recommendedAmount => _correlation?.optimalAmountMl ?? 150.0;
  int get recommendedGapMinutes => _correlation?.optimalGapMinutes ?? 30;
}
