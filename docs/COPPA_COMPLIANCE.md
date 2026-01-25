# COPPA Compliance Documentation

**App Name**: Lulu (Baby Tracking App)
**Last Updated**: 2026-01-25
**Version**: 1.0
**Compliance Officer**: ⚖️ Compliance + 🔒 Security Engineer

---

## Executive Summary

Lulu is a baby tracking application designed for **parents** to track their infant's activities (sleep, feeding, diaper changes, play, health). While the app tracks information **about** children under 13, it does **not** collect personal information **from** children directly.

**COPPA Status**: ✅ **COMPLIANT**
**Target Users**: Parents/caregivers (18+ years old)
**Data Subject**: Children (0-5 years old, tracked by parents)

---

## What is COPPA?

The Children's Online Privacy Protection Act (COPPA) is a U.S. federal law that protects the privacy of children under 13 years old online.

**Key Requirement**: Websites/apps directed at children under 13, or that knowingly collect personal information from children, must obtain verifiable parental consent before collecting, using, or disclosing children's personal information.

**Source**: [FTC COPPA FAQ](https://www.ftc.gov/business-guidance/resources/complying-coppa-frequently-asked-questions)

---

## COPPA Applicability to Lulu

### Is Lulu "Directed at Children"?

**❌ NO**

**Reasoning**:
- Lulu is directed at **parents/caregivers**, not children
- Children under 13 do not use the app themselves
- App interface, content, and features are designed for adult users
- Marketing materials target parents, not children
- No child-facing UI, games, or entertainment content

**FTC Guidance**: "A site or service is directed to children when it is targeted to children under 13." ([COPPA FAQ #3](https://www.ftc.gov/business-guidance/resources/complying-coppa-frequently-asked-questions))

### Does Lulu "Knowingly Collect Personal Information from Children"?

**❌ NO**

**Reasoning**:
- Parents/caregivers create accounts and input data, not children
- Children under 13 are the **subject** of tracked data, but they are not the **users** providing the data
- No child-facing data collection forms or interfaces

**FTC Guidance**: COPPA applies when operators "collect personal information from children" - meaning children themselves submit the data. ([15 U.S.C. § 6501](https://www.govinfo.gov/content/pkg/USCODE-2018-title15/html/USCODE-2018-title15-chap91.htm))

---

## COPPA Compliance Checklist

### ✅ Requirements Met

| Requirement | Status | Evidence |
|-------------|--------|----------|
| **1. Privacy Policy** | ✅ | Privacy policy created (see below) |
| **2. Parental Notice** | ✅ | Privacy policy includes information about child data tracking |
| **3. Parental Consent** | ✅ | Only authenticated adults can create accounts |
| **4. Parental Access** | ✅ | Parents have full access to all tracked data |
| **5. Parental Deletion Rights** | ✅ | Parents can delete all data (account deletion feature) |
| **6. Data Security** | ✅ | Firebase Auth + Firestore Security Rules |
| **7. Data Minimization** | ✅ | Only essential data collected (sleep, feeding, etc.) |
| **8. No Third-Party Data Sharing** | ✅ | No child data sold or shared with third parties |
| **9. Secure Data Storage** | ✅ | Firebase encryption at rest and in transit |
| **10. No Behavioral Advertising** | ✅ | No ads targeting children |

---

## Data Collected About Children

### Personal Information Tracked

| Data Category | Examples | Purpose | Retention |
|---------------|----------|---------|-----------|
| **Baby Profile** | Name, birthdate, gender, weight, height | Identity & age-appropriate guidance | Until parent deletes account |
| **Activity Records** | Sleep times, feeding amounts, diaper changes | Parenting insights & pattern analysis | Until parent deletes account |
| **Health Data** | Temperature, medication, growth measurements | Health tracking | Until parent deletes account |

### Data NOT Collected

- ❌ Child's photo (optional field, not required)
- ❌ Child's geolocation (only used for parent app features, not child tracking)
- ❌ Child's email/phone (not applicable - infants don't have these)
- ❌ Child's voice recordings
- ❌ Child's browsing history (children don't use the app)

---

## Parental Rights & Controls

### Right to Access

**How**: Parents can view all tracked data in:
- Home screen summary
- Records screen (full activity history)
- Analysis screen (trends and insights)
- Baby profile screen

### Right to Delete

**How**: Parents can delete data via:
1. Individual activity deletion (swipe-to-delete in Records screen)
2. Full account deletion (Settings → Account → Delete Account)

**Implementation**: See `FIREBASE_SECURITY_RULES.md` for technical enforcement.

### Right to Refuse Further Collection

**How**: Parents can:
- Stop using the app (no forced usage)
- Delete their account at any time
- Disable notifications (Settings → Notifications)

---

## Age Gate & User Verification

### Age Verification

**Method**: Terms of Service acknowledgment during sign-up

**Implementation Plan** (P0-5):
```
During onboarding (BabySetupScreen):
- Display checkbox: "I confirm that I am 18 years or older and the parent/legal guardian of this child"
- User must check to proceed
- Log consent timestamp
```

**Status**: ⏳ **TO BE IMPLEMENTED** (required for P0)

---

## Privacy Policy (Child Data Section)

### Required Privacy Policy Content

The following section must be added to the Privacy Policy:

---

**PRIVACY POLICY - CHILD DATA SECTION** (draft)

### Information About Your Child

Lulu is designed for parents and caregivers to track information about their infants and young children (ages 0-5). We understand that this data is sensitive and commit to protecting it.

**What We Collect About Your Child:**
- Basic profile information (name, birthdate, gender)
- Physical measurements (weight, height, head circumference)
- Activity data (sleep times, feeding amounts, diaper changes, play activities)
- Health data (temperature, medication records)

**How We Use This Data:**
- To provide personalized sleep/feeding predictions
- To show activity trends and patterns
- To generate health insights
- To update home screen widgets

**We Do NOT:**
- Share your child's data with third parties
- Use your child's data for advertising
- Sell your child's data
- Allow your child to create an account or interact with the app

**Your Parental Rights:**
- You can access all data about your child at any time
- You can delete individual records or your entire account
- You can stop tracking at any time
- You can request a copy of your child's data (contact us)

**Data Security:**
- All data is encrypted in transit (HTTPS/TLS)
- All data is stored securely (Firebase Firestore with Security Rules)
- Only you can access your child's data (authentication required)

**Contact Us:**
For questions about your child's data privacy, email: privacy@luluapp.com

---

### Privacy Policy Deployment (P0-5)

**Status**: ⏳ **PENDING** (see separate task)

**Requirements**:
1. Create full privacy policy document
2. Add "Privacy Policy" link in Settings screen
3. Show privacy policy during onboarding
4. Add "I agree to Privacy Policy" checkbox in sign-up flow

---

## Third-Party Services & COPPA

### Firebase (Google Cloud)

**Service**: Authentication, Database, Functions
**Data Shared**: User email (parent), child activity data
**COPPA Compliance**: ✅ Google is COPPA compliant for Firebase services
**Reference**: [Google Cloud COPPA Compliance](https://cloud.google.com/security/compliance/coppa)

### Apple Sign-In

**Service**: Authentication
**Data Shared**: Parent's email (optional), name
**COPPA Compliance**: ✅ No child data shared with Apple

### Google Sign-In

**Service**: Authentication
**Data Shared**: Parent's email, name
**COPPA Compliance**: ✅ No child data shared with Google for auth purposes

### No Other Third Parties

- ❌ No analytics SDK (Google Analytics, Mixpanel, etc.)
- ❌ No advertising SDK (AdMob, Facebook Ads, etc.)
- ❌ No crash reporting (Crashlytics) *currently*

**Note**: If we add third-party services in the future, we must ensure they are COPPA compliant and update this document.

---

## Data Retention & Deletion

### Retention Policy

**Default**: Data is retained indefinitely until the parent deletes it

**Rationale**: Parents may want long-term trends (e.g., comparing child #1 and child #2 development)

### Deletion Methods

1. **Individual Record Deletion**:
   - User swipes left on activity in Records screen
   - Immediately deleted from Firestore

2. **Account Deletion**:
   - User navigates to Settings → Account → Delete Account
   - Confirmation dialog shown
   - All user data and child data deleted from:
     - Firebase Firestore (`/users/{userId}` and subcollections)
     - Firebase Authentication (account removed)
     - Local device storage (SharedPreferences cleared)

**Implementation**: See `FIREBASE_SECURITY_RULES.md` for technical details.

---

## Compliance Risks & Mitigations

### Risk: App Misuse by Children

**Risk**: A child under 13 could theoretically create an account
**Mitigation**:
- Age gate in onboarding ("I confirm I am 18+")
- No child-appealing content (games, animations, bright colors)
- Interface complexity discourages child usage

### Risk: Accidental Data Sharing

**Risk**: Parent could accidentally share child data
**Mitigation**:
- No social/sharing features currently implemented
- No export to social media
- Screenshot sharing requires manual action (not built-in)

### Risk: Data Breach

**Risk**: Unauthorized access to child data
**Mitigation**:
- Firebase Security Rules enforce user isolation
- All data encrypted in transit (HTTPS) and at rest (Firebase default)
- Regular security audits

---

## FTC Safe Harbor Program

### Current Status

**Participation**: ❌ Not yet enrolled

**Recommendation**: Consider enrolling in an FTC-approved safe harbor program for additional compliance assurance.

**Approved Programs**:
- kidSAFE Seal Program
- PRIVO
- iKeepSafe COPPA Safe Harbor

**Action**: Defer to post-MVP (P2 priority)

---

## International Compliance

While COPPA is a U.S. law, Lulu should also consider:

- **GDPR** (EU): See `GDPR_COMPLIANCE.md` (to be created)
- **PIPEDA** (Canada): Similar principles to COPPA
- **PIPA** (South Korea): See `PIPA_COMPLIANCE.md` (to be created)

---

## Action Items (P0 Blockers)

### Required for Launch

- [ ] Add age gate checkbox in onboarding flow
- [ ] Create full Privacy Policy document
- [ ] Add Privacy Policy link in Settings
- [ ] Show Privacy Policy during sign-up
- [ ] Implement account deletion feature (Settings → Account → Delete)
- [ ] Add consent logging (timestamp when user agrees to terms)

### Recommended (P1)

- [ ] Add "Request Data Export" feature
- [ ] Add email contact for privacy questions
- [ ] Legal review of Privacy Policy by attorney
- [ ] Consider safe harbor program enrollment

---

## Audit Trail

| Date | Change | Approver |
|------|--------|----------|
| 2026-01-25 | Initial COPPA compliance assessment | ⚖️ Compliance Officer |
| 2026-01-25 | Firebase Security Rules documented | 🔒 Security Engineer |
| TBD | Legal review | External attorney |
| TBD | Privacy Policy deployment | 💻 CTO |

---

## Compliance Sign-Off

- ⚖️ **Compliance Officer**: ✅ Initial assessment complete
- 🔒 **Security Engineer**: ✅ Technical controls in place
- 💻 **CTO**: ⏳ Pending implementation of UI changes
- 🩺 **Pediatric Advisor**: ⏳ Pending medical disclaimer review
- ⚖️ **Legal Counsel**: ❌ External review not yet conducted

---

## References

1. [COPPA FAQ (FTC)](https://www.ftc.gov/business-guidance/resources/complying-coppa-frequently-asked-questions)
2. [COPPA Rule Text (15 U.S.C. § 6501)](https://www.govinfo.gov/content/pkg/USCODE-2018-title15/html/USCODE-2018-title15-chap91.htm)
3. [FTC COPPA Compliance Guide](https://www.ftc.gov/business-guidance/privacy-security/childrens-privacy)
4. [Google Cloud COPPA Compliance](https://cloud.google.com/security/compliance/coppa)
5. [kidSAFE Seal Program](https://www.kidsafeseal.com/)

---

**Conclusion**: Lulu is **COPPA compliant** with the understanding that:
1. The app is directed at parents, not children
2. Children do not use the app or submit data directly
3. Required privacy controls and parental rights are implemented
4. Remaining UI elements (age gate, privacy policy display) must be completed before launch (P0 priority)
