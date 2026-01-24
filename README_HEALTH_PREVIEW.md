# 🏥 Advanced Health Features - Preview Guide

## ✨ What's New

고급 건강 기능이 UI에 완전히 통합되었습니다! 이제 미리보기하고 테스트할 수 있습니다.

### 주요 기능 (3가지)

1. **💊 자동 복용량 계산기** (Medication Tab)
   - 아기 몸무게 기반 자동 계산
   - Tylenol (Acetaminophen) 및 Advil (Ibuprofen) 지원
   - AAP 가이드라인 기반 권장 복용량 (mg, ml)
   - 안전 경고 및 최대 일일 복용량 표시

2. **🌡️ 발열 조언 카드** (Temperature Tab)
   - 실시간 AAP 가이드라인 기반 조언
   - 연령별 맞춤 권장사항 (0-3개월, 3-6개월, 6개월+)
   - 체온 심각도에 따른 색상 코딩
   - 수분 섭취, 옷차림 등 실용적인 팁 제공

3. **🚨 긴급 발열 다이얼로그** (3개월 미만 영아)
   - 생후 3개월 미만 + 38°C 이상 발열 시 자동 표시
   - 즉시 소아과 의사 상담 필요 경고
   - "소아과 전화하기", "응급실 가기" 버튼

---

## 🎬 미리보기 방법

### 1. 앱 실행 확인
```bash
# 터미널에서 확인 (이미 실행 중이어야 함)
ps aux | grep flutter | grep chrome

# Chrome에서 http://localhost:51172 열기
```

앱이 실행되고 있지 않으면:
```bash
cd lulu
flutter run -d chrome
```

---

### 2. 테스트 데이터 준비

**중요**: 복용량 계산기와 발열 조언을 테스트하려면 아기 프로필에 **몸무게**와 **생년월일** 데이터가 필요합니다.

#### 빠른 설정 (Firebase Console)
1. https://console.firebase.google.com 접속
2. 프로젝트 선택 → Firestore Database
3. `users` → `demo-user` → `babies` 컬렉션으로 이동
4. 기존 문서 편집 또는 새 문서 추가:

```javascript
{
  id: "baby-001",
  userId: "demo-user",
  name: "테스트 아기",
  birthDate: "2025-05-01T00:00:00.000Z",  // 생후 8개월
  weightKg: 8.2,  // 몸무게 8.2kg
  weightUnit: "kg",
  gender: "female",
  isPremature: false,
  createdAt: "2025-05-01T00:00:00.000Z",
  updatedAt: "2026-01-22T12:00:00.000Z"
}
```

**필수 필드**:
- `weightKg` (숫자): 복용량 계산에 사용
- `birthDate` (문자열, ISO 8601): 연령 계산에 사용

📝 **자세한 설정 가이드**: `SETUP_TEST_DATA.md` 참고

---

### 3. 기능별 테스트 가이드

#### ✅ 복용량 계산기 테스트
1. **홈 화면** → **Health** 버튼 클릭
2. **Medication** 탭 선택
3. **Medication Type**: "Fever Reducer" 선택
4. **Medication Name**: "Acetaminophen (Tylenol)" 선택
5. ✨ **파란색 복용량 계산기 카드** 표시됨!
   - 아기 몸무게: 8.2 kg
   - 권장 복용량: 82-123 mg (2.6-3.8 ml)
   - 복용 간격: 4-6시간마다
   - 최대 일일 복용량: 615 mg
   - ⚠️ 안전 경고 표시

**Ibuprofen 테스트** (6개월 미만 제한):
- 생후 4개월 아기로 테스트 (birthDate: "2025-09-01")
- "Ibuprofen (Advil)" 선택
- → **빨간색 경고 카드**: "6개월 미만 영아에게는 권장되지 않습니다"

---

#### ✅ 발열 조언 카드 테스트
1. **홈 화면** → **Health** 버튼 클릭
2. **Temperature** 탭 선택
3. 체온 입력:
   - **36.5°C** → 정상 범위 (파란색 카드)
   - **38.5°C** → 발열 (주황색/빨간색 카드)
   - **39.5°C** → 고열 (빨간색 카드)
4. ✨ **발열 조언 카드** 표시됨!
   - 연령별 맞춤 조언
   - 실행 가능한 액션 ("약물 고려", "주의 깊게 모니터링")
   - 실용적인 팁 (수분 섭취, 옷차림, 측정 빈도)

**단위 전환 테스트**:
- 화씨(℉) ↔ 섭씨(℃) 전환
- 38.0°C = 100.4°F (발열 기준)

---

#### ✅ 긴급 발열 다이얼로그 테스트
**⚠️ 중요**: 이 기능은 생후 3개월 미만 영아의 안전을 위한 최우선 기능입니다.

1. **아기 프로필 변경**:
   ```javascript
   birthDate: "2025-11-01T00:00:00.000Z"  // 생후 2.7개월
   ```
2. **Temperature** 탭에서 **38.5°C** 입력
3. ✨ **긴급 다이얼로그 자동 표시!**
   - 🚨 "URGENT MEDICAL ATTENTION NEEDED"
   - 즉시 취해야 할 조치 안내
   - "Call Pediatrician" (소아과 전화)
   - "Go to ER" (응급실 가기)
4. 다이얼로그 외부 클릭으로 닫히지 않음 (안전 기능)

---

## 📱 UI 미리보기

### 복용량 계산기 화면
```
┌────────────────────────────────────┐
│  💊 Dosage Calculator              │
├────────────────────────────────────┤
│  Medication: Acetaminophen         │
│  Baby's Weight: 8.2 kg             │
│                                     │
│  Recommended Dosage:                │
│  📏 82 - 123 mg                    │
│  💧 2.6 - 3.8 ml                   │
│                                     │
│  Frequency: Every 4-6 hours        │
│  Max Daily: 615 mg                 │
│                                     │
│  ⚠️ Safety Warnings:               │
│  • Wait at least 4 hours           │
│  • Do not exceed 5 doses/day       │
│  • Contact doctor if fever >3 days │
│                                     │
│  ℹ️ Guideline only. Consult doctor │
└────────────────────────────────────┘
```

### 발열 조언 카드
```
┌────────────────────────────────────┐
│  ⚠️ Fever Advice (8 months old)    │
├────────────────────────────────────┤
│  • Consider fever reducer          │
│  • Monitor closely                 │
│                                     │
│  Tips:                             │
│  💧 Keep baby well-hydrated        │
│  👶 Dress in light clothing        │
│  🌡️ Measure temp every 2-4 hours  │
│  💊 Can use Tylenol or Advil       │
└────────────────────────────────────┘
```

### 긴급 다이얼로그
```
┌────────────────────────────────────┐
│  🚨 긴급 의료 조치 필요             │
├────────────────────────────────────┤
│  생후 3개월 미만 아기의 체온이     │
│  38.5°C (101.3°F)입니다.           │
│                                     │
│  ⚠️ 즉시 소아과 의사 상담 필요     │
│                                     │
│  지금 바로:                        │
│  • 소아과에 전화하세요              │
│  • 연락 안되면 응급실 방문         │
│                                     │
│  [ 소아과 전화 ]  [ 응급실 가기 ]   │
└────────────────────────────────────┘
```

---

## 🔧 문제 해결

### Q: 복용량 계산기가 안 보여요
**A**:
1. Firebase에서 아기 프로필에 `weightKg` 필드가 있는지 확인
2. Fever Reducer 타입 선택 후 Tylenol 또는 Advil 선택
3. 터미널에서 'r' 입력 (Hot Reload)

### Q: 발열 조언 카드가 안 보여요
**A**:
1. 아기 프로필에 `birthDate` 필드 확인 (ISO 8601 형식)
2. 체온을 정확히 입력했는지 확인
3. 브라우저 콘솔에서 에러 확인 (F12)

### Q: 긴급 다이얼로그가 안 떠요
**A**:
1. 아기 나이가 정말 3개월 미만인지 확인
   - birthDate 계산: 오늘 날짜 - 90일 = 약 3개월 전
2. 체온이 38.0°C (100.4°F) 이상인지 확인
3. Temperature 탭에서 입력했는지 확인 (Medication 탭 X)

### Q: Hot Reload가 안 돼요
**A**:
```bash
# 터미널에서 강제 Hot Restart
cd lulu
# 실행 중인 터미널에서 'R' 입력 (대문자)

# 또는 앱 재시작
flutter run -d chrome
```

---

## 📊 테스트 체크리스트

### 데이터 준비
- [ ] 아기 프로필에 `weightKg` 필드 추가됨
- [ ] 아기 프로필에 `birthDate` 필드 추가됨
- [ ] Firebase 규칙에서 읽기 권한 허용됨

### 복용량 계산기
- [ ] Tylenol 선택 시 계산기 표시됨
- [ ] Advil 선택 시 계산기 표시됨
- [ ] 6개월 미만 아기 + Advil → 경고 표시됨
- [ ] 몸무게 기반 복용량이 정확함
- [ ] 안전 경고가 명확하게 표시됨

### 발열 조언
- [ ] 정상 체온 → 파란색 카드
- [ ] 발열 → 주황색/빨간색 카드
- [ ] 연령별 맞춤 조언 표시됨
- [ ] 단위 전환 (℃↔℉) 정상 작동

### 긴급 다이얼로그
- [ ] 3개월 미만 + 38°C 이상 → 다이얼로그 표시
- [ ] "Call Pediatrician" 버튼 작동
- [ ] "Go to ER" 버튼 작동
- [ ] 외부 클릭으로 닫히지 않음

---

## 📚 추가 문서

- **`HEALTH_FEATURES_ADVANCED.md`**: 전체 구현 가이드
- **`ADVANCED_HEALTH_UI_COMPLETE.md`**: UI 통합 완료 상세 문서
- **`SETUP_TEST_DATA.md`**: 테스트 데이터 설정 가이드
- **`medication_calculator.dart`**: 복용량 계산 로직 (lib/core/utils/)

---

## 🚀 다음 단계

현재 완료된 기능:
- ✅ 복용량 계산기 UI
- ✅ 발열 조언 카드
- ✅ 긴급 발열 다이얼로그

향후 구현 예정:
- 🔲 홈 화면 약물 타이머 위젯 (교차 복용 추적)
- 🔲 24-48시간 의료 리포트 차트
- 🔲 다국어 지원 (한국어)
- 🔲 PDF 내보내기
- 🔲 알림 기능

---

## 💡 핵심 요약

**지금 바로 테스트 가능**:
1. Chrome에서 앱 실행 중
2. Firebase에 아기 프로필 데이터 추가
3. Home → Health → Temperature/Medication 탭 테스트
4. 다양한 체온과 약물로 기능 확인

**모든 계산은 AAP (미국 소아과 학회) 가이드라인 기반**으로 안전하고 정확합니다! 🏥✨

---

**마지막 업데이트**: 2026-01-22
**상태**: UI 통합 완료, 미리보기 준비 완료 🎉
**문의**: 문제 발생 시 에러 메시지와 함께 질문해주세요!
