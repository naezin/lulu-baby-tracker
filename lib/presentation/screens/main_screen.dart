import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import 'home/home_screen.dart';
import 'sleep/sleep_tracking_screen.dart';
import 'analytics/analytics_screen.dart';
import 'chat/chat_screen.dart';
import 'settings/settings_screen.dart';

/// 메인 화면 - Bottom Navigation Bar
class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const HomeScreen(),
      const SleepTrackingScreen(),
      const AnalyticsScreen(),
      const ChatScreen(),
      const SettingsScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppTheme.surfaceDark,
          selectedItemColor: AppTheme.lavenderMist,
          unselectedItemColor: AppTheme.textTertiary,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          selectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
          unselectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w500,
          ),
          items: [
            BottomNavigationBarItem(
              icon: _NavIcon(
                icon: Icons.home_outlined,
                isSelected: _currentIndex == 0,
              ),
              activeIcon: _NavIcon(
                icon: Icons.home,
                isSelected: true,
              ),
              label: l10n.tabHome,
            ),
            BottomNavigationBarItem(
              icon: _NavIcon(
                icon: Icons.nightlight_outlined,
                isSelected: _currentIndex == 1,
              ),
              activeIcon: _NavIcon(
                icon: Icons.nightlight,
                isSelected: true,
              ),
              label: l10n.tabSleep,
            ),
            BottomNavigationBarItem(
              icon: _NavIcon(
                icon: Icons.analytics_outlined,
                isSelected: _currentIndex == 2,
              ),
              activeIcon: _NavIcon(
                icon: Icons.analytics,
                isSelected: true,
              ),
              label: l10n.tabAnalytics,
            ),
            BottomNavigationBarItem(
              icon: _NavIcon(
                icon: Icons.chat_bubble_outline,
                isSelected: _currentIndex == 3,
              ),
              activeIcon: _NavIcon(
                icon: Icons.chat_bubble,
                isSelected: true,
              ),
              label: l10n.tabChat,
            ),
            BottomNavigationBarItem(
              icon: _NavIcon(
                icon: Icons.settings_outlined,
                isSelected: _currentIndex == 4,
              ),
              activeIcon: _NavIcon(
                icon: Icons.settings,
                isSelected: true,
              ),
              label: l10n.tabSettings,
            ),
          ],
        ),
      ),
    );
  }
}

/// 네비게이션 아이콘 위젯 (선택 시 애니메이션 효과)
class _NavIcon extends StatelessWidget {
  final IconData icon;
  final bool isSelected;

  const _NavIcon({
    required this.icon,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isSelected
            ? AppTheme.lavenderMist.withOpacity(0.15)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        size: 24,
      ),
    );
  }
}
