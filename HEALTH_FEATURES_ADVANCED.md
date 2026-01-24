# 🏥 Advanced Health Features Implementation Guide

## ✅ Completed Core Features

### 1. Baby Profile Model Enhancement
**File**: `lib/data/models/baby_model.dart`

Added fields:
```dart
- double? weightKg  // Weight for dosage calculation
- String? weightUnit  // 'kg' or 'lb'
- int get ageInMonths  // Helper for age-based logic
- int get ageInDays  // Helper for precise age calculation
```

### 2. Medication Calculator Utility
**File**: `lib/core/utils/medication_calculator.dart`

**Features**:
- AAP-based dosage calculation for Acetaminophen and Ibuprofen
- Weight-based automatic dosing (mg and ml)
- Age-appropriate restrictions (e.g., no Ibuprofen under 6 months)
- Maximum daily limits
- Safety warnings and frequency guidelines

**Usage**:
```dart
final dosage = MedicationCalculator.calculateAcetaminophen(babyWeightKg);
// Returns: minDose, maxDose, warnings, frequency, etc.
```

### 3. Fever Guidelines System
**File**: `lib/core/utils/medication_calculator.dart`

**Features**:
- Age-stratified fever assessment (0-3mo, 3-6mo, 6mo+)
- Emergency detection for infants < 3 months with fever ≥ 38°C
- Severity levels: normal, warning, moderate, high, emergency
- Actionable advice and tips

**Usage**:
```dart
final advice = FeverGuidelines.getAdvice(tempCelsius, ageInMonths);
if (advice.needsUrgentCare) {
  // Show emergency dialog
}
```

---

## 🚀 Implementation Roadmap

### Phase 1: Temperature Recording Enhancement

**Add to `log_health_screen.dart` - Temperature Tab**:

1. **Fetch Baby Profile** on screen load
2. **Auto-calculate age** from birthdate
3. **Show real-time fever advice** as user types temperature
4. **Emergency popup** for infants < 3mo with temp ≥ 38°C

```dart
// After temperature input
if (_temperature != null && _babyProfile != null) {
  final advice = FeverGuidelines.getAdvice(
    _temperature!,
    _babyProfile!.ageInMonths
  );

  if (advice.needsUrgentCare) {
    _showEmergencyDialog(context, advice);
  }

  // Show advice card below temperature input
  _buildFeverAdviceCard(advice);
}
```

### Phase 2: Medication Recording Enhancement

**Add to `log_health_screen.dart` - Medication Tab**:

1. **Fetch Baby Profile** and weight
2. **Show Dosage Calculator** when medication selected
3. **Display recommended dose range** based on weight
4. **Show safety warnings** and frequency guidelines
5. **Add disclaimer** about consulting healthcare provider

```dart
// When medication type selected
if (_medicationType == 'fever_reducer' && _babyProfile?.weightKg != null) {
  DosageRecommendation? dosage;

  if (_selectedMedication == 'Acetaminophen (Tylenol)') {
    dosage = MedicationCalculator.calculateAcetaminophen(
      _babyProfile!.weightKg!
    );
  } else if (_selectedMedication == 'Ibuprofen (Advil)') {
    dosage = MedicationCalculator.calculateIbuprofen(
      _babyProfile!.weightKg!,
      _babyProfile!.ageInMonths
    );
  }

  if (dosage != null) {
    _buildDosageCalculatorCard(dosage);
  }
}
```

### Phase 3: Cross-Dosing Timer Widget

**Create**: `lib/presentation/widgets/medication_timer_widget.dart`

Display on home screen showing:
- Last Tylenol dose time + countdown to next dose
- Last Advil dose time + countdown to next dose
- Visual indicators (green = safe to give, red = wait)

```dart
StreamBuilder<List<ActivityModel>>(
  stream: getMedicationHistory(),
  builder: (context, snapshot) {
    final lastTylenol = getLastDose('Acetaminophen');
    final lastAdvil = getLastDose('Ibuprofen');

    return MedicationTimerCard(
      medications: [
        MedicationTimer(
          name: 'Tylenol',
          lastDoseTime: lastTylenol?.timestamp,
          intervalHours: 4,
        ),
        MedicationTimer(
          name: 'Advil',
          lastDoseTime: lastAdvil?.timestamp,
          intervalHours: 6,
        ),
      ],
    );
  },
)
```

### Phase 4: Doctor's Report View

**Create**: `lib/presentation/screens/health/health_report_screen.dart`

Features:
- **Time range selector**: Last 24h / 48h / 72h
- **Combo chart**: Temperature line + medication markers
- **Export as PDF** option for doctor visits
- **Summary statistics**: max/min/avg temp, medication count

```dart
class HealthReportScreen extends StatelessWidget {
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Health Report for Doctor'),
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: _exportToPdf,
          ),
          IconButton(
            icon: Icon(Icons.share),
            onPressed: _shareReport,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTimeRangeSelector(),
          _buildComboChart(), // Temp line + med markers
          _buildSummaryStats(),
          _buildMedicationLog(),
        ],
      ),
    );
  }
}
```

### Phase 5: Internationalization

**Add to `app_localizations.dart`**:

```dart
// English
'health_fever_warning_infant': 'URGENT: Infants under 3 months with fever need immediate medical attention',
'health_dosage_disclaimer': 'This is a guideline only. Always consult your pediatrician or pharmacist.',
'health_dosage_recommended': 'Recommended dosage',
'health_dosage_based_on_weight': 'Based on baby\'s weight: {weight} kg',
'health_next_dose_available': 'Next dose available at',
'health_wait_hours': 'Wait {hours} hours between doses',
'health_emergency_call_doctor': 'Call your pediatrician NOW',

// Korean
'health_fever_warning_infant': '긴급: 생후 3개월 미만 영아의 발열은 즉시 의사 상담이 필요합니다',
'health_dosage_disclaimer': '이것은 가이드일 뿐입니다. 반드시 소아과 의사나 약사와 상의하세요.',
'health_dosage_recommended': '권장 복용량',
'health_dosage_based_on_weight': '아기 체중 기준: {weight} kg',
'health_next_dose_available': '다음 복용 가능 시간',
'health_wait_hours': '복용 간격 {hours}시간 필요',
'health_emergency_call_doctor': '지금 바로 소아과에 연락하세요',
```

---

## 🎨 UI/UX Mockups

### Emergency Fever Dialog (< 3 months, ≥ 38°C)

```
┌─────────────────────────────────────────┐
│  🚨  URGENT MEDICAL ATTENTION NEEDED    │
├─────────────────────────────────────────┤
│                                          │
│  Your baby is under 3 months old with   │
│  a fever of 38.5°C (101.3°F).           │
│                                          │
│  ⚠️  This requires IMMEDIATE evaluation │
│      by a pediatrician.                 │
│                                          │
│  Actions to take NOW:                   │
│  • Call your pediatrician immediately   │
│  • Go to ER if unable to reach doctor   │
│  • Do NOT give medication without       │
│    doctor's approval                    │
│                                          │
│  [ Call Pediatrician ]  [ Go to ER ]    │
└─────────────────────────────────────────┘
```

### Dosage Calculator Card

```
┌─────────────────────────────────────────┐
│  💊 Dosage Calculator                   │
├─────────────────────────────────────────┤
│  Medication: Acetaminophen (Tylenol)    │
│  Baby's Weight: 7.5 kg (16.5 lbs)       │
│                                          │
│  Recommended Dosage:                    │
│  📏 75 - 112.5 mg                       │
│  🥄 2.3 - 3.5 ml                        │
│                                          │
│  Frequency: Every 4-6 hours             │
│  Max Daily: 562.5 mg (5 doses)          │
│                                          │
│  ⚠️ Safety Warnings:                    │
│  • Wait at least 4 hours between doses  │
│  • Do not exceed 5 doses in 24 hours    │
│  • Contact doctor if fever lasts >3 days│
│                                          │
│  ℹ️ This is a guideline only. Always    │
│     consult your pediatrician.          │
└─────────────────────────────────────────┘
```

### Medication Timer Widget (Home Screen)

```
┌─────────────────────────────────────────┐
│  ⏱️  Medication Tracker                 │
├─────────────────────────────────────────┤
│  Tylenol (Acetaminophen)                │
│  Last: 2:30 PM                          │
│  Next: 6:30 PM  ⏰ in 1h 23m           │
│  Status: 🟢 OK to give in 1 hour        │
├─────────────────────────────────────────┤
│  Advil (Ibuprofen)                      │
│  Last: 12:00 PM                         │
│  Next: 6:00 PM  ⏰ in 53 min           │
│  Status: 🟡 Almost ready                │
└─────────────────────────────────────────┘
```

### Doctor's Report Chart

```
Temperature & Medication Log (Last 48 Hours)

Temp
(°C)
40  ┤
39  ┤         ⚫─────⚫
38  ┤    ⚫───┘      └─────⚫    💊Tylenol
37  ┤───┘                  └───⚫
36  └────────────────────────────────> Time
     12/20 12/21   12/22
     6PM   6AM 6PM 6AM 6PM

Medications Given:
💊 12/20 8:00 PM - Tylenol 100mg
💊 12/21 2:00 AM - Advil 75mg
💊 12/21 8:00 AM - Tylenol 100mg
💊 12/21 6:00 PM - Tylenol 100mg

Summary:
• Max Temp: 39.2°C (102.6°F)
• Avg Temp: 38.1°C (100.6°F)
• Medications: 4 doses
• Duration: 48 hours
```

---

## 📋 Implementation Checklist

### Must-Have Features
- [x] Baby weight field in profile
- [x] Age calculation helpers
- [x] Medication dosage calculator
- [x] Fever guidelines system
- [ ] Emergency fever dialog (< 3mo)
- [ ] Dosage calculator UI in medication tab
- [ ] Fever advice card in temperature tab
- [ ] Medication timer widget on home
- [ ] Doctor's report screen
- [ ] I18n for all health strings

### Nice-to-Have Features
- [ ] Push notifications for next dose reminders
- [ ] PDF export for doctor's report
- [ ] Temperature trend prediction
- [ ] Medication interaction warnings
- [ ] Voice input for temperature
- [ ] Photo attachment for rash/symptoms

---

## 🔧 Technical Notes

### State Management
Use Provider/Riverpod to share baby profile across screens:
```dart
final babyProfileProvider = StreamProvider<BabyModel?>((ref) {
  return FirebaseFirestore.instance
    .collection('users/demo-user/babies')
    .doc('baby-id')
    .snapshots()
    .map((doc) => BabyModel.fromJson(doc.data()!));
});
```

### Real-time Timer Updates
```dart
Timer.periodic(Duration(minutes: 1), (timer) {
  setState(() {
    // Update medication timer countdown
  });
});
```

### Chart Library
Use `fl_chart` for combo chart:
```dart
LineChart(
  LineChartData(
    lineBarsData: [temperatureLine],
    extraLinesData: ExtraLinesData(
      verticalLines: medicationMarkers,
    ),
  ),
)
```

---

## 🚀 Deployment Considerations

1. **Legal Disclaimer**: Add prominent disclaimer that app is for tracking only, not medical advice
2. **Data Privacy**: Ensure HIPAA/GDPR compliance for health data
3. **Testing**: Thoroughly test dosage calculations with pharmacist review
4. **Localization**: Test all text with native speakers
5. **Accessibility**: Add screen reader support for vision-impaired users

---

## 📚 References

- American Academy of Pediatrics (AAP) Fever Guidelines
- Medication dosing based on pediatric formulary
- UI/UX inspired by leading baby tracking apps (Huckleberry, Baby Tracker)

---

**Status**: Core utilities implemented ✅
**Next Step**: Integrate into UI screens
**Priority**: Emergency fever detection (< 3mo) - HIGHEST
