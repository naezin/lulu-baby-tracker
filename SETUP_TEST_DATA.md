# 🧪 Test Data Setup for Advanced Health Features

## Quick Firebase Console Setup

### Step 1: Open Firebase Console
1. Go to: https://console.firebase.google.com
2. Select your project
3. Go to Firestore Database
4. Navigate to: `users` → `demo-user` → `babies`

### Step 2: Create Test Baby Profiles

#### Option A: Infant < 3 Months (Emergency Testing)
```javascript
// Click "Add Document" in babies collection
// Document ID: baby-infant

{
  id: "baby-infant",
  userId: "demo-user",
  name: "Baby Emma",
  birthDate: "2025-11-01T00:00:00.000Z",  // ~2.7 months old
  weightKg: 5.5,
  weightUnit: "kg",
  gender: "female",
  isPremature: false,
  createdAt: "2025-11-01T00:00:00.000Z",
  updatedAt: "2026-01-22T12:00:00.000Z"
}
```
**Test with**: 38.5°C → Should trigger emergency dialog!

---

#### Option B: Baby 3-6 Months (Ibuprofen Restriction)
```javascript
// Document ID: baby-young

{
  id: "baby-young",
  userId: "demo-user",
  name: "Baby Noah",
  birthDate: "2025-09-01T00:00:00.000Z",  // ~4.7 months old
  weightKg: 6.8,
  weightUnit: "kg",
  gender: "male",
  isPremature: false,
  createdAt: "2025-09-01T00:00:00.000Z",
  updatedAt: "2026-01-22T12:00:00.000Z"
}
```
**Test with**: Ibuprofen → Should show "NOT recommended for <6 months"

---

#### Option C: Baby > 6 Months (Full Features)
```javascript
// Document ID: baby-full

{
  id: "baby-full",
  userId: "demo-user",
  name: "Baby Olivia",
  birthDate: "2025-05-01T00:00:00.000Z",  // ~8.7 months old
  weightKg: 8.2,
  weightUnit: "kg",
  gender: "female",
  isPremature: false,
  createdAt: "2025-05-01T00:00:00.000Z",
  updatedAt: "2026-01-22T12:00:00.000Z"
}
```
**Test with**: Both Tylenol and Advil → Full dosage calculator available

---

## Step 3: Update Existing Baby Profile (If Exists)

If you already have a baby profile, just add these fields:

1. Find the existing document in: `users/demo-user/babies/{id}`
2. Click "Edit" (pencil icon)
3. Add these fields:
   - `weightKg` (number): e.g., `7.5`
   - `weightUnit` (string): `"kg"` or `"lb"`
   - `birthDate` (string): Use ISO 8601 format (see examples above)

**Calculate birthDate for specific age**:
- For 2 months old: Today - 60 days
- For 4 months old: Today - 120 days
- For 8 months old: Today - 240 days

---

## Testing Scenarios

### 🔴 Emergency Scenario (< 3 months)
1. Use `baby-infant` profile (birthDate: 2025-11-01)
2. Go to Health → Temperature
3. Enter: **38.5°C** or **101.3°F**
4. ✅ **Emergency dialog should appear immediately**
5. Dialog says: "URGENT MEDICAL ATTENTION NEEDED"

### 🟡 Ibuprofen Restriction (< 6 months)
1. Use `baby-young` profile (birthDate: 2025-09-01, ~4.7 months)
2. Go to Health → Medication
3. Select: Fever Reducer → **Ibuprofen (Advil)**
4. ✅ **Red warning card appears**: "NOT recommended for infants under 6 months"

### 🟢 Full Dosage Calculator (> 6 months)
1. Use `baby-full` profile (birthDate: 2025-05-01, ~8.7 months)
2. Go to Health → Medication
3. Select: Fever Reducer → **Acetaminophen (Tylenol)**
4. ✅ **Blue dosage calculator appears** with:
   - Weight: 8.2 kg
   - Dosage: 82 - 123 mg (2.6 - 3.8 ml)
   - Frequency: Every 4-6 hours
   - Max Daily: 615 mg

### 🌡️ Fever Advice (All Ages)
1. Use any baby profile
2. Go to Health → Temperature
3. Enter temperatures and observe advice:
   - **36.5°C** → Blue card, normal advice
   - **38.2°C** → Yellow/Orange card, "Monitor closely"
   - **39.5°C** → Orange/Red card, "Consider medication"
4. ✅ **Advice changes based on baby's age**

---

## Quick Copy-Paste Values

### BirthDate Examples (ISO 8601)
```
2 months ago:  "2025-11-22T00:00:00.000Z"
4 months ago:  "2025-09-22T00:00:00.000Z"
8 months ago:  "2025-05-22T00:00:00.000Z"
12 months ago: "2025-01-22T00:00:00.000Z"
```

### Weight Examples (kg)
```
Newborn:    3.5 kg
2 months:   5.5 kg
4 months:   6.8 kg
6 months:   7.5 kg
8 months:   8.2 kg
12 months:  9.5 kg
```

### Temperature Test Values
```
Normal:     36.5°C (97.7°F)
Low Fever:  37.8°C (100.0°F)
Fever:      38.5°C (101.3°F)
High Fever: 39.5°C (103.1°F)
Very High:  40.2°C (104.4°F)
```

---

## Verification Checklist

After adding test data, verify:

- [ ] Baby profile exists: `users/demo-user/babies/{id}`
- [ ] `weightKg` field is present (number)
- [ ] `birthDate` field is present (ISO 8601 string)
- [ ] App shows dosage calculator when medication selected
- [ ] App shows fever advice when temperature entered
- [ ] Emergency dialog appears for <3mo with ≥38°C

---

## Troubleshooting

**Q: Dosage calculator not showing?**
- Check if `weightKg` field exists in baby profile
- Ensure you selected a fever reducer medication (not "Other")
- Refresh the app (press 'R' in terminal for hot restart)

**Q: Fever advice not showing?**
- Check if `birthDate` field exists in baby profile
- Ensure birthDate is in ISO 8601 format
- Verify temperature is entered correctly

**Q: Emergency dialog not appearing?**
- Verify baby age is < 3 months (check birthDate calculation)
- Ensure temperature is ≥ 38.0°C (or ≥ 100.4°F)
- Check browser console for errors

**Q: "No baby profile found" message?**
- Go to Firebase Console
- Verify document exists in: `users/demo-user/babies`
- Check that document has required fields (id, birthDate, weightKg)

---

## Firebase Rules Note

Ensure your Firestore rules allow reading from babies collection:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/babies/{babyId} {
      allow read, write: if true;  // For demo/dev only
    }
  }
}
```

**⚠️ For production, add proper authentication checks!**

---

**Quick Start**: Use **Option C** (Baby > 6 months) for full feature testing without restrictions.

**Last Updated**: 2026-01-22
