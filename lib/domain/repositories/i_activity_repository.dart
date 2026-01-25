import '../entities/activity_entity.dart';

/// 활동 데이터 Repository 인터페이스
///
/// Firebase/Supabase 구현체는 이 인터페이스를 구현해야 합니다.
/// 비즈니스 로직은 이 인터페이스에만 의존하며, 구체적인 구현체를 알지 못합니다.
abstract class IActivityRepository {
  /// 활동 저장
  ///
  /// [babyId]: 아기 ID
  /// [activity]: 저장할 활동 엔티티
  Future<void> saveActivity({
    required String babyId,
    required ActivityEntity activity,
  });

  /// 활동 목록 조회 (기간별)
  ///
  /// [babyId]: 아기 ID
  /// [startDate]: 조회 시작일 (null이면 제한 없음)
  /// [endDate]: 조회 종료일 (null이면 제한 없음)
  /// [type]: 활동 타입 필터 (null이면 모든 타입)
  /// [limit]: 최대 조회 개수 (null이면 제한 없음)
  Future<List<ActivityEntity>> getActivities({
    required String babyId,
    DateTime? startDate,
    DateTime? endDate,
    ActivityType? type,
    int? limit,
  });

  /// 특정 활동 조회
  ///
  /// [babyId]: 아기 ID
  /// [activityId]: 활동 ID
  /// Returns: 활동 엔티티 또는 null (존재하지 않을 경우)
  Future<ActivityEntity?> getActivityById({
    required String babyId,
    required String activityId,
  });

  /// 활동 수정
  ///
  /// [babyId]: 아기 ID
  /// [activity]: 수정할 활동 엔티티
  Future<void> updateActivity({
    required String babyId,
    required ActivityEntity activity,
  });

  /// 활동 삭제
  ///
  /// [babyId]: 아기 ID
  /// [activityId]: 삭제할 활동 ID
  Future<void> deleteActivity({
    required String babyId,
    required String activityId,
  });

  /// 오늘의 활동 통계
  ///
  /// [babyId]: 아기 ID
  /// Returns: 오늘의 요약 데이터
  Future<DailySummary> getTodaySummary({
    required String babyId,
  });

  /// 특정 날짜의 활동 통계
  ///
  /// [babyId]: 아기 ID
  /// [date]: 조회할 날짜
  Future<DailySummary> getDailySummary({
    required String babyId,
    required DateTime date,
  });

  /// 실시간 활동 스트림 (선택적 구현)
  ///
  /// [babyId]: 아기 ID
  /// [startDate]: 조회 시작일
  /// [endDate]: 조회 종료일
  /// Returns: 활동 목록 스트림
  Stream<List<ActivityEntity>> watchActivities({
    required String babyId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// 특정 기간의 수면 패턴 분석
  ///
  /// [babyId]: 아기 ID
  /// [startDate]: 분석 시작일
  /// [endDate]: 분석 종료일
  /// Returns: 수면 활동 목록
  Future<List<ActivityEntity>> getSleepPattern({
    required String babyId,
    required DateTime startDate,
    required DateTime endDate,
  });

  /// 특정 기간의 수유 패턴 분석
  ///
  /// [babyId]: 아기 ID
  /// [startDate]: 분석 시작일
  /// [endDate]: 분석 종료일
  /// Returns: 수유 활동 목록
  Future<List<ActivityEntity>> getFeedingPattern({
    required String babyId,
    required DateTime startDate,
    required DateTime endDate,
  });

  /// 최근 N개의 활동 조회
  ///
  /// [babyId]: 아기 ID
  /// [type]: 활동 타입 (null이면 모든 타입)
  /// [limit]: 조회 개수 (기본값: 10)
  Future<List<ActivityEntity>> getRecentActivities({
    required String babyId,
    ActivityType? type,
    int limit = 10,
  });
}
