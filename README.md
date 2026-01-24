# 🌙 Lulu - AI-Powered Baby Care & Sleep Tracking Platform

> **Universal Baby Care Platform** with specialized algorithms for premature and low-birth-weight infants

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Version](https://img.shields.io/badge/Version-1.0.0-blue.svg)](https://github.com/naezin/lulu-baby-tracker/releases)

---

## 📋 Table of Contents

- [Project Overview](#-project-overview)
- [Tech Stack](#-tech-stack)
- [Key Features](#-key-features)
- [Getting Started](#-getting-started)
- [Data Context](#-data-context)
- [Architecture](#-architecture)
- [Security](#-security)
- [Contributing](#-contributing)

---

## 🎯 Project Overview

**Lulu** is an AI-powered baby care and sleep tracking application designed to help parents optimize their baby's sleep schedule and overall care routine. While supporting all infants, Lulu provides **specialized algorithms and recommendations** for premature and low-birth-weight babies who require more precise care patterns.

### Vision

To become the **most trusted AI companion** for parents, providing:
- Evidence-based sleep predictions using wake window science
- Personalized care recommendations based on individual baby patterns
- Specialized support for premature infants and special care cases
- Multilingual support (Korean/English) with plans for global expansion

### Target Users

- Parents of newborns (0-12 months)
- Parents of premature babies requiring specialized care
- Caregivers seeking data-driven insights
- Health professionals monitoring infant development

---

## 🛠 Tech Stack

### Core Technologies

- **Frontend**: Flutter 3.0+ (Dart)
- **State Management**: Provider
- **Local Storage**: SharedPreferences
- **Backend Services**: Firebase (Authentication, Analytics)
- **AI/ML**: OpenAI GPT-4 API
- **Localization**: Flutter Intl

### Platform Support

- ✅ iOS (14.0+)
- ✅ Android (API 21+)
- 🔄 Web (Planned)

### Key Dependencies

```yaml
flutter: 3.0+
provider: ^6.1.1
shared_preferences: ^2.2.0
home_widget: ^0.4.0
http: ^1.1.0
intl: ^0.19.0
uuid: ^4.0.0
```

---

## ✨ Key Features

### P0 Features (Currently Implemented)

#### 🎯 Core Functionality
- **Activity Tracking**: Comprehensive logging for Sleep, Feeding, Diaper, Play, and Health
- **AI-Powered Sweet Spot**: Intelligent sleep timing predictions based on wake windows
- **Smart Predictions**: Feeding interval calculations and sleep schedule optimization
- **Data Persistence**: Complete local storage with CRUD operations

#### 📊 Analytics & Insights
- **Pattern Recognition**: Analyze trends in sleep and feeding patterns
- **Daily Rhythm Visualization**: Interactive wheel showing baby's 24-hour patterns
- **Activity History**: Comprehensive view with filtering and search capabilities
- **CSV Export/Import**: Backup and data migration support

#### 🎨 User Experience
- **Beautiful Dark Theme**: Inspired by Huckleberry and BabyTime
- **Smooth Animations**: Fluid transitions with haptic feedback
- **Dual Language Support**: Full localization for Korean and English
- **Home Widgets**: Real-time updates on iOS and Android

#### 🔔 Smart Features
- **AI Coaching**: Personalized recommendations based on patterns
- **Intelligent Notifications**: Context-aware reminders
- **Premature Baby Support**: Specialized care algorithms
- **Development Tracking**: Monitor milestones with development tags

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.0 or higher
- Dart SDK 2.19 or higher
- Xcode 14+ (for iOS development)
- Android Studio / VS Code with Flutter extensions

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/naezin/lulu-baby-tracker.git
   cd lulu-baby-tracker
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure environment variables**
   ```bash
   # Copy the example file
   cp .env.example .env

   # Edit .env and add your API keys
   # NEVER commit the .env file to version control
   ```

4. **Required Environment Variables**

   Create a `.env` file in the project root with these variables:

   ```bash
   # OpenAI API Key (required for AI coaching features)
   OPENAI_API_KEY=sk-proj-xxxxxxxxxxxxx

   # Firebase Configuration (optional for MVP, required for production)
   FIREBASE_API_KEY=AIzaxxxxxxxxxxxxxxxxx
   FIREBASE_AUTH_DOMAIN=your-project.firebaseapp.com
   FIREBASE_PROJECT_ID=your-project-id
   FIREBASE_STORAGE_BUCKET=your-project.appspot.com
   FIREBASE_MESSAGING_SENDER_ID=123456789
   FIREBASE_APP_ID=1:123456789:web:abcdef123456

   # App Environment
   ENVIRONMENT=development  # development | staging | production
   ```

   ⚠️ **SECURITY WARNING**: The `.env` file is in `.gitignore`. NEVER commit actual API keys to version control!

5. **Run the app**
   ```bash
   # iOS
   flutter run -d ios

   # Android
   flutter run -d android

   # Web (coming soon)
   flutter run -d chrome
   ```

### Platform-Specific Setup

#### iOS Setup

1. Configure signing in Xcode
2. Update `ios/Runner/Info.plist` with required permissions
3. (Optional) Add `GoogleService-Info.plist` for Firebase

#### Android Setup

1. Update `android/app/build.gradle` with your app ID
2. (Optional) Add `google-services.json` for Firebase
3. Configure signing for release builds

---

## 📊 Data Context

### Baby Profile Reference Case

Lulu's algorithms are optimized and tested against real-world special care cases:

**Reference Case**: Premature Infant
- **Birth Date**: November 11, 2025
- **Birth Weight**: 2.46 kg (low birth weight)
- **Current Age**: 72 days (as of reference date)
- **Care Category**: Premature infant requiring specialized monitoring

### Why This Matters

This reference case drives our algorithmic precision:

1. **Wake Windows**: Adjusted for premature infant developmental age (not chronological age)
2. **Feeding Intervals**: More frequent, smaller amounts (90-135ml vs standard)
3. **Sleep Quality Monitoring**: Enhanced sensitivity to sleep disturbances
4. **Growth Tracking**: Specialized percentile curves for low-birth-weight infants
5. **Risk Indicators**: Proactive alerts for patterns requiring medical consultation

### Universal Support

While optimized for special cases, Lulu supports **all infants**:
- Full-term healthy babies
- Premature infants (any gestational age)
- Multiples (twins, triplets)
- Babies with medical conditions

The app automatically adjusts recommendations based on:
- Actual birth weight
- Gestational age at birth
- Current chronological age
- Observed feeding/sleep patterns

---

## 🏗 Architecture

### Project Structure

```
lulu/
├── lib/
│   ├── core/                    # Core utilities and constants
│   │   ├── constants/           # App constants and personas
│   │   ├── localization/        # i18n support
│   │   ├── theme/               # App theming
│   │   └── utils/               # Utility functions
│   │       ├── wake_window_calculator.dart
│   │       ├── feeding_interval_calculator.dart
│   │       └── sweet_spot_calculator.dart
│   │
│   ├── data/                    # Data layer
│   │   ├── models/              # Data models
│   │   │   ├── activity_model.dart
│   │   │   ├── baby_model.dart
│   │   │   └── play_activity_model.dart
│   │   ├── services/            # Business logic services
│   │   │   ├── local_storage_service.dart
│   │   │   ├── ai_coaching_service.dart
│   │   │   ├── notification_service.dart
│   │   │   └── widget_service.dart
│   │   ├── analysis/            # Pattern analysis
│   │   └── knowledge/           # Expert guidelines
│   │
│   └── presentation/            # UI layer
│       ├── providers/           # State management
│       ├── screens/             # App screens
│       │   ├── auth/            # Onboarding & authentication
│       │   ├── home/            # Main dashboard
│       │   ├── activities/      # Activity logging screens
│       │   ├── settings/        # App settings
│       │   └── insights/        # AI insights & analytics
│       └── widgets/             # Reusable UI components
│
├── android/                     # Android-specific code
├── ios/                         # iOS-specific code
├── test/                        # Unit and widget tests
└── scripts/                     # Build and utility scripts
```

### Design Patterns

- **Provider Pattern**: State management
- **Repository Pattern**: Data access abstraction
- **Service Layer**: Business logic separation
- **Factory Pattern**: Model creation
- **Observer Pattern**: Widget updates

---

## 🔒 Security

### Critical Security Rules

⚠️ **NEVER commit these files to version control:**

#### Environment Variables
- `.env`
- `.env.local`
- `.env.*`
- Any file containing API keys or secrets

#### Firebase Configuration
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`
- `firebase_options.dart`

#### Platform Signing Keys
- `*.keystore`
- `*.jks`
- `*.p12`
- `*.mobileprovision`
- `key.properties`

#### Cloud Credentials
- AWS, GCP, or any cloud provider credentials
- OAuth client secrets
- Database connection strings

### Security Checklist

Before committing:

```bash
# 1. Check git status for sensitive files
git status

# 2. Search for accidentally staged secrets
git diff --staged | grep -i "api.*key\|secret\|password"

# 3. Verify .gitignore is working
git check-ignore .env android/app/google-services.json

# 4. Scan commit history (if suspicious)
git log --all --full-history -- **/*.env
```

### If You Accidentally Committed Secrets

**IMMEDIATE ACTION REQUIRED**:

```bash
# 1. Revoke the exposed API keys immediately
# (Go to OpenAI/Firebase console and regenerate)

# 2. Remove from git history using BFG Repo-Cleaner
brew install bfg
bfg --delete-files .env
git reflog expire --expire=now --all
git gc --prune=now --aggressive

# 3. Force push (WARNING: Coordinate with team first)
git push --force

# 4. Update .env with new keys
```

Alternatively, use `git filter-repo`:

```bash
pip install git-filter-repo
git filter-repo --path .env --invert-paths
git push --force
```

---

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/unit/utils/sweet_spot_calculator_test.dart

# Run widget tests
flutter test test/widget_test.dart
```

---

## 📱 Deployment

### iOS

1. Update version in `pubspec.yaml`
2. Build release:
   ```bash
   flutter build ios --release
   ```
3. Open Xcode and archive for App Store

### Android

1. Configure signing in `android/key.properties`
2. Build APK/App Bundle:
   ```bash
   flutter build apk --release
   flutter build appbundle --release
   ```
3. Upload to Google Play Console

---

## 🤝 Contributing

### For AI Agents Reading This Code

When analyzing or modifying this codebase:

1. **Context Preservation**: Always maintain the specialized care algorithms for premature infants
2. **Data Privacy**: Never log or expose actual user data
3. **Algorithm Accuracy**: Sleep predictions are based on peer-reviewed research - maintain references
4. **Localization**: All user-facing strings must use `l10n.translate()` - run `dart scripts/check_i18n.dart`
5. **Testing**: Add tests for any new calculators or business logic

### Code Style

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use meaningful variable names
- Document complex algorithms with research references
- Keep functions small and focused

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- Inspired by Huckleberry and BabyTime apps
- Wake window calculations based on research from:
  - American Academy of Pediatrics sleep guidelines
  - Stanford Children's Health developmental milestones
  - Premature infant care protocols from WHO

---

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/naezin/lulu-baby-tracker/issues)
- **Discussions**: [GitHub Discussions](https://github.com/naezin/lulu-baby-tracker/discussions)
- **Email**: naezinh@gmail.com

---

## 🗺 Roadmap

### v1.1 (Q1 2026)
- [ ] Cloud sync with Firebase
- [ ] Multiple baby profiles
- [ ] Advanced analytics dashboard
- [ ] Export to PDF reports

### v1.2 (Q2 2026)
- [ ] Collaborative features (family sharing)
- [ ] Integration with wearables
- [ ] Pediatrician portal
- [ ] Expanded language support

### v2.0 (Q3 2026)
- [ ] Machine learning pattern prediction
- [ ] Voice command support
- [ ] Smart home integrations
- [ ] Community features

---

**Built with ❤️ for parents everywhere**

*Last updated: January 24, 2025*
