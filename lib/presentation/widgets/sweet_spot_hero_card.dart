import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/utils/sweet_spot_calculator.dart';
import '../../data/services/daily_summary_service.dart';
import '../providers/home_data_provider.dart';
import '../providers/sweet_spot_provider.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import 'notification_toggle.dart';
import 'empty_sweet_spot_card.dart';  // 🆕 Empty State
import '../screens/activities/log_sleep_screen.dart';  // 🆕

/// 🌟 Sweet Spot Hero Card v2.0
/// - Today's Snapshot 통합
/// - 스마트 알림 통합
class SweetSpotHeroCard extends StatefulWidget {
  final String babyName;

  const SweetSpotHeroCard({
    Key? key,
    required this.babyName,
  }) : super(key: key);

  @override
  State<SweetSpotHeroCard> createState() => _SweetSpotHeroCardState();
}

class _SweetSpotHeroCardState extends State<SweetSpotHeroCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<SweetSpotProvider, HomeDataProvider>(
      builder: (context, sweetSpotProvider, homeDataProvider, child) {
        // SweetSpotProvider에서 Sweet Spot 데이터 가져오기 (우선순위)
        final sweetSpotFromProvider = sweetSpotProvider.currentSweetSpot;
        final sweetSpotFromHome = homeDataProvider.sweetSpot;
        final sweetSpot = sweetSpotFromProvider ?? sweetSpotFromHome;
        final dailySummary = homeDataProvider.dailySummary;
        final notificationState = homeDataProvider.notificationState;

        // 🆕 현재 아기 이름 가져오기 (동적으로 업데이트됨)
        final currentBabyName = sweetSpotProvider.currentBaby?.name ?? widget.babyName;

        print('🎨 [SweetSpotHeroCard] build() called');
        print('   sweetSpot: ${sweetSpot != null ? "EXISTS" : "NULL"}');
        print('   dailySummary: ${dailySummary != null ? "sleep=${dailySummary.totalSleepMinutes}min, feeding=${dailySummary.feedingCount}, diaper=${dailySummary.diaperCount}" : "NULL"}');
        print('   currentBabyName: $currentBabyName');

        // 🔧 Empty State 조건 단순화: 수면 기록이 없으면 바로 Empty State 표시
        final hasNoSleepData = dailySummary == null || dailySummary.totalSleepMinutes == 0;
        print('   hasNoSleepData: $hasNoSleepData');

        if (hasNoSleepData) {
          print('📭 [SweetSpotHeroCard] No sleep data - showing Empty State');
          return FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: EmptySweetSpotCard(
                babyName: currentBabyName,  // 🔧 동적 아기 이름 사용
                onRecordSleepTap: () {
                  // 수면 기록 화면으로 이동
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LogSleepScreen()),
                  );
                },
              ),
            ),
          );
        }

        if (sweetSpot == null) {
          return _buildEmptyState(context);
        }

        return _buildHeroCard(
          context,
          sweetSpot,
          dailySummary,
          notificationState,
          homeDataProvider,
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isKorean = l10n.locale.languageCode == 'ko';

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppTheme.surfaceCard,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: AppTheme.softBlue.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.lavenderMist.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.bedtime_outlined,
                  size: 48,
                  color: AppTheme.lavenderMist,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                isKorean ? '🌙 아기의 골든타임을 찾아요' : '🌙 Find Your Baby\'s Golden Time',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                isKorean
                    ? '기상 시간을 알려주시면,\n아기가 가장 쉽게 잠들 시간을 예측해드릴게요'
                    : 'Tell us when your baby woke up,\nand we\'ll predict the best sleep time',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textTertiary,
                      height: 1.5,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard(
    BuildContext context,
    SweetSpotResult sweetSpot,
    DailySummary? dailySummary,
    notificationState,
    HomeDataProvider provider,
  ) {
    final l10n = AppLocalizations.of(context);
    final isKorean = l10n.locale.languageCode == 'ko';
    final urgency = sweetSpot.urgencyLevel;
    final colorScheme = _getColorScheme(urgency);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          onTap: () => HapticFeedback.mediumImpact(),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primaryColor,
                  colorScheme.primaryColor.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primaryColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: Stack(
                children: [
                  // Subtle pattern overlay
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.05,
                      child: CustomPaint(
                        painter: _DotPatternPainter(),
                      ),
                    ),
                  ),

                  // Main content
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header: Status chip + Notification toggle
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildStatusChip(urgency, isKorean),
                            NotificationToggle(
                              state: notificationState,
                              onTap: () => _handleNotificationToggle(context, provider, l10n),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Main message
                        Text(
                          _getLocalizedMessage(sweetSpot, isKorean),
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                height: 1.3,
                              ),
                        ),

                        const SizedBox(height: 24),

                        // Time window display
                        _buildTimeWindow(context, sweetSpot, isKorean),

                        const SizedBox(height: 20),

                        // Progress bar
                        _buildProgressBar(context, sweetSpot, isKorean),

                        const SizedBox(height: 24),

                        // Stats row (Today's Snapshot 통합)
                        _buildExpandedStatsRow(context, sweetSpot, dailySummary, isKorean),

                        // Notification footer (조건부)
                        if (notificationState.isEnabled) ...[
                          const SizedBox(height: 16),
                          _buildNotificationFooter(context, notificationState, isKorean),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(UrgencyLevel urgency, bool isKorean) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(urgency.emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(
            _getUrgencyName(urgency, isKorean),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }

  String _getUrgencyName(UrgencyLevel urgency, bool isKorean) {
    switch (urgency) {
      case UrgencyLevel.tooEarly:
        return isKorean ? '너무 빨라요' : 'Too Early';
      case UrgencyLevel.approaching:
        return isKorean ? '곧 시작' : 'Approaching';
      case UrgencyLevel.optimal:
        return isKorean ? '지금이에요!' : 'Now!';
      case UrgencyLevel.overtired:
        return isKorean ? '놓쳤어요' : 'Overtired';
    }
  }

  String _getLocalizedMessage(SweetSpotResult sweetSpot, bool isKorean) {
    switch (sweetSpot.urgencyLevel) {
      case UrgencyLevel.tooEarly:
        return isKorean
            ? '아직 깨어있는 시간이에요! Sweet spot이 ${sweetSpot.minutesUntilSweetSpot}분 후에 시작됩니다.'
            : 'Still awake time! Sweet spot starts in ${sweetSpot.minutesUntilSweetSpot} minutes.';
      case UrgencyLevel.approaching:
        return isKorean ? '곧 Sweet Spot이에요! 수면 루틴을 준비하세요' : 'Sweet Spot approaching! Prepare the sleep routine';
      case UrgencyLevel.optimal:
        return isKorean ? '✨ 지금이 최적의 수면 시간이에요!' : '✨ Perfect time for a nap!';
      case UrgencyLevel.overtired:
        return isKorean ? '괜찮아요, 지금 재워볼까요? 🌙' : 'It\'s okay, let\'s try now 🌙';
    }
  }

  Widget _buildTimeWindow(BuildContext context, SweetSpotResult sweetSpot, bool isKorean) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.access_time_rounded, color: Colors.white.withOpacity(0.9), size: 22),
              const SizedBox(width: 10),
              Text(
                isKorean ? '스위트 스팟 시간대' : 'Sweet Spot Time',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            sweetSpot.getFormattedTimeRange(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getRemainingTimeText(sweetSpot, isKorean),
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _getRemainingTimeText(SweetSpotResult sweetSpot, bool isKorean) {
    // Use average of min and max for optimal wake window
    final optimalMinutes = ((sweetSpot.wakeWindowData.minMinutes + sweetSpot.wakeWindowData.maxMinutes) / 2).round();

    if (sweetSpot.isActive) {
      final remaining = sweetSpot.minutesUntilSweetSpotEnd;
      return isKorean ? '깨어있는 시간: ${optimalMinutes ~/ 60}h ${optimalMinutes % 60}m - ${remaining}분 남음'
          : 'Awake time: ${optimalMinutes ~/ 60}h ${optimalMinutes % 60}m - $remaining min left';
    } else if (sweetSpot.minutesUntilSweetSpot > 0) {
      final hours = sweetSpot.minutesUntilSweetSpot ~/ 60;
      final mins = sweetSpot.minutesUntilSweetSpot % 60;
      return isKorean
          ? '깨어있는 시간: ${optimalMinutes ~/ 60}h ${optimalMinutes % 60}m - ${hours > 0 ? "$hours시간 " : ""}${mins}분 후'
          : 'Awake time: ${optimalMinutes ~/ 60}h ${optimalMinutes % 60}m - ${hours > 0 ? "${hours}h " : ""}${mins}m';
    } else {
      return isKorean ? '지금 재우세요' : 'Sleep now';
    }
  }

  Widget _buildProgressBar(BuildContext context, SweetSpotResult sweetSpot, bool isKorean) {
    final wakeWindow = ((sweetSpot.wakeWindowData.minMinutes + sweetSpot.wakeWindowData.maxMinutes) / 2).round();
    final elapsed = sweetSpot.minutesSinceWakeUp;
    final progress = (elapsed / wakeWindow).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isKorean ? '깨어있음: 5분' : 'Awake: 5min',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              isKorean ? '80분 후' : '80min later',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withOpacity(0.9)),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  /// 확장된 Stats Row (Today's Snapshot 통합)
  Widget _buildExpandedStatsRow(
    BuildContext context,
    SweetSpotResult sweetSpot,
    DailySummary? summary,
    bool isKorean,
  ) {
    // 수면 시간 (시간 단위)
    final sleepHours = summary != null && summary.totalSleepMinutes > 0
        ? (summary.totalSleepMinutes / 60).toStringAsFixed(1)
        : '--';

    // 수유 횟수
    final feedingCount = summary != null && summary.feedingCount > 0
        ? summary.feedingCount.toString()
        : '--';

    // 기저귀 횟수
    final diaperCount = summary != null && summary.diaperCount > 0
        ? summary.diaperCount.toString()
        : '--';

    // 패턴 안정성
    final patternStatus = _getPatternStatus(summary, isKorean);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(
            emoji: '💤',
            value: '${sleepHours}h',
            label: isKorean ? '총 수면' : 'Sleep',
          ),
          _buildStatDivider(),
          _buildStatItem(
            emoji: '🍼',
            value: '${feedingCount}${isKorean ? "회" : "x"}',
            label: isKorean ? '수유' : 'Feeds',
          ),
          _buildStatDivider(),
          _buildStatItem(
            emoji: '🧷',
            value: '${diaperCount}${isKorean ? "회" : "x"}',
            label: isKorean ? '기저귀' : 'Diapers',
          ),
          _buildStatDivider(),
          _buildStatItem(
            emoji: '📊',
            value: patternStatus,
            label: isKorean ? '패턴' : 'Pattern',
          ),
        ],
      ),
    );
  }

  String _getPatternStatus(DailySummary? summary, bool isKorean) {
    if (summary == null || summary.totalSleepMinutes == 0) return '--';

    // 간단한 패턴 안정성 판단
    if (summary.totalSleepMinutes >= 600) {
      // 10시간 이상
      return isKorean ? '안정' : 'Stable';
    } else if (summary.totalSleepMinutes >= 420) {
      // 7시간 이상
      return isKorean ? '보통' : 'Normal';
    } else {
      return isKorean ? '부족' : 'Low';
    }
  }

  Widget _buildStatItem({
    required String emoji,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.75),
              fontSize: 11,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 40,
      color: Colors.white.withOpacity(0.2),
    );
  }

  /// 알림 Footer
  Widget _buildNotificationFooter(BuildContext context, notificationState, bool isKorean) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              notificationState.getStatusMessage(isKorean: isKorean),
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleNotificationToggle(
    BuildContext context,
    HomeDataProvider provider,
    AppLocalizations l10n,
  ) async {
    final success = await provider.toggleNotification(
      babyName: widget.babyName,
      l10n: l10n,
    );

    if (!success && mounted) {
      // 권한 거부 시 안내
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.locale.languageCode == 'ko'
                ? '알림 권한이 필요합니다. 설정에서 허용해주세요.'
                : 'Notification permission required. Please allow in settings.',
          ),
        ),
      );
    }
  }

  _SweetSpotColorScheme _getColorScheme(UrgencyLevel urgency) {
    switch (urgency) {
      case UrgencyLevel.tooEarly:
        return _SweetSpotColorScheme(primaryColor: const Color(0xFF4A90E2)); // 파란색
      case UrgencyLevel.approaching:
        return _SweetSpotColorScheme(primaryColor: const Color(0xFFF5A623)); // 주황색
      case UrgencyLevel.optimal:
        return _SweetSpotColorScheme(primaryColor: const Color(0xFF7ED321)); // 녹색
      case UrgencyLevel.overtired:
        return _SweetSpotColorScheme(primaryColor: const Color(0xFFE87878)); // 빨간색
    }
  }
}

class _SweetSpotColorScheme {
  final Color primaryColor;
  _SweetSpotColorScheme({required this.primaryColor});
}

/// Subtle dot pattern painter for background
class _DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    const dotSize = 2.0;
    const spacing = 20.0;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotSize, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
