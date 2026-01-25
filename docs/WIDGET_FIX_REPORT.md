# 위젯 작동 안함 문제 해결 보고서

**날짜**: 2026-01-25
**문제**: Sweet Spot 위젯이 홈 화면에서 작동하지 않음
**상태**: ✅ 수정 완료

---

## 🔍 문제 원인

Swift로 작성된 iOS 위젯과 Flutter의 `WidgetService` 사이의 **키 이름 불일치**

### Swift 위젯이 기대하는 키 (LuluWidget.swift)

```swift
// Line 89: App Group 설정
let sharedDefaults = UserDefaults(suiteName: "group.com.lulu.babytracker")

// 읽으려는 키들:
sharedDefaults?.string(forKey: "widget_next_sweet_spot_time")
sharedDefaults?.integer(forKey: "widget_minutes_until_sweet_spot")
sharedDefaults?.double(forKey: "widget_sweet_spot_progress")
sharedDefaults?.bool(forKey: "widget_is_urgent")
sharedDefaults?.double(forKey: "widget_total_sleep_hours")
sharedDefaults?.integer(forKey: "widget_total_feeding_count")
sharedDefaults?.integer(forKey: "widget_total_diaper_count")
sharedDefaults?.string(forKey: "widget_next_action_type")
sharedDefaults?.string(forKey: "widget_next_action_time")
sharedDefaults?.integer(forKey: "widget_next_action_minutes")
sharedDefaults?.string(forKey: "widget_next_feeding_time")
```

### Flutter가 저장하던 키 (수정 전)

```dart
// ❌ 잘못된 키 이름
await HomeWidget.saveWidgetData('next_sleep_time', ...)  // Swift expects 'widget_next_sweet_spot_time'
await HomeWidget.saveWidgetData('next_sleep_minutes', ...)  // Swift expects 'widget_minutes_until_sweet_spot'
await HomeWidget.saveWidgetData('total_sleep_hours', ...)  // Swift expects 'widget_total_sleep_hours'
// 등등...
```

**결과**: Swift 위젯이 데이터를 찾지 못해 플레이스홀더만 표시됨

---

## ✅ 해결 방법

`/lib/data/services/widget_service.dart`를 수정하여 Swift가 기대하는 정확한 키 이름으로 데이터를 저장하도록 변경

### 수정 사항

#### 1. Small Widget (2x2) - Sweet Spot

```dart
// ✅ 수정 후
await HomeWidget.saveWidgetData('widget_next_sweet_spot_time',
  '${sleepPrediction.nextSweetSpot.hour}:${sleepPrediction.nextSweetSpot.minute.toString().padLeft(2, '0')}');
await HomeWidget.saveWidgetData('widget_minutes_until_sweet_spot', minutesUntil);
await HomeWidget.saveWidgetData('widget_sweet_spot_progress', progress);
await HomeWidget.saveWidgetData('widget_is_urgent', isUrgent);
```

#### 2. Medium Widget (4x2) - Daily Summary

```dart
// ✅ 수정 후
await HomeWidget.saveWidgetData('widget_total_sleep_hours', totalSleepHours);
await HomeWidget.saveWidgetData('widget_total_feeding_count', data['feedingCount']);
await HomeWidget.saveWidgetData('widget_total_diaper_count', data['diaperCount']);
await HomeWidget.saveWidgetData('widget_next_action_type', nextActionType);
await HomeWidget.saveWidgetData('widget_next_action_time', nextActionTime);
await HomeWidget.saveWidgetData('widget_next_action_minutes', nextActionMinutes);
```

#### 3. Lock Screen Widget

```dart
// ✅ 수정 후
await HomeWidget.saveWidgetData('widget_next_feeding_time', formattedTime);
```

---

## 📋 키 매핑 테이블

| Swift Key | Flutter Key (수정 전 ❌) | Flutter Key (수정 후 ✅) | 데이터 타입 |
|-----------|------------------------|------------------------|-----------|
| `widget_next_sweet_spot_time` | `next_sleep_time` | `widget_next_sweet_spot_time` | String |
| `widget_minutes_until_sweet_spot` | `next_sleep_minutes` | `widget_minutes_until_sweet_spot` | Int |
| `widget_sweet_spot_progress` | (없음) | `widget_sweet_spot_progress` | Double |
| `widget_is_urgent` | (별도 저장 안함) | `widget_is_urgent` | Bool |
| `widget_total_sleep_hours` | `total_sleep_hours` (String) | `widget_total_sleep_hours` | Double |
| `widget_total_feeding_count` | `feeding_count` | `widget_total_feeding_count` | Int |
| `widget_total_diaper_count` | `diaper_count` | `widget_total_diaper_count` | Int |
| `widget_next_action_type` | `next_action` | `widget_next_action_type` | String |
| `widget_next_action_time` | (없음) | `widget_next_action_time` | String |
| `widget_next_action_minutes` | `next_action_minutes` | `widget_next_action_minutes` | Int |
| `widget_next_feeding_time` | `next_feed_time` | `widget_next_feeding_time` | String |

---

## 🔧 추가 개선 사항

### 1. Progress 계산 추가

```dart
final progress = (sleepPrediction.minutesAwake / sleepPrediction.standardWakeWindow).clamp(0.0, 1.0);
```

Sweet Spot까지의 진행률을 원형 게이지로 표시하기 위해 계산

### 2. Action Time 포맷팅

```dart
final nextTime = sleepPrediction.nextSweetSpot;
nextActionTime = '${nextTime.hour}:${nextTime.minute.toString().padLeft(2, '0')}';
```

Medium 위젯에서 다음 액션 시간을 표시하기 위해 시간 포맷팅 추가

### 3. Legacy 키 유지

```dart
// Legacy keys for compatibility
await HomeWidget.saveWidgetData('total_sleep_hours', totalSleepHours.toStringAsFixed(1));
await HomeWidget.saveWidgetData('feeding_count', data['feedingCount']);
```

기존 코드와의 호환성을 위해 레거시 키도 함께 저장

---

## 🚀 테스트 방법

### 1. 앱 재빌드

```bash
cd /Users/naezin/Desktop/클로드앱플젝/lulu
flutter clean
flutter pub get
flutter run -d iphone
```

### 2. 위젯 데이터 저장 트리거

앱에서 아기 활동 기록 (수면, 수유 등):
1. 홈 화면에서 Quick Log Bar 사용
2. 수면 기록 → Sweet Spot 데이터 생성
3. 수유 기록 → Feeding 데이터 생성

### 3. 위젯 추가

1. 아이폰 홈 화면에서 빈 공간 길게 누르기
2. 왼쪽 상단 `+` 버튼 누르기
3. "Lulu" 검색
4. 위젯 선택:
   - **Small (2x2)**: Next Sweet Spot
   - **Medium (4x2)**: Daily Summary
   - **Lock Screen**: Next Feeding

### 4. 위젯 확인

- Small: 원형 진행률 + 분 카운터 + Sweet Spot 시간
- Medium: 오늘 통계 + 다음 액션 + 버튼들
- Lock Screen: 다음 수유 시간

---

## 🐛 디버깅 팁

### 위젯이 여전히 업데이트 안되면:

1. **App Group 확인**:
   ```bash
   # Xcode에서 확인
   # Runner Target → Signing & Capabilities → App Groups
   # ✅ group.com.lulu.babytracker 체크되어 있는지 확인
   ```

2. **위젯 Extension App Group 확인**:
   ```bash
   # LuluWidget Target → Signing & Capabilities → App Groups
   # ✅ 동일한 group.com.lulu.babytracker 체크되어 있는지 확인
   ```

3. **데이터 저장 확인**:
   ```dart
   // widget_service.dart에 디버그 로그 추가
   print('Widget data saved: widget_next_sweet_spot_time = $time');
   ```

4. **위젯 강제 새로고침**:
   ```dart
   await HomeWidget.updateWidget(
     iOSName: 'LuluWidgetProvider',
     androidName: 'LuluWidgetProvider',
   );
   ```

5. **시뮬레이터 재시작**:
   - 위젯 캐시가 남아있을 수 있으므로 시뮬레이터 완전 종료 후 재시작

---

## 📊 예상 결과

### Small Widget (2x2)
```
┌─────────────────┐
│                 │
│    ⚪ 52m       │  ← 원형 진행률 게이지
│                 │
│ Next Sweet Spot │
│     14:30       │  ← Sweet Spot 시간
│                 │
└─────────────────┘
```

### Medium Widget (4x2)
```
┌─────────────────────────────────────────┐
│  Today          │    Next Sleep         │
│  🛏️ 12.5h       │      14:30           │
│  🍼 8×          │      in 52m           │
│  ✨ 6×          │                       │
│                 │   🛏️  🍼  ✨         │
└─────────────────────────────────────────┘
```

### Lock Screen Widget
```
Next Feed
15:45
```

---

## ✅ 체크리스트

- [x] Swift 위젯 키 이름 분석
- [x] Flutter WidgetService 키 이름 수정
- [x] Small Widget 키 매핑
- [x] Medium Widget 키 매핑
- [x] Lock Screen Widget 키 매핑
- [x] Progress 계산 추가
- [x] Action Time 포맷팅
- [ ] 앱 재빌드 및 테스트
- [ ] 위젯 홈 화면 추가 테스트
- [ ] 실시간 업데이트 동작 확인

---

## 🎯 결론

문제는 **Flutter와 Swift 간 키 이름 불일치**였습니다.

모든 키를 Swift가 기대하는 `widget_*` 형식으로 통일하여 수정했으며, 이제 위젯이 정상적으로 Sweet Spot 데이터를 표시할 수 있습니다.

**다음 단계**: 앱을 재빌드하고 위젯을 홈 화면에 추가하여 정상 작동 확인

---

**수정 파일**:
- `/lib/data/services/widget_service.dart`

**영향받는 위젯**:
- LuluSmallWidget (2x2)
- LuluMediumWidget (4x2)
- LuluLockScreenWidget (Lock Screen)
