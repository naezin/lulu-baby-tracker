# Lulu Scripts

이 디렉토리에는 Lulu 앱 개발을 위한 유틸리티 스크립트가 포함되어 있습니다.

## i18n 컴플라이언스 체커

### 설명

`check_i18n.dart` 스크립트는 코드베이스에서 하드코딩된 영문 문자열을 자동으로 감지합니다. 모든 사용자 대면 텍스트가 제대로 국제화되었는지 확인하는 데 도움이 됩니다.

### 사용법

#### 로컬에서 실행:

```bash
# Dart로 직접 실행
dart scripts/check_i18n.dart

# 또는 Shell 스크립트 사용
./scripts/check_i18n.sh
```

#### CI/CD 통합:

이 스크립트는 GitHub Actions 워크플로우에 자동으로 통합되어 있습니다 (`.github/workflows/i18n-check.yml`). 모든 푸시 및 풀 리퀘스트에서 자동으로 실행됩니다.

### 작동 방식

스크립트는 다음을 확인합니다:

1. **Text() 위젯의 하드코딩된 문자열**
   ```dart
   // ❌ 나쁜 예
   Text('Hello World')

   // ✅ 좋은 예
   Text(l10n.translate('greeting_hello_world'))
   ```

2. **위젯 속성의 하드코딩된 문자열**
   ```dart
   // ❌ 나쁜 예
   TextField(hintText: 'Enter your name')

   // ✅ 좋은 예
   TextField(hintText: l10n.translate('hint_enter_name'))
   ```

3. **SnackBar, AlertDialog 등의 메시지**
   ```dart
   // ❌ 나쁜 예
   SnackBar(content: Text('Success!'))

   // ✅ 좋은 예
   SnackBar(content: Text(l10n.translate('message_success')))
   ```

### 제외 사항

다음은 체크에서 제외됩니다:

- 생성된 파일 (`*.g.dart`)
- 테스트 파일 (`*_test.dart`)
- 번역 파일 자체 (`app_localizations.dart`)
- URL, 경로, 기술적 식별자
- 버전 번호, 단일 문자
- 이모지만 포함된 문자열

### 출력 예시

```
🔍 Starting i18n compliance check...

❌ Found 3 potential i18n issue(s):

📄 lib/presentation/screens/example_screen.dart:
   Line 42: Hardcoded string in Text() widget
   Found: "Welcome Back"
   Suggested key: welcome_back

   Line 55: Hardcoded string in widget property
   Found: "Please enter your email"
   Suggested key: please_enter_your_email

💡 To fix these issues:
   1. Add translation keys to lib/core/localization/app_localizations.dart
   2. Replace hardcoded strings with l10n.translate('key_name')
   3. Add AppLocalizations import if missing
```

### i18n 이슈 수정 방법

1. **번역 키 추가** (`lib/core/localization/app_localizations.dart`):
   ```dart
   'en': {
     'welcome_back': 'Welcome Back',
     'please_enter_your_email': 'Please enter your email',
   },
   'ko': {
     'welcome_back': '다시 오신 것을 환영합니다',
     'please_enter_your_email': '이메일을 입력해주세요',
   },
   ```

2. **AppLocalizations import 추가**:
   ```dart
   import '../../core/localization/app_localizations.dart';
   ```

3. **하드코딩된 문자열 교체**:
   ```dart
   // build 메소드에서
   final l10n = AppLocalizations.of(context)!;

   // 사용
   Text(l10n.translate('welcome_back'))
   ```

### 종료 코드

- `0`: 모든 문자열이 올바르게 국제화됨
- `1`: 하드코딩된 문자열 발견

CI/CD 파이프라인에서 사용하기에 적합합니다.

---

## 추가 스크립트

이 디렉토리에 프로젝트의 다른 유틸리티 스크립트를 추가할 수 있습니다:

- 코드 생성 스크립트
- 배포 스크립트
- 데이터베이스 마이그레이션 스크립트
- 테스트 유틸리티

---

## 기여

새로운 스크립트를 추가할 때는 다음을 포함하세요:

1. 스크립트 상단에 명확한 주석
2. 사용 예시
3. 이 README 업데이트
4. 필요시 CI/CD 통합
