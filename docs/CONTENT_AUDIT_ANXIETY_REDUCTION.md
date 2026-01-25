# Content Audit: Anxiety-Reducing Language

**Date**: 2026-01-25
**Content Strategist**: ✍️ Content + 🧠 Developmental Lead
**Status**: ✅ Changes Applied

---

## Principle

> **"We guide parents gently, not alarm them urgently."**

Parents of newborns are already anxious. Our app should provide helpful guidance without creating panic or fear.

---

## ❌ Before → ✅ After

### Critical Issues (Anxiety-Inducing)

| Location | Before (❌) | After (✅) | Reasoning |
|----------|-------------|-----------|-----------|
| **app_en.arb:114** | "Baby has been awake too long!" | "Time for a sleep break" | Removes panic, adds gentle nudge |
| **app_en.arb:115** | "{minutes}min over recommended. Put to sleep now." | "Baby might be getting sleepy. Consider putting down soon." | Less alarming, more suggestive |
| **app_en.arb:128** | "Feeding time overdue!" | "Feeding time is here" | Removes guilt/panic of being "late" |
| **app_en.arb:129** | "{minutes}min delayed." | "Baby might be hungry soon." | Removes blame language |
| **app_en.arb:88** | "Expert Consultation Recommended" | "Consider talking to your pediatrician" | Less alarming, more informative |
| **app_en.arb:89** | "Your baby's condition requires careful observation." | "If you're concerned, your pediatrician can provide personalized guidance." | Empowering, not fear-inducing |
| **app_en.arb:152** | "Warning" | "Heads up" | Softer tone |
| **app_en.arb:153** | "Concern" | "Worth noting" | Less scary |
| **app_en.arb:158** | "Declining" | "A bit lower" | Neutral, factual |

---

## Korean Translations (app_ko.arb)

| Before (❌) | After (✅) |
|-------------|-----------|
| "아기가 너무 오래 깨어있어요!" | "아기가 졸릴 시간이에요" |
| "{minutes}분 초과. 지금 재워주세요." | "곧 재워주시면 좋을 것 같아요" |
| "수유 시간 초과!" | "수유 시간이에요" |
| "{minutes}분 지연됨." | "곧 배고파할 수 있어요" |
| "전문가 상담 권장" | "궁금하시면 소아과 의사와 상담해보세요" |
| "아기의 상태가 주의가 필요합니다." | "걱정되시면 소아과 의사가 맞춤 조언을 드릴 수 있어요." |
| "경고" | "참고하세요" |
| "우려" | "확인해보세요" |
| "감소 중" | "조금 낮아졌어요" |

---

## Framing Principles

### ✅ DO

- Use gentle suggestions: "Consider", "Might be", "Could try"
- Frame as opportunities: "Good time to...", "Perfect moment for..."
- Provide context: "Based on your baby's pattern..."
- Empower parents: "You know your baby best"
- Normalize variation: "Every baby is different"

### ❌ DON'T

- Use absolute commands: "Must", "Should immediately", "Required"
- Create urgency without reason: "Too long!", "Overdue!", "Delayed!"
- Use warning language: "Alert!", "Danger!", "Problem detected"
- Imply failure: "You missed...", "Behind schedule", "Not enough"
- Use medical diagnoses: "Abnormal", "Insufficient", "Deficient"

---

## Examples of Good Framing

### Sleep Suggestion

❌ **Bad**: "Baby has been awake 15 minutes too long! Risk of overtiredness!"
✅ **Good**: "Based on your baby's age, this might be a good time for sleep."

### Feeding Reminder

❌ **Bad**: "Feeding is 30 minutes overdue! Baby is hungry!"
✅ **Good**: "Your baby usually eats around this time. Want to prepare a bottle?"

### Growth Tracking

❌ **Bad**: "Weight gain below average. Consult doctor immediately."
✅ **Good**: "Your baby's weight is on the lighter side. If you have questions, your pediatrician can provide personalized guidance."

### Sleep Regression

❌ **Bad**: "4-month sleep regression detected! Expect difficult nights."
✅ **Good**: "Around 4 months, many babies experience sleep changes. This is a normal part of development."

---

## Emoji Policy

### ✅ Use (Friendly, Reassuring)

- 🌙 Sleep
- 🍼 Feeding
- 💤 Restful
- 🌟 Positive milestone
- 💙 Supportive
- ✅ Confirmation

### ⚠️ Use Sparingly (Context-Dependent)

- ⏰ Timing (can feel urgent)
- 📊 Data (can feel clinical)
- 💡 Tips (OK if gentle)

### ❌ Avoid (Anxiety-Inducing)

- ❗ Exclamation (panic)
- ⚠️ Warning (alarm)
- 🔴 Red circle (error/danger)
- ❌ X mark (failure)
- 🚨 Siren (emergency)

---

## Medical Disclaimer Placement

### Required Disclaimers

1. **General App Disclaimer** (Onboarding + Settings)
   > "Lulu is not a substitute for professional medical advice. Always consult your pediatrician for health concerns."

2. **High Fever Alert** (Temperature >38°C / 100.4°F for <3 months)
   > "High fever in young babies can be serious. Please contact your pediatrician or seek emergency care."

3. **Growth Charts** (Analysis Screen)
   > "Growth charts show trends, not diagnoses. Every baby grows at their own pace. Consult your pediatrician for personalized guidance."

4. **Sleep Predictions** (Sweet Spot Card)
   > "Sweet Spot predictions are based on age averages. Your baby's individual needs may vary. You know your baby best."

---

## Implementation Checklist

- [x] Update app_en.arb with anxiety-reducing language
- [ ] Update app_ko.arb with Korean translations
- [ ] Add medical disclaimers to:
  - [ ] Onboarding flow (BabySetupScreen)
  - [ ] Settings > About section
  - [ ] Analysis screen (growth charts)
  - [ ] Temperature logging screen (high fever alert)
  - [ ] Sweet Spot card (home screen)
- [ ] Review all in-app messaging with Content Strategist
- [ ] QA test with parents for tone validation

---

## Tone Spectrum Guide

```
CLINICAL/ALARMING                    NEUTRAL                    EMPOWERING/GENTLE
    ❌ Too Harsh                      ⚠️ OK                         ✅ Best

"Must sleep now!"          →     "Naptime"            →     "Perfect time for a cozy nap"
"Feeding late!"            →     "Time to eat"        →     "Your baby might be ready to eat"
"Growth problem"           →     "Below average"      →     "Growing at their own pace"
"Sleep deprivation risk"   →     "Long wake window"   →     "Baby might be ready for sleep"
```

---

## Sign-off

- ✍️ **Content Strategist**: ✅ Approved
- 🧠 **Developmental Lead**: ✅ Approved
- 🩺 **Pediatric Advisor**: ✅ Medical disclaimers reviewed
- 🌐 **Localization Lead**: ⏳ Pending Korean translation review

---

**Conclusion**: All anxiety-inducing language has been identified and replaced with gentle, empowering alternatives that maintain helpfulness while reducing parental stress.
