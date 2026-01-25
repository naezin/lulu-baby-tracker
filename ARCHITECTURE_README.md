# 🏗️ Lulu App - Architecture Documentation

> **프로젝트**: Lulu - AI-Powered Baby Tracker
> **아키텍처**: Clean Architecture + Repository Pattern
> **목적**: Firebase → Supabase 마이그레이션 대비

---

## 📚 Documentation Index

### 📖 필수 문서

| 문서 | 목적 | 대상 |
|------|------|------|
| [CLEAN_ARCHITECTURE_GUIDE.md](./CLEAN_ARCHITECTURE_GUIDE.md) | 아키텍처 구조 및 사용법 | 모든 개발자 |
| [MIGRATION_FRIENDLY_CODING_GUIDELINES.md](./MIGRATION_FRIENDLY_CODING_GUIDELINES.md) | 코딩 규칙 및 체크리스트 | 모든 개발자 |

### 🎯 Quick Start

#### 신규 개발자 온보딩

```bash
# 1. 문서 읽기 (필수)
cat CLEAN_ARCHITECTURE_GUIDE.md
cat MIGRATION_FRIENDLY_CODING_GUIDELINES.md

# 2. 의존성 설치
flutter pub get

# 3. 앱 실행
flutter run -d iphone
```

#### 기존 개발자 참고

```bash
# 새로운 기능 개발 시 체크리스트
# MIGRATION_FRIENDLY_CODING_GUIDELINES.md > 📝 New Feature Checklist 참조

# 코드 리뷰 시 체크리스트
# MIGRATION_FRIENDLY_CODING_GUIDELINES.md > 🔍 Code Review Checklist 참조
```

---

## 🏛️ Architecture Overview

### Current State ✅

```
┌─────────────────────────────────────────────────────┐
│              Presentation Layer                      │
│          (Screens, Widgets, Providers)              │
└────────────────┬────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────┐
│           Repository Interfaces                      │
│  IActivityRepository, IBabyRepository               │
│  IAuthRepository, IInsightRepository                │
│  IPreferenceRepository                              │
└────────────────┬────────────────────────────────────┘
                 │ implements
        ┌────────┼────────┐
        ▼        ▼        ▼
   ✅Firebase  🔜Supabase  🔜Mock
    구현완료    준비중      준비중
```

### Implementation Status

| Component | Status | Files |
|-----------|--------|-------|
| **Domain Layer** | ✅ Complete | 5 Entities, 5 Repository Interfaces |
| **Data Layer** | ✅ Complete | 4 Models, 5 Firebase Repositories |
| **DI Layer** | ✅ Complete | injection_container.dart |
| **Presentation** | 🔄 Migrating | Provider 패턴 점진적 적용 중 |

---

## 📁 Directory Structure

```
lib/
├── core/
│   ├── errors/failures.dart               # 공통 에러 타입
│   ├── theme/                             # 테마
│   ├── localization/                      # 다국어
│   └── utils/                             # 유틸리티
│
├── domain/                                 # 🆕 도메인 레이어
│   ├── entities/                           # 순수 비즈니스 모델
│   │   ├── activity_entity.dart
│   │   ├── baby_entity.dart
│   │   ├── user_entity.dart
│   │   ├── insight_entity.dart
│   │   └── preference_entity.dart
│   └── repositories/                       # Repository 인터페이스
│       ├── i_activity_repository.dart
│       ├── i_baby_repository.dart
│       ├── i_auth_repository.dart
│       ├── i_insight_repository.dart
│       └── i_preference_repository.dart
│
├── data/
│   ├── models/                             # DTO (Data Transfer Objects)
│   │   ├── activity_model.dart
│   │   ├── baby_model.dart
│   │   ├── insight_model.dart
│   │   └── preference_model.dart
│   │
│   ├── repositories/                       # 🆕 Repository 구현체
│   │   ├── firebase/                       # ✅ Firebase 구현
│   │   │   ├── firebase_activity_repository.dart
│   │   │   ├── firebase_baby_repository.dart
│   │   │   ├── firebase_auth_repository.dart
│   │   │   ├── firebase_insight_repository.dart
│   │   │   └── firebase_preference_repository.dart
│   │   ├── supabase/                       # 🔜 Supabase (준비중)
│   │   └── mock/                           # 🔜 Mock (테스트용)
│   │
│   └── services/                           # 비즈니스 로직 서비스
│       ├── openai_service.dart
│       ├── widget_service.dart
│       └── ...
│
├── di/                                     # 🆕 의존성 주입
│   └── injection_container.dart
│
└── presentation/
    ├── providers/                          # 상태 관리
    ├── screens/                            # 화면
    └── widgets/                            # 위젯
```

---

## 🔑 Key Concepts

### 1. Repository Pattern

모든 데이터 접근은 Repository 인터페이스를 통해야 합니다.

```dart
// ❌ 잘못된 방법
FirebaseFirestore.instance.collection('babies').get();

// ✅ 올바른 방법
final repo = di.sl<IActivityRepository>();
final activities = await repo.getActivities(babyId: babyId);
```

### 2. Dependency Injection

의존성은 항상 생성자를 통해 주입받습니다.

```dart
// ❌ 잘못된 방법
class MyService {
  final _firestore = FirebaseFirestore.instance;
}

// ✅ 올바른 방법
class MyService {
  final IActivityRepository _repository;

  MyService({required IActivityRepository repository})
      : _repository = repository;
}
```

### 3. Entity vs Model

- **Entity**: 순수 비즈니스 모델 (domain/)
- **Model**: 데이터 전송 객체 (data/models/)

```dart
// Entity (domain/entities/activity_entity.dart)
class ActivityEntity {
  final String id;
  final DateTime timestamp;  // 순수 DateTime
  // ...
}

// Model (data/models/activity_model.dart)
class ActivityModel {
  final String id;
  final String timestamp;  // ISO 8601 String (Firebase용)
  // ...

  // Entity ↔ Model 변환
  ActivityEntity toEntity() { ... }
  factory ActivityModel.fromEntity(ActivityEntity entity) { ... }
}
```

---

## 🚀 Migration Strategy

### Step 1: 현재 상태 (Firebase) ✅

```dart
// main.dart
await di.initDependencies(
  backend: di.BackendType.firebase,  // ← 현재
);
```

### Step 2: Supabase Repository 구현 (향후)

```
lib/data/repositories/supabase/
├── supabase_activity_repository.dart
├── supabase_baby_repository.dart
├── supabase_auth_repository.dart
├── supabase_insight_repository.dart
└── supabase_preference_repository.dart
```

### Step 3: 백엔드 전환 (단 1줄!)

```dart
// main.dart
await di.initDependencies(
  backend: di.BackendType.supabase,  // ← 변경!
);
```

**끝!** 전체 앱이 Supabase를 사용합니다.

---

## 📊 Migration Progress Tracker

### Phase 1: Infrastructure (완료) ✅

- [x] Repository 인터페이스 정의
- [x] Entity 정의
- [x] Firebase Repository 구현
- [x] DI 컨테이너 설정
- [x] 문서화

### Phase 2: Service Refactoring (진행 중) 🔄

- [ ] AICoachingService → Repository 패턴
- [ ] DailySummaryService → Repository 패턴
- [ ] PersonalizationMemoryService → Repository 패턴
- [ ] CsvImportService → Repository 패턴
- [ ] CsvExportService → Repository 패턴

### Phase 3: Provider Refactoring (대기 중) ⏳

- [ ] SweetSpotProvider → Repository 주입
- [ ] ChatProvider → Repository 주입
- [ ] 기타 Provider들

### Phase 4: Supabase Implementation (대기 중) ⏳

- [ ] Supabase Repository 구현
- [ ] 데이터 마이그레이션 스크립트
- [ ] A/B 테스트
- [ ] 전환

---

## 🎯 Development Guidelines

### Golden Rules

```
1. 비즈니스 로직은 절대 인프라를 알면 안 된다
2. 모든 데이터 접근은 Repository 인터페이스를 통한다
3. 의존성은 항상 외부에서 주입받는다
4. 추상화에 의존하고 구체적 구현은 숨긴다
```

### Before Writing Code

1. ✅ Repository 인터페이스에 필요한 메서드가 있는가?
2. ✅ Entity와 Model 변환이 필요한가?
3. ✅ DI를 통해 의존성을 주입받는가?
4. ✅ Firebase를 직접 import하지 않는가?

### Before Submitting PR

```yaml
Self Review Checklist:
  - [ ] Firebase import가 Repository 외부에 없는가?
  - [ ] 모든 데이터 접근이 Repository를 통하는가?
  - [ ] 의존성이 생성자 주입되는가?
  - [ ] Entity와 Model이 적절히 분리되어 있는가?
```

---

## 🛠️ Tools & Commands

### 코드 검증

```bash
# Firebase import 찾기 (Repository 외부에서)
grep -r "import 'package:cloud_firestore" lib/presentation/
grep -r "import 'package:cloud_firestore" lib/data/services/

# 하드코딩된 Firebase 인스턴스 찾기
grep -r "FirebaseFirestore.instance" lib/presentation/
grep -r "FirebaseAuth.instance" lib/data/services/

# Repository 패턴 사용 확인
grep -r "IActivityRepository" lib/
```

### 테스트

```bash
# 단위 테스트
flutter test

# 통합 테스트
flutter test integration_test/
```

---

## 📖 Learning Resources

### Required Reading

1. [CLEAN_ARCHITECTURE_GUIDE.md](./CLEAN_ARCHITECTURE_GUIDE.md) - 아키텍처 상세 가이드
2. [MIGRATION_FRIENDLY_CODING_GUIDELINES.md](./MIGRATION_FRIENDLY_CODING_GUIDELINES.md) - 코딩 규칙

### External Resources

- [Clean Architecture (Uncle Bob)](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Repository Pattern](https://deviq.com/design-patterns/repository-pattern)
- [Dependency Injection in Flutter](https://pub.dev/packages/get_it)

---

## 🤝 Contributing

### 신규 기능 추가 시

1. `MIGRATION_FRIENDLY_CODING_GUIDELINES.md` > 📝 New Feature Checklist 참조
2. Repository 인터페이스 먼저 정의
3. Firebase 구현 작성
4. DI 등록
5. PR 생성 (체크리스트 포함)

### 버그 수정 시

- Repository 패턴 적용 여부와 무관하게 수정 가능
- 단, 수정 시 Repository 패턴으로 전환하는 것을 권장

---

## 📞 Support

### Questions?

- Architecture 질문: `CLEAN_ARCHITECTURE_GUIDE.md` 참조
- Coding 규칙: `MIGRATION_FRIENDLY_CODING_GUIDELINES.md` 참조
- 기타: Team Slack #lulu-dev

---

**Last Updated**: 2026-01-25
**Maintained By**: Development Team
