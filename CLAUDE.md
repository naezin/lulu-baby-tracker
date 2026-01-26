# 🌙 CLAUDE.md - Lulu 글로벌 앱 개발 가이드라인

> **"18명의 Elite Agent가 하나의 목소리로, 전 세계 부모에게 안심을 전달한다."**
>
> **Last Updated**: 2026-01-26 | **Version**: 1.4 | **Maintained By**: Lulu Elite Agent Team

---

## 📋 Table of Contents

1. [Project Overview](#1-project-overview)
2. [Tech Stack](#2-tech-stack)
3. [Project Structure](#3-project-structure)
4. [Coding Standards](#4-coding-standards)
5. [State Management](#5-state-management)
6. [API & Data Guidelines](#6-api--data-guidelines)
7. [Security Requirements](#7-security-requirements)
8. [Testing Requirements](#8-testing-requirements)
9. [UI/UX Standards](#9-uiux-standards)
10. [Internationalization](#10-internationalization)
11. [Medical Content Guidelines](#11-medical-content-guidelines)
12. [Performance Standards](#12-performance-standards)
13. [Git Workflow](#13-git-workflow)
14. [Quality Gates](#14-quality-gates)
15. [Forbidden Patterns](#15-forbidden-patterns)

---

## 1. Project Overview

### 🎯 CPO (Chief Product Officer)

**미션**: "전 세계 모든 부모가 새벽 3시에도 한 손으로, 5초 안에, 아기의 다음 행동을 예측하고 안심할 수 있는 앱을 만든다."

```yaml
Core Principles:
  🎯 Zero Cognitive Load: 피로한 부모도 직관적으로 이해
  🔬 Evidence-Based: 모든 수치는 WHO/AAP 근거
  🌍 Universal by Default: 모든 문화권에서 작동
  ⚡ 3-Second Rule: 핵심 정보 3초 내 인지
  💚 Empathy First: 데이터가 아닌 안심을 전달
  🔒 Trust by Design: 보안과 규정 준수는 기본값

Target Markets:
  Tier 1 (Launch): US, KR
  Tier 2 (6개월): JP, DE
  Tier 3 (12개월): ES, FR, CN

Priority Framework (MoSCoW):
  P0 (Must): 사용자 안전, 핵심 기능, 법적 요구사항
  P1 (Should): 사용자 경험 개선, 성능 최적화
  P2 (Could): 추가 기능, 편의성 개선
  P3 (Won't): 현재 스프린트에서 제외
```

---

## 2. Tech Stack

### 💻 CTO (Chief Technology Officer)

```yaml
# Core Framework
Framework: Flutter 3.0+
Language: Dart (SDK >=3.0.0 <4.0.0)
Platforms: iOS, Android, Web

# State Management
Primary: Provider ^6.1.1
Pattern: ChangeNotifier + Consumer

# Backend & Authentication (v1.4 업데이트: Firebase → Supabase)
Backend: supabase_flutter ^2.0.0
Social Login: google_sign_in ^6.2.1
# Note: Firebase는 v1.3에서 완전히 제거됨

# Dependency Injection
DI Container: get_it ^7.6.0
Pattern: Service Locator with Repository interfaces

# AI Integration
AI Service: OpenAI API (GPT-4o-mini)
HTTP Client: http ^1.1.0

# Local Storage
Preferences: shared_preferences ^2.2.2

# UI & Utilities
Localization: intl ^0.20.2, flutter_localizations
Charts: fl_chart ^0.69.0
Icons: cupertino_icons ^1.0.2
UUID: uuid ^4.5.2

# Notifications
Local: flutter_local_notifications ^17.0.0
Timezone: timezone ^0.9.0

# File Handling
CSV Export: csv ^6.0.0
File Sharing: share_plus ^7.2.0
File System: path_provider ^2.1.0
File Picker: file_picker ^6.1.0

# Home Screen Widgets
Widget Integration: home_widget ^0.6.0

# Development
Linting: flutter_lints ^3.0.0
Testing: flutter_test (SDK)
```

### 🧩 System Architect

```yaml
Architecture: Clean Architecture + Repository Pattern

Layer Separation:
  - core/: 비즈니스 로직과 독립적인 공통 유틸리티
  - domain/: 순수 도메인 레이어 (Entities, Repository Interfaces)
  - data/: 데이터 레이어 (Models, Repository 구현체, Services)
  - di/: 의존성 주입 컨테이너 (GetIt 기반)
  - presentation/: UI 레이어 (Providers, Screens, Widgets)

Data Flow (v1.4):
  UI → Provider → Repository Interface → Repository Implementation → Backend/API

Dependency Direction:
  presentation → domain ← data (의존성 역전)
  presentation → data (서비스 직접 사용 시)
  core: 어느 레이어에서든 참조 가능

Repository Pattern:
  - domain/repositories/: 추상 인터페이스 정의 (I*Repository)
  - data/repositories/mock/: Mock 구현 (로컬 개발용)
  - data/repositories/supabase/: Supabase 구현 (프로덕션용)
```

---

## 3. Project Structure

### 💻 CTO + 🧩 System Architect

```
lulu/
├── lib/
│   ├── main.dart                      # 앱 진입점
│   │
│   ├── core/                          # 🔧 핵심 유틸리티
│   │   ├── constants/
│   │   │   └── lulu_persona.dart      # Lulu AI 페르소나 설정
│   │   ├── localization/
│   │   │   └── app_localizations.dart # 다국어 지원
│   │   ├── theme/
│   │   │   └── app_theme.dart         # Midnight Blue 테마
│   │   └── utils/
│   │       ├── sweet_spot_calculator.dart     # 수면 예측 알고리즘
│   │       ├── wake_window_calculator.dart    # 각성 시간 계산
│   │       ├── feeding_interval_calculator.dart
│   │       ├── premature_baby_calculator.dart
│   │       ├── corrected_age_calculator.dart
│   │       ├── date_formatter.dart
│   │       └── unit_converter.dart
│   │
│   ├── domain/                        # 🏛️ 도메인 레이어 (v1.3 추가)
│   │   ├── entities/                  # 순수 비즈니스 모델
│   │   │   ├── activity_entity.dart
│   │   │   ├── baby_entity.dart
│   │   │   ├── user_entity.dart
│   │   │   ├── insight_entity.dart
│   │   │   └── preference_entity.dart
│   │   └── repositories/              # 추상 인터페이스
│   │       ├── i_activity_repository.dart
│   │       ├── i_baby_repository.dart
│   │       ├── i_auth_repository.dart
│   │       ├── i_insight_repository.dart
│   │       └── i_preference_repository.dart
│   │
│   ├── di/                            # 💉 의존성 주입 (v1.3 추가)
│   │   └── injection_container.dart   # GetIt DI 컨테이너
│   │
│   ├── data/                          # 📊 데이터 레이어
│   │   ├── models/
│   │   │   ├── baby_model.dart        # JSON 직렬화 가능
│   │   │   ├── activity_model.dart
│   │   │   └── chat_message.dart
│   │   ├── repositories/
│   │   │   ├── mock/                  # Mock 구현 (로컬 개발)
│   │   │   │   ├── mock_activity_repository.dart
│   │   │   │   ├── mock_baby_repository.dart
│   │   │   │   ├── mock_auth_repository.dart
│   │   │   │   ├── mock_insight_repository.dart
│   │   │   │   └── mock_preference_repository.dart
│   │   │   └── supabase/              # Supabase 구현 (프로덕션)
│   │   └── services/
│   │       ├── openai_service.dart    # AI 채팅 서비스
│   │       ├── ai_coaching_service.dart
│   │       ├── widget_service.dart    # 홈 위젯 서비스
│   │       ├── csv_import_service.dart
│   │       ├── csv_export_service.dart
│   │       ├── daily_summary_service.dart
│   │       └── local_storage_service.dart
│   │
│   ├── l10n/                          # 🌐 번역 파일
│   │   ├── app_en.arb                 # 영어 (기준)
│   │   └── app_ko.arb                 # 한국어
│   │
│   └── presentation/                  # 🎨 UI 레이어
│       ├── providers/                 # 7개 Provider
│       │   ├── baby_provider.dart     # 아기 관리 (v1.4)
│       │   ├── chat_provider.dart
│       │   ├── sweet_spot_provider.dart
│       │   ├── home_data_provider.dart
│       │   ├── smart_coach_provider.dart
│       │   ├── locale_provider.dart
│       │   └── unit_preferences_provider.dart
│       ├── design_system/
│       │   └── components/            # 재사용 UI 컴포넌트
│       ├── screens/
│       │   ├── main/
│       │   ├── chat/
│       │   ├── activities/
│       │   ├── records/
│       │   ├── baby/                  # 아기 관리 화면 (v1.4)
│       │   ├── analysis/
│       │   ├── onboarding/
│       │   └── settings/
│       └── widgets/
│           ├── auth_wrapper.dart
│           ├── chat/
│           └── sweet_spot_card.dart
│
├── test/
│   └── unit/
│       ├── utils/
│       │   └── sweet_spot_calculator_test.dart
│       ├── models/
│       │   └── activity_model_test.dart
│       ├── services/
│       │   └── widget_service_test.dart
│       └── widgets/
│           └── lulu_time_picker_test.dart
│
├── ios/
│   └── LuluWidget/                    # iOS WidgetKit
│
├── android/
│   └── app/src/main/
│       ├── kotlin/.../LuluWidgetProvider.kt
│       └── res/
│
├── scripts/
│   ├── check_i18n.dart               # i18n 검증 스크립트
│   ├── check_i18n.sh
│   ├── clean_build.sh                # 빌드 캐시 정리
│   └── measure_build_time.sh         # 빌드 시간 측정
│
├── .github/
│   └── workflows/
│       └── i18n-check.yml            # CI/CD i18n 검사
│
├── .env.example                       # 환경변수 템플릿
├── .gitignore
├── pubspec.yaml
└── CLAUDE.md                          # 📖 이 문서
```

---

## 4. Coding Standards

### 💻 CTO + 🛡️ QA

### 4.1 Dart/Flutter 코딩 규칙

```dart
// ✅ 올바른 예시

// 1. 클래스명: PascalCase
class SweetSpotCalculator {}
class BabyModel {}

// 2. 변수/함수명: camelCase
final babyAgeInMonths = 6;
void calculateSweetSpot() {}

// 3. 상수: lowerCamelCase with const
const defaultWakeWindow = Duration(hours: 2);
static const maxNapCount = 5;

// 4. 파일명: snake_case
// sweet_spot_calculator.dart
// baby_model.dart

// 5. Private 멤버: underscore prefix
class _PrivateClass {}
final _privateVariable = 'secret';

// 6. Null Safety 필수
String? nullableString;
late final String lateInitString;

// 7. 타입 명시 (추론 가능해도 명시 권장)
final List<ActivityModel> activities = [];
final Map<String, dynamic> json = {};
```

### 4.2 Widget 작성 규칙

```dart
// ✅ 올바른 Widget 구조

class SweetSpotCard extends StatelessWidget {
  // 1. 생성자는 const 사용
  const SweetSpotCard({
    Key? key,
    required this.sweetSpotResult,
    this.onTap,
  }) : super(key: key);

  // 2. 필수 파라미터는 required
  final SweetSpotResult sweetSpotResult;

  // 3. 선택적 파라미터는 nullable
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // 4. 빌드 메서드 내에서 Provider 접근
    final l10n = AppLocalizations.of(context)!;

    // 5. 큰 위젯은 private 메서드로 분리
    return Card(
      child: Column(
        children: [
          _buildHeader(),
          _buildContent(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    // Private 빌드 메서드
  }
}
```

### 4.3 필수 코드 포맷팅

```yaml
# 모든 코드는 아래 명령어로 포맷팅 필수
Commands:
  - dart format lib/
  - dart analyze lib/

# 저장 시 자동 포맷팅 설정 권장 (VS Code)
Settings:
  editor.formatOnSave: true
  dart.lineLength: 80
```

---

## 5. State Management

### 💻 CTO + 📊 Data Scientist

### 5.1 Provider 패턴

```dart
// ✅ Provider 구현 패턴

class ChatProvider extends ChangeNotifier {
  // 1. Private 상태
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _errorMessage;

  // 2. Public getters
  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // 3. 상태 변경 메서드
  Future<void> sendMessage(String content) async {
    // 로딩 시작
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // API 호출
      final response = await _openAIService.sendMessage(content);
      _messages.add(response);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      // 로딩 종료
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

### 5.2 Provider 등록 (main.dart)

```dart
// ✅ MultiProvider 설정 (v1.4 - 7개 Provider)

import 'di/injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Supabase 초기화 (환경변수 설정 시)
  if (EnvironmentValidator.hasSupabaseConfig) {
    await Supabase.initialize(
      url: EnvironmentValidator.supabaseUrl!,
      anonKey: EnvironmentValidator.supabaseAnonKey!,
    );
  }

  // DI 컨테이너 초기화
  await di.initDependencies(backend: di.BackendType.supabase);

  runApp(
    MultiProvider(
      providers: [
        // 1. Baby Provider (다른 Provider가 의존하므로 먼저 등록)
        ChangeNotifierProvider(
          create: (_) => BabyProvider(
            babyRepository: di.sl<IBabyRepository>(),
            localStorage: di.sl<LocalStorageService>(),
            widgetService: WidgetService(),
          ),
        ),
        // 2. Locale Provider
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        // 3. Unit Preferences Provider
        ChangeNotifierProvider(create: (_) => UnitPreferencesProvider()),
        // 4. Chat Provider
        ChangeNotifierProvider(
          create: (_) => ChatProvider(openAIService: di.sl<OpenAIService>()),
        ),
        // 5. Sweet Spot Provider
        ChangeNotifierProvider(create: (_) => SweetSpotProvider()),
        // 6. Home Data Provider
        ChangeNotifierProvider(create: (_) => HomeDataProvider()),
        // 7. Smart Coach Provider
        ChangeNotifierProvider(create: (_) => SmartCoachProvider()),
      ],
      child: const LuluApp(),
    ),
  );
}
```

### 5.3 Provider 사용

```dart
// ✅ 읽기 전용 (rebuild 필요)
final messages = context.watch<ChatProvider>().messages;

// ✅ 메서드 호출용 (rebuild 불필요)
context.read<ChatProvider>().sendMessage(text);

// ✅ Consumer 사용 (부분 rebuild)
Consumer<ChatProvider>(
  builder: (context, provider, child) {
    if (provider.isLoading) {
      return const CircularProgressIndicator();
    }
    return MessageList(messages: provider.messages);
  },
)
```

---

## 6. API & Data Guidelines

### 💻 CTO + 🔒 Security Engineer + 📊 Data Scientist

### 6.1 API 호출 필수 규칙

```dart
// ⚠️ 모든 API 호출은 반드시 아래 패턴 따를 것

class OpenAIService {
  Future<ChatMessage> sendMessage(String content) async {
    // 1️⃣ [필수] 로딩 상태 시작 (Provider에서 처리)

    try {
      // 2️⃣ [필수] 타임아웃 설정
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: _headers,
        body: jsonEncode(body),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw TimeoutException('Request timed out'),
      );

      // 3️⃣ [필수] 응답 코드 확인
      if (response.statusCode != 200) {
        throw ApiException(
          'API Error: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }

      // 4️⃣ [필수] 응답 파싱 및 반환
      return ChatMessage.fromJson(jsonDecode(response.body));

    } on SocketException {
      // 5️⃣ [필수] 네트워크 에러 처리
      throw NetworkException('No internet connection');
    } on TimeoutException {
      throw NetworkException('Request timed out');
    } catch (e) {
      // 6️⃣ [필수] 기타 에러 처리
      throw ApiException('Unexpected error: $e');
    }

    // 7️⃣ [필수] 로딩 상태 종료 (Provider에서 finally 블록)
  }
}
```

### 6.2 Repository 패턴 (v1.4)

```dart
// ✅ Repository 인터페이스 정의 (domain/repositories/)

abstract class IActivityRepository {
  /// 특정 기간의 활동 조회
  Future<List<ActivityEntity>> getActivities({
    required String babyId,
    required DateTime start,
    required DateTime end,
  });

  /// 활동 저장
  Future<void> saveActivity(ActivityEntity activity);

  /// 활동 삭제
  Future<void> deleteActivity(String activityId);
}
```

```dart
// ✅ Mock Repository 구현 (data/repositories/mock/)

class MockActivityRepository implements IActivityRepository {
  final List<ActivityEntity> _activities = [];

  @override
  Future<List<ActivityEntity>> getActivities({
    required String babyId,
    required DateTime start,
    required DateTime end,
  }) async {
    return _activities
        .where((a) => a.babyId == babyId)
        .where((a) => a.timestamp.isAfter(start))
        .where((a) => a.timestamp.isBefore(end))
        .toList();
  }

  @override
  Future<void> saveActivity(ActivityEntity activity) async {
    _activities.add(activity);
  }
}
```

```dart
// ✅ DI 컨테이너에서 Repository 주입

// lib/di/injection_container.dart
void _registerMockRepositories() {
  sl.registerLazySingleton<IActivityRepository>(
    () => MockActivityRepository(),
  );
  sl.registerLazySingleton<IBabyRepository>(
    () => MockBabyRepository(),
  );
  // ... 나머지 Repository
}
```

### 6.3 데이터 모델 규칙

```dart
// ✅ Model 클래스 필수 구현

class ActivityModel {
  final String id;
  final ActivityType type;
  final String timestamp;  // ISO 8601 형식
  final int? durationMinutes;
  final double? amountMl;
  final String? notes;

  const ActivityModel({
    required this.id,
    required this.type,
    required this.timestamp,
    this.durationMinutes,
    this.amountMl,
    this.notes,
  });

  // ⚠️ 필수: fromJson 팩토리
  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id'] as String,
      type: ActivityType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ActivityType.other,
      ),
      timestamp: json['timestamp'] as String,
      durationMinutes: json['durationMinutes'] as int?,
      amountMl: (json['amountMl'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
    );
  }

  // ⚠️ 필수: toJson 메서드
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'timestamp': timestamp,
      if (durationMinutes != null) 'durationMinutes': durationMinutes,
      if (amountMl != null) 'amountMl': amountMl,
      if (notes != null) 'notes': notes,
    };
  }

  // ⚠️ 권장: copyWith 메서드
  ActivityModel copyWith({
    String? id,
    ActivityType? type,
    String? timestamp,
    int? durationMinutes,
    double? amountMl,
    String? notes,
  }) {
    return ActivityModel(
      id: id ?? this.id,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      amountMl: amountMl ?? this.amountMl,
      notes: notes ?? this.notes,
    );
  }
}
```

---

## 7. Security Requirements

### 🔒 Security Engineer + ⚖️ Compliance Officer

### 7.1 API 키 관리

```dart
// ❌ 절대 금지: 하드코딩
const apiKey = 'sk-xxxxxxxxxxxxx';

// ✅ 올바른 방법: 환경 변수
// .env 파일 (gitignore에 추가 필수)
OPENAI_API_KEY=sk-xxxxxxxxxxxxx

// 코드에서 사용
import 'package:flutter_dotenv/flutter_dotenv.dart';
final apiKey = dotenv.env['OPENAI_API_KEY'];
```

### 7.2 Supabase Row Level Security (v1.4)

```sql
-- ✅ Supabase RLS 정책 예시

-- 사용자는 자신의 데이터만 접근 가능
CREATE POLICY "Users can access own data"
ON users FOR ALL
USING (auth.uid() = id);

-- 아기 데이터는 부모만 접근
CREATE POLICY "Parents can access own babies"
ON babies FOR ALL
USING (auth.uid() = parent_id);

-- 활동 기록 접근 제어
CREATE POLICY "Users can access activities of own babies"
ON activities FOR ALL
USING (
  baby_id IN (
    SELECT id FROM babies WHERE parent_id = auth.uid()
  )
);
```

```dart
// ✅ 로컬 개발 시 Mock Repository 사용

// main.dart에서 BackendType 변경으로 전환
await di.initDependencies(
  backend: di.BackendType.mock,  // 로컬 개발
  // backend: di.BackendType.supabase,  // 프로덕션
);
```

### 7.3 민감 정보 처리

```yaml
# COPPA 준수 (아동 데이터 보호)
Required:
  - 부모 동의 없이 아동 데이터 수집 금지
  - 개인 식별 정보 최소화
  - 데이터 보존 기간 제한 (최대 2년)
  - 삭제 요청 시 30일 내 완전 삭제

Prohibited:
  - 아기 사진 서버 저장 (로컬만 허용)
  - 위치 정보 수집
  - 제3자 광고 SDK 사용
  - 아동 데이터 판매/공유
```

---

## 8. Testing Requirements

### 🛡️ QA + 💻 CTO

### 8.1 테스트 커버리지 목표

```yaml
Coverage Targets:
  Core Utils: 80%+ (sweet_spot_calculator 등)
  Data Models: 70%+
  Services: 60%+
  Providers: 50%+
  Widgets: Integration 테스트로 대체

Required Tests:
  - 모든 유틸리티 함수
  - 모든 데이터 모델 (fromJson/toJson)
  - 핵심 비즈니스 로직 (Sweet Spot 계산 등)
```

### 8.2 테스트 작성 규칙

```dart
// ✅ 테스트 파일 구조

// test/unit/utils/sweet_spot_calculator_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:lulu/core/utils/sweet_spot_calculator.dart';

void main() {
  group('SweetSpotCalculator', () {
    group('calculateWakeWindow', () {
      test('신생아(0-1개월)는 45-60분 반환', () {
        // Arrange
        final calculator = SweetSpotCalculator();
        final babyAgeWeeks = 2;

        // Act
        final result = calculator.calculateWakeWindow(babyAgeWeeks);

        // Assert
        expect(result.inMinutes, inInclusiveRange(45, 60));
      });

      test('월령 음수 입력 시 예외 발생', () {
        final calculator = SweetSpotCalculator();

        expect(
          () => calculator.calculateWakeWindow(-1),
          throwsA(isA<ArgumentError>()),
        );
      });
    });
  });
}
```

### 8.3 테스트 실행

```bash
# 전체 테스트
flutter test

# 커버리지 포함
flutter test --coverage

# 특정 파일
flutter test test/unit/utils/sweet_spot_calculator_test.dart
```

---

## 9. UI/UX Standards

### 🎨 CDO + 🔍 User Researcher

### 9.1 디자인 시스템

```yaml
# Midnight Blue 테마

Colors:
  Primary Background: "#0D1321" (Deep Midnight)
  Card Background: "rgba(26, 35, 50, 0.7)" (Glassmorphism)
  Accent Gold: "#D4AF6A" (Champagne Gold)

  Activity Colors:
    Sleep: "#E8D5E8" (Lavender)
    Feeding: "#D4AF6A" (Champagne Gold)
    Diaper: "#C5E8D5" (Mint)
    Play: "#B8D4B8" (Sage Green)
    Health: "#FFB5A7" (Coral)

Typography:
  Primary Font: SF Pro Display (iOS) / Roboto (Android)
  Title: 24sp, Bold
  Subtitle: 18sp, Medium
  Body: 16sp, Regular
  Caption: 14sp, Regular

Spacing:
  Base Unit: 8dp
  Card Padding: 16dp
  Section Gap: 24dp
```

### 9.2 Thumb Zone 규칙

```yaml
# 한 손 조작 최적화

Critical Zone (하단 1/3):
  - 주요 액션 버튼
  - 네비게이션
  - 기록 버튼

Comfortable Zone (중앙):
  - 주요 정보 표시
  - 카드 콘텐츠

Stretch Zone (상단 1/3):
  - 덜 중요한 정보
  - 설정, 프로필

Touch Target:
  Minimum: 44x44dp (Apple HIG)
  Recommended: 48x48dp
```

### 9.3 Dark Mode 필수

```dart
// ✅ 새벽 3시 시나리오 최적화

// Dark Mode가 기본값
class LuluApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.dark,  // ⚠️ 필수: Dark Mode 기본
      darkTheme: AppTheme.darkTheme,
      theme: AppTheme.lightTheme,
      // ...
    );
  }
}
```

---

## 10. Internationalization

### 🌐 Localization Lead + ✍️ Content Strategist

### 10.1 지원 언어

```yaml
Languages:
  Tier 1 (Launch):
    - en (English - US) - 기준 언어
    - ko (Korean)

  Tier 2 (6개월 후):
    - ja (Japanese)
    - de (German)

  Tier 3 (12개월 후):
    - es (Spanish)
    - fr (French)
    - zh (Chinese Simplified)
```

### 10.2 i18n 규칙

```dart
// ✅ 모든 사용자 노출 텍스트는 반드시 i18n 처리

// ❌ 잘못된 예시
Text('Sweet Spot Time')

// ✅ 올바른 예시
Text(AppLocalizations.of(context)!.sweetSpotTime)

// lib/l10n/app_en.arb
{
  "sweetSpotTime": "Sweet Spot Time",
  "@sweetSpotTime": {
    "description": "Title for the optimal sleep time card"
  }
}

// lib/l10n/app_ko.arb
{
  "sweetSpotTime": "최적 수면 시간"
}
```

### 10.3 숫자/날짜 포맷

```dart
// ✅ 로케일 기반 포맷팅

// 시간
final timeFormat = DateFormat.jm(locale);  // 2:30 PM (en) / 오후 2:30 (ko)

// 날짜
final dateFormat = DateFormat.yMMMd(locale);  // Jan 25, 2026 (en) / 2026년 1월 25일 (ko)

// 숫자
final numberFormat = NumberFormat.decimalPattern(locale);

// 단위 (설정에 따라)
final weightUnit = unitPrefs.useMetric ? 'kg' : 'lb';
final heightUnit = unitPrefs.useMetric ? 'cm' : 'in';
```

---

## 11. Medical Content Guidelines

### 🩺 Pediatric Advisor + 😴 Sleep Specialist + 🍼 Nutrition Specialist

### 11.1 필수 출처 명시

```yaml
# 모든 의학적 수치는 출처 필수

Required Sources:
  - WHO Child Growth Standards (2006)
  - AAP Safe Sleep Guidelines (2022)
  - CDC Developmental Milestones
  - 대한소아청소년과학회 가이드라인

Example:
  Wake Window (3-4개월): 1.5-2시간
  Source: "Based on AAP recommendations and peer-reviewed sleep studies"
```

### 11.2 면책 조항 (Disclaimer)

```dart
// ✅ 모든 의학 정보 화면에 포함

const medicalDisclaimer = '''
이 앱은 의학적 조언을 대체하지 않습니다.
아기의 건강에 대한 우려가 있으면 소아과 전문의와 상담하세요.

This app does not replace medical advice.
Consult a pediatrician for any health concerns about your baby.
''';
```

### 11.3 응급 상황 안내

```yaml
# 자동 경고 트리거

Red Flags:
  - 체온 38°C+ (100.4°F+): "발열이 감지되었습니다. 소아과 상담을 권장합니다."
  - 체중 감소 10%+: "체중 변화가 큽니다. 전문가 상담을 권장합니다."
  - 수유 거부 24시간+: "수유 패턴이 변했습니다. 관찰이 필요합니다."

Emergency Info:
  - 응급실 연결 버튼 (전화 앱 연동)
  - 지역별 응급 번호 안내 (119, 911 등)
```

### 11.4 콘텐츠 톤

```yaml
# Content Strategist 가이드라인

Principles:
  1. "데이터 → 감정" 변환:
    ❌ "7시간 23분 수면"
    ✅ "충분히 푹 잤어요! 오늘 기분 좋을 거예요 💤"

  2. "문제 → 해결" 프레이밍:
    ❌ "수면 부족 감지됨"
    ✅ "오늘은 조금 일찍 재워볼까요?"

  3. "경고 → 안내" 톤:
    ❌ "체중 미달 경고!"
    ✅ "성장 속도가 조금 느린 편이에요. 소아과 상담을 권해드려요."

금지 표현:
  - "이상", "문제", "경고", "실패"
  - 비교 표현 ("다른 아기보다...")
  - 명령형 ("~하세요" 대신 "~해볼까요?")
```

---

## 12. Performance Standards

### 💻 CTO + 📊 Data Scientist

### 12.1 성능 목표

```yaml
Performance Targets:
  App Launch: < 3초
  Screen Transition: < 300ms
  API Response: < 2초 (timeout: 30초)
  ML Inference: < 100ms

  Battery Consumption: < 10% (24시간)
  Memory Usage: < 150MB (일반 사용)
```

### 12.2 최적화 규칙

```dart
// ✅ ListView 최적화

// ❌ 잘못된 예시
ListView(
  children: activities.map((a) => ActivityCard(a)).toList(),
)

// ✅ 올바른 예시 - builder 사용
ListView.builder(
  itemCount: activities.length,
  itemBuilder: (context, index) => ActivityCard(activities[index]),
)

// ✅ const 생성자 적극 활용
const SizedBox(height: 16),
const Divider(),
const Icon(Icons.home),
```

### 12.3 이미지 최적화

```dart
// ✅ 이미지 캐싱

Image.network(
  imageUrl,
  cacheWidth: 200,   // 표시 크기에 맞춰 리사이즈
  cacheHeight: 200,
  fit: BoxFit.cover,
  loadingBuilder: (context, child, loadingProgress) {
    if (loadingProgress == null) return child;
    return const CircularProgressIndicator();
  },
  errorBuilder: (context, error, stackTrace) {
    return const Icon(Icons.error);
  },
)
```

### 12.4 빌드 성능 기준

```yaml
# 빌드 시간 목표 (CLAUDE.md v1.2 추가)

Build Time Targets:
  Clean Build (iOS Debug): < 5분 (300초)
  Clean Build (Android Debug): < 4분 (240초)
  Incremental Build: < 30초

  Hot Reload: < 1초
  Hot Restart: < 5초

Monitoring:
  - 주 1회: scripts/measure_build_time.sh 실행
  - CI/CD 파이프라인에서 자동 추적
  - 10% 이상 증가 시 원인 분석 필수

성능 저하 시 조치:
  1. scripts/clean_build.sh 실행
  2. 대형 파일 분할 검토 (1,000줄 초과)
  3. 의존성 최적화 검토
```

### 12.5 빌드 최적화 규칙

```yaml
# 의존성 관리
Dependencies:
  ❌ 버전에 'any' 사용 금지
     예: uuid: any  # 잘못된 예

  ✅ Caret 버전 범위 사용
     예: uuid: ^4.5.2  # 올바른 예

  ⚠️ 월 1회: flutter pub upgrade 실행

  🔍 분기 1회: 미사용 패키지 정리
     flutter pub deps --style=compact 로 확인

# 코드 구조
Code Structure:
  ⚠️ 단일 파일 1,000줄 초과 시 분할 검토

  ✅ 권장 파일 크기:
     - Widget: 최대 300줄
     - Screen: 최대 500줄
     - Model/Service: 최대 400줄

  ✅ 큰 위젯은 private 빌드 메서드로 분리:
     Widget _buildHeader() { ... }
     Widget _buildContent() { ... }

# Backend 전환 (v1.4)
Backend Configuration:
  개발 환경: Mock Backend (DI)
  스테이징: Supabase
  프로덕션: Supabase

  환경변수로 전환:
    BackendType backend =
      EnvironmentValidator.isProduction
        ? BackendType.supabase
        : BackendType.mock;

# iOS 빌드 설정
iOS Configuration:
  ✅ Podfile에 platform :ios, '13.0' 명시
  ✅ ENABLE_BITCODE = 'NO' (빌드 시간 단축)
  ✅ BUILD_LIBRARY_FOR_DISTRIBUTION = 'YES'
  ✅ CocoaPods Stats 비활성화됨

# 정기 유지보수
Maintenance Schedule:
  월 1회:
    - flutter clean && flutter pub get
    - cd ios && pod deintegrate && pod install
    - scripts/clean_build.sh 실행

  분기 1회:
    - flutter pub cache repair
    - 빌드 성능 측정 및 기록

  반기 1회:
    - 대형 파일 리팩토링 검토
    - 의존성 버전 업그레이드
```

### 12.6 빌드 도구 및 스크립트

```bash
# 빌드 정리 스크립트
# scripts/clean_build.sh

용도:
  - 빌드 캐시 및 아티팩트 완전 정리
  - iOS Pods, Android Gradle 캐시 삭제
  - .dart_tool, build 디렉토리 정리

사용법:
  ./scripts/clean_build.sh

권장 실행 주기:
  - 월 1회 정기 실행
  - 빌드 시간이 평소보다 20% 이상 느릴 때
  - Flutter/Xcode 버전 업그레이드 후


# 빌드 시간 측정 스크립트
# scripts/measure_build_time.sh

용도:
  - Clean Build 시간 측정
  - Incremental Build 시간 측정
  - build_performance_log.txt에 기록

사용법:
  ./scripts/measure_build_time.sh

권장 실행 주기:
  - 주 1회 성능 모니터링
  - 주요 리팩토링 전후 비교
  - 의존성 추가/제거 후


# 의존성 분석
flutter pub deps --style=compact     # 간단한 트리
flutter pub deps --style=tree        # 전체 트리
flutter pub outdated                 # 업데이트 가능 패키지


# 빌드 크기 분석
flutter build apk --analyze-size     # Android APK 크기 분석
flutter build ios --analyze-size     # iOS IPA 크기 분석
```

### 12.7 성능 측정 및 추적

```yaml
# Baseline 설정 (최초 1회)
Initial Measurement:
  1. scripts/measure_build_time.sh 실행
  2. 결과를 build_performance_log.txt에 기록
  3. README.md에 현재 빌드 시간 명시

# 지속적 모니터링
Continuous Monitoring:
  주간 체크:
    - 빌드 시간 측정
    - 로그 파일 확인
    - 추세 분석

  경고 기준:
    - Clean Build 10% 증가
    - Incremental Build 20% 증가

  조치:
    1. 최근 변경사항 검토
    2. 의존성 추가 확인
    3. 대형 파일 증가 확인
    4. scripts/clean_build.sh 실행

# CI/CD 통합 (선택적)
GitHub Actions Example:
  - name: Measure Build Time
    run: |
      ./scripts/measure_build_time.sh
      cat build_performance_log.txt

  - name: Check Performance
    run: |
      # 빌드 시간이 5분 초과 시 경고
      if [ $CLEAN_BUILD_TIME -gt 300 ]; then
        echo "⚠️ Build time exceeded 5 minutes"
        exit 1
      fi
```

---

## 13. Git Workflow

### 💻 CTO + 🛡️ QA

### 13.1 브랜치 전략

```yaml
Branches:
  main: 프로덕션 배포용 (보호됨)
  develop: 개발 통합 브랜치
  feature/*: 기능 개발
  bugfix/*: 버그 수정
  hotfix/*: 긴급 수정

Naming Convention:
  feature/sweet-spot-calculator
  bugfix/fix-timezone-issue
  hotfix/critical-crash-fix
```

### 13.2 커밋 메시지 규칙

```yaml
Format: <type>(<scope>): <subject>

Types:
  feat: 새로운 기능
  fix: 버그 수정
  docs: 문서 수정
  style: 코드 포맷팅
  refactor: 리팩토링
  test: 테스트 추가
  chore: 빌드, 설정 변경

Examples:
  feat(sleep): add Sweet Spot calculator
  fix(i18n): correct Korean translations
  docs(readme): update setup instructions
  test(calculator): add edge case tests
```

### 13.3 PR 체크리스트

```markdown
## PR Checklist

### 기본 요구사항
- [ ] `dart format lib/` 실행 완료
- [ ] `dart analyze lib/` 경고 없음
- [ ] `flutter test` 모든 테스트 통과

### 기능 관련
- [ ] 새로운 문자열은 i18n 처리 완료
- [ ] API 호출에 로딩/에러 처리 포함
- [ ] 민감 정보 하드코딩 없음

### 의학적 콘텐츠 (해당 시)
- [ ] WHO/AAP 출처 명시
- [ ] 면책 조항 포함
- [ ] Pediatric Advisor 검토 완료

### UI/UX
- [ ] Dark Mode 테스트 완료
- [ ] Thumb Zone 내 주요 액션 배치
- [ ] 접근성 테스트 (VoiceOver/TalkBack)
```

### 13.4 Claude Code 커밋 규칙

```yaml
# 🤖 Claude Code 자동 커밋 가이드라인
# 이 규칙은 Claude Code가 작업 시 자동으로 따릅니다.

커밋 트리거:
  필수:
    - 작업 지시서의 ✅ CHECKPOINT 도달 시
    - Phase 완료 시
    - 사용자가 "커밋해줘" 요청 시

  선택:
    - 새 파일 생성 완료 (빌드 가능 상태일 때)
    - 버그 수정 완료

커밋 전 필수 확인:
  1. flutter analyze lib/ → 에러 0개
  2. 앱 빌드 가능한 상태 (import 누락 없음)
  3. 작업 중인 기능이 완결된 단위

커밋하지 않는 경우:
  - 작업 중간 (빌드 불가능 상태)
  - 단순 주석/포맷팅만 변경
  - 디버깅용 print문 추가
  - 실험적 코드 (사용자 확인 전)

커밋 메시지:
  우선순위:
    1. 작업 지시서에 명시된 메시지 사용
    2. 없으면 13.2 규칙에 따라 자동 생성

  형식: <type>(<scope>): <subject>
  예시:
    - feat(sweet-spot): integrate hero card with provider
    - fix(home): remove duplicate summary section
    - refactor(legacy): delete deprecated action zone card
```

### 13.5 작업 지시서 CHECKPOINT 템플릿

```markdown
## Phase N: [작업명] (예상 시간)

### Task N.1: [세부 작업]
- [ ] 구현 내용 1
- [ ] 구현 내용 2

### Task N.2: [세부 작업]
- [ ] 구현 내용 1

### ✅ CHECKPOINT
- [ ] `flutter analyze lib/` 에러 0개
- [ ] 앱 빌드 성공
- [ ] 커밋: `feat(scope): description`
- [ ] GitHub Sync 요청 (Claude.ai 프로젝트 동기화용)
```

### 13.6 Claude.ai ↔ Claude Code 동기화

```yaml
# 두 환경 간 코드 동기화 워크플로우

작업 흐름:
  1. Claude.ai: 작업 지시서 작성 & GitHub 연동
  2. Claude Code: 작업 지시서 기반 코드 작성
  3. Claude Code: CHECKPOINT 도달 → 커밋 & 푸시
  4. Claude.ai: GitHub "Sync now" 클릭 → 최신 코드 확인
  5. Claude.ai: 다음 작업 지시서 작성 (반복)

동기화 시점:
  - Phase 완료 시
  - 주요 기능 구현 완료 시
  - 코드 리뷰/검토 필요 시

Claude Code 커밋 후 메시지:
  "✅ 커밋 완료: [커밋 메시지]
   → Claude.ai에서 GitHub Sync 해주세요."
```

---

## 14. Quality Gates

### 🛡️ QA + 🧐 Product Auditor

### 14.1 커밋 전 필수 체크

```bash
#!/bin/bash
# pre-commit hook

# 1. 포맷팅
dart format lib/ --set-exit-if-changed

# 2. 정적 분석
dart analyze lib/

# 3. 테스트
flutter test

# 4. i18n 체크
dart scripts/check_i18n.dart

# 모두 통과해야 커밋 가능
```

### 14.2 릴리즈 전 체크리스트

```yaml
# 🚀 릴리즈 전 필수 확인

Technical:
  - [ ] 모든 테스트 통과
  - [ ] 크래시 없음 (24시간 내부 테스트)
  - [ ] 메모리 누수 없음
  - [ ] 배터리 소모 10% 미만

Medical:
  - [ ] 모든 수치 WHO/AAP 출처 확인
  - [ ] 면책 조항 포함 확인
  - [ ] 응급 상황 프로토콜 동작 확인

UX:
  - [ ] 다국어(EN/KR) 완전 번역
  - [ ] Dark Mode 모든 화면 확인
  - [ ] 접근성 테스트 통과

Security:
  - [ ] API 키 노출 없음
  - [ ] Supabase RLS 정책 검증
  - [ ] 개인정보처리방침 최신화

Compliance:
  - [ ] App Store 가이드라인 준수
  - [ ] Play Store 정책 준수
  - [ ] COPPA 준수 (아동 데이터)
```

---

## 15. Forbidden Patterns

### 🛡️ QA + 🔒 Security Engineer

### 15.1 절대 금지 코드 패턴

```dart
// ❌ 절대 금지

// 1. API 키 하드코딩
const apiKey = 'sk-xxxxxxxxxxxxx';  // ❌ NEVER

// 2. print문 프로덕션 코드
print('Debug: $value');  // ❌ 로깅 라이브러리 사용

// 3. 빈 catch 블록
try {
  await api.call();
} catch (e) {
  // ❌ 에러 무시 금지
}

// 4. 강제 null unwrap (뱅 연산자)
final name = user!.name!;  // ❌ null 체크 필수

// 5. 무한 ListView
ListView(
  children: hugeList.map((e) => Widget(e)).toList(),  // ❌
)

// 6. setState 남용 (Provider 사용)
setState(() {
  _data = newData;  // ❌ Provider로 관리
});

// 7. BuildContext 비동기 사용
onPressed: () async {
  await Future.delayed(Duration(seconds: 1));
  Navigator.of(context).pop();  // ❌ context가 유효하지 않을 수 있음
}
```

### 15.2 올바른 대안

```dart
// ✅ 올바른 패턴

// 1. 환경변수 사용
final apiKey = dotenv.env['OPENAI_API_KEY'];

// 2. 로깅 라이브러리
debugPrint('Debug: $value');  // 또는 logger 패키지

// 3. 에러 처리
try {
  await api.call();
} catch (e) {
  _errorMessage = e.toString();
  notifyListeners();
}

// 4. Null 안전 처리
final name = user?.name ?? 'Unknown';

// 5. ListView.builder
ListView.builder(
  itemCount: hugeList.length,
  itemBuilder: (_, i) => Widget(hugeList[i]),
)

// 6. Provider 사용
context.read<DataProvider>().updateData(newData);

// 7. mounted 체크
onPressed: () async {
  await Future.delayed(Duration(seconds: 1));
  if (mounted) {
    Navigator.of(context).pop();
  }
}
```

---

## 🤝 Agent Sign-offs

이 문서는 18명의 Elite Agent가 공동으로 작성하고 검토했습니다.

### C-Suite
- [x] 🎯 **CPO**: 제품 전략 및 우선순위 프레임워크
- [x] 🎨 **CDO**: UI/UX 디자인 시스템 및 접근성
- [x] 💻 **CTO**: 기술 스택 및 아키텍처
- [x] 🛡️ **QA**: 테스트 요구사항 및 품질 게이트

### Domain Specialists
- [x] 📈 **Growth Hacker**: 성장 메트릭 고려사항
- [x] 🩺 **Pediatric Advisor**: 의학적 정확성 가이드라인
- [x] 😴 **Sleep Specialist**: 수면 알고리즘 규칙
- [x] 🧠 **Developmental Lead**: 발달 콘텐츠 톤
- [x] 🏃 **Physical Specialist**: 신체 발달 지표
- [x] 🍼 **Nutrition Specialist**: 영양 가이드라인

### Quality & Integration
- [x] 🔍 **User Researcher**: 사용자 시나리오
- [x] 🧐 **Product Auditor**: 일관성 검사
- [x] 🧩 **System Architect**: 아키텍처 규칙

### Global & Scale
- [x] 🌐 **Localization Lead**: i18n 표준
- [x] 📊 **Data Scientist**: ML 통합 규칙
- [x] ✍️ **Content Strategist**: 콘텐츠 톤 가이드

### Trust & Safety
- [x] ⚖️ **Compliance Officer**: 규정 준수 요구사항
- [x] 🔒 **Security Engineer**: 보안 규칙

---

**Last Updated**: 2026-01-26
**Version**: 1.4
**Next Review**: 2026-02-26

---

## Changelog

### v1.4 (2026-01-26)
- **Added**: Multi-baby support with BabyProvider
  - Baby management screen with switcher widget
  - Onboarding Step 4 for multi-baby setup
  - babyId field added to ActivityModel
- **Added**: LuluTimePicker v2.0 integration in activity detail screen
- **Added**: Repository pattern documentation in Section 6.2
- **Updated**: Tech Stack section - Supabase as primary backend, GetIt for DI
- **Updated**: Architecture section - Clean Architecture + Repository Pattern
- **Updated**: Project Structure - Added domain/, di/, l10n/ layers
- **Updated**: State Management - 7 providers now registered (added BabyProvider, HomeDataProvider, SmartCoachProvider)
- **Updated**: Security section - Supabase RLS instead of Firebase Rules
- **Fixed**: Version inconsistency (header vs footer)
- **Fixed**: i18n missing keys - 7 keys added to records screens
- **Fixed**: DI issues - missing imports, duplicate registrations

### v1.3 (2026-01-26)
- **BREAKING**: Firebase → Supabase 마이그레이션 완료
- **Removed**: Firebase 패키지 (firebase_core, cloud_firestore, firebase_auth)
- **Added**: Supabase 패키지 (supabase_flutter ^2.0.0)
- **Added**: Mock Repository 구현 (로컬 개발용)
  - MockActivityRepository
  - MockBabyRepository
  - MockAuthRepository
  - MockInsightRepository
  - MockPreferenceRepository
- **Changed**: DI 컨테이너 - Firebase 제거, Mock/Supabase 지원
- **Changed**: environment_validator.dart - Supabase 환경변수 추가
- **Changed**: personalization_memory_service.dart - Timestamp → ISO8601
- **Updated**: .env.example - Supabase 설정 추가
- **Performance**: iOS Pod 개수 동일 유지 (20개)
- **Performance**: 빌드 시간 ~2분 (Xcode: 114.5초)

### v1.2 (2026-01-26)
- **Added**: 12.4 빌드 성능 기준 - 빌드 시간 목표 및 모니터링
- **Added**: 12.5 빌드 최적화 규칙 - 의존성, 코드 구조, Firebase 최적화
- **Added**: 12.6 빌드 도구 및 스크립트 - clean_build.sh, measure_build_time.sh
- **Added**: 12.7 성능 측정 및 추적 - Baseline 설정 및 CI/CD 통합
- **Fixed**: pubspec.yaml - uuid 버전 고정 (any → ^4.5.2)
- **Fixed**: iOS Podfile 최적화 - platform 명시, 빌드 설정 추가
- **Added**: scripts/clean_build.sh - 빌드 캐시 정리 자동화
- **Added**: scripts/measure_build_time.sh - 빌드 시간 측정 도구

### v1.1 (2026-01-26)
- **Added**: 13.4 Claude Code 커밋 규칙
- **Added**: 13.5 작업 지시서 CHECKPOINT 템플릿
- **Added**: 13.6 Claude.ai ↔ Claude Code 동기화 워크플로우

### v1.0 (2026-01-25)
- Initial release
