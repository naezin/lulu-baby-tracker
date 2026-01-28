# Android Build & Release Guide

**날짜**: 2026-01-28
**버전**: 1.0.0+1
**Sprint**: Sprint 3 Day 4

---

## 📋 현재 상태 확인

### 프로젝트 구조
```
lulu/
├── android/
│   ├── app/
│   │   ├── src/
│   │   │   └── main/
│   │   │       ├── res/
│   │   │       │   ├── drawable/
│   │   │       │   ├── layout/
│   │   │       │   ├── values/
│   │   │       │   └── xml/
│   │   │       └── AndroidManifest.xml
│   │   └── build.gradle (생성 필요)
│   ├── local.properties
│   └── build.gradle (생성 필요)
```

⚠️ **주의**: Android 빌드 파일이 완전히 생성되지 않았습니다.

---

## 🔧 Android 프로젝트 초기화

### Step 1: Flutter 프로젝트 재생성

현재 Android 폴더가 불완전한 상태이므로 Flutter가 다시 생성하도록 합니다:

```bash
# 현재 디렉토리 확인
cd /Users/naezin/Desktop/클로드앱플젝/lulu

# Android 폴더 백업 (선택)
mv android android_backup

# Flutter가 Android 프로젝트를 다시 생성하도록
flutter create --platforms=android .

# 또는 수동으로 build.gradle 파일 생성 (아래 참조)
```

### Step 2: build.gradle 파일 생성

#### android/build.gradle
```gradle
buildscript {
    ext.kotlin_version = '1.9.10'
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath 'com.android.tools.build:gradle:8.1.0'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
        classpath 'com.google.gms:google-services:4.4.0'
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.buildDir = '../build'
subprojects {
    project.buildDir = "${rootProject.buildDir}/${project.name}"
}
subprojects {
    project.evaluationDependsOn(':app')
}

tasks.register("clean", Delete) {
    delete rootProject.buildDir
}
```

#### android/app/build.gradle
```gradle
plugins {
    id "com.android.application"
    id "kotlin-android"
    id "dev.flutter.flutter-gradle-plugin"
}

def localProperties = new Properties()
def localPropertiesFile = rootProject.file('local.properties')
if (localPropertiesFile.exists()) {
    localPropertiesFile.withReader('UTF-8') { reader ->
        localProperties.load(reader)
    }
}

def flutterVersionCode = localProperties.getProperty('flutter.versionCode')
if (flutterVersionCode == null) {
    flutterVersionCode = '1'
}

def flutterVersionName = localProperties.getProperty('flutter.versionName')
if (flutterVersionName == null) {
    flutterVersionName = '1.0'
}

// 🔒 Signing configuration
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    namespace "com.lulubabyapp.lulu"
    compileSdkVersion 34
    ndkVersion "25.1.8937393"

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = '1.8'
    }

    sourceSets {
        main.java.srcDirs += 'src/main/kotlin'
    }

    defaultConfig {
        applicationId "com.lulubabyapp.lulu"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
        multiDexEnabled true
    }

    signingConfigs {
        release {
            if (keystorePropertiesFile.exists()) {
                keyAlias keystoreProperties['keyAlias']
                keyPassword keystoreProperties['keyPassword']
                storeFile file(keystoreProperties['storeFile'])
                storePassword keystoreProperties['storePassword']
            }
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
        debug {
            signingConfig signingConfigs.debug
        }
    }
}

flutter {
    source '../..'
}

dependencies {
    implementation 'com.google.android.material:material:1.10.0'
    implementation 'androidx.multidex:multidex:2.0.1'
}
```

---

## 🔑 Signing Key 생성

### Step 1: Keystore 파일 생성

```bash
# 홈 디렉토리에 keystore 생성 (최초 1회만)
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias upload

# 프롬프트에 따라 정보 입력:
# - 비밀번호: 강력한 비밀번호 설정 (잊지 마세요!)
# - 이름: Lulu Baby App
# - 조직 단위: Development
# - 조직: Lulu
# - 도시: Seoul
# - 주/도: Seoul
# - 국가 코드: KR
```

**⚠️ 중요**:
- Keystore 파일과 비밀번호를 **절대 잃어버리지 마세요**
- 잃어버리면 앱 업데이트 불가능
- 안전한 곳에 백업 (1Password, Bitwarden 등)

### Step 2: key.properties 파일 생성

```bash
# android/key.properties 파일 생성
cat > android/key.properties << EOF
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=/Users/yourname/upload-keystore.jks
EOF
```

**예시**:
```properties
storePassword=MyStrongPassword123!
keyPassword=MyStrongPassword123!
keyAlias=upload
storeFile=/Users/naezin/upload-keystore.jks
```

### Step 3: .gitignore 확인

```bash
# .gitignore에 다음 항목이 있는지 확인
echo "android/key.properties" >> .gitignore
echo "**/*.jks" >> .gitignore
```

---

## 🎨 App Icons 설정

### 현재 상태
```
android/app/src/main/res/
├── drawable/         # 있음
├── layout/           # 있음
├── values/           # 있음
└── xml/              # 있음

⚠️ mipmap-* 폴더 없음 (App Icon용)
```

### App Icons 생성 방법

#### Option 1: flutter_launcher_icons (권장)

1. **pubspec.yaml에 추가** (이미 설치됨):
```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1

flutter_icons:
  android: true
  ios: true
  image_path: "assets/icon/app_icon.png"
  adaptive_icon_background: "#1A2332"  # Lulu 다크 배경
  adaptive_icon_foreground: "assets/icon/app_icon_foreground.png"
```

2. **아이콘 생성**:
```bash
# App icon 이미지 준비 (1024x1024 PNG)
# assets/icon/app_icon.png

# 아이콘 생성
flutter pub run flutter_launcher_icons:main
```

#### Option 2: 수동 생성

필요한 크기의 아이콘을 각 폴더에 배치:

```
android/app/src/main/res/
├── mipmap-hdpi/ic_launcher.png         (72x72)
├── mipmap-mdpi/ic_launcher.png         (48x48)
├── mipmap-xhdpi/ic_launcher.png        (96x96)
├── mipmap-xxhdpi/ic_launcher.png       (144x144)
└── mipmap-xxxhdpi/ic_launcher.png      (192x192)
```

**Adaptive Icons** (Android 8.0+):
```
android/app/src/main/res/
├── mipmap-hdpi/ic_launcher_foreground.png
├── mipmap-mdpi/ic_launcher_foreground.png
├── mipmap-xhdpi/ic_launcher_foreground.png
├── mipmap-xxhdpi/ic_launcher_foreground.png
└── mipmap-xxxhdpi/ic_launcher_foreground.png
```

---

## 🏗️ 빌드 프로세스

### Step 1: 빌드 전 체크리스트

- [ ] `pubspec.yaml` 버전 확인: `version: 1.0.0+1`
- [ ] `android/app/build.gradle` applicationId 확인: `com.lulubabyapp.lulu`
- [ ] `key.properties` 파일 존재 확인
- [ ] Keystore 파일 존재 확인
- [ ] App Icons 생성 완료

### Step 2: Clean Build

```bash
cd /Users/naezin/Desktop/클로드앱플젝/lulu

# Flutter clean
flutter clean
flutter pub get

# Gradle clean (선택)
cd android
./gradlew clean
cd ..
```

### Step 3: Release Build

#### AAB (Android App Bundle) - Play Store용

```bash
flutter build appbundle --release

# 빌드 결과:
# build/app/outputs/bundle/release/app-release.aab

# 파일 크기 확인
ls -lh build/app/outputs/bundle/release/app-release.aab
```

#### APK - 테스트/배포용

```bash
# Fat APK (모든 아키텍처)
flutter build apk --release

# 빌드 결과:
# build/app/outputs/flutter-apk/app-release.apk

# Split APKs (아키텍처별)
flutter build apk --release --split-per-abi

# 빌드 결과:
# build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk
# build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
# build/app/outputs/flutter-apk/app-x86_64-release.apk
```

### Step 4: 빌드 검증

```bash
# AAB 서명 확인
jarsigner -verify -verbose -certs build/app/outputs/bundle/release/app-release.aab

# APK 서명 확인
jarsigner -verify -verbose -certs build/app/outputs/flutter-apk/app-release.apk

# APK 정보 확인
aapt dump badging build/app/outputs/flutter-apk/app-release.apk | grep -E "package|versionCode|versionName"
```

---

## 📤 Play Console 업로드

### Step 1: Play Console 접속

1. https://play.google.com/console 접속
2. 앱 선택 (또는 새 앱 생성)

### Step 2: 앱 생성 (최초 1회)

```
Create app
→ App name: Lulu - Baby Sleep Tracker
→ Default language: English (United States) 또는 Korean
→ App or game: App
→ Free or paid: Free
→ 약관 동의
→ Create app
```

### Step 3: Internal Testing Track

```
Release → Testing → Internal testing
→ Create new release
→ Upload: app-release.aab
→ Release name: 1.0.0 (1)
→ Release notes:
```

**Release Notes (영문)**:
```
Initial release (1.0.0)

✨ Features:
• Sweet Spot sleep predictions using wake windows
• Activity tracking (sleep, feeding, diaper, play, health)
• Sleep pattern analysis with heatmap
• WHO-standard growth charts
• Premature baby support
• Data export (JSON & CSV)
• Privacy-first design

This is the first release for internal testing. Please test all features and report any issues.
```

**Release Notes (한국어)**:
```
초기 릴리스 (1.0.0)

✨ 기능:
• Wake Window 기반 Sweet Spot 수면 예측
• 활동 기록 (수면, 수유, 기저귀, 놀이, 건강)
• 히트맵을 사용한 수면 패턴 분석
• WHO 표준 성장 곡선
• 조산아 지원
• 데이터 내보내기 (JSON & CSV)
• 프라이버시 우선 설계

내부 테스트를 위한 첫 번째 릴리스입니다. 모든 기능을 테스트하고 문제를 보고해 주세요.
```

### Step 4: 테스터 추가

```
Testing → Internal testing → Testers
→ Create email list
→ List name: "Internal Testers"
→ Add email addresses:
  - your.email@example.com
  - tester1@example.com
  - tester2@example.com
→ Save
```

### Step 5: Review & Rollout

```
Review release
→ Start rollout to Internal testing
→ Confirm
```

---

## 🧪 내부 테스트

### 테스터 초대

1. Play Console에서 테스트 링크 복사
2. 테스터에게 이메일로 전송
3. 테스터가 링크 클릭 → Google Play에서 앱 다운로드

### 피드백 수집

**테스트 체크리스트**:
- [ ] 앱 설치 성공
- [ ] 첫 실행 (온보딩)
- [ ] 아기 프로필 생성
- [ ] Sweet Spot 예측 확인
- [ ] 활동 로그 (수면, 수유 등)
- [ ] 수면 히트맵 확인
- [ ] 성장 차트 확인
- [ ] 데이터 내보내기
- [ ] 설정 변경 (언어, 단위 등)
- [ ] 앱 삭제 및 재설치

### 크래시 모니터링

```
Play Console → Quality → Android vitals
→ Crashes & ANRs
```

---

## 🚀 Production Release (향후)

### Step 1: Internal Testing 완료

- [ ] 모든 테스터가 테스트 완료
- [ ] 크래시 0건
- [ ] 주요 버그 수정 완료

### Step 2: Closed Testing (선택)

```
Release → Testing → Closed testing
→ Create new track
→ Countries: 선택 (Korea, United States 등)
→ Testers: 최대 수천 명
```

### Step 3: Production Track

```
Release → Production
→ Create new release
→ Upload: app-release.aab
→ Release name: 1.0.0
→ Release notes (사용자용):
```

**Production Release Notes**:
```
Welcome to Lulu! 🌙

Lulu helps tired parents predict their baby's optimal sleep time using scientifically-backed wake window calculations.

Features:
• Sweet Spot Predictions - AI-powered sleep timing
• Activity Tracking - Sleep, feeding, diaper, play, health
• Sleep Analysis - Visual heatmaps and patterns
• Growth Charts - WHO-standard tracking
• Data Export - JSON and CSV backup
• Privacy-First - Your data stays on your device

We hope Lulu helps you and your baby get better rest!

Questions? support@lulubabyapp.com
```

### Step 4: Store Listing 완성

```
Store presence → Main store listing
→ App name: Lulu - Baby Sleep Tracker
→ Short description: (80자)
→ Full description: (4000자)
→ Screenshots: (5개)
→ Feature graphic: (1024x500)
→ Privacy Policy URL
→ Save
```

### Step 5: Content Rating

```
Policy → App content
→ Content ratings questionnaire
→ 카테고리: Parenting
→ 설문 작성 (폭력, 성적 콘텐츠 등)
→ Submit
```

### Step 6: Pricing & Distribution

```
Release → Production → Countries/regions
→ Add countries: 전체 또는 선택
→ Pricing: Free
→ Contains ads: No
→ Save
```

### Step 7: Review & Publish

```
Review release
→ Start rollout to Production
→ Confirm
```

**예상 리뷰 시간**: 수 시간 ~ 1일

---

## ⚠️ 트러블슈팅

### 빌드 오류

#### "Execution failed for task ':app:lintVitalRelease'"
```bash
# android/app/build.gradle에 추가
android {
    lintOptions {
        checkReleaseBuilds false
        abortOnError false
    }
}
```

#### "Could not find com.android.tools.build:gradle:X.X.X"
```bash
# Android Studio에서 Gradle Sync
# 또는
cd android
./gradlew --refresh-dependencies
```

#### "MultiDex error"
```bash
# android/app/build.gradle에 이미 추가됨
defaultConfig {
    multiDexEnabled true
}

dependencies {
    implementation 'androidx.multidex:multidex:2.0.1'
}
```

### Signing 오류

#### "Keystore file not found"
```bash
# key.properties에서 storeFile 경로 확인
# 절대 경로 사용 권장
storeFile=/Users/naezin/upload-keystore.jks
```

#### "Incorrect password"
```bash
# key.properties의 비밀번호 확인
# keyPassword와 storePassword가 다를 수 있음
```

### 업로드 오류

#### "This release is not compliant with Google Play policy"
- Privacy Policy URL 확인
- 대상 API 레벨 확인 (최소 API 33 이상)
- Content Rating 완료 확인

---

## 📊 빌드 크기 최적화

### 현재 예상 크기

- **AAB**: ~30-50 MB (압축 전)
- **APK (Fat)**: ~50-70 MB
- **APK (arm64-v8a)**: ~20-30 MB

### 최적화 기법

#### 1. ProGuard/R8 (이미 활성화됨)
```gradle
buildTypes {
    release {
        minifyEnabled true
        shrinkResources true
    }
}
```

#### 2. Split APKs
```bash
flutter build apk --release --split-per-abi
```

#### 3. 사용하지 않는 리소스 제거
```bash
# Unused resources 자동 제거 (shrinkResources: true)
# 수동 확인:
./gradlew :app:analyzeRelease
```

---

## 🔒 보안 체크리스트

### Git에 커밋하지 말 것

- [ ] `android/key.properties`
- [ ] `*.jks` 파일
- [ ] `.env` 파일
- [ ] `google-services.json` (Firebase 사용 시)

### 코드 난독화

- [ ] ProGuard/R8 활성화 (`minifyEnabled true`)
- [ ] 중요한 클래스 제외 규칙 (`proguard-rules.pro`)

---

## 📝 체크리스트

### 빌드 전
- [ ] Bundle ID/Application ID 확인: `com.lulubabyapp.lulu`
- [ ] 버전 확인: `1.0.0+1`
- [ ] Keystore 생성 및 백업
- [ ] key.properties 설정
- [ ] App Icons 생성
- [ ] build.gradle 파일 확인

### 빌드
- [ ] `flutter clean`
- [ ] `flutter pub get`
- [ ] `flutter build appbundle --release`
- [ ] AAB 서명 확인
- [ ] 빌드 크기 확인

### 업로드
- [ ] Play Console 계정 생성
- [ ] 앱 등록
- [ ] Internal Testing Track 생성
- [ ] AAB 업로드
- [ ] Release notes 작성
- [ ] 테스터 추가

### 테스트
- [ ] 내부 테스터 초대
- [ ] 크래시 없음 확인
- [ ] 주요 기능 테스트
- [ ] 피드백 수집

---

**작성자**: Claude (Sprint 3 Day 4)
**마지막 업데이트**: 2026-01-28

**다음 단계**: Android 프로젝트 재생성 및 빌드 테스트
