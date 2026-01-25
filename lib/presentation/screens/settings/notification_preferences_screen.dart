import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/notification_service.dart';
import '../../../data/services/local_storage_service.dart';

/// 알림 환경설정 화면
///
/// 기능:
/// - Sweet Spot 알림 On/Off
/// - 수유 알림 On/Off + 간격 설정 (2-4시간)
/// - 기저귀 알림 On/Off + 간격 설정 (2-4시간)
/// - 설정값 SharedPreferences 저장
class NotificationPreferencesScreen extends StatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  State<NotificationPreferencesScreen> createState() =>
      _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState
    extends State<NotificationPreferencesScreen> {
  final _notificationService = NotificationService();
  final _storage = LocalStorageService();

  // 알림 활성화 상태
  bool _sweetSpotEnabled = true;
  bool _feedingEnabled = false;
  bool _diaperEnabled = false;

  // 알림 간격 (시간)
  int _feedingInterval = 3;
  int _diaperInterval = 3;

  bool _isLoading = true;
  String _babyName = '아기';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);

    // 베이비 정보 로드
    final baby = await _storage.getBaby();
    if (baby != null) {
      _babyName = baby.name;
    }

    // SharedPreferences에서 설정 로드
    final prefs = await SharedPreferences.getInstance();
    _sweetSpotEnabled = prefs.getBool('notification_sweetspot_enabled') ?? true;
    _feedingEnabled = prefs.getBool('notification_feeding_enabled') ?? false;
    _diaperEnabled = prefs.getBool('notification_diaper_enabled') ?? false;
    _feedingInterval = prefs.getInt('notification_feeding_interval') ?? 3;
    _diaperInterval = prefs.getInt('notification_diaper_interval') ?? 3;

    setState(() => _isLoading = false);
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notification_sweetspot_enabled', _sweetSpotEnabled);
    await prefs.setBool('notification_feeding_enabled', _feedingEnabled);
    await prefs.setBool('notification_diaper_enabled', _diaperEnabled);
    await prefs.setInt('notification_feeding_interval', _feedingInterval);
    await prefs.setInt('notification_diaper_interval', _diaperInterval);
  }

  Future<void> _toggleSweetSpot(bool value) async {
    HapticFeedback.lightImpact();
    setState(() => _sweetSpotEnabled = value);

    if (!value) {
      // Sweet Spot 알림 취소
      await _notificationService.cancelAllNotifications();
    } else {
      // TODO: Sweet Spot 재설정 (SweetSpotProvider와 연동 필요)
    }

    await _saveSettings();
    _showSnackbar('Sweet Spot 알림이 ${value ? "활성화" : "비활성화"}되었습니다');
  }

  Future<void> _toggleFeeding(bool value) async {
    HapticFeedback.lightImpact();
    setState(() => _feedingEnabled = value);

    if (!value) {
      await _notificationService.cancelFeedingReminders();
    } else {
      // 수유 알림 스케줄링
      final l10n = AppLocalizations.of(context);
      await _notificationService.scheduleFeedingReminders(
        intervalHours: _feedingInterval,
        babyName: _babyName,
        l10n: l10n,
        startFromNow: true,
      );
    }

    await _saveSettings();
    _showSnackbar('수유 알림이 ${value ? "활성화" : "비활성화"}되었습니다');
  }

  Future<void> _toggleDiaper(bool value) async {
    HapticFeedback.lightImpact();
    setState(() => _diaperEnabled = value);

    if (!value) {
      await _notificationService.cancelDiaperReminders();
    } else {
      // 기저귀 알림 스케줄링
      final l10n = AppLocalizations.of(context);
      await _notificationService.scheduleDiaperReminders(
        intervalHours: _diaperInterval,
        babyName: _babyName,
        l10n: l10n,
        startFromNow: true,
      );
    }

    await _saveSettings();
    _showSnackbar('기저귀 알림이 ${value ? "활성화" : "비활성화"}되었습니다');
  }

  Future<void> _changeFeedingInterval(int? newInterval) async {
    if (newInterval == null) return;

    HapticFeedback.lightImpact();
    setState(() => _feedingInterval = newInterval);
    await _saveSettings();

    // 알림이 활성화되어 있으면 재설정
    if (_feedingEnabled) {
      final l10n = AppLocalizations.of(context);
      await _notificationService.scheduleFeedingReminders(
        intervalHours: _feedingInterval,
        babyName: _babyName,
        l10n: l10n,
        startFromNow: true,
      );
      _showSnackbar('수유 알림 간격이 ${_feedingInterval}시간으로 변경되었습니다');
    }
  }

  Future<void> _changeDiaperInterval(int? newInterval) async {
    if (newInterval == null) return;

    HapticFeedback.lightImpact();
    setState(() => _diaperInterval = newInterval);
    await _saveSettings();

    // 알림이 활성화되어 있으면 재설정
    if (_diaperEnabled) {
      final l10n = AppLocalizations.of(context);
      await _notificationService.scheduleDiaperReminders(
        intervalHours: _diaperInterval,
        babyName: _babyName,
        l10n: l10n,
        startFromNow: true,
      );
      _showSnackbar('기저귀 알림 간격이 ${_diaperInterval}시간으로 변경되었습니다');
    }
  }

  void _showSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.successSoft,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppTheme.surfaceDark,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.translate('notification_preferences') ?? '알림 환경설정',
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 설명
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.lavenderMist.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.lavenderMist.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: AppTheme.lavenderMist,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '${_babyName}의 케어 일정을 놓치지 않도록 알림을 설정하세요.',
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Sweet Spot 알림
                  _buildSettingCard(
                    icon: Icons.bedtime,
                    iconColor: AppTheme.lavenderMist,
                    title: 'Sweet Spot 알림',
                    subtitle: 'AI가 예측한 최적의 수면 시간 15분 전 알림',
                    enabled: _sweetSpotEnabled,
                    onToggle: _toggleSweetSpot,
                  ),

                  const SizedBox(height: 16),

                  // 수유 알림
                  _buildSettingCard(
                    icon: Icons.restaurant,
                    iconColor: AppTheme.feedingColor,
                    title: '수유 알림',
                    subtitle: '정해진 시간마다 수유 알림 받기',
                    enabled: _feedingEnabled,
                    onToggle: _toggleFeeding,
                    showIntervalSelector: _feedingEnabled,
                    currentInterval: _feedingInterval,
                    onIntervalChanged: _changeFeedingInterval,
                  ),

                  const SizedBox(height: 16),

                  // 기저귀 알림
                  _buildSettingCard(
                    icon: Icons.child_care,
                    iconColor: AppTheme.diaperColor,
                    title: '기저귀 알림',
                    subtitle: '정해진 시간마다 기저귀 체크 알림 받기',
                    enabled: _diaperEnabled,
                    onToggle: _toggleDiaper,
                    showIntervalSelector: _diaperEnabled,
                    currentInterval: _diaperInterval,
                    onIntervalChanged: _changeDiaperInterval,
                  ),

                  const SizedBox(height: 32),

                  // 테스트 버튼
                  Center(
                    child: TextButton.icon(
                      onPressed: _sendTestNotification,
                      icon: const Icon(Icons.notifications_active),
                      label: const Text('테스트 알림 보내기'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.lavenderMist,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 주의사항
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.glassBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.tips_and_updates,
                              color: AppTheme.textTertiary,
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Text(
                              '알림 관련 안내',
                              style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildTipItem('알림이 오지 않는다면 기기 설정에서 알림 권한을 확인하세요.'),
                        const SizedBox(height: 8),
                        _buildTipItem('배터리 절약 모드에서는 알림이 지연될 수 있습니다.'),
                        const SizedBox(height: 8),
                        _buildTipItem('수유/기저귀 알림은 24시간 단위로 자동 갱신됩니다.'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool enabled,
    required Function(bool) onToggle,
    bool showIntervalSelector = false,
    int? currentInterval,
    Function(int?)? onIntervalChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: enabled
              ? iconColor.withOpacity(0.5)
              : AppTheme.glassBorder,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                ),
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
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: enabled,
                onChanged: onToggle,
                activeColor: iconColor,
                activeTrackColor: iconColor.withOpacity(0.5),
              ),
            ],
          ),
          if (showIntervalSelector && currentInterval != null) ...[
            const SizedBox(height: 16),
            const Divider(color: AppTheme.glassBorder, height: 1),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(
                  Icons.schedule,
                  color: AppTheme.textTertiary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                const Text(
                  '알림 간격',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                DropdownButton<int>(
                  value: currentInterval,
                  dropdownColor: AppTheme.surfaceDark,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  underline: const SizedBox(),
                  items: [2, 3, 4].map((hours) {
                    return DropdownMenuItem(
                      value: hours,
                      child: Text('$hours시간'),
                    );
                  }).toList(),
                  onChanged: onIntervalChanged,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTipItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '• ',
          style: TextStyle(
            color: AppTheme.textTertiary,
            fontSize: 13,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppTheme.textTertiary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _sendTestNotification() async {
    HapticFeedback.mediumImpact();

    final l10n = AppLocalizations.of(context);
    await _notificationService.showImmediateNotification(
      title: '🎉 테스트 알림',
      body: 'Lulu 알림이 정상적으로 작동하고 있습니다!',
      l10n: l10n,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('테스트 알림이 전송되었습니다'),
        backgroundColor: AppTheme.successSoft,
        duration: Duration(seconds: 2),
      ),
    );
  }
}
