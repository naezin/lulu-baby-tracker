import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';
import '../../core/localization/app_localizations.dart';

/// 📝 Quick Log Bar - BabyTime-inspired one-tap logging
/// Positioned at bottom for thumb-driven interaction
class QuickLogBar extends StatelessWidget {
  final Function(String activityType) onQuickLog;

  const QuickLogBar({
    super.key,
    required this.onQuickLog,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _CircularQuickLogButton(
              icon: Icons.bedtime_rounded,
              label: l10n.translate('activity_sleep') ?? 'Sleep',
              color: AppTheme.lavenderMist,
              onTap: () {
                _triggerHaptic();
                onQuickLog('sleep');
              },
            ),
            _CircularQuickLogButton(
              icon: Icons.restaurant_rounded,
              label: l10n.translate('activity_feeding') ?? 'Feed',
              color: const Color(0xFFE8B87E),
              onTap: () {
                _triggerHaptic();
                onQuickLog('feeding');
              },
            ),
            _CircularQuickLogButton(
              icon: Icons.toys_outlined,
              label: l10n.translate('activity_play') ?? 'Play',
              color: const Color(0xFF5FB37B),
              onTap: () {
                _triggerHaptic();
                onQuickLog('play');
              },
            ),
            _CircularQuickLogButton(
              icon: Icons.child_care_rounded,
              label: l10n.translate('activity_diaper') ?? 'Diaper',
              color: const Color(0xFF7BB8E8),
              onTap: () {
                _triggerHaptic();
                onQuickLog('diaper');
              },
            ),
            _CircularQuickLogButton(
              icon: Icons.favorite_rounded,
              label: l10n.translate('activity_health') ?? 'Health',
              color: const Color(0xFFE87878),
              onTap: () {
                _triggerHaptic();
                onQuickLog('health');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _triggerHaptic() {
    HapticFeedback.lightImpact();
  }
}

class _CircularQuickLogButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _CircularQuickLogButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<_CircularQuickLogButton> createState() => _CircularQuickLogButtonState();
}

class _CircularQuickLogButtonState extends State<_CircularQuickLogButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color,
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                widget.icon,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.label,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
