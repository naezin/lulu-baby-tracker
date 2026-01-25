# 🏗️ Clean Architecture Implementation Guide

> **작성일**: 2026-01-25
> **버전**: 1.0.0
> **목적**: Firebase → Supabase 마이그레이션을 위한 Repository 패턴 구현

---

## 📋 목차

1. [개요](#개요)
2. [아키텍처 구조](#아키텍처-구조)
3. [디렉토리 구조](#디렉토리-구조)
4. [사용 방법](#사용-방법)
5. [마이그레이션 방법](#마이그레이션-방법)
6. [개발 규칙](#개발-규칙)

---

## 개요

### 목적

현재 Firebase에 강하게 결합된 코드를 **Repository 패턴** 기반으로 리팩토링하여, 향후 Supabase 또는 다른 백엔드로의 마이그레이션을 **최소 비용**으로 가능하게 합니다.

### 핵심 원칙

```
┌─────────────────────────────────────────────────────────────┐
│           MIGRATION-FRIENDLY PRINCIPLE                       │
├─────────────────────────────────────────────────────────────┤
│  1. 비즈니스 로직은 인프라를 모른다 (Clean Architecture)     │
│  2. 데이터 접근은 항상 Repository 인터페이스를 통한다         │
│  3. Firebase/Supabase는 구현 상세(Implementation Detail)다  │
│  4. 의존성은 항상 안쪽(도메인)을 향한다                       │
└─────────────────────────────────────────────────────────────┘
```

---

## 아키텍처 구조

### Before (기존 구조)

```
┌─────────────────────────────────────────────────────┐
│              Presentation Layer                      │
│  (Screens, Widgets, Providers)                      │
└────────────────┬────────────────────────────────────┘
                 │ 직접 호출 ❌
                 ▼
┌─────────────────────────────────────────────────────┐
│              Service Layer                           │
│  AICoachingService ──► FirebaseFirestore            │
│  DailySummaryService ──► FirebaseFirestore          │
└─────────────────────────────────────────────────────┘
```

### After (목표 구조) ✅ 완료!

```
┌─────────────────────────────────────────────────────┐
│              Presentation Layer                      │
│  (Screens, Widgets, Providers)                      │
└────────────────┬────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────┐
│           Repository Interfaces                      │
│  IActivityRepository, IBabyRepository               │
│  IAuthRepository, IInsightRepository                │
└────────────────┬────────────────────────────────────┘
                 │ implements
        ┌────────┼────────┐
        ▼        ▼        ▼
   Firebase  Supabase   Mock
   Impl      Impl       Impl
```

---

## 디렉토리 구조

```
lib/
├── core/
│   └── errors/
│       └── failures.dart                   # 공통 에러 타입
│
├── domain/                                  # 🆕 도메인 레이어
│   ├── entities/                            # 순수 도메인 모델
│   │   ├── activity_entity.dart
│   │   ├── baby_entity.dart
│   │   ├── user_entity.dart
│   │   ├── insight_entity.dart
│   │   └── preference_entity.dart
│   │
│   └── repositories/                        # Repository 인터페이스
│       ├── i_activity_repository.dart
│       ├── i_baby_repository.dart
│       ├── i_auth_repository.dart
│       ├── i_insight_repository.dart
│       └── i_preference_repository.dart
│
├── data/
│   ├── models/                              # DTO (Data Transfer Object)
│   │   ├── activity_model.dart             # ✅ toEntity/fromEntity 추가됨
│   │   ├── baby_model.dart                 # ✅ toEntity/fromEntity 추가됨
│   │   ├── insight_model.dart              # 🆕
│   │   └── preference_model.dart           # 🆕
│   │
│   └── repositories/                        # 🆕 Repository 구현체
│       ├── firebase/                        # ✅ Firebase 구현 완료
│       │   ├── firebase_activity_repository.dart
│       │   ├── firebase_baby_repository.dart
│       │   ├── firebase_auth_repository.dart
│       │   ├── firebase_insight_repository.dart
│       │   └── firebase_preference_repository.dart
│       │
│       ├── supabase/                        # 🔜 향후 Supabase 구현
│       │   └── .gitkeep
│       │
│       └── mock/                            # 🔜 테스트용 Mock
│           └── .gitkeep
│
├── di/                                      # 🆕 의존성 주입
│   └── injection_container.dart            # ✅ DI 컨테이너
│
└── presentation/
    ├── providers/
    ├── screens/
    └── widgets/
```

---

## 사용 방법

### 1. Repository 사용하기

**❌ 잘못된 방법 (직접 Firebase 사용)**:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';  // ❌ 금지!

class MyScreen extends StatelessWidget {
  void _saveData() {
    FirebaseFirestore.instance.collection('babies')...  // ❌ 금지!
  }
}
```

**✅ 올바른 방법 (Repository 사용)**:

```dart
import 'package:lulu/domain/repositories/i_activity_repository.dart';
import 'package:lulu/di/injection_container.dart' as di;

class MyScreen extends StatelessWidget {
  final IActivityRepository _activityRepository = di.sl<IActivityRepository>();

  void _saveData() async {
    await _activityRepository.saveActivity(
      babyId: 'baby123',
      activity: ActivityEntity(...),
    );
  }
}
```

### 2. Provider에서 Repository 주입

```dart
import 'package:provider/provider.dart';
import 'package:lulu/domain/repositories/i_activity_repository.dart';
import 'package:lulu/di/injection_container.dart' as di;

// main.dart에서 Provider 설정
MultiProvider(
  providers: [
    ChangeNotifierProvider(
      create: (_) => SweetSpotProvider(
        activityRepository: di.sl<IActivityRepository>(),  // ✅ DI로 주입
      ),
    ),
  ],
  child: MyApp(),
)
```

### 3. Service에서 Repository 사용

```dart
class AICoachingService {
  final IInsightRepository _insightRepository;
  final IActivityRepository _activityRepository;

  AICoachingService({
    required IInsightRepository insightRepository,
    required IActivityRepository activityRepository,
  })  : _insightRepository = insightRepository,
        _activityRepository = activityRepository;

  Future<void> generateInsight(String babyId) async {
    // 1. 활동 데이터 조회
    final activities = await _activityRepository.getActivities(
      babyId: babyId,
      limit: 10,
    );

    // 2. AI 분석...

    // 3. 인사이트 저장
    await _insightRepository.saveInsight(
      babyId: babyId,
      insight: InsightEntity(...),
    );
  }
}
```

---

## 마이그레이션 방법

### Firebase → Supabase로 전환하기

#### Step 1: Supabase Repository 구현

```dart
// lib/data/repositories/supabase/supabase_activity_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseActivityRepository implements IActivityRepository {
  final SupabaseClient _client;

  SupabaseActivityRepository({required SupabaseClient client})
      : _client = client;

  @override
  Future<void> saveActivity({
    required String babyId,
    required ActivityEntity activity,
  }) async {
    final model = ActivityModel.fromEntity(activity);
    await _client
        .from('activities')
        .insert(model.toJson());
  }

  // ... 나머지 메서드 구현
}
```

#### Step 2: DI 컨테이너에 Supabase Repository 등록

```dart
// lib/di/injection_container.dart

void _registerSupabaseRepositories() {
  sl.registerLazySingleton<IActivityRepository>(
    () => SupabaseActivityRepository(client: sl()),
  );

  sl.registerLazySingleton<IBabyRepository>(
    () => SupabaseBabyRepository(client: sl()),
  );

  // ... 나머지 Repository 등록
}
```

#### Step 3: main.dart에서 백엔드 전환

```dart
// lib/main.dart

await di.initDependencies(
  backend: di.BackendType.supabase,  // ✅ 이 한 줄만 변경!
);
```

**끝!** 이제 전체 앱이 Supabase를 사용합니다.

---

## 개발 규칙

### ❌ 절대 하지 말 것

```dart
// ❌ Presentation Layer에서 Firebase 직접 사용
class MyScreen extends StatelessWidget {
  void _saveData() {
    FirebaseFirestore.instance.collection('babies')...  // ❌ 금지!
  }
}

// ❌ Service에서 Firebase 직접 import
import 'package:cloud_firestore/cloud_firestore.dart';  // ❌ Repository 외부에서 금지
```

### ✅ 반드시 할 것

```dart
// ✅ Repository 인터페이스 사용
class MyScreen extends StatelessWidget {
  final IActivityRepository _activityRepository;  // ✅ 인터페이스 의존

  void _saveData() {
    _activityRepository.saveActivity(...);  // ✅ 추상화된 메서드 호출
  }
}

// ✅ DI 컨테이너에서 가져오기
final activityRepo = di.sl<IActivityRepository>();
```

### Rule 1: 새로운 데이터 접근이 필요할 때

```
1. Repository 인터페이스에 메서드 추가
2. Firebase 구현체에 구현
3. (선택) Supabase 구현체 틀 작성
4. Service/Provider에서 Repository 메서드 호출
```

### Rule 2: 새로운 컬렉션/테이블이 필요할 때

```
1. 새로운 Entity 정의 (lib/domain/entities/)
2. 새로운 Model 정의 (lib/data/models/)
3. 새로운 Repository 인터페이스 정의
4. Firebase 구현체 작성
5. DI 컨테이너에 등록
```

### Rule 3: 코드 리뷰 체크리스트

```yaml
리뷰어 확인사항:
  - [ ] Firebase/Supabase import가 Repository 외부에 없는가?
  - [ ] 새로운 데이터 접근이 Repository를 통해 이루어지는가?
  - [ ] Entity와 Model이 적절히 분리되어 있는가?
  - [ ] DI를 통해 의존성이 주입되는가?
```

---

## 🎯 마이그레이션 시 예상 효과

| 항목 | Before (기존) | After (Clean Arch) |
|------|-------------|-------------------|
| 파일 수정 | 13+ 파일 | 5개 파일 |
| 테스트 수정 | 전체 재작성 | Mock으로 유지 |
| 다운타임 | 1-2일 | 2-4시간 |
| 위험도 | 높음 | 낮음 |

---

## 📚 참고 자료

- [Clean Architecture by Uncle Bob](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Repository Pattern](https://docs.microsoft.com/en-us/dotnet/architecture/microservices/microservice-ddd-cqrs-patterns/infrastructure-persistence-layer-design)
- [Dependency Injection in Flutter](https://pub.dev/packages/get_it)

---

**Last Updated**: 2026-01-25
**Author**: Development Team
