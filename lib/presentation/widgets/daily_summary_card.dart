import 'package:flutter/material.dart';
import '../../core/localization/app_localizations.dart';
import '../../data/services/daily_summary_service.dart';
import '../screens/main/main_navigation.dart';

/// Daily Summary Card showing today's statistics
class DailySummaryCard extends StatelessWidget {
  const DailySummaryCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const userId = 'demo-user';

    return FutureBuilder<DailySummary>(
      future: _fetchSummary(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingCard();
        }

        if (snapshot.hasError || !snapshot.hasData) {
          // Show empty state if error or no data
          return _buildSummaryCard(context, DailySummary.empty());
        }

        final summary = snapshot.data!;
        return _buildSummaryCard(context, summary);
      },
    );
  }

  Future<DailySummary> _fetchSummary(String userId) async {
    try {
      return await DailySummaryService().getTodaysSummary(userId);
    } catch (e) {
      // Return empty summary on any error (including Firebase initialization)
      return DailySummary.empty();
    }
  }

  Widget _buildLoadingCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 1,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          height: 50,
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, DailySummary summary) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 1,
        child: InkWell(
          onTap: () {
            // Switch to Statistics tab (index 4)
            final mainNavState = MainNavigation.of(context);
            mainNavState?.switchToTab(4);
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Title
                Text(
                  l10n.translate('summary_label_today'),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(width: 16),

                // Sleep stat
                _buildCompactStat(
                  context,
                  icon: Icons.bedtime,
                  iconColor: Colors.purple,
                  value: summary.sleepFormatted,
                  trend: summary.sleepTrend,
                ),
                const SizedBox(width: 12),

                // Feeding stat
                _buildCompactStat(
                  context,
                  icon: Icons.restaurant,
                  iconColor: Colors.orange,
                  value: summary.feedingFormatted,
                  trend: summary.feedingTrend,
                ),
                const SizedBox(width: 12),

                // Diaper stat
                _buildCompactStat(
                  context,
                  icon: Icons.baby_changing_station,
                  iconColor: Colors.green,
                  value: '${summary.diaperCount}x',
                  trend: summary.diaperTrend,
                ),

                const Spacer(),

                // Arrow
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactStat(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String value,
    required Trend? trend,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        if (trend != null) ...[
          const SizedBox(width: 2),
          _buildTrendIcon(trend),
        ],
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required Trend? trend,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
              if (trend != null) _buildTrendIcon(trend),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[900],
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendIcon(Trend trend) {
    IconData icon;
    Color color;

    switch (trend) {
      case Trend.up:
        icon = Icons.arrow_upward;
        color = Colors.green;
        break;
      case Trend.down:
        icon = Icons.arrow_downward;
        color = Colors.red;
        break;
      case Trend.stable:
        icon = Icons.remove;
        color = Colors.grey;
        break;
    }

    return Icon(
      icon,
      size: 16,
      color: color,
    );
  }
}
