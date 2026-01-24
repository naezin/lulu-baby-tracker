import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
// import 'package:firebase_core/firebase_core.dart'; // Temporarily disabled for web
import 'package:home_widget/home_widget.dart';
import 'core/theme/app_theme.dart';
import 'core/localization/app_localizations.dart';
import 'core/utils/environment_validator.dart';
import 'data/services/openai_service.dart';
import 'data/services/widget_service.dart';
import 'presentation/providers/chat_provider.dart';
import 'presentation/providers/sweet_spot_provider.dart';
import 'presentation/providers/locale_provider.dart';
import 'presentation/providers/unit_preferences_provider.dart';
import 'presentation/screens/main/main_navigation.dart';
import 'presentation/screens/activities/log_feeding_screen.dart';
import 'presentation/screens/activities/log_sleep_screen.dart';
import 'presentation/screens/activities/log_diaper_screen.dart';
import 'presentation/widgets/auth_wrapper.dart';

// Global navigator key for widget deep linking
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 환경 변수 검증
  final validation = EnvironmentValidator.validate();
  if (!validation.isValid) {
    debugPrint(validation.errorMessage);
    // 개발 모드에서는 경고만, Production에서는 차단
    if (EnvironmentValidator.isProduction) {
      throw Exception('필수 환경 변수가 설정되지 않았습니다');
    }
  }

  // Skip Firebase initialization on web due to compatibility issues
  // if (!kIsWeb) {
  //   try {
  //     await Firebase.initializeApp(
  //       options: const FirebaseOptions(
  //         apiKey: "AIzaSyDemo-Key-Replace-With-Real-Key",
  //         authDomain: "lulu-demo.firebaseapp.com",
  //         projectId: "lulu-demo",
  //         storageBucket: "lulu-demo.appspot.com",
  //         messagingSenderId: "123456789",
  //         appId: "1:123456789:web:abcdef123456",
  //       ),
  //     );
  //   } catch (e) {
  //     // Firebase already initialized or initialization failed
  //     debugPrint('Firebase initialization: $e');
  //   }
  // }

  // Initialize widget service (only on non-web platforms)
  if (!kIsWeb) {
    try {
      // Set App Group ID for iOS widgets (required for shared data storage)
      await HomeWidget.setAppGroupId('group.com.lulu.babytracker');

      final widgetService = WidgetService();

      // Set up widget interaction listener
      HomeWidget.widgetClicked.listen((Uri? uri) {
        if (uri != null) {
          _handleWidgetAction(uri.toString());
        }
      });

      // Update widgets with initial data
      widgetService.updateAllWidgets();
    } catch (e) {
      // Widget initialization failed (e.g., on Android or if not configured)
      debugPrint('Widget initialization: $e');
    }
  }

  runApp(const LuluApp());
}

/// Handle widget deep link actions
void _handleWidgetAction(String action) {
  final context = navigatorKey.currentContext;
  if (context == null) return;

  Widget? targetScreen;

  switch (action) {
    case 'sleep':
      targetScreen = const LogSleepScreen();
      break;
    case 'feeding':
      targetScreen = const LogFeedingScreen();
      break;
    case 'diaper':
      targetScreen = const LogDiaperScreen();
      break;
    case 'open_app':
      // Just open the app, no navigation needed
      return;
    default:
      debugPrint('Unknown widget action: $action');
      return;
  }

  if (targetScreen != null) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => targetScreen!),
    );
  }
}

class LuluApp extends StatelessWidget {
  const LuluApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Locale Provider
        ChangeNotifierProvider(
          create: (_) => LocaleProvider(),
        ),

        // Unit Preferences Provider
        ChangeNotifierProvider(
          create: (_) => UnitPreferencesProvider(),
        ),

        // Chat Provider
        ChangeNotifierProvider(
          create: (_) => ChatProvider(
            openAIService: OpenAIService(
              // OpenAI API 키를 환경변수에서 가져오거나 직접 입력
              // flutter run --dart-define=OPENAI_API_KEY=your_key
              apiKey: const String.fromEnvironment(
                'OPENAI_API_KEY',
                defaultValue: 'demo-mode', // 데모 모드
              ),
              model: 'gpt-4o-mini',
            ),
          ),
        ),

        // Sweet Spot Provider
        ChangeNotifierProvider(
          create: (_) => SweetSpotProvider(),
        ),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, child) {
          return MaterialApp(
            title: 'Lulu - AI Sleep Consultant',
            debugShowCheckedModeBanner: false,
            navigatorKey: navigatorKey, // Add global navigator key for widget deep linking

            // Localization
            locale: localeProvider.locale,
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [
              Locale('en', ''), // English
              Locale('ko', ''), // Korean
            ],

            // Theme - Midnight Blue (Default)
            theme: AppTheme.darkTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.dark,

            // iOS-style page transitions
            builder: (context, child) {
              return child ?? SizedBox.shrink();
            },

            // Home - AuthWrapper handles routing based on auth state
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}
