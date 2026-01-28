import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/locale_provider.dart';
import '../../providers/unit_preferences_provider.dart';
import '../../providers/baby_provider.dart';
import '../../utils/snackbar_utils.dart';
import '../export/export_data_screen.dart';
import '../import/import_data_screen.dart';
import '../demo_setup_screen.dart';
import '../../../data/services/notification_service.dart';
import '../profile/baby_profile_screen.dart';
import 'widget_settings_screen.dart';
import 'privacy_policy_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../widgets/common/medical_disclaimer.dart';
import '../../../data/services/account_deletion_service.dart';  // 🆕 Day 2 - Account Deletion
import '../../../data/services/data_export_service.dart';  // 🆕 Day 3 - Data Export

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _notificationService = NotificationService();
  bool _sweetSpotNotificationsEnabled = false;
  bool _marketingNotificationsEnabled = false;
  int _minutesBefore = 15;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    try {
      final pending = await _notificationService.getPendingNotifications();
      if (mounted) {
        setState(() {
          _sweetSpotNotificationsEnabled = pending.isNotEmpty;
        });
      }
    } catch (e) {
      // Notifications not supported on web
      print('Notifications not available: $e');
      if (mounted) {
        setState(() {
          _sweetSpotNotificationsEnabled = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navSettings)),
      body: ListView(
        children: [
          // Baby Profile Section
          _buildBabyProfileSection(context, l10n),
          const Divider(),

          // Language Settings Section
          _buildSectionHeader(context, l10n.language),
          Consumer<LocaleProvider>(
            builder: (context, localeProvider, child) {
              return Column(
                children: [
                  RadioListTile<String>(
                    title: Text(l10n.languageEnglish),
                    subtitle: Text(l10n.languageEnglishUS),
                    value: 'en',
                    groupValue: localeProvider.locale.languageCode,
                    onChanged: (value) {
                      localeProvider.setEnglish();
                    },
                  ),
                  RadioListTile<String>(
                    title: Text(l10n.languageKorean),
                    subtitle: Text(l10n.languageKoreanKR),
                    value: 'ko',
                    groupValue: localeProvider.locale.languageCode,
                    onChanged: (value) {
                      localeProvider.setKorean();
                    },
                  ),
                ],
              );
            },
          ),
          const Divider(),

          // Unit Settings Section
          _buildSectionHeader(context, l10n.units),
          Consumer<UnitPreferencesProvider>(
            builder: (context, unitPrefs, child) {
              return Column(
                children: [
                  // Temperature Unit
                  ListTile(
                    leading: const Icon(Icons.thermostat),
                    title: Text(l10n.temperature),
                    trailing: SegmentedButton<String>(
                      segments: [
                        ButtonSegment(
                          value: 'celsius',
                          label: Text(l10n.unitCelsius),
                        ),
                        ButtonSegment(
                          value: 'fahrenheit',
                          label: Text(l10n.unitFahrenheit),
                        ),
                      ],
                      selected: {unitPrefs.temperatureUnit},
                      onSelectionChanged: (Set<String> newSelection) {
                        unitPrefs.setTemperatureUnit(newSelection.first);
                      },
                    ),
                  ),

                  // Weight Unit
                  ListTile(
                    leading: const Icon(Icons.monitor_weight),
                    title: Text(l10n.weight),
                    trailing: SegmentedButton<String>(
                      segments: [
                        ButtonSegment(
                          value: 'kg',
                          label: Text(l10n.unitKg),
                        ),
                        ButtonSegment(
                          value: 'lb',
                          label: Text(l10n.unitLb),
                        ),
                      ],
                      selected: {unitPrefs.weightUnit},
                      onSelectionChanged: (Set<String> newSelection) {
                        unitPrefs.setWeightUnit(newSelection.first);
                      },
                    ),
                  ),

                  // Volume Unit
                  ListTile(
                    leading: const Icon(Icons.local_drink),
                    title: Text(l10n.volume),
                    trailing: SegmentedButton<String>(
                      segments: [
                        ButtonSegment(
                          value: 'ml',
                          label: Text(l10n.unitMl),
                        ),
                        ButtonSegment(
                          value: 'oz',
                          label: Text(l10n.unitOz),
                        ),
                      ],
                      selected: {unitPrefs.volumeUnit},
                      onSelectionChanged: (Set<String> newSelection) {
                        unitPrefs.setVolumeUnit(newSelection.first);
                      },
                    ),
                  ),
                ],
              );
            },
          ),
          const Divider(),

          // Notification Settings Section
          _buildSectionHeader(context, l10n.notifications),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                SwitchListTile(
                  title: Text(l10n.sweetSpotAlerts),
                  subtitle: Text(l10n.notifyMeMinutesBefore(_minutesBefore)),
                  value: _sweetSpotNotificationsEnabled,
                  onChanged: (value) async {
                    if (value) {
                      final granted = await _notificationService.requestPermission();
                      if (granted) {
                        setState(() => _sweetSpotNotificationsEnabled = true);
                        _showSnackBar('Sweet Spot notifications enabled!');
                      } else {
                        _showSnackBar(l10n.translate('error_permission_denied'), isError: true);
                      }
                    } else {
                      await _notificationService.cancelAllNotifications();
                      setState(() => _sweetSpotNotificationsEnabled = false);
                      _showSnackBar(l10n.translate('notification_sweet_spot_disabled'));
                    }
                    _loadNotificationSettings();
                  },
                  secondary: const Icon(Icons.bedtime),
                ),
                if (_sweetSpotNotificationsEnabled)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.translate('notification_alert_time_format').replaceAll('{minutes}', '$_minutesBefore'),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                        Slider(
                          value: _minutesBefore.toDouble(),
                          min: 5,
                          max: 30,
                          divisions: 5,
                          label: '$_minutesBefore min',
                          onChanged: (value) {
                            setState(() {
                              _minutesBefore = value.toInt();
                            });
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(l10n.translate('slider_label_5_minutes'), style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                            Text(l10n.translate('slider_label_30_minutes'), style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                          ],
                        ),
                      ],
                    ),
                  ),
                const Divider(height: 1),
                SwitchListTile(
                  title: Text(l10n.appUpdatesAndTips),
                  subtitle: Text(l10n.receiveHelpfulTips),
                  value: _marketingNotificationsEnabled,
                  onChanged: (value) {
                    setState(() => _marketingNotificationsEnabled = value);
                    _showSnackBar(
                      value ? l10n.translate('notification_updates_enabled') : l10n.translate('notification_updates_disabled'),
                    );
                  },
                  secondary: const Icon(Icons.tips_and_updates),
                ),
              ],
            ),
          ),
          const Divider(),

          // Widget Settings Section
          _buildSectionHeader(context, l10n.translate('widget_settings')),
          ListTile(
            leading: const Icon(Icons.widgets),
            title: Text(l10n.translate('widget_settings')),
            subtitle: Text(l10n.translate('widget_settings_description')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WidgetSettingsScreen()),
              );
            },
          ),
          const Divider(),

          // 🆕 Data Management Section (Enhanced)
          _buildSectionHeader(context, l10n.dataManagement),
          ListTile(
            leading: const Icon(Icons.file_download_outlined),
            title: Text(l10n.translate('export_json') ?? 'Export All Data (JSON)'),
            subtitle: Text(l10n.translate('export_json_subtitle') ?? 'Complete backup including all babies and activities'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _handleJsonExport(context, l10n),
          ),
          ListTile(
            leading: const Icon(Icons.table_chart_outlined),
            title: Text(l10n.exportData),
            subtitle: Text(l10n.exportToCSV),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _handleCsvExport(context, l10n),
          ),
          ListTile(
            leading: const Icon(Icons.upload),
            title: Text(l10n.importData),
            subtitle: Text(l10n.importFromCSV),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ImportDataScreen()),
              );
            },
          ),
          const Divider(),

          // Demo & Testing Section
          _buildSectionHeader(context, l10n.translate('demo_and_testing')),
          ListTile(
            leading: const Icon(Icons.play_circle_outline),
            title: Text(l10n.sweetSpotDemo),
            subtitle: Text(l10n.tryAISleepPredictionDemo),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DemoSetupScreen()),
              );
            },
          ),
          const Divider(),

          // Privacy & Legal Section
          _buildSectionHeader(context, 'Privacy & Legal'),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy Policy'),
            subtitle: const Text('How we protect your family\'s data'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Terms of Service'),
            subtitle: const Text('App usage terms and conditions'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Implement Terms of Service screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Terms of Service coming soon'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.shield_outlined),
            title: const Text('Data & Security'),
            subtitle: const Text('Learn how your data is protected'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Implement Data & Security screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Data & Security info coming soon'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          const Divider(),

          // 🆕 About Section
          _buildSectionHeader(context, l10n.translate('about') ?? 'About'),
          _buildAboutSection(context, l10n),

          const Divider(),

          // 🆕 Danger Zone Section (Account Deletion)
          _buildSectionHeader(
            context,
            l10n.translate('danger_zone') ?? '⚠️ Danger Zone',
          ),
          _buildDangerZoneSection(context, l10n),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// 🆕 About 섹션
  Widget _buildAboutSection(BuildContext context, AppLocalizations l10n) {
    final isKorean = l10n.locale.languageCode == 'ko';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 앱 버전
          _buildInfoRow(
            label: isKorean ? '버전' : 'Version',
            value: '1.0.0 (Build 1)',
          ),
          const SizedBox(height: 16),

          // Medical Disclaimer
          const MedicalDisclaimer(),

          const SizedBox(height: 16),

          // 앱 설명
          Text(
            isKorean
                ? 'Lulu는 과학적으로 검증된 Wake Window 계산을 사용하여 부모님들이 아기의 최적 수면 시간을 예측할 수 있도록 돕습니다.'
                : 'Lulu helps tired parents predict their baby\'s optimal sleep time using scientifically-backed wake window calculations.',
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  /// 정보 행 위젯
  Widget _buildInfoRow({required String label, required String value}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondary,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// 🆕 Danger Zone 섹션 (계정 삭제)
  Widget _buildDangerZoneSection(BuildContext context, AppLocalizations l10n) {
    final isKorean = l10n.locale.languageCode == 'ko';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.red.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 경고 헤더
            Row(
              children: [
                const Icon(
                  Icons.warning_rounded,
                  color: Colors.red,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isKorean ? '계정 삭제' : 'Delete Account',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 설명
            Text(
              isKorean
                  ? '계정을 삭제하면 모든 데이터가 영구적으로 삭제됩니다. 이 작업은 되돌릴 수 없습니다.'
                  : 'Deleting your account will permanently erase all your data. This action cannot be undone.',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),

            // 삭제 버튼
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showDeleteAccountDialog(context, l10n),
                icon: const Icon(Icons.delete_forever_rounded),
                label: Text(
                  isKorean ? '계정 삭제' : 'Delete My Account',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red, width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 계정 삭제 확인 다이얼로그
  Future<void> _showDeleteAccountDialog(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final isKorean = l10n.locale.languageCode == 'ko';
    final accountService = AccountDeletionService();

    // 1단계: 데이터 요약 조회
    final dataSummary = await accountService.getAccountDataSummary();

    if (!mounted) return;

    // 2단계: 확인 다이얼로그 표시
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1A2332),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.warning_rounded, color: Colors.red, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isKorean ? '정말 삭제하시겠습니까?' : 'Are you sure?',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isKorean
                  ? '다음 데이터가 영구적으로 삭제됩니다:'
                  : 'The following data will be permanently deleted:',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            _buildDataSummaryRow(
              icon: Icons.child_care,
              label: isKorean ? '아기 프로필' : 'Baby profiles',
              count: dataSummary.babyCount,
            ),
            _buildDataSummaryRow(
              icon: Icons.timeline,
              label: isKorean ? '활동 기록' : 'Activity records',
              count: dataSummary.activityCount,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isKorean
                    ? '⚠️ 이 작업은 되돌릴 수 없습니다'
                    : '⚠️ This action cannot be undone',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              isKorean ? '취소' : 'Cancel',
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(isKorean ? '삭제' : 'Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      // 3단계: 계정 삭제 실행
      _showLoadingDialog(context, l10n);

      final result = await accountService.deleteAccount();

      if (!mounted) return;

      // 로딩 다이얼로그 닫기
      Navigator.pop(context);

      if (result.success) {
        // 성공: 온보딩 화면으로 이동
        _showSnackBar(
          isKorean ? '계정이 삭제되었습니다' : 'Account deleted successfully',
        );

        // 온보딩 화면으로 이동 (모든 스택 제거)
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/onboarding',
            (route) => false,
          );
        }
      } else {
        // 실패: 에러 메시지 표시
        _showSnackBar(
          result.errorMessage ??
              (isKorean ? '계정 삭제에 실패했습니다' : 'Failed to delete account'),
          isError: true,
        );
      }
    }
  }

  /// 데이터 요약 행 위젯
  Widget _buildDataSummaryRow({
    required IconData icon,
    required String label,
    required int count,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.textSecondary),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            '$count',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// 로딩 다이얼로그 표시
  void _showLoadingDialog(BuildContext context, AppLocalizations l10n) {
    final isKorean = l10n.locale.languageCode == 'ko';
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A2332),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Colors.red),
            const SizedBox(height: 16),
            Text(
              isKorean ? '계정 삭제 중...' : 'Deleting account...',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  /// 아기 프로필 섹션
  Widget _buildBabyProfileSection(BuildContext context, AppLocalizations l10n) {
    final isKorean = l10n.locale.languageCode == 'ko';

    return Consumer<BabyProvider>(
      builder: (context, babyProvider, child) {
        final baby = babyProvider.currentBaby;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(context, isKorean ? '아기 프로필' : 'Baby Profile'),

            // 기본 프로필 정보
            if (baby != null) ...[
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.lavenderMist.withOpacity(0.3),
                  child: Text(
                    baby.name.isNotEmpty ? baby.name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: AppTheme.lavenderMist,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(baby.name),
                subtitle: Text(
                  isKorean
                      ? '${baby.ageInMonths}개월 • ${baby.gender == 'male' ? '남아' : baby.gender == 'female' ? '여아' : '기타'}'
                      : '${baby.ageInMonths} months • ${baby.gender == 'male' ? 'Boy' : baby.gender == 'female' ? 'Girl' : 'Other'}',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BabyProfileScreen(existingBaby: baby),
                    ),
                  );
                  if (result == true) {
                    // Reload baby data if edited
                    babyProvider.loadBabies(baby.userId);
                  }
                },
              ),

              // 조산아 교정 연령 설정 (조산아인 경우만 표시)
              if (baby.isPremature && baby.dueDate != null) ...[
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      isKorean ? '교정 연령 사용' : 'Use Corrected Age',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Icon(
                                      Icons.info_outline,
                                      size: 16,
                                      color: AppTheme.textTertiary,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isKorean
                                      ? '예정일 기준으로 월령을 계산합니다'
                                      : 'Calculate age based on due date',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: baby.useCorrectedAge,
                            onChanged: (value) {
                              babyProvider.toggleCorrectedAge(value);
                            },
                            activeColor: AppTheme.lavenderMist,
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // 연령 비교 박스
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: baby.useCorrectedAge
                                    ? AppTheme.surfaceCard
                                    : AppTheme.lavenderMist.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: baby.useCorrectedAge
                                      ? AppTheme.glassBorder
                                      : AppTheme.lavenderMist.withOpacity(0.3),
                                  width: baby.useCorrectedAge ? 1 : 2,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isKorean ? '실제 월령' : 'Actual Age',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    isKorean
                                        ? '${baby.actualAgeInMonths.toStringAsFixed(1)}개월'
                                        : '${baby.actualAgeInMonths.toStringAsFixed(1)} mo',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: baby.useCorrectedAge
                                          ? AppTheme.textSecondary
                                          : AppTheme.lavenderMist,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: baby.useCorrectedAge
                                    ? AppTheme.lavenderMist.withOpacity(0.15)
                                    : AppTheme.surfaceCard,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: baby.useCorrectedAge
                                      ? AppTheme.lavenderMist.withOpacity(0.3)
                                      : AppTheme.glassBorder,
                                  width: baby.useCorrectedAge ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isKorean ? '교정 월령' : 'Corrected Age',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    isKorean
                                        ? '${baby.correctedAgeInMonths.toStringAsFixed(1)}개월'
                                        : '${baby.correctedAgeInMonths.toStringAsFixed(1)} mo',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: baby.useCorrectedAge
                                          ? AppTheme.lavenderMist
                                          : AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // 조산 정보
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.infoSoft.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.infoSoft.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 18,
                              color: AppTheme.infoSoft,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                isKorean
                                    ? '${baby.pretermWeeks}주 조산 • Sweet Spot 예측에 ${baby.useCorrectedAge ? '교정 월령' : '실제 월령'} 사용 중'
                                    : '${baby.pretermWeeks} weeks premature • Using ${baby.useCorrectedAge ? 'corrected' : 'actual'} age for Sweet Spot',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ] else ...[
              ListTile(
                leading: const Icon(Icons.child_care),
                title: Text(isKorean ? '아기 프로필 추가' : 'Add Baby Profile'),
                subtitle: Text(isKorean ? '아기 정보를 입력해주세요' : 'Please add baby information'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const BabyProfileScreen(),
                    ),
                  );
                },
              ),
            ],
          ],
        );
      },
    );
  }

  /// 섹션 헤더
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (isError) {
      LuluSnackBar.showError(context, message: message);
    } else {
      LuluSnackBar.showSuccess(context, message: message, duration: const Duration(seconds: 2));
    }
  }

  /// 🆕 JSON 내보내기 핸들러
  Future<void> _handleJsonExport(BuildContext context, AppLocalizations l10n) async {
    final isKorean = l10n.locale.languageCode == 'ko';
    final exportService = DataExportService();

    // 로딩 다이얼로그 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A2332),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppTheme.lavenderMist),
            const SizedBox(height: 16),
            Text(
              isKorean ? '데이터 내보내는 중...' : 'Exporting data...',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );

    // JSON 내보내기 실행
    final result = await exportService.exportToJson();

    if (!mounted) return;

    // 로딩 다이얼로그 닫기
    Navigator.pop(context);

    if (result.success) {
      // 성공: 공유 다이얼로그 표시
      await _showExportSuccessDialog(
        context,
        l10n,
        result,
        isJson: true,
        onShare: () async {
          await exportService.shareFile(
            result.filePath!,
            subject: 'Lulu Baby Data Backup',
          );
        },
      );
    } else {
      // 실패: 에러 메시지
      _showSnackBar(
        result.errorMessage ?? (isKorean ? '내보내기 실패' : 'Export failed'),
        isError: true,
      );
    }
  }

  /// 🆕 CSV 내보내기 핸들러
  Future<void> _handleCsvExport(BuildContext context, AppLocalizations l10n) async {
    final isKorean = l10n.locale.languageCode == 'ko';
    final exportService = DataExportService();

    // 로딩 다이얼로그 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A2332),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppTheme.lavenderMist),
            const SizedBox(height: 16),
            Text(
              isKorean ? 'CSV 생성 중...' : 'Creating CSV...',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );

    // CSV 내보내기 실행
    final result = await exportService.exportActivitiesToCsv();

    if (!mounted) return;

    // 로딩 다이얼로그 닫기
    Navigator.pop(context);

    if (result.success) {
      // 성공: 공유 다이얼로그 표시
      await _showExportSuccessDialog(
        context,
        l10n,
        result,
        isJson: false,
        onShare: () async {
          await exportService.shareFile(
            result.filePath!,
            subject: 'Lulu Activity Records',
          );
        },
      );
    } else {
      // 실패: 에러 메시지
      _showSnackBar(
        result.errorMessage ?? (isKorean ? 'CSV 생성 실패' : 'CSV export failed'),
        isError: true,
      );
    }
  }

  /// 🆕 내보내기 성공 다이얼로그
  Future<void> _showExportSuccessDialog(
    BuildContext context,
    AppLocalizations l10n,
    DataExportResult result, {
    required bool isJson,
    required Future<void> Function() onShare,
  }) async {
    final isKorean = l10n.locale.languageCode == 'ko';

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1A2332),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isKorean ? '내보내기 완료' : 'Export Complete',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildExportInfoRow(
              icon: Icons.description,
              label: isKorean ? '파일 형식' : 'Format',
              value: isJson ? 'JSON' : 'CSV',
            ),
            _buildExportInfoRow(
              icon: Icons.storage,
              label: isKorean ? '파일 크기' : 'Size',
              value: result.fileSizeFormatted,
            ),
            _buildExportInfoRow(
              icon: Icons.timeline,
              label: isKorean ? '기록 수' : 'Records',
              value: '${result.recordCount}',
            ),
            const SizedBox(height: 16),
            Text(
              isKorean
                  ? '파일이 기기에 저장되었습니다. 공유 버튼을 눌러 다른 앱으로 보내거나 백업하세요.'
                  : 'File saved to device. Use the share button to send to another app or backup.',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              isKorean ? '닫기' : 'Close',
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              await onShare();
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
              }
            },
            icon: const Icon(Icons.share),
            label: Text(isKorean ? '공유' : 'Share'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lavenderMist,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// 내보내기 정보 행
  Widget _buildExportInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.textSecondary),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.lavenderMist,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
