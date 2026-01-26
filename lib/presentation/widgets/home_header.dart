import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/localization/app_localizations.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/settings/notification_settings_screen.dart';

/// 홈 화면 헤더
/// 오버플로우 방지를 위해 Expanded + Flexible 패턴 사용
class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Row(
      children: [
        // 1. 로고 (고정 크기)
        const _Logo(),

        const SizedBox(width: 12),

        // 2. App name (유연한 너비)
        Expanded(
          child: Text(
            l10n.appName,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),

        const SizedBox(width: 8),

        // 3. 알림 버튼 (고정 크기)
        _HeaderIconButton(
          icon: Icons.notifications_outlined,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationSettingsScreen()),
            );
          },
        ),

        const SizedBox(width: 8),

        // 4. 설정 버튼 (고정 크기)
        _HeaderIconButton(
          icon: Icons.settings_outlined,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            );
          },
        ),
      ],
    );
  }
}

/// 로고 위젯
class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.nightlight_round,
      size: 24,
      color: Color(0xFFFFD93D),
    );
  }
}

/// 헤더 아이콘 버튼
class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _HeaderIconButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon),
      iconSize: 24,
      padding: const EdgeInsets.all(8),
      constraints: const BoxConstraints(
        minWidth: 40,
        minHeight: 40,
      ),
      color: AppTheme.textSecondary,
      onPressed: onPressed,
    );
  }
}
