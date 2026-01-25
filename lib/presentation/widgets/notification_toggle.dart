import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/models/notification_state.dart';

/// 알림 토글 아이콘 버튼
class NotificationToggle extends StatelessWidget {
  final NotificationState state;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const NotificationToggle({
    Key? key,
    required this.state,
    required this.onTap,
    this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isEnabled = state.isEnabled &&
        state.permission == NotificationPermission.granted;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      onLongPress: () {
        HapticFeedback.mediumImpact();
        onLongPress?.call();
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(isEnabled ? 0.25 : 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              isEnabled ? Icons.notifications_active : Icons.notifications_off_outlined,
              key: ValueKey(isEnabled),
              color: Colors.white.withOpacity(isEnabled ? 1.0 : 0.7),
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}
