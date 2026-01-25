// import 'package:cloud_firestore/cloud_firestore.dart';  // ❌ Firebase 제거됨
// import 'package:firebase_auth/firebase_auth.dart';      // ❌ Firebase 제거됨
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get_it/get_it.dart';

// Domain Repositories
import '../domain/repositories/i_activity_repository.dart';
import '../domain/repositories/i_baby_repository.dart';
import '../domain/repositories/i_auth_repository.dart';
import '../domain/repositories/i_insight_repository.dart';
import '../domain/repositories/i_preference_repository.dart';

// Firebase Implementations (주석 처리 - Supabase로 마이그레이션 중)
// import '../data/repositories/firebase/firebase_activity_repository.dart';
// import '../data/repositories/firebase/firebase_baby_repository.dart';
// import '../data/repositories/firebase/firebase_auth_repository.dart';
// import '../data/repositories/firebase/firebase_insight_repository.dart';
// import '../data/repositories/firebase/firebase_preference_repository.dart';

// Mock Implementations (로컬 개발용)
import '../data/repositories/mock/mock_activity_repository.dart';
import '../data/repositories/mock/mock_baby_repository.dart';
import '../data/repositories/mock/mock_auth_repository.dart';
import '../data/repositories/mock/mock_insight_repository.dart';
import '../data/repositories/mock/mock_preference_repository.dart';

// Services
import '../data/services/openai_service.dart';
import '../data/services/ai_coaching_service.dart';
import '../data/services/personalization_memory_service.dart';
import '../data/services/csv_import_service.dart';
import '../data/services/csv_export_service.dart';
import '../data/services/daily_summary_service.dart';

final GetIt sl = GetIt.instance;

/// 의존성 주입 초기화
///
/// [BackendType]을 변경하면 전체 앱의 백엔드가 변경됩니다.
///
/// 사용 예시:
/// ```dart
/// await initDependencies(backend: BackendType.firebase);
/// ```
Future<void> initDependencies({
  BackendType backend = BackendType.firebase,
}) async {
  print('🚀 [DI] Initializing dependencies with backend: $backend');

  // ============================================================
  // External Dependencies
  // ============================================================

  // Firebase는 제거되었습니다 (Supabase로 마이그레이션 완료)
  // sl.registerLazySingleton(() => FirebaseFirestore.instance);
  // sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => GoogleSignIn());

  print('✅ [DI] External dependencies registered');

  // ============================================================
  // Repositories (Backend Selection)
  // ============================================================

  switch (backend) {
    case BackendType.firebase:
      _registerFirebaseRepositories();
      print('✅ [DI] Firebase repositories registered');
      break;
    case BackendType.supabase:
      _registerSupabaseRepositories();
      print('✅ [DI] Supabase repositories registered');
      break;
    case BackendType.mock:
      _registerMockRepositories();
      print('✅ [DI] Mock repositories registered');
      break;
  }

  // ============================================================
  // Services
  // ============================================================

  // OpenAI 서비스
  sl.registerLazySingleton(() => OpenAIService(
    apiKey: const String.fromEnvironment('OPENAI_API_KEY', defaultValue: ''),
  ));

  // Personalization Memory Service
  sl.registerLazySingleton(() => PersonalizationMemoryService(
    preferenceRepository: sl(),
  ));

  // AI Coaching Service (✅ Repository 패턴 적용 완료)
  sl.registerLazySingleton(() => AICoachingService(
    activityRepository: sl(),
    insightRepository: sl(),
    openAIService: sl(),
    memoryService: sl(),
  ));

  // Personalization Memory Service (✅ Repository 패턴 적용 완료)
  sl.registerLazySingleton(() => PersonalizationMemoryService(
    preferenceRepository: sl(),
  ));

  // CSV Import Service (✅ Repository 패턴 적용 완료)
  sl.registerLazySingleton(() => CsvImportService(
    activityRepository: sl(),
  ));

  // CSV Export Service (✅ Repository 패턴 적용 완료)
  sl.registerLazySingleton(() => CsvExportService(
    activityRepository: sl(),
  ));

  // Daily Summary Service (✅ Repository 패턴 적용 완료)
  sl.registerLazySingleton(() => DailySummaryService(
    activityRepository: sl(),
  ));

  print('🎉 [DI] All dependencies initialized successfully');
}

/// Firebase Repository 등록 (현재 사용 안 함 - Supabase로 마이그레이션 완료)
void _registerFirebaseRepositories() {
  throw UnimplementedError(
    '⚠️ Firebase 백엔드는 제거되었습니다.\n'
    'Supabase 또는 Mock 백엔드를 사용하세요:\n'
    '  - BackendType.supabase (권장)\n'
    '  - BackendType.mock (로컬 개발용)',
  );

  // Firebase 구현은 주석 처리됨
  // sl.registerLazySingleton<IActivityRepository>(
  //   () => FirebaseActivityRepository(firestore: sl()),
  // );
  // ...
}

/// Supabase Repository 등록 (임시로 Mock 사용)
void _registerSupabaseRepositories() {
  // Supabase 구현이 완료될 때까지 Mock으로 대체
  print('⚠️  Supabase 구현 진행 중 - 임시로 Mock backend 사용');
  _registerMockRepositories();
}

/// Mock Repository 등록 (로컬 개발용)
void _registerMockRepositories() {
  sl.registerLazySingleton<IActivityRepository>(
    () => MockActivityRepository(),
  );

  sl.registerLazySingleton<IBabyRepository>(
    () => MockBabyRepository(),
  );

  sl.registerLazySingleton<IAuthRepository>(
    () => MockAuthRepository(),
  );

  sl.registerLazySingleton<IInsightRepository>(
    () => MockInsightRepository(),
  );

  sl.registerLazySingleton<IPreferenceRepository>(
    () => MockPreferenceRepository(),
  );

  print('✅ [DI] Mock repositories registered (로컬 개발 모드)');
}

/// 백엔드 타입 열거형
enum BackendType {
  /// Firebase (Firestore + Firebase Auth)
  firebase,

  /// Supabase (PostgreSQL + Supabase Auth)
  supabase,

  /// Mock (In-memory, for testing)
  mock,
}

/// DI 컨테이너 리셋 (테스트용)
Future<void> resetDependencies() async {
  await sl.reset();
  print('🔄 [DI] Dependencies reset');
}
