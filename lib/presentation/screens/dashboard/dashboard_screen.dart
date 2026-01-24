import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../sleep/sleep_tracking_screen.dart';
import '../ai_chat/ai_chat_screen.dart';
import '../records/records_screen.dart';

/// 대시보드 화면
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dashboard ?? 'Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Navigate to notifications
            },
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Welcome Card
          Card(
            color: AppTheme.primaryLight.withOpacity(0.3),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.welcomeBack ?? 'Welcome back!',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  SizedBox(height: 8),
                  Text(
                    l10n.todayOverview ?? "Today's Overview",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 24),

          // Quick Stats
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  icon: Icons.nightlight,
                  label: l10n.totalSleep ?? 'Total Sleep',
                  value: '9h 30m',
                  color: AppTheme.sleepColor,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  icon: Icons.restaurant,
                  label: l10n.totalFeedings ?? 'Total Feedings',
                  value: '8',
                  color: AppTheme.feedingColor,
                ),
              ),
            ],
          ),

          SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  icon: Icons.baby_changing_station,
                  label: l10n.totalDiapers ?? 'Total Diapers',
                  value: '6',
                  color: AppTheme.diaperColor,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  icon: Icons.mood,
                  label: l10n.translate('mood'),
                  value: 'Happy',
                  color: AppTheme.softBlue,
                ),
              ),
            ],
          ),

          SizedBox(height: 24),

          // Quick Actions
          Text(
            l10n.quickActions ?? 'Quick Actions',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  context,
                  icon: Icons.nightlight,
                  label: l10n.logSleep ?? 'Log Sleep',
                  color: AppTheme.sleepColor,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SleepTrackingScreen(),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  context,
                  icon: Icons.restaurant,
                  label: l10n.logFeeding ?? 'Log Feeding',
                  color: AppTheme.feedingColor,
                  onTap: () {
                    // TODO: Navigate to feeding form
                  },
                ),
              ),
            ],
          ),

          SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  context,
                  icon: Icons.baby_changing_station,
                  label: l10n.logDiaper ?? 'Log Diaper',
                  color: AppTheme.diaperColor,
                  onTap: () {
                    // TODO: Navigate to diaper form
                  },
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  context,
                  icon: Icons.chat,
                  label: l10n.askAI ?? 'Ask AI',
                  color: AppTheme.aiColor,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AiChatScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          SizedBox(height: 24),

          // Recent Activities
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.recentActivities ?? 'Recent Activities',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              TextButton(
                onPressed: () {
                  // Navigate to records tab
                  DefaultTabController.of(context)?.animateTo(1);
                },
                child: Text(l10n.translate('view_all')),
              ),
            ],
          ),
          SizedBox(height: 12),

          // Activity List
          _buildActivityItem(
            context,
            icon: Icons.nightlight,
            title: l10n.translate('night_sleep'),
            time: '2 hours ago',
            duration: '7h 30m',
            color: AppTheme.sleepColor,
          ),
          SizedBox(height: 8),
          _buildActivityItem(
            context,
            icon: Icons.restaurant,
            title: l10n.translate('bottle_feeding'),
            time: '4 hours ago',
            duration: '120 ml',
            color: AppTheme.feedingColor,
          ),
          SizedBox(height: 8),
          _buildActivityItem(
            context,
            icon: Icons.baby_changing_station,
            title: l10n.translate('diaper_change'),
            time: '5 hours ago',
            duration: 'Wet',
            color: AppTheme.diaperColor,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      color: color.withOpacity(0.15),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      color: color.withOpacity(0.15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String time,
    required String duration,
    required Color color,
  }) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(title),
        subtitle: Text(time),
        trailing: Text(
          duration,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ),
    );
  }
}
