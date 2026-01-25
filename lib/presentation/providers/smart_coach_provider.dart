import 'package:flutter/material.dart';
import '../../data/models/daily_timeline.dart';
import '../../data/models/timeline_item.dart';
import '../../data/models/alert_chain.dart';
import '../../data/models/coaching_message.dart';
import '../../data/services/smart_coach_service.dart';

/// 스마트 코치 Provider
class SmartCoachProvider extends ChangeNotifier {
  final SmartCoachService _smartCoachService = SmartCoachService();

  DailyTimeline _timeline = DailyTimeline.empty();
  CoachingMessage? _currentMessage;
  bool _isLoading = false;
  String? _error;

  // Getters
  DailyTimeline get timeline => _timeline;
  CoachingMessage? get currentMessage => _currentMessage;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<TimelineItem> get pastItems => _timeline.pastItems;
  List<TimelineItem> get upcomingItems => _timeline.upcomingItems;
  TimelineItem? get nextItem => _timeline.nextItem;
  List<AlertChain> get activeChains => _timeline.activeChains;

  /// 타임라인 로드
  Future<void> loadTimeline({
    required String userId,
    required String babyName,
    required int ageInMonths,
    required DateTime? lastWakeUpTime,
    required DateTime? lastFeedingTime,
    required bool isKorean,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _timeline = await _smartCoachService.generateDailyTimeline(
        userId: userId,
        babyName: babyName,
        ageInMonths: ageInMonths,
        lastWakeUpTime: lastWakeUpTime,
        lastFeedingTime: lastFeedingTime,
        isKorean: isKorean,
      );

      _currentMessage = _smartCoachService.getCurrentCoachingMessage(
        timeline: _timeline,
        babyName: babyName,
        isKorean: isKorean,
      );
    } catch (e) {
      _error = e.toString();
      print('⚠️ [SmartCoachProvider] Error loading timeline: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 활동 기록 후 업데이트
  Future<void> onActivityLogged({
    required TimelineItem newActivity,
    required String babyName,
    required int ageInMonths,
    required bool isKorean,
  }) async {
    try {
      _timeline = await _smartCoachService.onActivityLogged(
        currentTimeline: _timeline,
        newActivity: newActivity,
        babyName: babyName,
        ageInMonths: ageInMonths,
        isKorean: isKorean,
      );

      _currentMessage = _smartCoachService.getCurrentCoachingMessage(
        timeline: _timeline,
        babyName: babyName,
        isKorean: isKorean,
      );

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      print('⚠️ [SmartCoachProvider] Error updating timeline: $e');
      notifyListeners();
    }
  }

  /// 코칭 메시지 닫기
  void dismissCoachingMessage() {
    _currentMessage = null;
    notifyListeners();
  }

  /// 타임라인 새로고침
  Future<void> refresh({
    required String userId,
    required String babyName,
    required int ageInMonths,
    required DateTime? lastWakeUpTime,
    required DateTime? lastFeedingTime,
    required bool isKorean,
  }) async {
    await loadTimeline(
      userId: userId,
      babyName: babyName,
      ageInMonths: ageInMonths,
      lastWakeUpTime: lastWakeUpTime,
      lastFeedingTime: lastFeedingTime,
      isKorean: isKorean,
    );
  }
}
