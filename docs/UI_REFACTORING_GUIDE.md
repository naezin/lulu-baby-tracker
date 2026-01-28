# UI Refactoring Guide

**날짜**: 2026-01-28
**Sprint**: Sprint 3 Day 3
**목적**: AppStyles를 사용한 UI 일관성 개선

---

## 📋 개요

`lib/core/theme/app_styles.dart`를 생성하여 앱 전체에서 사용하는 공통 스타일을 중앙 집중화했습니다.

### 생성된 스타일 카테고리

1. **Container Styles**
   - `glassCard()` - Glassmorphism 카드
   - `settingsCard()` - Settings 화면용 카드
   - `infoCard()` - 정보/경고/성공 카드
   - `dangerCard()` - Danger Zone 카드
   - `inputField()` - 입력 필드

2. **Text Styles**
   - `sectionHeader()` - 섹션 헤더
   - `bodyText()` - 본문
   - `caption()` - 보조 텍스트
   - `title()` - 제목
   - `headline()` - 대형 제목
   - `label()` - 라벨

3. **Button Styles**
   - `primaryButton()` - 기본 버튼
   - `dangerButton()` - Danger 버튼
   - `outlinedButton()` - Outlined 버튼
   - `textButton()` - Text 버튼

4. **Input Decoration**
   - `textFieldDecoration()` - TextField용 InputDecoration

5. **Dialog Styles**
   - `dialogBackground` - 다이얼로그 배경색
   - `dialogShape()` - 다이얼로그 Shape

6. **Spacing & Layout**
   - 표준 간격 상수 (XS ~ XXL)
   - 표준 패딩
   - SizedBox 헬퍼

7. **Loading Indicators**
   - `smallLoading()` - 작은 로딩
   - `mediumLoading()` - 중간 로딩

8. **Alert/Banner Styles**
   - `successBanner()` - 성공 배너
   - `warningBanner()` - 경고 배너
   - `errorBanner()` - 에러 배너
   - `infoBanner()` - 정보 배너

---

## 🔧 리팩토링 가이드

### Before (중복 코드)

```dart
Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: const Color(0x1AFFFFFF),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: const Color(0x33FFFFFF)),
  ),
  child: ...
)
```

### After (AppStyles 사용)

```dart
import '../../core/theme/app_styles.dart';

Container(
  padding: AppStyles.paddingAll,
  decoration: AppStyles.glassCard(),
  child: ...
)
```

---

## 📝 리팩토링 우선순위

### P0 (즉시 적용)

**Settings Screen** - 이미 부분적으로 적용됨
- Danger Zone 카드 → `AppStyles.dangerCard()`
- 다이얼로그 배경 → `AppStyles.dialogBackground`

### P1 (다음 Sprint)

**Log Screens**
- `/lib/presentation/screens/activities/log_sleep_screen.dart`
- `/lib/presentation/screens/activities/log_feeding_screen.dart`
- `/lib/presentation/screens/activities/log_diaper_screen.dart`
- `/lib/presentation/screens/activities/log_play_screen.dart`
- `/lib/presentation/screens/activities/log_health_screen.dart`

**리팩토링 예시**:
```dart
// Before
Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: _themeColor.withOpacity(0.1),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: _themeColor.withOpacity(0.3)),
  ),
  child: ...
)

// After
Container(
  padding: AppStyles.paddingAll,
  decoration: AppStyles.infoCard(accentColor: _themeColor),
  child: ...
)
```

### P2 (추후 정리)

**Analysis Screen**
- `/lib/presentation/screens/analysis/analysis_screen.dart`

**Home Screen**
- `/lib/presentation/screens/home/home_screen.dart`

**Widgets**
- `/lib/presentation/widgets/` 폴더 내 모든 위젯

---

## 🎯 리팩토링 체크리스트

### Container 스타일

- [ ] Glass 카드 → `AppStyles.glassCard()`
- [ ] Settings 카드 → `AppStyles.settingsCard()`
- [ ] 정보 카드 → `AppStyles.infoCard()`
- [ ] 입력 필드 → `AppStyles.inputField()`

### Text 스타일

- [ ] 섹션 헤더 → `AppStyles.sectionHeader()`
- [ ] 본문 → `AppStyles.bodyText()`
- [ ] 보조 텍스트 → `AppStyles.caption()`

### Button 스타일

- [ ] Primary 버튼 → `AppStyles.primaryButton()`
- [ ] Danger 버튼 → `AppStyles.dangerButton()`
- [ ] Outlined 버튼 → `AppStyles.outlinedButton()`

### Input Decoration

- [ ] TextField → `AppStyles.textFieldDecoration()`

### Spacing

- [ ] 하드코딩된 간격 → `AppStyles.spacingXX`
- [ ] `SizedBox(height: 16)` → `AppStyles.verticalSpacing(16)`
- [ ] `EdgeInsets.all(16)` → `AppStyles.paddingAll`

### Loading

- [ ] CircularProgressIndicator → `AppStyles.smallLoading()` / `mediumLoading()`

---

## 📊 예상 효과

### 코드 중복 감소
- **Before**: 각 화면마다 동일한 스타일 코드 반복 (~50줄/화면)
- **After**: AppStyles import 1줄 + 메서드 호출 1줄

### 유지보수성 향상
- 스타일 변경 시 한 곳만 수정
- 디자인 일관성 자동 보장

### 파일 크기 감소
- **예상**: 각 화면당 ~30% 코드 감소
- **전체**: ~500줄 이상 코드 감소

---

## 🚀 다음 단계

1. **Sprint 4**: Log Screens 리팩토링 (2시간)
2. **Sprint 5**: Analysis & Home 리팩토링 (1.5시간)
3. **Sprint 6**: Widgets 리팩토링 (1시간)

---

## 📚 참고 자료

**AppStyles 파일**: `/lib/core/theme/app_styles.dart`
**AppTheme 파일**: `/lib/core/theme/app_theme.dart`

**사용 예시**:
```dart
import 'package:lulu/core/theme/app_styles.dart';
import 'package:lulu/core/theme/app_theme.dart';

// Container
Container(
  decoration: AppStyles.glassCard(borderRadius: 16),
  child: Text(
    'Hello',
    style: AppStyles.title(),
  ),
)

// Button
ElevatedButton(
  style: AppStyles.primaryButton(backgroundColor: AppTheme.lavenderMist),
  onPressed: () {},
  child: Text('Continue'),
)

// TextField
TextField(
  decoration: AppStyles.textFieldDecoration(
    hintText: 'Enter name',
    focusedBorderColor: AppTheme.lavenderMist,
  ),
)
```

---

**작성자**: Claude (Sprint 3 Day 3)
**마지막 업데이트**: 2026-01-28
