import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/activity_model.dart';
import '../models/baby_model.dart';

/// 로컬 저장소 서비스 (SharedPreferences 사용)
class LocalStorageService {
  static const String _activitiesKey = 'activities';
  static const String _currentBabyKey = 'current_baby';
  static const String _currentBabyIdKey = 'current_baby_id';  // 🆕 다중 아기 지원
  static const String _allBabiesKey = 'all_babies';  // 🆕 모든 아기 목록
  static const String _migrationVersionKey = 'migration_version';

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
      if (kDebugMode) {
        print('✅ [LocalStorage] Migrated ${activities.length} activities with babyId');
      }
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

  /// 날짜 범위로 활동 가져오기
  /// [startDate]와 [endDate] 사이의 활동을 반환 (양쪽 끝 포함)
  /// InsightCalculator에서 사용
  Future<List<ActivityModel>> getActivitiesByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final allActivities = await getActivities();

    // 시작일은 00:00:00으로, 종료일은 23:59:59로 정규화
    final normalizedStart = DateTime(startDate.year, startDate.month, startDate.day);
    final normalizedEnd = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);

    return allActivities.where((activity) {
      final activityDate = DateTime.parse(activity.timestamp);
      return activityDate.isAfter(normalizedStart.subtract(const Duration(seconds: 1))) &&
          activityDate.isBefore(normalizedEnd.add(const Duration(seconds: 1)));
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
    if (kDebugMode) {
      print('📝 [Storage] Updating activity: ${activity.id}');
    }

    try {
      final activities = await getActivities();
      final index = activities.indexWhere((a) => a.id == activity.id);

      if (index != -1) {
        activities[index] = activity;

        final prefs = await SharedPreferences.getInstance();
        final jsonList = activities.map((a) => a.toJson()).toList();
        await prefs.setString(_activitiesKey, jsonEncode(jsonList));
        if (kDebugMode) {
          print('✅ [Storage] Activity updated successfully');
        }
      } else {
        if (kDebugMode) {
          print('⚠️ [Storage] Activity not found for update: ${activity.id}');
        }
        // 없으면 새로 저장
        await saveActivity(activity);
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [Storage] Failed to update activity: $e');
      }
      rethrow;
    }
  }

  /// 활동 삭제
  Future<void> deleteActivity(String activityId) async {
    if (kDebugMode) {
      print('🗑️ [Storage] Deleting activity: $activityId');
    }

    try {
      final activities = await getActivities();
      final originalLength = activities.length;
      activities.removeWhere((a) => a.id == activityId);

      if (activities.length < originalLength) {
        final prefs = await SharedPreferences.getInstance();
        final jsonList = activities.map((a) => a.toJson()).toList();
        await prefs.setString(_activitiesKey, jsonEncode(jsonList));
        if (kDebugMode) {
          print('✅ [Storage] Activity deleted successfully');
        }
      } else {
        if (kDebugMode) {
          print('⚠️ [Storage] Activity not found for deletion: $activityId');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [Storage] Failed to delete activity: $e');
      }
      rethrow;
    }
  }

  /// 모든 데이터 삭제
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // ==================== Account Deletion Methods (GDPR/CCPA) ====================

  /// 모든 활동 데이터 삭제
  Future<void> clearAllActivities() async {
    if (kDebugMode) {
      print('🗑️ [Storage] Clearing all activities');
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_activitiesKey);
  }

  /// 모든 아기 데이터 삭제
  Future<void> clearAllBabies() async {
    if (kDebugMode) {
      print('🗑️ [Storage] Clearing all babies');
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentBabyKey);
    await prefs.remove(_currentBabyIdKey);
    await prefs.remove(_allBabiesKey);
  }

  /// 사용자 설정 삭제
  Future<void> clearUserPreferences() async {
    if (kDebugMode) {
      print('🗑️ [Storage] Clearing user preferences');
    }
    final prefs = await SharedPreferences.getInstance();
    // 앱 설정 관련 키들 삭제 (필요시 추가)
    await prefs.remove('language');
    await prefs.remove('theme');
    await prefs.remove('notifications_enabled');
  }

  /// 캐시 데이터 삭제
  Future<void> clearCache() async {
    if (kDebugMode) {
      print('🗑️ [Storage] Clearing cache');
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_migrationVersionKey);
    // 기타 캐시 키들 삭제 (필요시 추가)
  }

  /// 모든 데이터 삭제 (계정 삭제용)
  /// clearAll()과 동일하지만 명시적으로 GDPR/CCPA 준수 목적
  Future<void> clearAllData() async {
    if (kDebugMode) {
      print('🗑️ [Storage] Clearing ALL data for account deletion');
    }
    await clearAllActivities();
    await clearAllBabies();
    await clearUserPreferences();
    await clearCache();

    // 마지막으로 모든 키 삭제 (안전 장치)
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (kDebugMode) {
      print('✅ [Storage] All local data cleared');
    }
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

  // ==================== Multi-Baby Support ====================

  /// 현재 선택된 아기 ID 저장
  Future<void> setCurrentBabyId(String babyId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentBabyIdKey, babyId);
  }

  /// 현재 선택된 아기 ID 가져오기
  Future<String?> getCurrentBabyId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentBabyIdKey);
  }

  /// 모든 아기 가져오기
  Future<List<BabyModel>> getAllBabies() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_allBabiesKey);

    if (jsonString == null || jsonString.isEmpty) {
      // 마이그레이션: 기존 단일 아기를 리스트로 변환
      final singleBaby = await getBaby();
      if (singleBaby != null) {
        final babies = [singleBaby];
        await saveAllBabies(babies);
        return babies;
      }
      return [];
    }

    try {
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList
          .map((json) => BabyModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ [LocalStorage] Error parsing babies: $e');
      }
      return [];
    }
  }

  /// 모든 아기 저장
  Future<void> saveAllBabies(List<BabyModel> babies) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = babies.map((b) => b.toJson()).toList();
    await prefs.setString(_allBabiesKey, jsonEncode(jsonList));
  }

  /// 아기 추가
  Future<void> addBaby(BabyModel baby) async {
    final babies = await getAllBabies();
    babies.add(baby);
    await saveAllBabies(babies);

    // 현재 아기로 설정
    await saveBaby(baby);
    await setCurrentBabyId(baby.id);
  }

  /// 아기 삭제
  Future<void> removeBaby(String babyId) async {
    final babies = await getAllBabies();
    babies.removeWhere((b) => b.id == babyId);
    await saveAllBabies(babies);

    // 현재 아기가 삭제된 경우 첫 번째 아기로 전환
    final currentId = await getCurrentBabyId();
    if (currentId == babyId) {
      final prefs = await SharedPreferences.getInstance();
      if (babies.isNotEmpty) {
        await saveBaby(babies.first);
        await setCurrentBabyId(babies.first.id);
      } else {
        await deleteBaby();
        await prefs.remove(_currentBabyIdKey);
      }
    }
  }

  // ==================== Data Migration ====================

  /// 현재 마이그레이션 버전 확인
  Future<int> getMigrationVersion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_migrationVersionKey) ?? 0;
  }

  /// 마이그레이션 버전 업데이트
  Future<void> setMigrationVersion(int version) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_migrationVersionKey, version);
  }

  /// 🆕 Migration v2: useCorrectedAge 필드 추가
  /// 기존 조산아 데이터에 useCorrectedAge = true 기본값 적용
  Future<void> migrateToV2() async {
    final currentVersion = await getMigrationVersion();
    if (currentVersion >= 2) {
      if (kDebugMode) {
        print('✅ [Migration] Already at version 2 or higher');
      }
      return;
    }

    if (kDebugMode) {
      print('🔄 [Migration] Starting migration to v2...');
    }

    try {
      // 1. 현재 아기 마이그레이션
      final currentBaby = await getBaby();
      if (currentBaby != null) {
        // useCorrectedAge 필드가 없으면 기본값 적용
        // fromJson에서 이미 처리되지만, 명시적으로 저장
        final migrated = currentBaby.copyWith(
          useCorrectedAge: currentBaby.isPremature ? true : currentBaby.useCorrectedAge,
          updatedAt: DateTime.now().toIso8601String(),
        );
        await saveBaby(migrated);

        if (kDebugMode) {
          print('✅ [Migration] Migrated current baby: ${currentBaby.name}');
        }
      }

      // 2. 모든 아기 마이그레이션
      final allBabies = await getAllBabies();
      if (allBabies.isNotEmpty) {
        final migratedBabies = allBabies.map((baby) {
          return baby.copyWith(
            useCorrectedAge: baby.isPremature ? true : baby.useCorrectedAge,
            updatedAt: DateTime.now().toIso8601String(),
          );
        }).toList();
        await saveAllBabies(migratedBabies);

        if (kDebugMode) {
          print('✅ [Migration] Migrated ${migratedBabies.length} babies');
        }
      }

      // 3. 마이그레이션 버전 업데이트
      await setMigrationVersion(2);

      if (kDebugMode) {
        print('✅ [Migration] Successfully migrated to v2');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [Migration] Failed to migrate to v2: $e');
      }
      rethrow;
    }
  }
}
