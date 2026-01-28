# Lulu - Build & Release Checklist

**날짜**: 2026-01-28
**버전**: 1.0.0+1
**Sprint**: Sprint 3 Day 4

---

## 📋 빌드 전 체크리스트

### ✅ 버전 확인
- [x] pubspec.yaml version: `1.0.0+1`
- [ ] iOS Info.plist: `$(FLUTTER_BUILD_NAME)` / `$(FLUTTER_BUILD_NUMBER)`
- [ ] Android build.gradle: `versionName`, `versionCode`

### ✅ 앱 식별자 (Bundle ID / Application ID)

#### 현재 설정
- **iOS Bundle ID**: `com.example.lulu` ⚠️ **변경 필요**
- **Android Application ID**: 미확인 ⚠️

#### 권장 설정
```
iOS: com.lulubabyapp.lulu
Android: com.lulubabyapp.lulu
```

#### 변경 방법

**iOS (Xcode)**:
1. Xcode 열기: `open ios/Runner.xcworkspace`
2. Runner 프로젝트 선택 → General 탭
3. Bundle Identifier: `com.lulubabyapp.lulu`로 변경
4. Team 선택 (개인 또는 조직 Apple Developer 계정)

**Android (build.gradle)**:
```gradle
// android/app/build.gradle
defaultConfig {
    applicationId "com.lulubabyapp.lulu"
    minSdkVersion 21
    targetSdkVersion 34
    versionCode flutterVersionCode.toInteger()
    versionName flutterVersionName
}
```

---

## 🍎 iOS 빌드 가이드

### 1️⃣ 사전 준비 (필수)

#### Apple Developer Program
- [ ] Apple Developer 계정 가입 ($99/year)
- [ ] App Store Connect 접근 확인

#### Xcode 설정
- [ ] Xcode 최신 버전 설치 (15.0+)
- [ ] Command Line Tools 설치
  ```bash
  xcode-select --install
  ```

#### Certificates & Profiles
- [ ] Development Certificate 생성
- [ ] Distribution Certificate 생성
- [ ] App ID 등록 (`com.lulubabyapp.lulu`)
- [ ] Provisioning Profile 생성
  - Development
  - Distribution (App Store)

### 2️⃣ 프로젝트 설정

#### Bundle ID 변경
```bash
# Xcode에서 수동 변경
open ios/Runner.xcworkspace
# 또는 project.pbxproj 직접 수정 (권장하지 않음)
```

#### Capabilities 확인
- [ ] App Groups (위젯용)
- [ ] Push Notifications (알림용)
- [ ] Background Modes (백그라운드 실행)

#### Info.plist 확인
```xml
<key>CFBundleDisplayName</key>
<string>Lulu</string>
<key>CFBundleVersion</key>
<string>$(FLUTTER_BUILD_NUMBER)</string>
<key>CFBundleShortVersionString</key>
<string>$(FLUTTER_BUILD_NAME)</string>
```

### 3️⃣ App Icons 설정

#### 요구사항
- **1024x1024 PNG** (투명도 없음)
- App Store용 아이콘

#### 추가 방법
```bash
# Assets.xcassets에 추가
ios/Runner/Assets.xcassets/AppIcon.appiconset/
```

#### 자동 생성 (선택)
```bash
flutter pub run flutter_launcher_icons:main
```

**flutter_launcher_icons 설정** (pubspec.yaml):
```yaml
flutter_icons:
  android: true
  ios: true
  image_path: "assets/icon/app_icon.png"
```

### 4️⃣ 빌드 & Archive

#### Clean Build
```bash
cd ios
rm -rf Pods Podfile.lock
pod install --repo-update
cd ..
flutter clean
flutter pub get
```

#### Release Build
```bash
# iOS 시뮬레이터 테스트
flutter run --release

# iOS 기기 빌드
flutter build ios --release

# Xcode Archive (App Store 업로드용)
open ios/Runner.xcworkspace
# Xcode → Product → Archive
```

### 5️⃣ App Store Connect 업로드

#### Xcode Organizer
1. Xcode → Window → Organizer
2. Archives 탭에서 최신 빌드 선택
3. **Distribute App** 클릭
4. **App Store Connect** 선택
5. **Upload** 선택
6. 자동 서명 사용 또는 수동 선택
7. Upload 완료 대기 (5-10분)

#### App Store Connect 확인
1. https://appstoreconnect.apple.com 접속
2. My Apps → Lulu 선택
3. TestFlight 탭 → 빌드 확인 (최대 30분 소요)

### 6️⃣ TestFlight 내부 테스트

#### 내부 테스터 추가
```
App Store Connect → TestFlight → Internal Testing
→ Add Internal Testers (최대 100명)
```

#### 테스트 정보
- **What to Test**: "First release. Please test all features."
- **Email Notification**: ON

#### 테스터 초대
- 이메일로 TestFlight 초대 발송
- TestFlight 앱에서 설치
- 피드백 수집

---

## 🤖 Android 빌드 가이드

### 1️⃣ 사전 준비 (필수)

#### Google Play Console
- [ ] Google Play Console 계정 가입 ($25 one-time)
- [ ] 앱 등록 완료

#### Signing Key 생성
```bash
# keystore 생성 (최초 1회만)
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload

# 비밀번호 설정 및 정보 입력
# 조직 이름: Lulu Baby App
# 도시: Seoul
# 국가: KR
```

#### key.properties 파일 생성
```bash
# android/key.properties
storePassword=<keystore password>
keyPassword=<key password>
keyAlias=upload
storeFile=<keystore 파일 경로>
```

**예시**:
```properties
storePassword=myStrongPassword123
keyPassword=myStrongPassword123
keyAlias=upload
storeFile=/Users/yourname/upload-keystore.jks
```

### 2️⃣ build.gradle 설정

#### android/app/build.gradle
```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    compileSdkVersion 34

    defaultConfig {
        applicationId "com.lulubabyapp.lulu"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
    }

    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
        }
    }
}
```

### 3️⃣ App Icons 설정

#### 요구사항
- **512x512 PNG** (투명도 가능)
- Adaptive Icons (Android 8.0+)

#### 위치
```
android/app/src/main/res/
  mipmap-hdpi/ic_launcher.png (72x72)
  mipmap-mdpi/ic_launcher.png (48x48)
  mipmap-xhdpi/ic_launcher.png (96x96)
  mipmap-xxhdpi/ic_launcher.png (144x144)
  mipmap-xxxhdpi/ic_launcher.png (192x192)
```

### 4️⃣ 빌드 & 테스트

#### Clean Build
```bash
flutter clean
flutter pub get
```

#### Release Build (AAB - Android App Bundle)
```bash
flutter build appbundle --release

# 빌드 결과
# build/app/outputs/bundle/release/app-release.aab
```

#### Release Build (APK - 테스트용)
```bash
flutter build apk --release

# 빌드 결과
# build/app/outputs/flutter-apk/app-release.apk
```

#### 로컬 테스트
```bash
# APK 설치
flutter install --release
```

### 5️⃣ Play Console 업로드

#### Internal Testing Track
1. https://play.google.com/console 접속
2. 앱 선택 → Release → Testing → Internal testing
3. **Create new release** 클릭
4. AAB 파일 업로드 (`app-release.aab`)
5. Release notes 작성:
   ```
   Initial release (1.0.0)

   Features:
   - Sweet Spot sleep predictions
   - Activity tracking
   - Sleep analysis
   - Growth charts
   - Data export
   ```
6. **Save** → **Review release** → **Start rollout**

#### 테스터 추가
```
Testing → Internal testing → Testers
→ Create email list → Add testers
```

#### 테스트 링크 공유
- 내부 테스터에게 링크 전송
- Google Play에서 앱 설치
- 피드백 수집

---

## 📸 스크린샷 가이드

### iOS 요구사항

#### 6.5" Display (필수)
- **해상도**: 1284 x 2778 pixels
- **기기**: iPhone 13 Pro Max, 14 Plus, 15 Plus
- **개수**: 최소 1개, 최대 10개

#### 5.5" Display (선택)
- **해상도**: 1242 x 2208 pixels
- **기기**: iPhone 8 Plus
- **개수**: 최소 1개, 최대 10개

#### iPad Pro 12.9" (선택)
- **해상도**: 2048 x 2732 pixels

### Android 요구사항

#### Phone Screenshots
- **최소 해상도**: 1080 x 1920 pixels
- **개수**: 최소 2개, 최대 8개
- **형식**: PNG or JPEG

#### Tablet Screenshots (선택)
- **7-inch**: 1200 x 1920 pixels
- **10-inch**: 1800 x 2560 pixels

### 핵심 스크린샷 리스트

#### 1. Home Screen (Sweet Spot Prediction)
- **내용**: Sweet Spot 카드 + 타이머
- **강조**: AI 예측 시간 표시
- **텍스트 오버레이**: "Know exactly when your baby needs a nap"

#### 2. Activity Logging
- **내용**: 수면/수유/기저귀 로그 화면
- **강조**: 간편한 원 탭 기록
- **텍스트 오버레이**: "Track everything in one tap"

#### 3. Sleep Analysis (Heatmap)
- **내용**: 수면 히트맵
- **강조**: 시간대별 패턴 시각화
- **텍스트 오버레이**: "Discover your baby's sleep patterns"

#### 4. Growth Chart
- **내용**: WHO 성장 곡선
- **강조**: 아기 성장 추적
- **텍스트 오버레이**: "Track healthy growth with WHO standards"

#### 5. Settings / Privacy
- **내용**: 설정 화면 또는 데이터 내보내기
- **강조**: 프라이버시 우선, 데이터 소유권
- **텍스트 오버레이**: "Your data stays on your device"

### 스크린샷 촬영 방법

#### 시뮬레이터/에뮬레이터 사용
```bash
# iOS 시뮬레이터
open -a Simulator
# 기기 선택: iPhone 15 Plus (6.5")
flutter run --release

# 스크린샷: Cmd + S

# Android 에뮬레이터
flutter emulators --launch Pixel_7_API_34
flutter run --release

# 스크린샷: 에뮬레이터 오른쪽 패널 → Camera 아이콘
```

#### 실제 기기 사용
- 더 자연스러운 화면
- 실제 성능 반영
- QuickTime 화면 녹화 (iOS)

#### 디자인 툴 (선택)
- Figma / Sketch로 스크린샷 꾸미기
- 텍스트 오버레이 추가
- 디바이스 프레임 추가

---

## ⚠️ 주의사항

### iOS

#### 1. Provisioning Profile 만료
- **증상**: Archive 실패 또는 서명 오류
- **해결**: Xcode → Preferences → Accounts → Download Manual Profiles

#### 2. BitCode 에러
- **증상**: Archive 시 BitCode 관련 오류
- **해결**: Build Settings → Enable Bitcode → NO

#### 3. 위젯 타겟 서명
- **증상**: 위젯 확장이 서명되지 않음
- **해결**: 각 타겟마다 개별 서명 설정

### Android

#### 1. key.properties 누락
- **증상**: Signing config 없음 오류
- **해결**: android/key.properties 파일 생성

#### 2. MultiDex 오류
- **증상**: Method count 초과
- **해결**: android/app/build.gradle에 MultiDex 추가

#### 3. 권한 문제
- **증상**: 런타임 권한 거부
- **해결**: AndroidManifest.xml 권한 확인

---

## 🔒 보안 체크리스트

### 절대 Git에 커밋하지 말 것
- [ ] `ios/Runner.xcodeproj/project.pbxproj` (서명 정보 포함 시)
- [ ] `android/key.properties`
- [ ] `android/app/upload-keystore.jks`
- [ ] `.env` 파일 (API keys)

### .gitignore 확인
```gitignore
# iOS
ios/Runner.xcworkspace/xcuserdata/
ios/Pods/
*.mobileprovision
*.p12

# Android
android/key.properties
android/app/upload-keystore.jks
android/app/*.jks

# Environment
.env
.env.local
```

---

## 📋 최종 체크리스트

### Pre-Launch

#### Technical
- [ ] 모든 테스트 통과 (80%+ coverage)
- [ ] 크래시 없음
- [ ] 성능 프로파일링 완료
- [ ] 메모리 누수 확인

#### Legal & Compliance
- [ ] Privacy Policy 웹 배포
- [ ] Medical Disclaimer 확인
- [ ] COPPA/GDPR/CCPA 준수

#### Store Metadata
- [ ] App Name, Description, Keywords
- [ ] Screenshots (5개)
- [ ] App Icon (1024x1024)
- [ ] Privacy Policy URL

#### Build & Upload
- [ ] iOS Archive → App Store Connect
- [ ] Android AAB → Play Console
- [ ] TestFlight 내부 테스트
- [ ] Internal Testing Track

### Post-Upload

#### Monitoring
- [ ] TestFlight 피드백 확인
- [ ] Play Console 크래시 리포트 확인
- [ ] 사용자 리뷰 모니터링

#### Marketing
- [ ] 랜딩 페이지 라이브
- [ ] Support 이메일 준비
- [ ] SNS 계정 준비

---

## 🚀 출시 타임라인

### Week 1
- [ ] Bundle ID 변경
- [ ] Certificates & Profiles 생성
- [ ] Signing Key 생성
- [ ] Icons 준비

### Week 2
- [ ] iOS Archive → TestFlight
- [ ] Android AAB → Internal Testing
- [ ] 내부 테스트 진행
- [ ] 버그 수정

### Week 3
- [ ] 스크린샷 촬영
- [ ] 메타데이터 최종 검토
- [ ] Review 제출
- [ ] Monitoring 설정

### Week 4+
- [ ] Review 대기 (iOS: 1-3일, Android: 수시간-1일)
- [ ] 승인 후 출시!
- [ ] 마케팅 시작

---

**작성자**: Claude (Sprint 3 Day 4)
**마지막 업데이트**: 2026-01-28

**다음 단계**: Bundle ID 변경 및 최초 빌드 테스트
