import 'package:flutter/material.dart';
import '../../../core/localization/app_localizations.dart';

/// Notification Center - Shows received notifications
class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Mock notification data
    final notifications = _getMockNotifications(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notifications),
        actions: [
          if (notifications.isNotEmpty)
            TextButton(
              onPressed: () {
                // Mark all as read
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.allNotificationsMarkedAsRead)),
                );
              },
              child: Text(l10n.markAllRead),
            ),
        ],
      ),
      body: notifications.isEmpty
          ? _buildEmptyState(context)
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return _buildNotificationItem(context, notification);
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noNotificationsYet,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.youllSeeSweetSpotAlerts,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(BuildContext context, NotificationItem item) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        backgroundColor: item.isRead
            ? Colors.grey[200]
            : item.iconBackgroundColor.withValues(alpha: 0.2),
        child: Icon(
          item.icon,
          color: item.isRead ? Colors.grey[500] : item.iconBackgroundColor,
          size: 24,
        ),
      ),
      title: Text(
        item.title,
        style: TextStyle(
          fontWeight: item.isRead ? FontWeight.normal : FontWeight.bold,
          fontSize: 15,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            item.body,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.timeAgo,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
      trailing: !item.isRead
          ? Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            )
          : null,
      onTap: () {
        // Mark as read - no snackbar needed
      },
    );
  }

  List<NotificationItem> _getMockNotifications(BuildContext context) {
    final locale = AppLocalizations.of(context).locale;
    final isKorean = locale.languageCode == 'ko';

    return [
      NotificationItem(
        icon: Icons.bedtime,
        iconBackgroundColor: Colors.purple,
        title: isKorean ? '🌙 스위트 스팟 알림' : '🌙 Sweet Spot Alert',
        body: isKorean
          ? '아기의 최적 수면 시간이 15분 후입니다. 지금 취침 루틴을 시작하세요!'
          : 'Your baby\'s optimal sleep time is in 15 minutes. Start the bedtime routine now!',
        timeAgo: isKorean ? '10분 전' : '10 minutes ago',
        isRead: false,
      ),
      NotificationItem(
        icon: Icons.tips_and_updates,
        iconBackgroundColor: Colors.orange,
        title: isKorean ? '💡 육아 팁' : '💡 Parenting Tip',
        body: isKorean
          ? '아시나요? 아기는 약간 시원한 방(20-22°C)에서 더 잘 잡니다.'
          : 'Did you know? Babies sleep better in a slightly cool room (68-72°F / 20-22°C).',
        timeAgo: isKorean ? '2시간 전' : '2 hours ago',
        isRead: false,
      ),
      NotificationItem(
        icon: Icons.bedtime,
        iconBackgroundColor: Colors.purple,
        title: isKorean ? '🌙 스위트 스팟 알림' : '🌙 Sweet Spot Alert',
        body: isKorean
          ? '오후 낮잠 시간입니다! 아기가 2.5시간 동안 깨어 있었습니다.'
          : 'Time for the afternoon nap! Your baby has been awake for 2.5 hours.',
        timeAgo: isKorean ? '5시간 전' : '5 hours ago',
        isRead: true,
      ),
      NotificationItem(
        icon: Icons.celebration,
        iconBackgroundColor: Colors.green,
        title: isKorean ? '🎉 잘하셨어요!' : '🎉 Great Job!',
        body: isKorean
          ? '7일 연속 기록하셨습니다! 아기의 수면 패턴이 더 명확해지고 있어요.'
          : 'You\'ve tracked 7 days in a row! Your baby\'s sleep pattern is becoming clearer.',
        timeAgo: isKorean ? '1일 전' : '1 day ago',
        isRead: true,
      ),
      NotificationItem(
        icon: Icons.update,
        iconBackgroundColor: Colors.blue,
        title: isKorean ? '🆕 새로운 기능' : '🆕 New Feature Available',
        body: isKorean
          ? '새로운 통계 탭에서 아기의 수면 트렌드를 확인해보세요!'
          : 'Check out the new Statistics tab to see your baby\'s sleep trends over time!',
        timeAgo: isKorean ? '2일 전' : '2 days ago',
        isRead: true,
      ),
      NotificationItem(
        icon: Icons.bedtime,
        iconBackgroundColor: Colors.purple,
        title: isKorean ? '🌙 스위트 스팟 알림' : '🌙 Sweet Spot Alert',
        body: isKorean
          ? '저녁 취침 시간이 15분 후입니다. 조명을 어둡게 하세요!'
          : 'Evening bedtime approaching in 15 minutes. Time to dim the lights!',
        timeAgo: isKorean ? '2일 전' : '2 days ago',
        isRead: true,
      ),
      NotificationItem(
        icon: Icons.insights,
        iconBackgroundColor: Colors.teal,
        title: isKorean ? '📊 주간 인사이트' : '📊 Weekly Insight',
        body: isKorean
          ? '이번 주 아기가 평균 12시간 30분 동안 잤습니다. 나이에 비해 아주 좋아요!'
          : 'Your baby slept 12h 30m on average this week. That\'s excellent for their age!',
        timeAgo: isKorean ? '3일 전' : '3 days ago',
        isRead: true,
      ),
    ];
  }
}

class NotificationItem {
  final IconData icon;
  final Color iconBackgroundColor;
  final String title;
  final String body;
  final String timeAgo;
  final bool isRead;

  NotificationItem({
    required this.icon,
    required this.iconBackgroundColor,
    required this.title,
    required this.body,
    required this.timeAgo,
    this.isRead = false,
  });
}
