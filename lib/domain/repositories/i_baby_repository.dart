import '../entities/baby_entity.dart';

/// 아기 데이터 Repository 인터페이스
abstract class IBabyRepository {
  /// 아기 정보 저장
  ///
  /// [userId]: 사용자 ID
  /// [baby]: 저장할 아기 엔티티
  Future<void> saveBaby({
    required String userId,
    required BabyEntity baby,
  });

  /// 아기 정보 조회
  ///
  /// [babyId]: 아기 ID
  /// Returns: 아기 엔티티 또는 null (존재하지 않을 경우)
  Future<BabyEntity?> getBaby({
    required String babyId,
  });

  /// 사용자의 모든 아기 조회
  ///
  /// [userId]: 사용자 ID
  /// Returns: 아기 엔티티 목록
  Future<List<BabyEntity>> getBabiesByUser({
    required String userId,
  });

  /// 아기 정보 수정
  ///
  /// [baby]: 수정할 아기 엔티티
  Future<void> updateBaby({
    required BabyEntity baby,
  });

  /// 아기 삭제
  ///
  /// [babyId]: 삭제할 아기 ID
  Future<void> deleteBaby({
    required String babyId,
  });

  /// 현재 선택된 아기 (로컬 캐시)
  ///
  /// Returns: 현재 선택된 아기 엔티티 또는 null
  Future<BabyEntity?> getCurrentBaby();

  /// 현재 아기 설정 (로컬 캐시)
  ///
  /// [baby]: 선택할 아기 엔티티
  Future<void> setCurrentBaby(BabyEntity baby);

  /// 현재 아기 ID 가져오기 (로컬 캐시)
  ///
  /// Returns: 현재 선택된 아기 ID 또는 null
  Future<String?> getCurrentBabyId();

  /// 실시간 아기 정보 스트림
  ///
  /// [babyId]: 아기 ID
  /// Returns: 아기 엔티티 스트림
  Stream<BabyEntity?> watchBaby({
    required String babyId,
  });

  /// 사용자의 아기 목록 실시간 스트림
  ///
  /// [userId]: 사용자 ID
  /// Returns: 아기 엔티티 목록 스트림
  Stream<List<BabyEntity>> watchBabies({
    required String userId,
  });
}
