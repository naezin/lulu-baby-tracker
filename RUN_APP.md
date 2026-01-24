# 🚀 Lulu 앱 실행 가이드

## 빠른 실행 방법

### 방법 1: Chrome에서 실행 (가장 쉬움!)

```bash
cd /Users/naezin/Desktop/클로드앱플젝/lulu
flutter run -d chrome
```

그러면 자동으로 Chrome 브라우저가 열리며 앱이 실행됩니다!

### 방법 2: macOS 앱으로 실행

```bash
cd /Users/naezin/Desktop/클로드앱플젝/lulu
flutter run -d macos
```

### 방법 3: iOS 시뮬레이터 (iOS 개발 환경이 설정된 경우)

```bash
# 시뮬레이터 목록 보기
flutter emulators

# 시뮬레이터 실행
flutter emulators --launch apple_ios_simulator

# 앱 실행
flutter run
```

## 📱 현재 사용 가능한 디바이스

실행 전에 사용 가능한 디바이스를 확인하려면:

```bash
flutter devices
```

## 🎯 주요 기능 테스트

앱이 실행되면 다음 기능들을 테스트해볼 수 있습니다:

### 1. Sweet Spot 데모
1. 홈 화면에서 **"Try Sweet Spot Demo"** 버튼 클릭
2. 아기 나이 선택 (예: 6개월)
3. 마지막 기상 시간 선택 (예: 2시간 전)
4. **"Calculate Sweet Spot"** 클릭
5. 결과 확인!

### 2. AI 채팅 (Lulu)
1. 하단 네비게이션에서 **"Chat with Lulu"** 탭 클릭
2. 빠른 질문 선택 또는 직접 질문 입력
3. 예시: "My baby keeps waking at night"
4. Lulu의 따뜻한 답변 확인

**주의**: OpenAI API 키 없이는 실제 AI 응답을 받을 수 없습니다.
데모 모드에서는 에러가 표시되지만 UI는 정상적으로 작동합니다.

### 3. Sweet Spot 카드
- 홈 화면에 표시되는 Sweet Spot 카드
- 현재는 데모 버튼을 통해 데이터를 설정해야 표시됩니다

## 🔑 OpenAI API 키 사용 (선택사항)

실제 AI 채팅을 사용하려면 OpenAI API 키가 필요합니다:

```bash
# API 키와 함께 실행
flutter run -d chrome --dart-define=OPENAI_API_KEY=sk-your-api-key-here
```

API 키 발급: https://platform.openai.com/api-keys

## 🛠️ 문제 해결

### "No connected devices" 에러
```bash
# Chrome이 설치되어 있는지 확인
flutter devices

# Chrome이 없다면 macOS로 실행
flutter run -d macos
```

### 빌드 에러 발생 시
```bash
# 캐시 정리
flutter clean
flutter pub get

# 다시 실행
flutter run -d chrome
```

### "Gradle build failed" 또는 Android 관련 에러
- Android 관련 에러는 무시하고 웹이나 macOS로 실행하세요

## 📊 앱 구조

```
홈 화면
├── Sweet Spot 카드 (낮잠 예측)
├── Quick Actions (빠른 기록)
└── Try Sweet Spot Demo (데모 버튼)

채팅 화면
├── Lulu AI와 대화
├── 빠른 질문 선택
└── 채팅 히스토리

인사이트 (준비 중)
└── Coming Soon
```

## 🎨 UI 미리보기

### 홈 화면
- 환영 메시지 ("Good Morning!")
- Sweet Spot 카드 (예: "2:30 PM - 3:15 PM")
- Quick Actions (Sleep, Feeding, Diaper, Chat)

### 채팅 화면
- Lulu 프로필 (🌙 아이콘)
- 말풍선 채팅 UI
- 타이핑 인디케이터
- 빠른 질문 바

### Sweet Spot 데모 화면
- 아기 나이 선택 슬라이더
- 마지막 기상 시간 선택
- 계산 결과 다이얼로그

## 🚀 지금 바로 실행!

터미널을 열고 아래 명령어를 복사해서 붙여넣기만 하세요:

```bash
cd /Users/naezin/Desktop/클로드앱플젝/lulu && flutter run -d chrome
```

Chrome이 자동으로 열리고 앱이 실행됩니다!

빌드에 1-2분 정도 걸릴 수 있습니다. 기다리시면 됩니다 😊

## 💡 팁

- **Hot Reload**: 코드 수정 후 터미널에서 `r` 키를 누르면 즉시 반영됩니다
- **Hot Restart**: `R` (대문자) 키를 누르면 앱이 재시작됩니다
- **종료**: `q` 키를 누르면 앱이 종료됩니다
- **DevTools**: Chrome에서 F12를 누르면 개발자 도구를 볼 수 있습니다

## 📹 실행 후 확인 사항

1. ✅ 앱이 Chrome에 표시되는가?
2. ✅ "Lulu" 타이틀이 보이는가?
3. ✅ 하단에 3개의 네비게이션 버튼이 있는가?
4. ✅ "Try Sweet Spot Demo" 버튼을 클릭하면 동작하는가?
5. ✅ Chat 탭으로 이동하면 Lulu가 인사하는가?

모두 확인되면 성공입니다! 🎉
