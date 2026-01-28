import 'package:supabase_flutter/supabase_flutter.dart';
import 'local_storage_service.dart';

/// 계정 삭제 서비스
/// GDPR/CCPA 준수를 위한 완전한 데이터 삭제 처리
class AccountDeletionService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final LocalStorageService _localStorage = LocalStorageService();

  /// 계정 완전 삭제 (7일 유예 기간 없음)
  ///
  /// GDPR/CCPA 요구사항:
  /// 1. 모든 사용자 데이터 삭제
  /// 2. 로컬 캐시 삭제
  /// 3. Supabase Auth 계정 삭제
  /// 4. 즉시 로그아웃
  Future<AccountDeletionResult> deleteAccount() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        return AccountDeletionResult.failure('No user logged in');
      }

      // Step 1: 로컬 데이터 삭제
      await _localStorage.clearAllData();

      // Step 2: Supabase 데이터베이스 데이터 삭제
      // babies 테이블 (CASCADE로 activities 자동 삭제)
      await _supabase
          .from('babies')
          .delete()
          .eq('user_id', userId);

      // activities 테이블 (명시적 삭제 - 안전 장치)
      await _supabase
          .from('activities')
          .delete()
          .eq('user_id', userId);

      // profiles 테이블
      await _supabase
          .from('profiles')
          .delete()
          .eq('id', userId);

      // Step 3: Supabase Auth 계정 삭제
      // 주의: 이 작업은 되돌릴 수 없음
      await _supabase.auth.admin.deleteUser(userId);

      // Step 4: 로그아웃
      await _supabase.auth.signOut();

      return AccountDeletionResult.success();
    } on PostgrestException catch (e) {
      return AccountDeletionResult.failure('Database error: ${e.message}');
    } on AuthException catch (e) {
      return AccountDeletionResult.failure('Auth error: ${e.message}');
    } catch (e) {
      return AccountDeletionResult.failure('Unknown error: $e');
    }
  }

  /// 계정 삭제 전 데이터 요약 조회 (사용자에게 보여주기 위함)
  Future<AccountDataSummary> getAccountDataSummary() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        return AccountDataSummary.empty();
      }

      // 아기 수 조회
      final babiesResponse = await _supabase
          .from('babies')
          .select('id')
          .eq('user_id', userId);
      final babyCount = (babiesResponse as List).length;

      // 활동 기록 수 조회
      final activitiesResponse = await _supabase
          .from('activities')
          .select('id')
          .eq('user_id', userId);
      final activityCount = (activitiesResponse as List).length;

      // 계정 생성일
      final user = _supabase.auth.currentUser;
      final createdAt = user?.createdAt ?? DateTime.now();

      return AccountDataSummary(
        babyCount: babyCount,
        activityCount: activityCount,
        accountCreatedAt: createdAt,
      );
    } catch (e) {
      // 오류 발생 시 빈 요약 반환
      return AccountDataSummary.empty();
    }
  }
}

/// 계정 삭제 결과
class AccountDeletionResult {
  final bool success;
  final String? errorMessage;

  AccountDeletionResult.success()
      : success = true,
        errorMessage = null;

  AccountDeletionResult.failure(this.errorMessage) : success = false;
}

/// 계정 데이터 요약
class AccountDataSummary {
  final int babyCount;
  final int activityCount;
  final DateTime accountCreatedAt;

  AccountDataSummary({
    required this.babyCount,
    required this.activityCount,
    required this.accountCreatedAt,
  });

  AccountDataSummary.empty()
      : babyCount = 0,
        activityCount = 0,
        accountCreatedAt = DateTime.now();

  /// 총 데이터 항목 수
  int get totalDataCount => babyCount + activityCount;

  /// 계정 사용 기간 (일)
  int get accountAgeDays => DateTime.now().difference(accountCreatedAt).inDays;
}
