import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../providers/sweet_spot_provider.dart';
import '../../widgets/sweet_spot_gauge.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final sweetSpotProvider = Provider.of<SweetSpotProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(context, l10n),
              SizedBox(height: 24),

              // Daily Briefing - 2x2 Grid
              _buildDailyBriefing(context, l10n),
              SizedBox(height: 32),

              // Sweet Spot Gauge
              _buildSweetSpotSection(context, l10n, sweetSpotProvider),
              SizedBox(height: 32),

              // Recent Activities
              _buildRecentActivities(context, l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = l10n.translate('greeting_good_morning');
    } else if (hour < 18) {
      greeting = l10n.translate('greeting_good_afternoon');
    } else {
      greeting = l10n.translate('greeting_good_evening');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppTheme.textPrimary.withOpacity(0.7),
              ),
        ),
        SizedBox(height: 4),
        Text(
          l10n.translate('dashboard_title_babys_journey'),
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildDailyBriefing(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.translate('dashboard_section_daily_briefing'),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildBriefingCard(
                context,
                icon: Icons.bedtime,
                title: l10n.translate('briefing_card_title_sleep_score'),
                value: '85',
                subtitle: l10n.translate('briefing_card_subtitle_great'),
                color: AppTheme.successSoft,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildBriefingCard(
                context,
                icon: Icons.restaurant,
                title: l10n.translate('briefing_card_title_feeding'),
                value: '720ml',
                subtitle: l10n.translate('briefing_card_subtitle_today'),
                color: AppTheme.warningSoft,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildBriefingCard(
                context,
                icon: Icons.baby_changing_station,
                title: l10n.translate('briefing_card_title_diaper'),
                value: '6',
                subtitle: l10n.translate('briefing_card_subtitle_changes'),
                color: AppTheme.infoSoft,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildBriefingCard(
                context,
                icon: Icons.thermostat,
                title: l10n.translate('briefing_card_title_temperature'),
                value: '36.8°C',
                subtitle: l10n.translate('briefing_card_subtitle_normal'),
                color: AppTheme.successSoft,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBriefingCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSweetSpotSection(
    BuildContext context,
    AppLocalizations l10n,
    SweetSpotProvider provider,
  ) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              l10n.translate('dashboard_section_sweet_spot_timer'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 24),
            SweetSpotGauge(
              remainingMinutes: provider.remainingMinutes,
              totalMinutes: provider.totalMinutes,
            ),
            SizedBox(height: 16),
            Text(
              provider.statusMessage,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivities(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.translate('dashboard_section_recent_activities'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            TextButton(
              onPressed: () {},
              child: Text(l10n.translate('button_see_all')),
            ),
          ],
        ),
        SizedBox(height: 12),
        _buildActivityItem(
          context,
          icon: Icons.bedtime,
          title: l10n.translate('activity_title_nap_time'),
          time: '2 hours ago',
          subtitle: '1h 30m',
          color: AppTheme.successSoft,
        ),
        SizedBox(height: 8),
        _buildActivityItem(
          context,
          icon: Icons.restaurant,
          title: l10n.translate('activity_title_feeding'),
          time: '4 hours ago',
          subtitle: '180ml',
          color: AppTheme.warningSoft,
        ),
        SizedBox(height: 8),
        _buildActivityItem(
          context,
          icon: Icons.baby_changing_station,
          title: l10n.translate('activity_title_diaper_change'),
          time: '5 hours ago',
          subtitle: l10n.translate('activity_subtitle_wet_diaper'),
          color: AppTheme.infoSoft,
        ),
      ],
    );
  }

  Widget _buildActivityItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String time,
    required String subtitle,
    required Color color,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Text(
          time,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
  }
}
