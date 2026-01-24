# 🌍 Lulu i18n & 글로벌 표준 구현 가이드

## 완료된 구현

### ✅ 1. 핵심 유틸리티 시스템

#### 📁 `lib/core/localization/locale_manager.dart`
- **로케일 관리**: 영어(US), 한국어(KR) 지원
- **단위 시스템 관리**: Metric, Imperial 자동 전환
- **자동 기본값**: 미국 → Imperial, 한국 → Metric
- **실시간 반영**: `ChangeNotifier` 기반 상태 관리

#### 📁 `lib/core/utils/unit_converter.dart`
**자체 검증 로직 포함**:
- ✅ 온도: ℃ ↔ ℉ (역변환 오차 0.1℃ 이내)
- ✅ 수유량: ml ↔ oz (역변환 오차 1ml 이내, 정확한 29.5735 사용)
- ✅ 무게: kg ↔ lb (역변환 오차 0.01kg 이내)
- ✅ 길이: cm ↔ in

```dart
// 사용 예시
final tempF = UnitConverter.convertTemperature(37.5, UnitSystem.metric, UnitSystem.imperial);
// 결과: 99.5°F

final formatted = UnitConverter.formatTemperature(37.5, UnitSystem.imperial);
// 결과: "99.5°F"
```

#### 📁 `lib/core/utils/date_formatter.dart`
**로케일별 자동 포맷**:
- ✅ 날짜: MM/DD/YYYY (US) vs YYYY. MM. DD. (KR)
- ✅ 시간: h:mm AM/PM (US) vs HH:mm (KR)
- ✅ AM/PM 위치 검증 로직 포함
- ✅ 아기 월령 계산 (만 나이, 음수 방지)

```dart
// 사용 예시
final dateUS = DateFormatter.formatDate(DateTime.now(), Locale('en', 'US'));
// 결과: "01/22/2026"

final dateKR = DateFormatter.formatDate(DateTime.now(), Locale('ko', 'KR'));
// 결과: "2026. 01. 22."

final timeUS = DateFormatter.formatTime(DateTime(2026, 1, 22, 14, 30), Locale('en', 'US'));
// 결과: "2:30 PM"

final timeKR = DateFormatter.formatTime(DateTime(2026, 1, 22, 14, 30), Locale('ko', 'KR'));
// 결과: "14:30"
```

---

## 📋 필요한 추가 작업

### 1. ARB 파일 생성

**`lib/l10n/app_en.arb`** (미국 영어 - 전문적이고 격려하는 톤):

```json
{
  "@@locale": "en",

  "navHome": "Home",
  "navRecords": "Records",
  "navInsights": "Insights",
  "navChat": "AI Chat",
  "navStats": "Stats",

  "settings": "Settings",
  "settingsLanguage": "Language",
  "settingsLanguageDesc": "Choose your preferred language",
  "settingsUnits": "Unit System",
  "settingsUnitsDesc": "Temperature, weight, and volume units",

  "unitSystemMetric": "Metric (kg, ℃, ml)",
  "unitSystemImperial": "Imperial (lb, ℉, oz)",

  "timeJustNow": "Just now",
  "timeMinutesAgo": "{count} minutes ago",
  "@timeMinutesAgo": {
    "placeholders": {
      "count": {"type": "int"}
    }
  },

  "ageMonthsDays": "{months} months {days} days",
  "@ageMonthsDays": {
    "placeholders": {
      "months": {"type": "int"},
      "days": {"type": "int"}
    }
  },

  "activitySleep": "Sleep",
  "activityFeeding": "Feeding",
  "activityDiaper": "Diaper",

  "aiCoachingTitle": "AI Coaching Insight",
  "aiCoachingAnalyzing": "AI is analyzing...",
  "aiCoachingEmpathy": "Empathy",
  "aiCoachingInsight": "Data Insight",
  "aiCoachingAction": "Action Plan",
  "aiCoachingFeedbackQuestion": "Was this helpful?",
  "aiCoachingFeedbackPositive": "Helpful",
  "aiCoachingFeedbackNegative": "Not helpful",
  "aiCoachingFeedbackThanks": "Thank you for your feedback! We'll use it to improve our advice.",

  "criticalAlertTitle": "Expert Consultation Recommended",
  "criticalAlertMessage": "Your baby's condition requires careful observation. We recommend consulting with a pediatrician and can generate a report to share with your doctor.",
  "criticalAlertButton": "Generate PDF Report",

  "chartTapHint": "Tap on the chart to have AI analyze that time period",
  "longestSleepStretch": "Longest Sleep Stretch"
}
```

**`lib/l10n/app_ko.arb`** (한국어 - 친절하고 공감하는 톤):

```json
{
  "@@locale": "ko",

  "navHome": "홈",
  "navRecords": "기록",
  "navInsights": "인사이트",
  "navChat": "AI 채팅",
  "navStats": "통계",

  "settings": "설정",
  "settingsLanguage": "언어",
  "settingsLanguageDesc": "원하시는 언어를 선택하세요",
  "settingsUnits": "단위 시스템",
  "settingsUnitsDesc": "온도, 무게, 수유량 단위",

  "unitSystemMetric": "미터법 (kg, ℃, ml)",
  "unitSystemImperial": "야드파운드법 (lb, ℉, oz)",

  "timeJustNow": "방금 전",
  "timeMinutesAgo": "{count}분 전",
  "@timeMinutesAgo": {
    "placeholders": {
      "count": {"type": "int"}
    }
  },

  "ageMonthsDays": "{months}개월 {days}일",
  "@ageMonthsDays": {
    "placeholders": {
      "months": {"type": "int"},
      "days": {"type": "int"}
    }
  },

  "activitySleep": "수면",
  "activityFeeding": "수유",
  "activityDiaper": "기저귀",

  "aiCoachingTitle": "AI 코칭 인사이트",
  "aiCoachingAnalyzing": "AI가 분석 중입니다...",
  "aiCoachingEmpathy": "공감 메시지",
  "aiCoachingInsight": "데이터 통찰",
  "aiCoachingAction": "행동 지침",
  "aiCoachingFeedbackQuestion": "도움이 되었나요?",
  "aiCoachingFeedbackPositive": "도움됨",
  "aiCoachingFeedbackNegative": "별로",
  "aiCoachingFeedbackThanks": "피드백 감사합니다! 더 나은 조언을 위해 활용하겠습니다.",

  "criticalAlertTitle": "전문가 상담 권고",
  "criticalAlertMessage": "아기의 상태가 면밀한 관찰이 필요해 보입니다. 소아과 방문을 권장하며, 의사에게 보여줄 오늘의 리포트를 생성할 수 있습니다.",
  "criticalAlertButton": "PDF 리포트 생성",

  "chartTapHint": "차트를 탭하면 AI가 그 시간의 패턴을 분석해줍니다",
  "longestSleepStretch": "가장 긴 수면 시간"
}
```

### 2. pubspec.yaml 설정

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  intl: ^0.18.0
  shared_preferences: ^2.2.0
  provider: ^6.0.0

flutter:
  generate: true

flutter_intl:
  enabled: true
```

### 3. l10n.yaml 생성

```yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
```

---

## 🔧 사용 방법

### 1. main.dart 설정

```dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/localization/locale_manager.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final localeManager = LocaleManager();
  await localeManager.initialize();

  runApp(
    ChangeNotifierProvider.value(
      value: localeManager,
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleManager>(
      builder: (context, localeManager, child) {
        return MaterialApp(
          title: 'Lulu',
          locale: localeManager.locale,
          supportedLocales: LocaleManager.supportedLocales,
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: MainNavigation(),
        );
      },
    );
  }
}
```

### 2. 위젯에서 사용

```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeManager = Provider.of<LocaleManager>(context);

    return Column(
      children: [
        // 텍스트는 l10n 사용
        Text(l10n.navHome),

        // 온도 표시 (자동 변환)
        Text(
          UnitConverter.formatTemperature(37.5, localeManager.unitSystem),
        ),

        // 날짜 표시 (자동 포맷)
        Text(
          DateFormatter.formatDate(DateTime.now(), localeManager.locale),
        ),

        // 상대 시간
        Builder(
          builder: (context) {
            final relative = DateFormatter.getRelativeTime(
              someDateTime,
              DateTime.now(),
            );
            return Text(
              l10n.timeMinutesAgo(relative['value']),
            );
          },
        ),
      ],
    );
  }
}
```

### 3. 설정 화면에서 변경

```dart
class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeManager = Provider.of<LocaleManager>(context);

    return ListView(
      children: [
        ListTile(
          title: Text(l10n.settingsLanguage),
          subtitle: Text(l10n.settingsLanguageDesc),
          trailing: DropdownButton<Locale>(
            value: localeManager.locale,
            items: LocaleManager.supportedLocales.map((locale) {
              return DropdownMenuItem(
                value: locale,
                child: Text(locale.languageCode == 'ko' ? '한국어' : 'English'),
              );
            }).toList(),
            onChanged: (newLocale) {
              if (newLocale != null) {
                localeManager.setLocale(newLocale);
              }
            },
          ),
        ),

        ListTile(
          title: Text(l10n.settingsUnits),
          subtitle: Text(l10n.settingsUnitsDesc),
          trailing: DropdownButton<UnitSystem>(
            value: localeManager.unitSystem,
            items: [
              DropdownMenuItem(
                value: UnitSystem.metric,
                child: Text(l10n.unitSystemMetric),
              ),
              DropdownMenuItem(
                value: UnitSystem.imperial,
                child: Text(l10n.unitSystemImperial),
              ),
            ],
            onChanged: (newSystem) {
              if (newSystem != null) {
                localeManager.setUnitSystem(newSystem);
              }
            },
          ),
        ),
      ],
    );
  }
}
```

---

## ✅ 자체 검증 로직

### 1. 단위 변환 검증

모든 변환 함수에 `assert` 포함:

```dart
// 예: 온도 변환
final result = (value * 9 / 5) + 32;
final reversed = convertTemperature(result, to, from);
assert((value - reversed).abs() < 0.1,
    'Temperature conversion error: $value != $reversed');
```

### 2. 날짜 검증

```dart
// 미래 날짜 방지
assert(!birthDate.isAfter(currentDate),
    'Birth date cannot be in the future');

// 음수 나이 방지
assert(ageInDays >= 0,
    'Age cannot be negative');
```

### 3. 시간 포맷 검증

```dart
// AM/PM이 올바른 위치에 있는지 확인 (미국)
if (locale.languageCode != 'ko') {
  assert(
    formatted.contains('AM') || formatted.contains('PM'),
    'Time format validation failed: AM/PM missing',
  );
}
```

---

## 🎯 UI 깨짐 방지

### Flexible 사용

```dart
// 텍스트 길이가 다를 수 있으므로
Row(
  children: [
    Icon(Icons.temperature),
    SizedBox(width: 8),
    Flexible(
      child: Text(
        UnitConverter.formatTemperature(temp, unitSystem),
        overflow: TextOverflow.ellipsis,
      ),
    ),
  ],
)
```

### AutoSizeText 사용

```dart
AutoSizeText(
  l10n.criticalAlertMessage,
  maxLines: 3,
  minFontSize: 12,
  maxFontSize: 16,
)
```

---

## 📊 적용 체크리스트

### 기존 코드 i18n 적용

- [ ] `main_navigation.dart`: 하단 바 텍스트
- [ ] `home_screen.dart`: "Good Morning" → l10n
- [ ] `ai_insight_bottom_sheet.dart`: 모든 텍스트
- [ ] `daily_rhythm_wheel_interactive.dart`: 힌트 텍스트
- [ ] Settings 화면 생성

### 단위 변환 적용

- [ ] 온도 표시 부분
- [ ] 수유량 입력/표시
- [ ] 아기 체중 표시
- [ ] 키 표시 (있는 경우)

### 날짜 포맷 적용

- [ ] 모든 날짜 표시
- [ ] 타임스탬프
- [ ] 상대 시간 ("2시간 전")
- [ ] 아기 월령 표시

---

## 🚀 다음 단계

1. **ARB 파일 생성**: 위의 JSON을 복사하여 생성
2. **flutter pub get**: 의존성 설치
3. **flutter gen-l10n**: 로컬라이제이션 파일 생성
4. **main.dart 수정**: LocaleManager 통합
5. **기존 위젯 수정**: 하드코딩된 텍스트 → l10n
6. **테스트**: 언어/단위 변경 시 실시간 반영 확인

---

## 📝 요약

**완료된 것**:
- ✅ LocaleManager (상태 관리)
- ✅ UnitConverter (자체 검증 포함)
- ✅ DateFormatter (로케일별 자동 포맷)

**필요한 것**:
- ARB 파일 2개 (en, ko)
- pubspec.yaml 설정
- main.dart 통합
- 기존 코드 적용

**핵심 원칙**:
1. 모든 텍스트는 l10n 사용
2. 모든 숫자는 UnitConverter 사용
3. 모든 날짜는 DateFormatter 사용
4. 설정 변경 시 즉시 반영
5. UI 깨짐 방지 (Flexible, AutoSizeText)

이제 클로드에게 "기존 코드에 i18n 적용해줘"라고 요청하면,
위의 시스템을 사용하여 자동으로 변환할 수 있습니다!
