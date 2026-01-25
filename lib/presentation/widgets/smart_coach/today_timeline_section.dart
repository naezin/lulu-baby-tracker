import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../providers/smart_coach_provider.dart';
import 'timeline_header.dart';
import 'timeline_item_card.dart';
import 'timeline_divider.dart';
import 'ask_coach_button.dart';
import 'coaching_tip_card.dart';

/// 오늘의 타임라인 섹션
class TodayTimelineSection extends StatelessWidget {
  final VoidCallback? onSeeAllTap;
  final VoidCallback? onAskCoachTap;

  const TodayTimelineSection({
    Key? key,
    this.onSeeAllTap,
    this.onAskCoachTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isKorean = l10n.locale.languageCode == 'ko';

    return Consumer<SmartCoachProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return _buildLoadingState();
        }

        if (provider.error != null) {
          return _buildErrorState(provider.error!, isKorean);
        }

        return _buildContent(context, provider, l10n, isKorean);
      },
    );
  }

  Widget _buildLoadingState() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorState(String error, bool isKorean) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        isKorean ? '타임라인을 불러올 수 없어요' : 'Could not load timeline',
        style: TextStyle(color: AppTheme.textSecondary),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    SmartCoachProvider provider,
    AppLocalizations l10n,
    bool isKorean,
  ) {
    final timeline = provider.timeline;
    final coachingMessage = provider.currentMessage;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.lavenderMist.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          TimelineHeader(
            title: isKorean ? '오늘의 일정' : 'Today\'s Schedule',
            onSeeAllTap: onSeeAllTap,
          ),

          // 코칭 메시지 (있으면)
          if (coachingMessage != null) ...[
            CoachingTipCard(
              message: coachingMessage,
              onDismiss: () => provider.dismissCoachingMessage(),
              onActionTap: coachingMessage.actionRoute != null
                  ? () => Navigator.pushNamed(
                        context,
                        coachingMessage.actionRoute!,
                      )
                  : null,
            ),
            const SizedBox(height: 8),
          ],

          // 타임라인 아이템들
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                // 과거 아이템 (최대 3개만 표시)
                ..._buildPastItems(timeline.pastItems, isKorean),

                // 현재 시점 구분선
                if (timeline.pastItems.isNotEmpty &&
                    timeline.upcomingItems.isNotEmpty)
                  TimelineDivider(isKorean: isKorean),

                // 예정 아이템 (최대 4개만 표시)
                ..._buildUpcomingItems(timeline.upcomingItems, isKorean),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // "더 궁금해요" 버튼
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AskCoachButton(
              onTap: onAskCoachTap ?? () => _navigateToChat(context),
              isKorean: isKorean,
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  List<Widget> _buildPastItems(List<dynamic> items, bool isKorean) {
    // 최근 3개만 표시
    final displayItems = items.length > 3
        ? items.sublist(items.length - 3)
        : items;

    return displayItems.map((item) {
      return TimelineItemCard(
        item: item,
        isKorean: isKorean,
      );
    }).toList();
  }

  List<Widget> _buildUpcomingItems(List<dynamic> items, bool isKorean) {
    // 최대 4개만 표시
    final displayItems = items.length > 4 ? items.sublist(0, 4) : items;

    return displayItems.map((item) {
      return TimelineItemCard(
        item: item,
        isKorean: isKorean,
      );
    }).toList();
  }

  void _navigateToChat(BuildContext context) {
    HapticFeedback.mediumImpact();
    Navigator.pushNamed(context, '/chat');
  }
}
