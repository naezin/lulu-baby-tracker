# 🛡️ Lulu App - Migration-Friendly Coding Guidelines

> **적용 범위**: 모든 신규 코드 및 기존 코드 수정
> **Version**: 1.0.0
> **Effective Date**: 2026-01-25
> **Owner**: 💻 CTO

---

## 📌 Core Principles (핵심 원칙)

```
┌─────────────────────────────────────────────────────────────────────┐
│                    THE GOLDEN RULES                                  │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  1️⃣  비즈니스 로직은 절대로 인프라(Firebase/Supabase)를 알면 안 된다  │
│                                                                      │
│  2️⃣  모든 외부 데이터 접근은 Repository 인터페이스를 통해야 한다      │
│                                                                      │
│  3️⃣  의존성은 항상 외부에서 주입받아야 한다 (DI)                     │
│                                                                      │
│  4️⃣  구체적인 구현보다 추상화(인터페이스)에 의존해야 한다            │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 🚫 PROHIBITED (금지 사항)

### ❌ 절대 금지 - Firebase 직접 사용

```dart
// ❌ NEVER DO THIS - Presentation Layer에서 Firebase 직접 사용
class HomeScreen extends StatelessWidget {
  void _loadData() {
    // 🚫 금지!
    FirebaseFirestore.instance.collection('babies').get();
  }
}

// ❌ NEVER DO THIS - Service에서 Firebase 직접 import
// lib/data/services/some_service.dart
import 'package:cloud_firestore/cloud_firestore.dart'; // 🚫 금지!

class SomeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // 🚫 금지!
}

// ❌ NEVER DO THIS - Provider에서 Firebase 직접 사용
class MyProvider extends ChangeNotifier {
  void saveData() {
    FirebaseFirestore.instance.collection('data').add({...}); // 🚫 금지!
  }
}
```

### ❌ 절대 금지 - 하드코딩된 서비스 생성

```dart
// ❌ NEVER DO THIS - 서비스 직접 인스턴스화
class MyScreen extends StatelessWidget {
  final _storage = LocalStorageService(); // 🚫 금지!
  final _authService = AuthService();     // 🚫 금지!
}

// ❌ NEVER DO THIS - Provider 내부에서 서비스 직접 생성
class MyProvider extends ChangeNotifier {
  final _service = SomeService(); // 🚫 금지! 항상 생성자 주입
}
```

---

## ✅ REQUIRED (필수 사항)

### ✅ 필수 - Repository 인터페이스 사용

```dart
// ✅ CORRECT - Repository 인터페이스에 의존
class HomeScreen extends StatelessWidget {
  final IActivityRepository _activityRepository;

  const HomeScreen({required IActivityRepository activityRepository})
      : _activityRepository = activityRepository;

  void _loadData() {
    // ✅ 추상화된 메서드 호출
    _activityRepository.getActivities(babyId: babyId);
  }
}
```

### ✅ 필수 - DI 컨테이너에서 의존성 가져오기

```dart
// ✅ CORRECT - DI 컨테이너 사용
import '../di/injection_container.dart' as di;

// Provider 설정
ChangeNotifierProvider(
  create: (_) => SweetSpotProvider(
    activityRepository: di.sl<IActivityRepository>(),  // ✅ DI에서 가져옴
    babyRepository: di.sl<IBabyRepository>(),
  ),
),

// Widget에서 사용
Widget build(BuildContext context) {
  final activityRepo = di.sl<IActivityRepository>();  // ✅ DI에서 가져옴
}
```

### ✅ 필수 - 생성자 주입 패턴

```dart
// ✅ CORRECT - 생성자를 통한 의존성 주입
class AICoachingService {
  final IInsightRepository _insightRepository;
  final IActivityRepository _activityRepository;
  final OpenAIService _openAIService;

  // ✅ 생성자에서 모든 의존성 주입
  AICoachingService({
    required IInsightRepository insightRepository,
    required IActivityRepository activityRepository,
    required OpenAIService openAIService,
  })  : _insightRepository = insightRepository,
        _activityRepository = activityRepository,
        _openAIService = openAIService;
}
```

---

## 📁 File Organization Rules (파일 구조 규칙)

### 레이어별 import 규칙

```dart
// ============================================================
// lib/presentation/ (Screens, Widgets, Providers)
// ============================================================

// ✅ 허용되는 import
import '../domain/repositories/i_activity_repository.dart';  // 인터페이스
import '../domain/entities/activity_entity.dart';             // 엔티티
import '../di/injection_container.dart';                      // DI
import '../core/...';                                         // 공통 유틸

// 🚫 금지되는 import
import 'package:cloud_firestore/cloud_firestore.dart';        // Firebase
import 'package:firebase_auth/firebase_auth.dart';            // Firebase
import '../data/repositories/firebase/...';                   // 구현체 직접 참조


// ============================================================
// lib/data/services/ (비즈니스 로직 서비스)
// ============================================================

// ✅ 허용되는 import
import '../../domain/repositories/i_activity_repository.dart';
import '../../domain/entities/activity_entity.dart';
import '../models/activity_model.dart';
import 'package:http/http.dart';                              // 외부 API OK

// 🚫 금지되는 import
import 'package:cloud_firestore/cloud_firestore.dart';        // Firebase
import '../repositories/firebase/...';                        // 구현체


// ============================================================
// lib/data/repositories/firebase/ (Firebase 구현체만)
// ============================================================

// ✅ 허용되는 import (여기서만 Firebase 허용!)
import 'package:cloud_firestore/cloud_firestore.dart';        // ✅ 여기서만!
import 'package:firebase_auth/firebase_auth.dart';            // ✅ 여기서만!
import '../../../domain/repositories/i_activity_repository.dart';
import '../../models/activity_model.dart';
```

### 레이어별 책임

| 레이어 | 위치 | 책임 | Firebase 사용 |
|--------|------|------|---------------|
| **Presentation** | `lib/presentation/` | UI, 상태 관리 | ❌ 금지 |
| **Domain** | `lib/domain/` | 인터페이스, 엔티티 | ❌ 금지 |
| **Service** | `lib/data/services/` | 비즈니스 로직 | ❌ 금지 |
| **Repository 구현** | `lib/data/repositories/firebase/` | 데이터 접근 | ✅ 허용 |
| **DI** | `lib/di/` | 의존성 주입 | ✅ 허용 (등록만) |

---

## 🔄 Data Flow Pattern (데이터 흐름 패턴)

### 읽기 (Read) 흐름

```
┌──────────┐     ┌──────────┐     ┌──────────────┐     ┌──────────┐
│  Screen  │────►│ Provider │────►│ IRepository  │────►│ Firebase │
│          │◄────│          │◄────│ (interface)  │◄────│   Impl   │
└──────────┘     └──────────┘     └──────────────┘     └──────────┘
     UI            State           Abstraction          Concrete
   Layer          Layer             Layer               Layer
```

### 쓰기 (Write) 흐름

```dart
// 1. Screen에서 사용자 액션 감지
onPressed: () {
  context.read<ActivityProvider>().saveActivity(activity);
}

// 2. Provider에서 Repository 호출
class ActivityProvider {
  final IActivityRepository _repository;  // 인터페이스

  Future<void> saveActivity(ActivityEntity activity) async {
    await _repository.saveActivity(babyId: babyId, activity: activity);
    notifyListeners();
  }
}

// 3. Firebase Repository에서 실제 저장
class FirebaseActivityRepository implements IActivityRepository {
  @override
  Future<void> saveActivity({...}) async {
    await _firestore.collection('babies')...  // 여기서만 Firebase 사용
  }
}
```

---

## 📝 New Feature Checklist (신규 기능 체크리스트)

### 새로운 데이터 접근이 필요할 때

```yaml
Step 1 - 인터페이스 정의:
  Location: lib/domain/repositories/
  Action: 필요한 메서드를 인터페이스에 추가
  Example: |
    // i_activity_repository.dart
    Future<List<ActivityEntity>> getActivitiesByType(ActivityType type);

Step 2 - Firebase 구현:
  Location: lib/data/repositories/firebase/
  Action: 인터페이스 메서드 구현
  Example: |
    @override
    Future<List<ActivityEntity>> getActivitiesByType(ActivityType type) async {
      final snapshot = await _firestore...;
      return snapshot.docs.map(...).toList();
    }

Step 3 - (선택) Supabase 틀 작성:
  Location: lib/data/repositories/supabase/
  Action: 빈 메서드 또는 TODO 주석
  Example: |
    @override
    Future<List<ActivityEntity>> getActivitiesByType(ActivityType type) {
      // TODO: Implement when migrating to Supabase
      throw UnimplementedError();
    }

Step 4 - 서비스/Provider에서 사용:
  Action: Repository 인터페이스를 통해 메서드 호출
  Example: |
    final activities = await _activityRepository.getActivitiesByType(type);
```

### 새로운 데이터 모델이 필요할 때

```yaml
Step 1 - Entity 정의 (순수 도메인):
  Location: lib/domain/entities/
  Rules:
    - Firebase/Supabase 의존성 없음
    - 순수 Dart 타입만 사용
    - toJson/fromJson 없음 (Model에서 처리)

Step 2 - Model 정의 (DTO):
  Location: lib/data/models/
  Rules:
    - Entity 변환 메서드 포함 (toEntity, fromEntity)
    - JSON 직렬화 포함 (toJson, fromJson)
    - Firestore Timestamp → DateTime 변환 등

Step 3 - Repository 인터페이스에 메서드 추가:
  Location: lib/domain/repositories/

Step 4 - Firebase 구현체 작성:
  Location: lib/data/repositories/firebase/

Step 5 - DI 컨테이너 등록 (필요시):
  Location: lib/di/injection_container.dart
```

---

## 🧪 Testing Guidelines (테스트 가이드라인)

### Mock Repository 사용

```dart
// ✅ 테스트에서 Mock Repository 사용
class MockActivityRepository implements IActivityRepository {
  final List<ActivityEntity> _activities = [];

  @override
  Future<void> saveActivity({...}) async {
    _activities.add(activity);
  }

  @override
  Future<List<ActivityEntity>> getActivities({...}) async {
    return _activities;
  }
}

// 테스트 코드
void main() {
  late SweetSpotProvider provider;
  late MockActivityRepository mockRepo;

  setUp(() {
    mockRepo = MockActivityRepository();
    provider = SweetSpotProvider(activityRepository: mockRepo);
  });

  test('Sweet Spot 계산 테스트', () async {
    // Mock 데이터 추가
    await mockRepo.saveActivity(...);

    // 테스트 실행
    await provider.calculateSweetSpot(babyId);

    // 검증
    expect(provider.sweetSpot, isNotNull);
  });
}
```

### 통합 테스트

```dart
// 실제 Firebase를 사용하는 통합 테스트
void main() {
  late IActivityRepository repository;

  setUpAll(() async {
    await Firebase.initializeApp();
    repository = FirebaseActivityRepository();
  });

  test('Firebase 저장 테스트', () async {
    await repository.saveActivity(...);
    final activities = await repository.getActivities(babyId: 'test');
    expect(activities, isNotEmpty);
  });
}
```

---

## 🔍 Code Review Checklist (코드 리뷰 체크리스트)

### PR 생성 시 자가 점검

```yaml
Architecture Compliance:
  - [ ] Firebase import가 Repository 구현체 외부에 없는가?
  - [ ] 모든 데이터 접근이 Repository 인터페이스를 통하는가?
  - [ ] 의존성이 생성자를 통해 주입되는가?
  - [ ] 하드코딩된 서비스 인스턴스가 없는가?

Layer Separation:
  - [ ] Presentation 레이어가 Domain 인터페이스만 참조하는가?
  - [ ] Service가 Repository 구현체를 직접 참조하지 않는가?
  - [ ] Entity와 Model이 적절히 분리되어 있는가?

Future Migration:
  - [ ] Supabase로 전환 시 이 코드를 수정해야 하는가?
  - [ ] (수정 필요하다면) Repository 구현체만 수정하면 되는가?
  - [ ] 비즈니스 로직이 인프라에 의존하지 않는가?
```

### 리뷰어 체크리스트

```yaml
Mandatory Checks:
  - [ ] Golden Rules 4가지 준수 여부
  - [ ] Import 규칙 준수 여부
  - [ ] DI 패턴 준수 여부
  - [ ] 테스트 가능성 확보 여부

Recommended Checks:
  - [ ] 불필요한 중복 코드 없는지
  - [ ] 에러 처리 적절한지
  - [ ] 문서화 충분한지
```

---

## 📊 Migration Readiness Score (마이그레이션 준비도 점수)

### 점수 계산 기준

| 항목 | 점수 | 기준 |
|------|------|------|
| Repository 패턴 적용 | 30점 | 모든 데이터 접근이 Repository 통해 이루어짐 |
| DI 설정 완료 | 20점 | GetIt 등 DI 컨테이너 사용 |
| Entity/Model 분리 | 20점 | 도메인 모델과 DTO 분리 |
| Firebase 격리 | 20점 | Repository 외부에 Firebase 의존성 없음 |
| 테스트 커버리지 | 10점 | Mock Repository로 테스트 가능 |

### 목표 점수

```
MVP 런칭 전: 70점 이상
v1.1 릴리즈 전: 90점 이상
마이그레이션 전: 100점
```

---

## 🆘 Troubleshooting (문제 해결)

### Q: 기존 코드에서 Firebase를 직접 사용하고 있는데 어떻게 해야 하나요?

```dart
// Before (문제 코드)
class OldService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveData() async {
    await _firestore.collection('data').add({...});
  }
}

// After (리팩토링)
// Step 1: Repository 인터페이스 생성
abstract class IDataRepository {
  Future<void> saveData(DataEntity data);
}

// Step 2: Firebase 구현체 생성
class FirebaseDataRepository implements IDataRepository {
  final FirebaseFirestore _firestore;

  FirebaseDataRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> saveData(DataEntity data) async {
    await _firestore.collection('data').add(data.toJson());
  }
}

// Step 3: 기존 서비스 수정
class NewService {
  final IDataRepository _repository;  // 인터페이스로 변경

  NewService({required IDataRepository repository})
      : _repository = repository;

  Future<void> saveData() async {
    await _repository.saveData(data);  // Repository 통해 호출
  }
}

// Step 4: DI 등록
sl.registerLazySingleton<IDataRepository>(
  () => FirebaseDataRepository(firestore: sl()),
);
```

### Q: 급하게 기능을 추가해야 하는데 Repository 패턴을 적용할 시간이 없어요

```yaml
단기적 해결책:
  1. 일단 Firebase 직접 사용하되, 파일 상단에 TODO 주석 추가
  2. PR에 "Tech Debt" 라벨 추가
  3. 다음 스프린트에 리팩토링 태스크 등록

예시:
  // TODO: [TECH-DEBT] Repository 패턴으로 리팩토링 필요
  // Ticket: LULU-123
  // Deadline: 2026-02-15
  final _firestore = FirebaseFirestore.instance;

장기적:
  - 스프린트 계획에 Tech Debt 해소 시간 포함 (10-20%)
  - Repository 패턴 미적용 코드는 2주 내 리팩토링
```

---

## 📚 Reference

### 관련 문서

- [CLEAN_ARCHITECTURE_GUIDE.md](./CLEAN_ARCHITECTURE_GUIDE.md) - 상세 아키텍처 가이드
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html) - 원칙 참조
- [Repository Pattern](https://deviq.com/design-patterns/repository-pattern) - 패턴 참조

### 참고 코드

```
lib/domain/repositories/      - 인터페이스 예시
lib/data/repositories/firebase/ - Firebase 구현 예시
lib/di/injection_container.dart - DI 설정 예시
```

---

**Document Version**: 1.0.0
**Last Updated**: 2026-01-25
**Maintained By**: 💻 CTO Agent
**Approved By**: 🎯 CPO Agent
