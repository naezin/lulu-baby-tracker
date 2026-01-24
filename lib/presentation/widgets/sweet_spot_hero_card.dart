import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/utils/sweet_spot_calculator.dart';
import '../providers/sweet_spot_provider.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_theme.dart';

/// 🌟 Sweet Spot Hero Card - Huckleberry-inspired
/// Prominently displays sleep prediction at dashboard center
class SweetSpotHeroCard extends StatefulWidget {
  const SweetSpotHeroCard({Key? key}) : super(key: key);

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
    return Consumer<SweetSpotProvider>(
      builder: (context, provider, child) {
        final sweetSpot = provider.currentSweetSpot;

        if (sweetSpot == null) {
          return _buildEmptyState(context);
        }

        return _buildHeroCard(context, sweetSpot);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
                l10n.translate('empty_state_track_sleep_sweet_spot'),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.textPrimary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.translate('empty_state_wake_up_hint_detailed'),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textTertiary,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context, SweetSpotResult sweetSpot) {
    final l10n = AppLocalizations.of(context)!;
    final urgency = sweetSpot.urgencyLevel;
    final colorScheme = _getColorScheme(urgency);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          onTap: () => _triggerHaptic(),
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
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status chip
                        _buildStatusChip(urgency),

                        const SizedBox(height: 24),

                        // Main message
                        Text(
                          sweetSpot.userFriendlyMessage,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                        ),

                        const SizedBox(height: 28),

                        // Time window display
                        _buildTimeWindow(context, sweetSpot, l10n),

                        const SizedBox(height: 24),

                        // Progress bar
                        _buildProgressBar(context, sweetSpot, l10n),

                        const SizedBox(height: 24),

                        // Stats row
                        _buildStatsRow(context, sweetSpot, l10n),
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

  Widget _buildStatusChip(UrgencyLevel urgency) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          Text(
            urgency.emoji,
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(width: 8),
          Text(
            urgency.displayName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeWindow(
      BuildContext context, SweetSpotResult sweetSpot, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
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
              Icon(
                Icons.access_time_rounded,
                color: Colors.white.withOpacity(0.9),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.translate('sweet_spot_title_window'),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            sweetSpot.getFormattedTimeRange(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: -1,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n
                .translate('sweet_spot_label_wake_window_value')
                .replaceAll('{range}', sweetSpot.wakeWindowData.displayRange),
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 13,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(
      BuildContext context, SweetSpotResult sweetSpot, AppLocalizations l10n) {
    final now = DateTime.now();
    final totalWindow =
        sweetSpot.sweetSpotEnd.difference(sweetSpot.lastWakeUpTime).inMinutes;
    final elapsed = now.difference(sweetSpot.lastWakeUpTime).inMinutes;
    final progress = (elapsed / totalWindow).clamp(0.0, 1.0);

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              Colors.white,
            ),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n
                  .translate('sweet_spot_progress_awake_minutes')
                  .replaceAll('{minutes}', '${sweetSpot.minutesSinceWakeUp}'),
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 13,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.1,
              ),
            ),
            if (!sweetSpot.isActive)
              Text(
                l10n
                    .translate('sweet_spot_progress_in_minutes')
                    .replaceAll('{minutes}', '${sweetSpot.minutesUntilSweetSpot}'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.1,
                ),
              )
            else
              Text(
                l10n
                    .translate('sweet_spot_progress_minutes_left')
                    .replaceAll(
                        '{minutes}', '${sweetSpot.minutesUntilSweetSpotEnd}'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.1,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsRow(
      BuildContext context, SweetSpotResult sweetSpot, AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(
          icon: Icons.child_care_rounded,
          label: l10n.translate('sweet_spot_info_age'),
          value: '${sweetSpot.ageInMonths}mo',
        ),
        Container(
          width: 1,
          height: 32,
          color: Colors.white.withOpacity(0.2),
        ),
        if (sweetSpot.napNumber != null)
          _buildStatItem(
            icon: Icons.hotel_rounded,
            label: l10n.translate('sweet_spot_info_nap'),
            value: '#${sweetSpot.napNumber}',
          ),
        if (sweetSpot.napNumber != null)
          Container(
            width: 1,
            height: 32,
            color: Colors.white.withOpacity(0.2),
          ),
        _buildStatItem(
          icon: Icons.repeat_rounded,
          label: l10n.translate('sweet_spot_info_daily_naps'),
          value: '${sweetSpot.wakeWindowData.recommendedNaps}',
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white.withOpacity(0.9),
          size: 20,
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 11,
            letterSpacing: -0.1,
          ),
        ),
      ],
    );
  }

  void _triggerHaptic() {
    HapticFeedback.mediumImpact();
  }

  _SweetSpotColorScheme _getColorScheme(UrgencyLevel urgency) {
    switch (urgency) {
      case UrgencyLevel.tooEarly:
        return _SweetSpotColorScheme(
          primaryColor: const Color(0xFF4A90E2),
        );
      case UrgencyLevel.approaching:
        return _SweetSpotColorScheme(
          primaryColor: const Color(0xFFF5A623),
        );
      case UrgencyLevel.optimal:
        return _SweetSpotColorScheme(
          primaryColor: const Color(0xFF7ED321),
        );
      case UrgencyLevel.overtired:
        return _SweetSpotColorScheme(
          primaryColor: const Color(0xFFE87878),
        );
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
