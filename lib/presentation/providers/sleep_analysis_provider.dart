import 'package:flutter/foundation.dart';
import '../../data/models/activity_model.dart';
import '../../data/models/sleep_analysis_data.dart';
import '../../data/services/sleep_analysis_service.dart';
import '../../data/services/local_storage_service.dart';

/// 수면 분석 Provider
/// 수면 데이터를 분석하고 인사이트를 제공
class SleepAnalysisProvider extends ChangeNotifier {
  final SleepAnalysisService _analysisService = SleepAnalysisService();
  final LocalStorageService _storage = LocalStorageService();

  SleepAnalysisData? _weeklyAnalysis;
  SleepAnalysisData? _monthlyAnalysis;
  bool _isLoading = false;
  String? _error;

  SleepAnalysisData? get weeklyAnalysis => _weeklyAnalysis;
  SleepAnalysisData? get monthlyAnalysis => _monthlyAnalysis;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// 주간 분석 로드
  Future<void> loadWeeklyAnalysis() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final activities = await _storage.getActivities();
      final sleepActivities = activities
          .where((a) => a.type == ActivityType.sleep)
          .toList();

      _weeklyAnalysis = _analysisService.analyzeWeekly(sleepActivities);

      if (kDebugMode) {
        print('✅ [SleepAnalysisProvider] Weekly analysis loaded: ${_weeklyAnalysis.toString()}');
      }
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('❌ [SleepAnalysisProvider] Failed to load weekly analysis: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 월간 분석 로드
  Future<void> loadMonthlyAnalysis() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final activities = await _storage.getActivities();
      final sleepActivities = activities
          .where((a) => a.type == ActivityType.sleep)
          .toList();

      _monthlyAnalysis = _analysisService.analyzeMonthly(sleepActivities);

      if (kDebugMode) {
        print('✅ [SleepAnalysisProvider] Monthly analysis loaded: ${_monthlyAnalysis.toString()}');
      }
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('❌ [SleepAnalysisProvider] Failed to load monthly analysis: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 커스텀 기간 분석
  Future<SleepAnalysisData?> analyzeCustomPeriod({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final activities = await _storage.getActivities();
      final periodActivities = activities.where((a) {
        if (a.type != ActivityType.sleep) return false;
        final date = DateTime.parse(a.timestamp);
        return date.isAfter(startDate) && date.isBefore(endDate);
      }).toList();

      // 이전 기간 데이터 (비교용)
      final periodDuration = endDate.difference(startDate);
      final prevStartDate = startDate.subtract(periodDuration);
      final prevActivities = activities.where((a) {
        if (a.type != ActivityType.sleep) return false;
        final date = DateTime.parse(a.timestamp);
        return date.isAfter(prevStartDate) && date.isBefore(startDate);
      }).toList();

      return _analysisService.analyzeSleepPeriod(
        sleepActivities: periodActivities,
        startDate: startDate,
        endDate: endDate,
        previousPeriodActivities: prevActivities,
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ [SleepAnalysisProvider] Failed to analyze custom period: $e');
      }
      return null;
    }
  }

  /// 모든 분석 새로고침
  Future<void> refreshAll() async {
    await Future.wait([
      loadWeeklyAnalysis(),
      loadMonthlyAnalysis(),
    ]);
  }

  /// 초기화
  void clear() {
    _weeklyAnalysis = null;
    _monthlyAnalysis = null;
    _error = null;
    notifyListeners();
  }
}
