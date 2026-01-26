import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/activity_model.dart';
import '../models/baby_model.dart';

/// 로컬 저장소 서비스 (SharedPreferences 사용)
class LocalStorageService {
  static const String _activitiesKey = 'activities';
  static const String _currentBabyKey = 'current_baby';

  /// 활동 저장
  Future<void> saveActivity(ActivityModel activity) async {
    final prefs = await SharedPreferences.getInstance();

    // 기존 활동 목록 가져오기
    final activities = await getActivities();

    // 새 활동 추가
    activities.add(activity);

    // JSON으로 변환하여 저장
    final jsonList = activities.map((a) => a.toJson()).toList();
    await prefs.setString(_activitiesKey, jsonEncode(jsonList));
  }

  /// 모든 활동 가져오기
  Future<List<ActivityModel>> getActivities() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_activitiesKey);

    if (jsonString == null) return [];

    final List<dynamic> jsonList = jsonDecode(jsonString);

    // 🔧 기존 데이터 마이그레이션: babyId가 없는 활동에 현재 아기 ID 추가
    final baby = await getBaby();
    final defaultBabyId = baby?.id ?? 'unknown';

    final activities = jsonList.map((json) {
      // babyId가 없으면 기본값 추가
      if (json['babyId'] == null) {
        json['babyId'] = defaultBabyId;
      }
      return ActivityModel.fromJson(json);
    }).toList();

    // 마이그레이션된 데이터 저장
    if (jsonList.any((json) => json['babyId'] == null)) {
      await _saveAllActivities(activities);
      print('✅ [LocalStorage] Migrated ${activities.length} activities with babyId');
    }

    return activities;
  }

  /// 모든 활동을 한번에 저장 (내부 헬퍼)
  Future<void> _saveAllActivities(List<ActivityModel> activities) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = activities.map((a) => a.toJson()).toList();
    await prefs.setString(_activitiesKey, jsonEncode(jsonList));
  }

  /// 특정 날짜의 활동 가져오기
  Future<List<ActivityModel>> getActivitiesByDate(DateTime date) async {
    final allActivities = await getActivities();

    return allActivities.where((activity) {
      final activityDate = DateTime.parse(activity.timestamp);
      return activityDate.year == date.year &&
          activityDate.month == date.month &&
          activityDate.day == date.day;
    }).toList();
  }

  /// 특정 타입의 활동 가져오기
  Future<List<ActivityModel>> getActivitiesByType(ActivityType type) async {
    final allActivities = await getActivities();
    return allActivities.where((a) => a.type == type).toList();
  }

  /// 오늘의 수면 활동 가져오기
  Future<List<ActivityModel>> getTodaySleepActivities() async {
    final today = DateTime.now();
    final todayActivities = await getActivitiesByDate(today);
    return todayActivities.where((a) => a.type == ActivityType.sleep).toList();
  }

  /// 마지막 기상 시간 가져오기
  /// 수면이 끝난 시간 (endTime)을 기준으로 마지막 기상 시간을 반환
  /// 진행 중인 수면이 있고 이전에 끝난 수면이 있으면, 이전 수면의 endTime 사용
  /// 진행 중인 수면만 있으면 null 반환 (아직 깨어나지 않음)
  Future<DateTime?> getLastWakeUpTime() async {
    final sleepActivities = await getActivitiesByType(ActivityType.sleep);

    if (sleepActivities.isEmpty) return null;

    // 최근 수면 활동부터 정렬
    sleepActivities.sort((a, b) =>
      DateTime.parse(b.timestamp).compareTo(DateTime.parse(a.timestamp))
    );

    // endTime이 있는 (끝난) 수면 활동 찾기
    for (var sleep in sleepActivities) {
      if (sleep.endTime != null) {
        return DateTime.parse(sleep.endTime!);
      }
    }

    // 끝난 수면이 없으면 null 반환
    // (모든 수면이 진행 중이거나, 수면 기록이 endTime 없이 저장된 경우)
    return null;
  }

  /// 활동 업데이트
  Future<void> updateActivity(ActivityModel activity) async {
    final activities = await getActivities();
    final index = activities.indexWhere((a) => a.id == activity.id);

    if (index != -1) {
      activities[index] = activity;

      final prefs = await SharedPreferences.getInstance();
      final jsonList = activities.map((a) => a.toJson()).toList();
      await prefs.setString(_activitiesKey, jsonEncode(jsonList));
    }
  }

  /// 활동 삭제
  Future<void> deleteActivity(String activityId) async {
    final activities = await getActivities();
    activities.removeWhere((a) => a.id == activityId);

    final prefs = await SharedPreferences.getInstance();
    final jsonList = activities.map((a) => a.toJson()).toList();
    await prefs.setString(_activitiesKey, jsonEncode(jsonList));
  }

  /// 모든 데이터 삭제
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  /// 통계 데이터
  Future<Map<String, dynamic>> getStatistics() async {
    final activities = await getActivities();
    final sleepActivities = activities.where((a) => a.type == ActivityType.sleep).toList();

    // 평균 밤 깨는 횟수 계산 (지난 7일)
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    final recentNightWakings = sleepActivities.where((activity) {
      final date = DateTime.parse(activity.timestamp);
      return date.isAfter(sevenDaysAgo) &&
             date.hour >= 19 || date.hour <= 6; // 밤 시간
    }).length;

    return {
      'totalActivities': activities.length,
      'sleepCount': sleepActivities.length,
      'avgNightWakings': recentNightWakings ~/ 7,
    };
  }

  // ==================== Baby Management ====================

  /// 아기 정보 저장
  Future<void> saveBaby(BabyModel baby) async {
    final prefs = await SharedPreferences.getInstance();
    final babyJson = jsonEncode(baby.toJson());
    await prefs.setString(_currentBabyKey, babyJson);
  }

  /// 현재 아기 정보 가져오기
  Future<BabyModel?> getBaby() async {
    final prefs = await SharedPreferences.getInstance();
    final babyJson = prefs.getString(_currentBabyKey);

    if (babyJson == null) return null;

    try {
      final babyMap = jsonDecode(babyJson) as Map<String, dynamic>;
      return BabyModel.fromJson(babyMap);
    } catch (e) {
      // JSON 파싱 오류 발생 시 null 반환
      return null;
    }
  }

  /// 아기 정보 업데이트
  Future<void> updateBaby(BabyModel baby) async {
    await saveBaby(baby);
  }

  /// 아기 정보 삭제
  Future<void> deleteBaby() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentBabyKey);
  }

  /// 아기가 등록되어 있는지 확인
  Future<bool> hasBaby() async {
    final baby = await getBaby();
    return baby != null;
  }
}
