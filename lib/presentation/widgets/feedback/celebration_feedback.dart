import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/activity_model.dart';
import '../../../core/utils/smart_cta_navigator.dart';  // 🆕

/// 📊 CelebrationFeedback - 기록 완료 후 보상 피드백 위젯
///
/// **목적**: 사용자가 기록을 완료하면 즉각적인 성취감 제공
/// - 체크마크 애니메이션 (Lottie)
/// - 인사이트 메시지 (오늘의 기록 현황)
/// - Smart CTA (맥락 기반 다음 액션 제안)
class CelebrationFeedback extends StatefulWidget {
  final ActivityType activityType;
  final ActivityModel activity;
  final String? insightMessage;
  final String? ctaText;
  final VoidCallback? onCTAPressed;
  final VoidCallback? onComplete;

  const CelebrationFeedback({
    super.key,
    required this.activityType,
    required this.activity,
    this.insightMessage,
    this.ctaText,
    this.onCTAPressed,
    this.onComplete,
  });

  /// 🎉 BottomSheet로 표시
  static Future<void> show({
    required BuildContext context,
    required ActivityType activityType,
    required ActivityModel activity,
    String? insightMessage,
    String? ctaText,
    VoidCallback? onCTAPressed,
  }) async {
    // Haptic feedback - 한 번만 실행
    await HapticFeedback.lightImpact();

    if (!context.mounted) return;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      isScrollControlled: true,
      builder: (context) => CelebrationFeedback(
        activityType: activityType,
        activity: activity,
        insightMessage: insightMessage,
        ctaText: ctaText,
        onCTAPressed: onCTAPressed,
        onComplete: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  State<CelebrationFeedback> createState() => _CelebrationFeedbackState();
}

class _CelebrationFeedbackState extends State<CelebrationFeedback>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _lottieLoadError = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward();

    // 3초 후 자동 닫기
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        widget.onComplete?.call();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          decoration: const BoxDecoration(
            color: AppTheme.surfaceDark,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 드래그 핸들
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 20),
                decoration: BoxDecoration(
                  color: AppTheme.glassBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // 체크마크 애니메이션 영역 (placeholder)
              _buildCheckmarkAnimation(),

              const SizedBox(height: 20),

              // 완료 메시지
              _buildCompletionMessage(),

              const SizedBox(height: 16),

              // 인사이트 메시지
              if (widget.insightMessage != null) ...[
                _buildInsightMessage(),
                const SizedBox(height: 16),
              ],

              // Smart CTA
              if (widget.ctaText != null && widget.onCTAPressed != null) ...[
                _buildSmartCTA(),
                const SizedBox(height: 16),
              ],

              // 닫기 버튼
              _buildCloseButton(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// ✅ 체크마크 애니메이션 (Lottie with Fallback)
  Widget _buildCheckmarkAnimation() {
    // Lottie 로딩 실패 시 fallback
    if (_lottieLoadError) {
      return _buildFallbackCheckmark();
    }

    return SizedBox(
      width: 120,
      height: 120,
      child: Lottie.asset(
        'assets/animations/checkmark.json',
        repeat: false,
        animate: true,
        frameRate: FrameRate.max,
        errorBuilder: (context, error, stackTrace) {
          // Lottie 로딩 실패 시 fallback으로 전환
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _lottieLoadError = true;
              });
            }
          });
          return _buildFallbackCheckmark();
        },
      ),
    );
  }

  /// 🔄 Fallback 체크마크 (Lottie 로딩 실패 시)
  Widget _buildFallbackCheckmark() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.lavenderMist.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              size: 48,
              color: AppTheme.lavenderMist,
            ),
          ),
        );
      },
    );
  }

  /// 📝 완료 메시지
  Widget _buildCompletionMessage() {
    final activityName = _getActivityName(widget.activityType);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Text(
            '$activityName 기록 완료!',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '오늘도 소중한 기록을 남겨주셨어요',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 💡 인사이트 메시지
  Widget _buildInsightMessage() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.infoSoft.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.infoSoft.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.infoSoft.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lightbulb_outline,
              color: AppTheme.infoSoft,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.insightMessage!,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textPrimary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🎯 Smart CTA
  Widget _buildSmartCTA() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ElevatedButton(
        onPressed: () {
          // 🆕 SmartCTANavigator를 사용하여 다음 화면으로 이동
          if (widget.onCTAPressed != null) {
            widget.onCTAPressed!();
          } else {
            // 기본 동작: SmartCTANavigator 사용
            SmartCTANavigator.navigateToNext(
              context: context,
              currentActivityType: widget.activityType,
            );
          }
          widget.onComplete?.call();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.lavenderMist,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          minimumSize: const Size(double.infinity, 52),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.ctaText!,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward, size: 20),
          ],
        ),
      ),
    );
  }

  /// ❌ 닫기 버튼
  Widget _buildCloseButton() {
    return TextButton(
      onPressed: widget.onComplete,
      child: const Text(
        '닫기',
        style: TextStyle(
          fontSize: 14,
          color: AppTheme.textTertiary,
        ),
      ),
    );
  }

  /// 🏷️ ActivityType → 한글 이름
  String _getActivityName(ActivityType type) {
    switch (type) {
      case ActivityType.sleep:
        return '수면';
      case ActivityType.feeding:
        return '수유';
      case ActivityType.diaper:
        return '기저귀';
      case ActivityType.play:
        return '놀이';
      case ActivityType.health:
        return '건강';
    }
  }
}
