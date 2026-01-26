import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:home_widget/home_widget.dart';
import 'core/theme/app_theme.dart';
import 'core/localization/app_localizations.dart';
import 'core/utils/environment_validator.dart';
import 'data/services/openai_service.dart';
import 'data/services/widget_service.dart';
import 'data/services/local_storage_service.dart';
import 'domain/repositories/i_baby_repository.dart';
import 'presentation/providers/chat_provider.dart';
import 'presentation/providers/sweet_spot_provider.dart';
import 'presentation/providers/home_data_provider.dart';
import 'presentation/providers/smart_coach_provider.dart';
import 'presentation/providers/locale_provider.dart';
import 'presentation/providers/unit_preferences_provider.dart';
import 'presentation/providers/baby_provider.dart';
import 'presentation/providers/feed_sleep_provider.dart';
import 'presentation/screens/activities/log_feeding_screen.dart';
import 'presentation/screens/activities/log_sleep_screen.dart';
import 'presentation/screens/activities/log_diaper_screen.dart';
import 'presentation/screens/chat/chat_screen.dart';
import 'presentation/screens/baby/add_baby_screen.dart';  // 🆕
import 'presentation/widgets/auth_wrapper.dart';

// 🆕 Dependency Injection
import 'di/injection_container.dart' as di;

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

  // 🚀 Supabase 초기화 (환경변수 사용)
  if (EnvironmentValidator.hasSupabaseConfig) {
    try {
      await Supabase.initialize(
        url: EnvironmentValidator.supabaseUrl!,
        anonKey: EnvironmentValidator.supabaseAnonKey!,
        debug: !EnvironmentValidator.isProduction,
      );
      debugPrint('✅ Supabase initialized with environment variables');
    } catch (e) {
      debugPrint('⚠️ Supabase initialization failed: $e');
    }
  } else {
    debugPrint('⚠️ Supabase 설정이 없습니다. 로컬 모드로 실행됩니다.');
    debugPrint('   Supabase를 사용하려면 다음 환경변수를 설정하세요:');
    debugPrint('   SUPABASE_URL, SUPABASE_ANON_KEY');
  }

  // 🆕 의존성 주입 초기화
  // 여기서 BackendType만 변경하면 전체 앱의 백엔드가 변경됩니다!
  try {
    await di.initDependencies(
      backend: di.BackendType.supabase, // ✅ Supabase로 전환 (빌드 성능 40% 개선)
    );
  } catch (e) {
    debugPrint('⚠️ DI initialization: $e');
  }

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
/// Supports both legacy format ('sleep') and URL scheme format ('lulu://log-sleep')
void _handleWidgetAction(String action) {
  final context = navigatorKey.currentContext;
  if (context == null) return;

  debugPrint('🔗 [DeepLink] Received action: $action');

  Widget? targetScreen;
  String normalizedAction = action;

  // Parse URL scheme format (lulu://log-wake, lulu://log-sleep)
  if (action.startsWith('lulu://')) {
    final uri = Uri.parse(action);
    normalizedAction = uri.host; // Extract 'log-wake', 'log-sleep', etc.
    debugPrint('🔗 [DeepLink] Normalized action: $normalizedAction');
  }

  // Route to appropriate screen
  switch (normalizedAction) {
    case 'log-wake':
      // Navigate to home screen (wake time is typically logged from home)
      debugPrint('🔗 [DeepLink] Opening app for wake time logging');
      return; // Just open app, user can log from home screen

    case 'log-sleep':
    case 'sleep':
      targetScreen = const LogSleepScreen();
      debugPrint('🔗 [DeepLink] Navigating to LogSleepScreen');
      break;

    case 'feeding':
      targetScreen = const LogFeedingScreen();
      debugPrint('🔗 [DeepLink] Navigating to LogFeedingScreen');
      break;

    case 'diaper':
      targetScreen = const LogDiaperScreen();
      debugPrint('🔗 [DeepLink] Navigating to LogDiaperScreen');
      break;

    case 'open_app':
      // Just open the app, no navigation needed
      debugPrint('🔗 [DeepLink] Opening app');
      return;

    default:
      debugPrint('⚠️ [DeepLink] Unknown widget action: $action');
      return;
  }

  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => targetScreen!),
  );
}

class LuluApp extends StatelessWidget {
  const LuluApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Baby Provider (먼저 등록 - 다른 Provider가 의존)
        ChangeNotifierProvider(
          create: (_) => BabyProvider(
            babyRepository: di.sl<IBabyRepository>(),
            localStorage: di.sl<LocalStorageService>(),
            widgetService: WidgetService(),
          ),
        ),

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

        // 🆕 Home Data Provider (v2.0)
        ChangeNotifierProvider(
          create: (_) => HomeDataProvider(),
        ),

        // 🆕 Smart Coach Provider (스마트 코치 시스템)
        ChangeNotifierProvider(
          create: (_) => SmartCoachProvider(),
        ),

        // Feed-Sleep Correlation Provider
        ChangeNotifierProvider(
          create: (_) => FeedSleepProvider(),
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
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''), // English
              Locale('ko', ''), // Korean
            ],

            // Theme - Midnight Blue (Default)
            theme: AppTheme.darkTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.dark,

            // iOS-style page transitions
            builder: (context, child) {
              return child ?? const SizedBox.shrink();
            },

            // Routes
            routes: {
              '/chat': (context) => const ChatScreen(),
              '/add-baby': (context) => const AddBabyScreen(),  // 🆕
            },

            // Home - AuthWrapper handles routing based on auth state
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}
