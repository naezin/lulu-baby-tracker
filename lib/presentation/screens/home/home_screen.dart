import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/wake_window_calculator.dart';
import '../../../core/utils/feeding_interval_calculator.dart';
import '../../../data/services/local_storage_service.dart';
import '../../../data/models/activity_model.dart';
import '../../../data/models/baby_model.dart';
import '../../widgets/sweet_spot_hero_card.dart';
import '../../widgets/quick_log_bar.dart';
import '../../widgets/home_header.dart';
import '../../providers/sweet_spot_provider.dart';
import '../../providers/home_data_provider.dart';
import '../../providers/smart_coach_provider.dart';
import '../../providers/baby_provider.dart';
import '../../providers/feed_sleep_provider.dart';
import '../../providers/ongoing_sleep_provider.dart';  // 🆕
import '../../widgets/smart_coach/today_timeline_section.dart';
import '../activities/log_sleep_screen.dart';
import '../activities/log_feeding_screen.dart';
import '../activities/log_diaper_screen.dart';
import '../activities/log_play_screen.dart';
import '../activities/log_health_screen.dart';
import '../records/records_screen.dart';
import '../records/activity_detail_screen.dart';
import '../settings/settings_screen.dart';
import '../settings/notification_settings_screen.dart';
import '../profile/baby_profile_screen.dart';
import '../../../data/services/widget_service.dart';

/// 🏠 Home Screen - Huckleberry + BabyTime Inspired Dashboard
/// Features: Sweet Spot prediction, Quick Log, Baby context (72 days, 2.46kg)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final _storage = LocalStorageService();
  final _widgetService = WidgetService();

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();

    // 🆕 Load Baby info and Sweet Spot data on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSweetSpotData();

      // 🆕 Restore ongoing sleep from storage
      final ongoingSleepProvider = context.read<OngoingSleepProvider>();
      ongoingSleepProvider.restoreOngoingSleep();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    // 🆕 v2.1 - Stop countdown timer
    final sweetSpotProvider = context.read<SweetSpotProvider>();
    sweetSpotProvider.stopCountdownTimer();
    super.dispose();
  }

  /// Load Baby info and last sleep activity for Sweet Spot calculation
  Future<void> _loadSweetSpotData() async {
    final babyProvider = Provider.of<BabyProvider>(context, listen: false);
    final sweetSpotProvider = Provider.of<SweetSpotProvider>(context, listen: false);
    final homeDataProvider = Provider.of<HomeDataProvider>(context, listen: false);
    final smartCoachProvider = Provider.of<SmartCoachProvider>(context, listen: false);
    final feedSleepProvider = Provider.of<FeedSleepProvider>(context, listen: false);
    final l10n = AppLocalizations.of(context);
    final isKorean = l10n.locale.languageCode == 'ko';

    // 1. Load baby info via BabyProvider
    if (!babyProvider.hasBaby) {
      await babyProvider.loadBabies('anonymous');  // 🔧 userId 추가 (임시)

      // 아직도 아기 데이터가 없으면 로컬 스토리지에서 직접 로드
      if (!babyProvider.hasBaby) {
        final localBaby = await _storage.getBaby();
        if (localBaby != null) {
          babyProvider.setCurrentBaby(localBaby);
          print('✅ [HomeScreen] Baby loaded from local storage: ${localBaby.name}');
        } else {
          print('⚠️ [HomeScreen] No baby data found');
          return;
        }
      }
    }

    final baby = babyProvider.currentBaby;
    if (baby == null) {
      print('⚠️ [HomeScreen] No baby data found');
      return;
    }
    print('✅ [HomeScreen] Baby loaded: ${baby.name}, ${baby.correctedAgeInMonths} months');

    // 2. Load last sleep activity (필터: 현재 아기만)
    final activities = await _storage.getActivities();
    final currentBabyId = baby.id;

    final sleepActivities = activities
        .where((a) =>
            a.babyId == currentBabyId &&  // 🚨 현재 아기만!
            a.type == ActivityType.sleep &&
            a.endTime != null)
        .toList();

    DateTime? lastWakeTime;
    DateTime? lastFeedingTime;

    if (sleepActivities.isNotEmpty) {
      // Sort by timestamp descending to get most recent
      sleepActivities.sort((a, b) {
        return b.timestamp.compareTo(a.timestamp);
      });

      final endTimeStr = sleepActivities.first.endTime;
      lastWakeTime = endTimeStr != null ? DateTime.parse(endTimeStr) : DateTime.parse(sleepActivities.first.timestamp);
      print('✅ [HomeScreen] Last wake time loaded: $lastWakeTime (baby: $currentBabyId)');
    } else {
      print('⚠️ [HomeScreen] No sleep records found for baby $currentBabyId, using default wake time');
    }

    // Load last feeding activity (필터: 현재 아기만)
    final feedingActivities = activities
        .where((a) =>
            a.babyId == currentBabyId &&  // 🚨 현재 아기만!
            a.type == ActivityType.feeding)
        .toList();
    if (feedingActivities.isNotEmpty) {
      feedingActivities.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      lastFeedingTime = DateTime.parse(feedingActivities.first.timestamp);
      print('✅ [HomeScreen] Last feeding time loaded: $lastFeedingTime (baby: $currentBabyId)');
    }

    // 3. Initialize SweetSpotProvider with new initialize method
    await sweetSpotProvider.initialize(
      baby: baby,
      lastWakeUpTime: lastWakeTime,
    );
    print('✅ [HomeScreen] SweetSpotProvider initialized');

    // 🆕 v2.1 - Start countdown timer
    sweetSpotProvider.startCountdownTimer();
    print('✅ [HomeScreen] Countdown timer started');

    // 4. Initialize HomeDataProvider
    homeDataProvider.setupBabyListener(baby.id);  // 🆕 Setup listener with initial baby ID
    await homeDataProvider.loadAll(
      babyId: baby.id,
      babyName: baby.name,
      lastWakeUpTime: lastWakeTime ?? DateTime.now().subtract(const Duration(hours: 1)),
      ageInMonths: baby.correctedAgeInMonths,
      l10n: l10n,
    );
    print('✅ [HomeScreen] HomeDataProvider initialized');

    // 5. Initialize SmartCoachProvider
    await smartCoachProvider.loadTimeline(
      userId: baby.id,
      babyName: baby.name,
      ageInMonths: baby.correctedAgeInMonths,
      lastWakeUpTime: lastWakeTime,
      lastFeedingTime: lastFeedingTime,
      isKorean: isKorean,
    );
    print('✅ [HomeScreen] SmartCoachProvider initialized');

    // 6. 🌙 Initialize FeedSleepProvider (막수-밤잠 상관관계 분석)
    if (!feedSleepProvider.hasData) {
      await feedSleepProvider.analyze(babyId: baby.id);
      print('✅ [HomeScreen] FeedSleepProvider initialized - hasData: ${feedSleepProvider.hasData}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppTheme.surfaceDark,
      body: Stack(
        children: [
          // Main scrollable content
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // App Bar
              _buildAppBar(context, l10n),

              // Content
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),

                      // Sweet Spot Hero Card v2.0 (Huckleberry-style)
                      FutureBuilder<BabyModel?>(
                        future: _storage.getBaby(),
                        builder: (context, snapshot) {
                          final babyName = snapshot.data?.name ?? 'Baby';
                          return SweetSpotHeroCard(babyName: babyName);
                        },
                      ),

                      const SizedBox(height: 16),

                      // 🆕 오늘의 타임라인 섹션 (스마트 코치)
                      TodayTimelineSection(
                        onSeeAllTap: () => _navigateToFullTimeline(context),
                        onAskCoachTap: () => _navigateToChat(context),
                      ),

                      // Bottom padding for Quick Log Bar
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Quick Log Bar (BabyTime-style, fixed at bottom)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: QuickLogBar(
              onQuickLog: (activityType) => _handleQuickLog(context, activityType),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, AppLocalizations l10n) {
    return SliverAppBar(
      expandedHeight: 70,
      floating: true,
      snap: true,
      backgroundColor: AppTheme.surfaceDark,
      elevation: 0,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      flexibleSpace: const FlexibleSpaceBar(
        titlePadding: EdgeInsets.only(left: 16, bottom: 16, right: 16),
        title: HomeHeader(),
      ),
      actions: const [],
    );
  }

  Widget _buildBabyContextCard(BuildContext context, AppLocalizations l10n) {
    final storage = LocalStorageService();

    return FutureBuilder<BabyModel?>(
      future: storage.getBaby(),
      builder: (context, snapshot) {
        String babyName = 'Baby';
        DateTime birthDate = DateTime(2025, 11, 11);
        double? birthWeight;
        bool isPremature = false;

        if (snapshot.hasData && snapshot.data != null) {
          final baby = snapshot.data!;
          babyName = baby.name;
          birthDate = DateTime.parse(baby.birthDate);
          birthWeight = baby.birthWeightKg;
          isPremature = baby.isPremature;
        }

        final ageInDays = DateTime.now().difference(birthDate).inDays;
        final weightText = birthWeight != null ? '${birthWeight}kg at birth' : '';

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.lavenderMist.withOpacity(0.15),
                AppTheme.lavenderMist.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.lavenderMist.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppTheme.lavenderMist.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    '👶',
                    style: TextStyle(fontSize: 28),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      babyName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      weightText.isNotEmpty
                          ? '$ageInDays days old • $weightText'
                          : '$ageInDays days old',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                    if (isPremature) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(
                            Icons.favorite,
                            size: 12,
                            color: AppTheme.errorSoft,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Premature baby care',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.textTertiary,
                                  fontSize: 11,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Growth indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.successSoft.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.trending_up_rounded,
                      size: 14,
                      color: AppTheme.successSoft,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Growing',
                      style: TextStyle(
                        color: AppTheme.successSoft,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTodaySummarySection(BuildContext context, AppLocalizations l10n) {
    final storage = LocalStorageService();

    // ✅ BabyProvider에서 현재 아기 정보 가져오기
    final babyProvider = Provider.of<BabyProvider>(context, listen: false);
    final baby = babyProvider.currentBaby;

    // ✅ 아기가 없으면 기본값 대신 Empty State 표시
    if (baby == null) {
      return _buildEmptyState(context, l10n);
    }

    // ✅ 실제 아기 나이 계산
    final birthDate = DateTime.parse(baby.birthDate);
    final ageInDays = DateTime.now().difference(birthDate).inDays;

    return FutureBuilder<Map<String, dynamic>>(
      future: _getPredictiveData(storage, ageInDays),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          // Show empty state while loading
          return _buildEmptyState(context, l10n);
        }

        final data = snapshot.data!;
        final sleepPrediction = data['sleep'] as WakeWindowPrediction?;
        final feedingPrediction = data['feeding'] as FeedingPrediction?;
        final activityProgress = data['activity'] as double?;
        final hasAnyData = data['hasData'] as bool;

        if (!hasAnyData) {
          return _buildEmptyState(context, l10n);
        }

        // Determine urgency and coaching message
        final isSleepUrgent = sleepPrediction?.isUrgent ?? false;
        final isFeedingUrgent = feedingPrediction?.isUrgent ?? false;

        String coachingMessage = l10n.translate('ai_coaching_all_good') ?? 'Everything looks good!';
        if (isSleepUrgent) {
          coachingMessage = l10n.translate('ai_coaching_sleepy') ?? 'Baby might be getting sleepy.';
        } else if (isFeedingUrgent) {
          coachingMessage = l10n.translate('ai_coaching_feeding_soon') ?? 'Feeding time approaching.';
        } else if (sleepPrediction != null && sleepPrediction.minutesUntilSweetSpot < 15) {
          coachingMessage = l10n.translate('ai_coaching_awake_too_long') ?? 'Watch for sleep cues.';
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.translate('today_summary') ?? 'Today\'s Summary',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildPredictiveSleepCard(
                      context,
                      l10n,
                      sleepPrediction,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildPredictiveFeedingCard(
                      context,
                      l10n,
                      feedingPrediction,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildPredictiveActivityCard(
                      context,
                      l10n,
                      activityProgress ?? 0.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildAICoachingBanner(context, l10n, coachingMessage, isSleepUrgent || isFeedingUrgent),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textTertiary,
              fontSize: 12,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildRecentActivitiesSection(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.locale.languageCode == 'ko' ? '최근 활동' : 'Recent Activities',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              TextButton(
                onPressed: () {
                  _triggerHaptic();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RecordsScreen()),
                  );
                },
                child: Text(
                  l10n.locale.languageCode == 'ko' ? '전체 보기' : 'View All',
                  style: const TextStyle(
                    color: AppTheme.lavenderGlow,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildActivityItem(
            icon: Icons.bedtime_rounded,
            color: AppTheme.lavenderMist,
            title: l10n.locale.languageCode == 'ko' ? '낮잠 종료' : 'Nap ended',
            time: '2:30 PM',
            duration: '1h 15m',
          ),
          const SizedBox(height: 12),
          _buildActivityItem(
            icon: Icons.restaurant_rounded,
            color: const Color(0xFFE8B87E),
            title: l10n.locale.languageCode == 'ko' ? '분유 수유' : 'Formula feeding',
            time: '12:45 PM',
            duration: '120ml',
          ),
          const SizedBox(height: 12),
          _buildActivityItem(
            icon: Icons.child_care_rounded,
            color: const Color(0xFF7BB8E8),
            title: l10n.locale.languageCode == 'ko' ? '기저귀 교체' : 'Diaper change',
            time: '11:20 AM',
            duration: l10n.locale.languageCode == 'ko' ? '소변' : 'Wet',
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required Color color,
    required String title,
    required String time,
    required String duration,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  duration,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                    letterSpacing: -0.1,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              color: AppTheme.textTertiary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting(AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    if (hour < 6) {
      return '🌙 Late night';
    } else if (hour < 12) {
      return '☀️ Good morning';
    } else if (hour < 18) {
      return '🌤️ Good afternoon';
    } else {
      return '🌆 Good evening';
    }
  }

  void _handleQuickLog(BuildContext context, String activityType) {
    HapticFeedback.mediumImpact();

    switch (activityType) {
      case 'sleep':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const LogSleepScreen(
              mode: SleepRecordMode.newRecord,
            ),
          ),
        );
        break;
      case 'feeding':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LogFeedingScreen()),
        );
        break;
      case 'diaper':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LogDiaperScreen()),
        );
        break;
      case 'play':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LogPlayScreen()),
        );
        break;
      case 'health':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LogHealthScreen()),
        );
        break;
    }
  }


  void _showSleepSuggestion(BuildContext context, AppLocalizations l10n) {
    // Show notification or alert that baby should sleep
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.bedtime_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.translate('awake_time_sleep_suggestion') ??
                    'Baby has been awake for too long. Consider putting them to sleep.',
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.errorSoft,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void _triggerHaptic() {
    HapticFeedback.lightImpact();
  }

  // Predictive Sleep Card with Next Sweet Spot
  Widget _buildPredictiveSleepCard(
    BuildContext context,
    AppLocalizations l10n,
    WakeWindowPrediction? prediction,
  ) {
    final isUrgent = prediction?.isUrgent ?? false;
    final timeStr = prediction != null
        ? '${prediction.nextSweetSpot.hour}:${prediction.nextSweetSpot.minute.toString().padLeft(2, '0')}'
        : '--:--';

    return GestureDetector(
      onTap: () {
        if (prediction != null) {
          _showSleepQuickAction(context, l10n, prediction);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUrgent ? AppTheme.lavenderMist : AppTheme.lavenderMist.withOpacity(0.3),
            width: isUrgent ? 2 : 1,
          ),
          boxShadow: isUrgent
              ? [
                  BoxShadow(
                    color: AppTheme.lavenderMist.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.bedtime_rounded, color: AppTheme.lavenderMist, size: 20),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isUrgent ? AppTheme.errorSoft : AppTheme.successSoft,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              prediction != null ? '${prediction.standardWakeWindow}m' : '--',
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              l10n.locale.languageCode == 'ko' ? '수면' : 'Sleep',
              style: const TextStyle(
                color: AppTheme.textTertiary,
                fontSize: 11,
                letterSpacing: -0.1,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.lavenderMist.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${l10n.translate('next_sweet_spot') ?? 'Next'} $timeStr',
                style: const TextStyle(
                  color: AppTheme.lavenderMist,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSleepQuickAction(BuildContext context, AppLocalizations l10n, WakeWindowPrediction prediction) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Icon(Icons.bedtime_rounded, color: AppTheme.lavenderMist, size: 48),
            const SizedBox(height: 16),
            Text(
              l10n.translate('sleep_prediction') ?? '수면 예측',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '${l10n.translate('next_sweet_spot') ?? 'Next Sweet Spot'}: ${prediction.nextSweetSpot.hour}:${prediction.nextSweetSpot.minute.toString().padLeft(2, '0')}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LogSleepScreen(
                      mode: SleepRecordMode.newRecord,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(l10n.translate('start_sleep_now') ?? '지금 수면 시작'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lavenderMist,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
          ],
        ),
      ),
    );
  }

  // Predictive Feeding Card with Countdown
  Widget _buildPredictiveFeedingCard(
    BuildContext context,
    AppLocalizations l10n,
    FeedingPrediction? prediction,
  ) {
    final isUrgent = prediction?.isUrgent ?? false;
    final minutesUntilFeed = prediction?.minutesUntilFeeding ?? 0;

    String feedingText;
    if (prediction == null) {
      feedingText = '--';
    } else if (minutesUntilFeed < 0) {
      feedingText = l10n.translate('feeding_overdue') ?? 'Overdue';
    } else if (minutesUntilFeed < 60) {
      feedingText = '${l10n.translate('next_feeding_in') ?? 'In'} ${minutesUntilFeed}m';
    } else {
      final hours = minutesUntilFeed ~/ 60;
      final mins = minutesUntilFeed % 60;
      feedingText = '${l10n.translate('next_feeding_in') ?? 'In'} ${hours}h ${mins}m';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUrgent ? const Color(0xFFE8B87E) : const Color(0xFFE8B87E).withOpacity(0.3),
          width: isUrgent ? 2 : 1,
        ),
        boxShadow: isUrgent ? [
          BoxShadow(
            color: const Color(0xFFE8B87E).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ] : null,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.restaurant_rounded, color: Color(0xFFE8B87E), size: 20),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isUrgent ? const Color(0xFFFFB74D) : AppTheme.successSoft,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '6',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            l10n.locale.languageCode == 'ko' ? '수유' : 'Feeds',
            style: const TextStyle(
              color: AppTheme.textTertiary,
              fontSize: 11,
              letterSpacing: -0.1,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE8B87E).withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              feedingText,
              style: const TextStyle(
                color: Color(0xFFE8B87E),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // Predictive Activity Card with Progress
  Widget _buildPredictiveActivityCard(
    BuildContext context,
    AppLocalizations l10n,
    double progress,
  ) {
    final tummyTimeProgress = progress;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF5FB37B).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.toys_outlined, color: Color(0xFF5FB37B), size: 20),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppTheme.successSoft,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '50%',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            l10n.locale.languageCode == 'ko' ? '활동 목표' : 'Activity',
            style: const TextStyle(
              color: AppTheme.textTertiary,
              fontSize: 11,
              letterSpacing: -0.1,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: tummyTimeProgress,
              backgroundColor: AppTheme.surfaceElevated,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF5FB37B)),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  // AI Coaching Banner
  Widget _buildAICoachingBanner(BuildContext context, AppLocalizations l10n, String message, bool isUrgent) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            (isUrgent ? AppTheme.warningSoft : AppTheme.lavenderMist).withOpacity(0.15),
            (isUrgent ? AppTheme.warningSoft : AppTheme.lavenderMist).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isUrgent ? AppTheme.warningSoft : AppTheme.lavenderMist).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (isUrgent ? AppTheme.warningSoft : AppTheme.lavenderMist).withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isUrgent ? Icons.lightbulb : Icons.auto_awesome,
              color: isUrgent ? AppTheme.warningSoft : AppTheme.lavenderMist,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Get predictive data from storage
  Future<Map<String, dynamic>> _getPredictiveData(LocalStorageService storage, int ageInDays) async {
    try {
      // 현재 아기 ID 가져오기
      final babyProvider = Provider.of<BabyProvider>(context, listen: false);
      final currentBaby = babyProvider.currentBaby;

      if (currentBaby == null) {
        return {
          'sleep': null,
          'feeding': null,
          'activity': 0.0,
          'hasData': false,
        };
      }

      final currentBabyId = currentBaby.id;

      // Get last wake up time (filtered by babyId)
      final allActivities = await storage.getActivities();
      final sleepActivities = allActivities
          .where((a) =>
              a.babyId == currentBabyId &&  // 🚨 필터링!
              a.type == ActivityType.sleep &&
              a.endTime != null)
          .toList();

      DateTime? lastWakeTime;
      if (sleepActivities.isNotEmpty) {
        sleepActivities.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        final endTimeStr = sleepActivities.first.endTime;
        lastWakeTime = endTimeStr != null
            ? DateTime.parse(endTimeStr)
            : DateTime.parse(sleepActivities.first.timestamp);
      }

      // Get last feeding (filtered by babyId)
      final feedingActivities = allActivities
          .where((a) =>
              a.babyId == currentBabyId &&  // 🚨 필터링!
              a.type == ActivityType.feeding)
          .toList();
      feedingActivities.sort((a, b) =>
          DateTime.parse(b.timestamp).compareTo(DateTime.parse(a.timestamp)));

      // Get today's play activities (filtered by babyId)
      final playActivities = allActivities
          .where((a) =>
              a.babyId == currentBabyId &&  // 🚨 필터링!
              a.type == ActivityType.play)
          .toList();
      final todayPlay = playActivities.where((a) {
        final activityDate = DateTime.parse(a.timestamp);
        final today = DateTime.now();
        return activityDate.year == today.year &&
            activityDate.month == today.month &&
            activityDate.day == today.day;
      }).toList();

      // Calculate sleep prediction
      WakeWindowPrediction? sleepPrediction;
      if (lastWakeTime != null) {
        sleepPrediction = WakeWindowCalculator.calculateNextSleepTime(
          lastWakeTime: lastWakeTime,
          ageInDays: ageInDays,
        );
      }

      // Calculate feeding prediction
      FeedingPrediction? feedingPrediction;
      if (feedingActivities.isNotEmpty) {
        final lastFeeding = feedingActivities.first;
        final lastFeedTime = DateTime.parse(lastFeeding.timestamp);

        // ✅ Option B: calculateNextFeedingTime()을 통해 나이별 권장량 가져오기
        double amountMl;
        if (lastFeeding.amountMl != null) {
          amountMl = lastFeeding.amountMl!;
        } else {
          // amountMl이 null일 때만 예측값 사용 (나이별 권장량)
          final tempPrediction = FeedingIntervalCalculator.calculateNextFeedingTime(
            lastFeedingTime: lastFeedTime,
            lastFeedingAmountMl: 0, // null이면 0으로 전달
            ageInDays: ageInDays,
          );
          amountMl = tempPrediction.recommendedAmountMl; // ← 나이별 권장량!
        }

        feedingPrediction = FeedingIntervalCalculator.calculateNextFeedingTime(
          lastFeedingTime: lastFeedTime,
          lastFeedingAmountMl: amountMl,
          ageInDays: ageInDays,
        );
      }

      // Calculate activity progress (goal: 3 play sessions per day)
      final activityProgress = (todayPlay.length / 3.0).clamp(0.0, 1.0);

      final hasData = lastWakeTime != null || feedingActivities.isNotEmpty;

      return {
        'sleep': sleepPrediction,
        'feeding': feedingPrediction,
        'activity': activityProgress,
        'hasData': hasData,
      };
    } catch (e) {
      return {
        'sleep': null,
        'feeding': null,
        'activity': 0.0,
        'hasData': false,
      };
    }
  }

  // Empty state UI
  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.lavenderMist.withOpacity(0.1),
            AppTheme.lavenderGlow.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.lavenderMist.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.lavenderMist.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome,
              size: 40,
              color: AppTheme.lavenderMist,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.translate('first_record_prompt') ?? '아기의 첫 기록을 남겨주세요',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.translate('first_record_description') ??
                '수면, 수유, 활동을 기록하면\nAI가 아기의 패턴을 분석해드려요',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // Show quick log sheet
              _showQuickLogSheet(context, l10n);
            },
            icon: const Icon(Icons.add_rounded),
            label: Text(l10n.translate('start_first_record') ?? '첫 기록 시작하기'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lavenderMist,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Show quick log bottom sheet
  void _showQuickLogSheet(BuildContext context, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.translate('quick_log') ?? '빠른 기록',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            _buildQuickLogOption(
              context,
              l10n,
              Icons.bedtime_rounded,
              l10n.translate('log_sleep') ?? '수면',
              AppTheme.lavenderMist,
              () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LogSleepScreen(
                      mode: SleepRecordMode.newRecord,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildQuickLogOption(
              context,
              l10n,
              Icons.restaurant_rounded,
              l10n.translate('log_feeding') ?? '수유',
              const Color(0xFFE8B87E),
              () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LogFeedingScreen()),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildQuickLogOption(
              context,
              l10n,
              Icons.toys_rounded,
              l10n.translate('log_play') ?? '활동',
              const Color(0xFF5FB37B),
              () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LogPlayScreen()),
                );
              },
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickLogOption(
    BuildContext context,
    AppLocalizations l10n,
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  /// 🌙 "지금 재우기" - 즉시 수면 시작
  Future<void> _startSleepNow(BuildContext context) async {
    if (kDebugMode) {
      debugPrint('🌙 [HomeScreen] _startSleepNow() called');
    }
    HapticFeedback.mediumImpact();

    try {
      final babyProvider = Provider.of<BabyProvider>(context, listen: false);
      final ongoingSleepProvider = Provider.of<OngoingSleepProvider>(context, listen: false);
      final babyId = babyProvider.currentBaby?.id ?? 'unknown';
      final l10n = AppLocalizations.of(context);
      final isKorean = l10n.locale.languageCode == 'ko';

      if (kDebugMode) {
        debugPrint('📝 [HomeScreen] Starting sleep via OngoingSleepProvider...');
      }

      // OngoingSleepProvider를 통해 수면 시작
      await ongoingSleepProvider.startSleep(
        babyId: babyId,
        notes: isKorean ? 'Sweet Spot에서 시작' : 'Started from Sweet Spot',
      );

      if (kDebugMode) {
        debugPrint('✅ [HomeScreen] Sleep started successfully');
      }

      if (!mounted) {
        if (kDebugMode) {
          debugPrint('⚠️ [HomeScreen] Widget not mounted after starting sleep, exiting');
        }
        return;
      }

      // 위젯 업데이트
      if (kDebugMode) {
        debugPrint('📱 [HomeScreen] Updating widgets...');
      }
      await _widgetService.updateAllWidgets();

      HapticFeedback.heavyImpact();

      // 🆕 Undo Toast (4초 동안 취소 가능)
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Text('😴', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 12),
                Text(
                  isKorean ? '수면이 시작되었어요' : 'Sleep started',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: isKorean ? '취소' : 'Undo',
              textColor: Colors.amber,
              onPressed: () async {
                try {
                  if (kDebugMode) {
                    debugPrint('🔙 [HomeScreen] Undoing sleep...');
                  }
                  await ongoingSleepProvider.cancelSleep();
                  await _widgetService.updateAllWidgets();

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isKorean ? '수면 기록이 취소되었어요' : 'Sleep cancelled',
                        ),
                        duration: const Duration(seconds: 2),
                        backgroundColor: const Color(0xFF5A4A85),
                      ),
                    );
                  }

                  if (kDebugMode) {
                    debugPrint('✅ [HomeScreen] Sleep cancelled successfully');
                  }
                } catch (e) {
                  if (kDebugMode) {
                    debugPrint('❌ [HomeScreen] Failed to cancel sleep: $e');
                  }
                }
              },
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: const Color(0xFF2D3351),
            margin: const EdgeInsets.all(16),
          ),
        );
      }

      // 홈 화면 새로고침
      if (mounted) {
        if (kDebugMode) {
          debugPrint('🔄 [HomeScreen] Refreshing home screen...');
        }
        setState(() {});
      }

      if (kDebugMode) {
        debugPrint('🎉 [HomeScreen] _startSleepNow() completed successfully!');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [HomeScreen] Error in _startSleepNow(): $e');
        debugPrint('📍 [HomeScreen] Stack trace: $stackTrace');
      }

      if (!context.mounted) {
        if (kDebugMode) {
          debugPrint('⚠️ [HomeScreen] Context not mounted, cannot show error');
        }
        return;
      }

      final l10n = AppLocalizations.of(context);
      final isKorean = l10n.locale.languageCode == 'ko';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isKorean
              ? '수면 시작 중 오류가 발생했습니다'
              : 'Error starting sleep',
          ),
          backgroundColor: AppTheme.errorSoft,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  /// 챗봇으로 이동
  void _navigateToChat(BuildContext context) {
    Navigator.pushNamed(context, '/chat');
  }

  /// 전체 타임라인으로 이동 (향후 구현)
  void _navigateToFullTimeline(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('전체 타임라인 화면은 곧 출시됩니다!'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
