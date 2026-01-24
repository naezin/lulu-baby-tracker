import 'package:flutter/material.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import 'home/home_screen.dart';
import 'records/records_screen.dart';
import 'analysis/analysis_screen.dart';
import 'ai_chat/ai_chat_screen.dart';
import 'settings/settings_screen.dart';

/// 메인 탭바 네비게이션
class MainNavigation extends StatefulWidget {
  const MainNavigation({Key? key}) : super(key: key);

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  // 각 탭의 화면 목록
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const HomeScreen(),
      const RecordsScreen(),
      const AnalysisScreen(),
      const AIChatScreen(),
      const SettingsScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

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
          selectedItemColor: AppTheme.primaryDark,
          unselectedItemColor: AppTheme.textSecondary,
          selectedFontSize: 12,
          unselectedFontSize: 11,
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
          unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w400),
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: localizations.navHome,
              backgroundColor: AppTheme.surfaceDark,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.edit_note_outlined),
              activeIcon: Icon(Icons.edit_note),
              label: localizations.navRecords,
              backgroundColor: AppTheme.surfaceDark,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics_outlined),
              activeIcon: Icon(Icons.analytics),
              label: localizations.navInsights,
              backgroundColor: AppTheme.surfaceDark,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              activeIcon: Icon(Icons.chat_bubble),
              label: localizations.navLulu,
              backgroundColor: AppTheme.surfaceDark,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.more_horiz_outlined),
              activeIcon: Icon(Icons.more_horiz),
              label: localizations.navMore,
              backgroundColor: AppTheme.surfaceDark,
            ),
          ],
        ),
      ),
    );
  }
}
