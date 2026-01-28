# Lulu - Screenshot Guide

**날짜**: 2026-01-28
**버전**: 1.0.0
**Sprint**: Sprint 3 Day 4

---

## 📸 스크린샷 요구사항

### 🍎 iOS (App Store)

#### 필수 크기

**6.5" Display** (iPhone 13 Pro Max, 14 Plus, 15 Plus)
- **해상도**: 1284 x 2778 pixels
- **개수**: 최소 1개, 권장 5개, 최대 10개
- **형식**: PNG or JPEG

**5.5" Display** (iPhone 8 Plus) - 선택 사항
- **해상도**: 1242 x 2208 pixels
- **개수**: 최소 1개, 최대 10개
- **형식**: PNG or JPEG

**iPad Pro 12.9"** - 선택 사항
- **해상도**: 2048 x 2732 pixels (portrait)
- **개수**: 최소 1개, 최대 10개

### 🤖 Android (Play Store)

#### 필수 크기

**Phone Screenshots**
- **최소 해상도**: 1080 x 1920 pixels
- **권장 해상도**: 1080 x 1920 또는 1440 x 2560 pixels
- **개수**: 최소 2개, 권장 5개, 최대 8개
- **형식**: PNG or JPEG (24-bit, no alpha)

**Tablet Screenshots** - 선택 사항
- **7-inch**: 1200 x 1920 pixels
- **10-inch**: 1800 x 2560 pixels
- **개수**: 최소 1개, 최대 8개

---

## 🎯 핵심 스크린샷 리스트

### 1. Home Screen - Sweet Spot Prediction ⭐

**우선순위**: 최고 (첫 번째 스크린샷)

**내용**:
- Sweet Spot 카드 (예측 시간 표시)
- 타이머 카운트다운
- 아기 이름과 월령
- 다음 낮잠까지 남은 시간

**강조 포인트**:
- 🌙 AI 예측 정확도
- ⏰ 실시간 타이머
- 👶 개인화된 추천

**추천 텍스트 오버레이**:
```
"Know exactly when your baby needs a nap"
AI-powered wake window predictions
```

**촬영 팁**:
- Sweet Spot이 "Now" 또는 "5 min" 상태에서 촬영
- 타이머가 활성화된 상태
- 깔끔한 배경 (다크 모드 권장)

---

### 2. Activity Logging ⭐

**우선순위**: 높음 (두 번째 스크린샷)

**내용**:
- 수면/수유/기저귀 로그 화면 중 하나
- 간편한 입력 폼
- 시간 선택 UI
- 메모 입력 (선택)

**강조 포인트**:
- 📝 원 탭 기록
- ⏱️ 직관적인 UI
- 🎨 깔끔한 디자인

**추천 텍스트 오버레이**:
```
"Track everything in one tap"
Simple, beautiful activity logging
```

**촬영 팁**:
- 수면 로그 화면 권장 (가장 핵심 기능)
- 입력 폼이 채워진 상태
- "Save" 버튼 강조

---

### 3. Sleep Analysis - Heatmap ⭐

**우선순위**: 높음 (세 번째 스크린샷)

**내용**:
- 수면 히트맵 (7일 또는 30일)
- 시간대별 패턴 시각화
- 색상 그라데이션 (파란색 → 보라색)
- 범례 (수면 시간 표시)

**강조 포인트**:
- 📊 시각적 인사이트
- 🌈 아름다운 데이터 시각화
- 📈 패턴 발견

**추천 텍스트 오버레이**:
```
"Discover your baby's sleep patterns"
Beautiful visual insights
```

**촬영 팁**:
- 데모 데이터로 히트맵 채우기
- 명확한 패턴이 보이는 상태
- 7일 뷰 권장

---

### 4. Growth Chart ⭐

**우선순위**: 중간 (네 번째 스크린샷)

**내용**:
- WHO 성장 곡선 (체중, 키, 머리둘레 중 하나)
- 아기의 성장 데이터 포인트
- 백분위수 선 (3rd, 50th, 97th)
- 차트 범례

**강조 포인트**:
- 📏 WHO 표준 기반
- 👶 건강한 성장 추적
- 📈 전문적인 차트

**추천 텍스트 오버레이**:
```
"Track healthy growth with WHO standards"
Weight, height, and head circumference
```

**촬영 팁**:
- 체중 차트 권장 (가장 직관적)
- 데이터 포인트 5-10개
- 성장 곡선이 명확하게 보이는 상태

---

### 5. Settings / Data Export ⭐

**우선순위**: 중간 (다섯 번째 스크린샷)

**내용**:
- 설정 화면 메인
- 또는 데이터 관리 섹션
- 또는 Privacy Policy 화면

**강조 포인트**:
- 🔒 프라이버시 우선
- 📤 데이터 내보내기
- 💾 로컬 저장

**추천 텍스트 오버레이**:
```
"Your data stays on your device"
Privacy-first, no cloud required
```

**촬영 팁**:
- 데이터 관리 섹션 권장
- JSON/CSV 내보내기 버튼 강조
- 깔끔한 레이아웃

---

## 📱 스크린샷 촬영 방법

### Option 1: 시뮬레이터/에뮬레이터 (권장)

#### iOS 시뮬레이터

```bash
# 1. 시뮬레이터 열기
open -a Simulator

# 2. 기기 선택
# Hardware → Device → iPhone 15 Plus (6.5")

# 3. 앱 실행
cd /path/to/lulu
flutter run --release

# 4. 스크린샷 촬영
# 방법 1: Cmd + S (파일로 저장)
# 방법 2: Cmd + Shift + 4 (클립보드에 복사)

# 저장 위치: ~/Desktop/
```

**크기 확인**:
```bash
# 스크린샷 크기 확인
sips -g pixelWidth -g pixelHeight screenshot.png

# 예상 결과: pixelWidth: 1284, pixelHeight: 2778
```

#### Android 에뮬레이터

```bash
# 1. 에뮬레이터 목록 확인
flutter emulators

# 2. 적절한 에뮬레이터 실행
# Pixel 7 Pro (1440 x 3120) 권장
flutter emulators --launch Pixel_7_API_34

# 3. 앱 실행
flutter run --release

# 4. 스크린샷 촬영
# 에뮬레이터 오른쪽 패널 → Camera 아이콘 클릭

# 저장 위치: ~/Desktop/
```

---

### Option 2: 실제 기기

#### 장점
- 더 자연스러운 화면
- 실제 성능 반영
- 터치 제스처 자연스러움

#### 단점
- 디바이스별로 별도 촬영 필요
- 크기 조정 필요할 수 있음

#### 촬영 방법 (iOS)

```bash
# QuickTime Player를 사용한 화면 녹화
1. iPhone을 Mac에 연결
2. QuickTime Player 열기
3. File → New Movie Recording
4. 카메라 선택: iPhone
5. 녹화 시작
6. 앱 사용 시연
7. 녹화 중지 → 프레임 추출
```

#### 촬영 방법 (Android)

```bash
# ADB를 사용한 스크린샷
adb shell screencap -p /sdcard/screenshot.png
adb pull /sdcard/screenshot.png ./screenshot.png
```

---

## 🎨 스크린샷 편집 가이드

### 텍스트 오버레이 추가

#### 권장 도구
- **Figma** (무료, 웹 기반)
- **Sketch** (macOS, 유료)
- **Canva** (무료, 템플릿 제공)

#### 텍스트 스타일 가이드

**Title Text**:
- Font: SF Pro Display (iOS) / Roboto (Android)
- Size: 48-60px
- Weight: Bold
- Color: White (#FFFFFF)
- Shadow: 0px 2px 8px rgba(0,0,0,0.3)

**Subtitle Text**:
- Font: SF Pro Text (iOS) / Roboto (Android)
- Size: 28-36px
- Weight: Regular
- Color: White (#F0F0F0)
- Shadow: 0px 1px 4px rgba(0,0,0,0.2)

#### 배치 가이드
- 상단 20% 또는 하단 20% 영역 사용
- 중앙 정렬
- 좌우 여백: 40-60px
- 위/아래 여백: 60-80px

---

### 디바이스 프레임 추가 (선택)

#### 권장 도구
- **Mockuper** - https://mockuper.net
- **Smartmockups** - https://smartmockups.com
- **Figma Community** - 무료 디바이스 프레임

#### 주의사항
⚠️ App Store/Play Store는 디바이스 프레임 **없이** 순수 스크린샷을 권장합니다.
프레임은 마케팅 자료용으로만 사용하세요.

---

## 📐 크기 조정 가이드

### 시뮬레이터 스크린샷이 요구사항과 다를 때

#### macOS 내장 도구 사용

```bash
# sips를 사용한 크기 조정
sips -z 2778 1284 input.png --out output.png

# 여러 파일 일괄 처리
for file in *.png; do
  sips -z 2778 1284 "$file" --out "resized_$file"
done
```

#### ImageMagick 사용

```bash
# 설치
brew install imagemagick

# 크기 조정
convert input.png -resize 1284x2778! output.png

# 여러 파일 일괄 처리
mogrify -resize 1284x2778! *.png
```

---

## ✅ 스크린샷 체크리스트

### 촬영 전

- [ ] 앱을 Release 모드로 실행
- [ ] 데모 데이터 준비 (아기 프로필, 활동 기록 등)
- [ ] Sweet Spot 타이머 활성화
- [ ] 히트맵에 충분한 데이터 (최소 7일)
- [ ] 성장 차트에 데이터 포인트 (5-10개)
- [ ] 다크 모드 활성화 (권장)
- [ ] 시뮬레이터/에뮬레이터 크기 확인

### 촬영 후

- [ ] 스크린샷 크기 확인 (픽셀 정확도)
- [ ] 상태바 제거 또는 깔끔한 상태 확인
  - Wi-Fi 연결됨
  - 배터리 충분
  - 시간: 9:41 (iOS 전통)
- [ ] 민감 정보 없음 (실제 아기 이름 등)
- [ ] 이미지 품질 확인 (압축, 노이즈)
- [ ] 파일 이름 정리
  - iOS: `ios_01_home.png`, `ios_02_log.png` ...
  - Android: `android_01_home.png`, `android_02_log.png` ...

### 업로드 전

- [ ] 파일 크기 확인 (각 스크린샷 < 8MB)
- [ ] 형식 확인 (PNG or JPEG)
- [ ] 순서 확인 (중요도 순)
- [ ] 텍스트 오버레이 가독성 확인
- [ ] 저작권 이슈 없음 (폰트, 아이콘 등)

---

## 🎬 동영상 프리뷰 (선택 사항)

### iOS (App Preview)

#### 요구사항
- **길이**: 15-30초
- **해상도**: 1080 x 1920 (portrait)
- **형식**: .mov, .m4v, .mp4
- **크기**: 최대 500 MB

#### 내용 제안
1. (0-5초) 앱 로고 + "Lulu - Baby Sleep Tracker"
2. (5-10초) Sweet Spot 예측 시연
3. (10-15초) 활동 로그 빠른 입력
4. (15-20초) 히트맵 스크롤
5. (20-25초) "Download now" CTA

### Android (Promo Video)

#### 요구사항
- **길이**: 30초 - 2분
- **해상도**: 최소 1280 x 720
- **형식**: MPEG-4 or WebM
- **크기**: 최대 100 MB

#### 제작 도구
- **iMovie** (macOS, 무료)
- **Final Cut Pro** (macOS, 유료)
- **DaVinci Resolve** (무료, 크로스 플랫폼)
- **Adobe Premiere Pro** (유료)

---

## 📊 스크린샷 A/B 테스팅 전략 (향후)

### 테스트 가능한 요소

1. **첫 번째 스크린샷**
   - A: Home Screen (Sweet Spot)
   - B: Sleep Analysis (Heatmap)
   - 가설: Sweet Spot이 더 명확한 가치 제안

2. **텍스트 오버레이**
   - A: 있음 (명확한 메시지)
   - B: 없음 (순수 UI)
   - 가설: 텍스트가 전환율 향상

3. **라이트 모드 vs 다크 모드**
   - A: 다크 모드
   - B: 라이트 모드
   - 가설: 다크 모드가 더 프리미엄

4. **디바이스 프레임**
   - A: 프레임 있음
   - B: 프레임 없음
   - 가설: 프레임 없는 것이 더 깔끔

### 측정 지표
- Impression → Install 전환율
- 스크린샷별 스와이프 비율
- 설치 후 첫 실행 비율

---

## 🌐 다국어 스크린샷 (향후)

### 한국어 버전

**촬영 시 주의사항**:
- 앱 언어를 한국어로 변경
- 텍스트 오버레이도 한국어로
- 시뮬레이터 언어 설정: 한국어

**한국어 텍스트 오버레이 예시**:
```
1. "아기의 낮잠 시간을 정확하게 예측"
   AI 기반 웨이크 윈도우 계산

2. "원 탭으로 모든 것을 기록"
   간편하고 아름다운 육아 일기

3. "아기의 수면 패턴 발견"
   시각적 인사이트

4. "WHO 표준 기반 성장 추적"
   체중, 키, 머리둘레

5. "내 데이터는 내 기기에만"
   프라이버시 우선, 클라우드 불필요
```

---

## 📁 파일 구조 제안

```
/screenshots
  /ios
    /6.5-inch
      01_home_sweet_spot.png
      02_activity_log_sleep.png
      03_analysis_heatmap.png
      04_growth_chart_weight.png
      05_settings_privacy.png
    /5.5-inch (선택)
      01_home_sweet_spot.png
      ...
  /android
    /phone
      01_home_sweet_spot.png
      02_activity_log_sleep.png
      03_analysis_heatmap.png
      04_growth_chart_weight.png
      05_settings_privacy.png
    /tablet (선택)
      01_home_sweet_spot.png
      ...
  /promo
    feature_graphic.png (1024x500, Play Store용)
    app_preview_video.mov (iOS용)
    promo_video.mp4 (Android용)
```

---

## 🚀 빠른 시작 가이드

### Step 1: 데모 데이터 준비
```dart
// test/helpers/demo_data_generator.dart
// 스크린샷용 데모 데이터 생성 헬퍼
```

### Step 2: 시뮬레이터 실행
```bash
# iOS
open -a Simulator
flutter run --release

# Android
flutter emulators --launch Pixel_7_API_34
flutter run --release
```

### Step 3: 스크린샷 촬영
```
1. Home Screen (Sweet Spot Now!)
2. Log Sleep Screen (입력 폼 채워진 상태)
3. Analysis Screen → Heatmap (7일 뷰)
4. Analysis Screen → Growth Chart (체중)
5. Settings Screen (데이터 관리 섹션)
```

### Step 4: 크기 확인 & 이름 변경
```bash
# 크기 확인
sips -g pixelWidth -g pixelHeight *.png

# 이름 변경
mv Screenshot1.png ios_01_home_sweet_spot.png
mv Screenshot2.png ios_02_log_sleep.png
...
```

### Step 5: 텍스트 오버레이 추가 (Figma)
```
1. Figma에서 1284x2778 프레임 생성
2. 스크린샷 배치
3. 텍스트 추가 (위 또는 아래)
4. Export: PNG, 2x
```

### Step 6: 업로드
```
App Store Connect → My Apps → Lulu
→ 1.0 Prepare for Submission
→ App Store Screenshots
→ iPhone 6.5" Display
→ Upload 5 images

Play Console → Lulu → Store presence
→ Main store listing → Phone screenshots
→ Upload 5 images
```

---

## 💡 팁 & 트릭

### 완벽한 스크린샷을 위한 팁

1. **일관된 시간 표시**
   - 모든 스크린샷에서 시간을 9:41 AM으로 통일 (iOS 전통)
   - Android는 10:30 또는 12:00 권장

2. **배터리 & 신호**
   - 배터리: 100% 또는 충전 중
   - Wi-Fi: 연결됨
   - 신호: 풀 바

3. **다크 모드 vs 라이트 모드**
   - 다크 모드 권장 (Lulu의 주요 테마)
   - 일관성 유지 (모든 스크린샷 동일 모드)

4. **민감 정보 제거**
   - 실제 아기 이름 → "Baby" 또는 "Emma" 등 예시 이름
   - 실제 날짜 → 최근 날짜로 통일
   - 개인 메모 → 일반적인 내용

5. **로딩 상태 피하기**
   - 로딩 인디케이터가 없는 상태
   - 데이터가 완전히 로드된 상태
   - 에러 메시지 없음

---

**작성자**: Claude (Sprint 3 Day 4)
**마지막 업데이트**: 2026-01-28

**다음 단계**: 데모 데이터 준비 및 스크린샷 촬영 시작
