import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/activity_model.dart';
import '../../../data/services/local_storage_service.dart';
import '../../../data/services/widget_service.dart';
import '../../providers/baby_provider.dart';
import '../../providers/home_data_provider.dart';
import '../../providers/sweet_spot_provider.dart';
import '../../providers/feed_sleep_provider.dart';
import '../../widgets/records/feed_sleep_correlation_card.dart';
import '../activities/log_sleep_screen.dart';
import '../activities/log_feeding_screen.dart';
import '../activities/log_diaper_screen.dart';
import '../activities/log_play_screen.dart';
import '../activities/log_health_screen.dart';
import 'activity_detail_screen.dart';

/// 날짜 범위 필터
enum DateRangeFilter {
  today,
  week,
  month,
  all,
}

/// 정렬 순서
enum SortOrder {
  newest,  // 최신순 (기본)
  oldest,  // 오래된순
}

/// 활동 타입 필터
enum ActivityTypeFilter {
  all,      // 전체
  sleep,    // 수면
  feeding,  // 수유
  diaper,   // 기저귀
  play,     // 놀이
  health,   // 건강
}

extension ActivityTypeFilterExtension on ActivityTypeFilter {
  String getLabel(bool isKorean) {
    switch (this) {
      case ActivityTypeFilter.all:
        return isKorean ? '전체' : 'All';
      case ActivityTypeFilter.sleep:
        return isKorean ? '수면' : 'Sleep';
      case ActivityTypeFilter.feeding:
        return isKorean ? '수유' : 'Feeding';
      case ActivityTypeFilter.diaper:
        return isKorean ? '기저귀' : 'Diaper';
      case ActivityTypeFilter.play:
        return isKorean ? '놀이' : 'Play';
      case ActivityTypeFilter.health:
        return isKorean ? '건강' : 'Health';
    }
  }

  String getEmoji() {
    switch (this) {
      case ActivityTypeFilter.all:
        return '📋';
      case ActivityTypeFilter.sleep:
        return '😴';
      case ActivityTypeFilter.feeding:
        return '🍼';
      case ActivityTypeFilter.diaper:
        return '🧷';
      case ActivityTypeFilter.play:
        return '🎮';
      case ActivityTypeFilter.health:
        return '🏥';
    }
  }

  ActivityType? toActivityType() {
    switch (this) {
      case ActivityTypeFilter.all:
        return null;
      case ActivityTypeFilter.sleep:
        return ActivityType.sleep;
      case ActivityTypeFilter.feeding:
        return ActivityType.feeding;
      case ActivityTypeFilter.diaper:
        return ActivityType.diaper;
      case ActivityTypeFilter.play:
        return ActivityType.play;
      case ActivityTypeFilter.health:
        return ActivityType.health;
    }
  }
}

extension DateRangeFilterExtension on DateRangeFilter {
  String getLabel(bool isKorean) {
    switch (this) {
      case DateRangeFilter.today:
        return isKorean ? '오늘' : 'Today';
      case DateRangeFilter.week:
        return isKorean ? '7일' : '7 Days';
      case DateRangeFilter.month:
        return isKorean ? '30일' : '30 Days';
      case DateRangeFilter.all:
        return isKorean ? '전체' : 'All';
    }
  }

  /// 시작 날짜 계산 (null이면 전체)
  DateTime? getStartDate() {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);

    switch (this) {
      case DateRangeFilter.today:
        return today;
      case DateRangeFilter.week:
        return today.subtract(const Duration(days: 7));
      case DateRangeFilter.month:
        return today.subtract(const Duration(days: 30));
      case DateRangeFilter.all:
        return null;
    }
  }
}

/// 📝 Records V2 - 원탭 기록 화면
/// 핵심 원칙: "1초 안에 기록 완료"
class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  final _storage = LocalStorageService();
  List<ActivityModel> _todayActivities = [];
  bool _isLoading = true;
  DateRangeFilter _selectedFilter = DateRangeFilter.week;  // 기본값 7일
  SortOrder _sortOrder = SortOrder.newest;  // 기본값 최신순
  ActivityTypeFilter _typeFilter = ActivityTypeFilter.all;  // 기본값 전체

  // 진행 중인 활동 (수면 타이머 등)
  ActivityModel? _ongoingActivity;

  @override
  void initState() {
    super.initState();
    _loadTodayActivities();

    // BabyProvider 변경 리스너 추가
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTodayActivities();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadTodayActivities() async {
    setState(() => _isLoading = true);

    final activities = await _storage.getActivities();

    // 현재 아기 ID 가져오기
    final babyProvider = Provider.of<BabyProvider>(context, listen: false);
    final currentBabyId = babyProvider.currentBaby?.id;

    // 날짜 필터 적용
    final DateTime? startDate = _selectedFilter.getStartDate();

    // 🆕 디버깅 로그
    print('🔍 [RecordsScreen] Filter: ${_selectedFilter.name}, startDate: $startDate');
    print('   currentBaby: ${babyProvider.currentBaby?.name}');
    print('   currentBabyId: $currentBabyId');
    print('   전체 activities 수: ${activities.length}');

    final filteredActivities = activities.where((a) {
      final actDate = DateTime.parse(a.timestamp);

      // 날짜 필터 적용
      final isInDateRange = startDate == null || actDate.isAfter(startDate) || actDate.isAtSameMomentAs(startDate);

      // 현재 아기의 활동만 필터링
      final isCurrentBaby = currentBabyId == null || a.babyId == currentBabyId;

      // 타입 필터 적용
      final ActivityType? filterType = _typeFilter.toActivityType();
      final isMatchingType = filterType == null || a.type == filterType;

      return isInDateRange && isCurrentBaby && isMatchingType;
    }).toList();

    print('   필터 후 activities 수: ${filteredActivities.length}');

    // 시간 역순 정렬 (최신순)
    filteredActivities.sort((a, b) =>
        DateTime.parse(b.timestamp).compareTo(DateTime.parse(a.timestamp)));

    // 진행 중인 수면 찾기
    final ongoing = filteredActivities.where((a) =>
        a.type == ActivityType.sleep && a.endTime == null).firstOrNull;

    setState(() {
      _todayActivities = filteredActivities;
      _ongoingActivity = ongoing;
      _isLoading = false;
    });
  }

  /// 원탭 기록 - 즉시 저장
  Future<void> _quickRecord(ActivityType type) async {
    HapticFeedback.mediumImpact();

    final now = DateTime.now();
    final babyProvider = Provider.of<BabyProvider>(context, listen: false);
    final babyId = babyProvider.currentBaby?.id ?? 'unknown';

    // 수면인 경우: 진행 중이면 종료, 아니면 시작
    if (type == ActivityType.sleep) {
      if (_ongoingActivity != null) {
        await _endSleep();
        return;
      }
    }

    final activity = ActivityModel(
      id: now.millisecondsSinceEpoch.toString(),
      babyId: babyId,
      type: type,
      timestamp: now.toIso8601String(),
      // 수면은 endTime 없이 시작 (진행 중)
      endTime: type == ActivityType.sleep ? null : now.toIso8601String(),
      // 기본값 설정
      durationMinutes: type == ActivityType.sleep ? null : 0,
      amountMl: type == ActivityType.feeding ? 120 : null, // 기본 수유량
      feedingType: type == ActivityType.feeding ? 'bottle' : null,
      diaperType: type == ActivityType.diaper ? 'wet' : null,
    );

    await _storage.saveActivity(activity);
    await WidgetService().updateAllWidgets();

    // ✅ HomeDataProvider의 dailySummary 업데이트
    final homeDataProvider = Provider.of<HomeDataProvider>(context, listen: false);
    await homeDataProvider.refreshDailySummary(babyId);

    _showQuickFeedback(type);
    _loadTodayActivities();
  }

  /// 수면 종료
  Future<void> _endSleep() async {
    if (_ongoingActivity == null) return;

    final now = DateTime.now();
    final startTime = DateTime.parse(_ongoingActivity!.timestamp);
    final duration = now.difference(startTime).inMinutes;
    final babyProvider = Provider.of<BabyProvider>(context, listen: false);
    final babyId = babyProvider.currentBaby?.id ?? 'unknown';

    final updated = ActivityModel(
      id: _ongoingActivity!.id,
      babyId: babyId,
      type: ActivityType.sleep,
      timestamp: _ongoingActivity!.timestamp,
      endTime: now.toIso8601String(),
      durationMinutes: duration,
      sleepQuality: _ongoingActivity!.sleepQuality,
      sleepLocation: _ongoingActivity!.sleepLocation,
    );

    await _storage.updateActivity(updated);
    await WidgetService().updateAllWidgets();

    // ✅ HomeDataProvider의 dailySummary 업데이트
    final homeDataProvider = Provider.of<HomeDataProvider>(context, listen: false);
    await homeDataProvider.refreshDailySummary(babyId);

    HapticFeedback.heavyImpact();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Text('😴'),
              const SizedBox(width: 8),
              Text('수면 종료! ${_formatDuration(duration)}'),
            ],
          ),
          backgroundColor: AppTheme.sleepColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }

    _loadTodayActivities();
  }

  void _showQuickFeedback(ActivityType type) {
    final emoji = _getEmoji(type);
    final label = _getLabel(type);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text('$label 기록됨!'),
            const Spacer(),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                _openDetailScreen(type);
              },
              child: const Text('상세 수정', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: _getColor(type),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// 상세 기록 화면 열기
  void _openDetailScreen(ActivityType type) {
    HapticFeedback.lightImpact();

    Widget screen;
    switch (type) {
      case ActivityType.sleep:
        screen = const LogSleepScreen();
        break;
      case ActivityType.feeding:
        screen = const LogFeedingScreen();
        break;
      case ActivityType.diaper:
        screen = const LogDiaperScreen();
        break;
      case ActivityType.play:
        screen = const LogPlayScreen();
        break;
      case ActivityType.health:
        screen = const LogHealthScreen();
        break;
    }

    Navigator.push(context, MaterialPageRoute(builder: (_) => screen))
        .then((_) => _loadTodayActivities());
  }

  String _getEmoji(ActivityType type) {
    switch (type) {
      case ActivityType.sleep: return '😴';
      case ActivityType.feeding: return '🍼';
      case ActivityType.diaper: return '🧷';
      case ActivityType.play: return '🎮';
      case ActivityType.health: return '🏥';
    }
  }

  String _getLabel(ActivityType type) {
    final l10n = AppLocalizations.of(context);
    switch (type) {
      case ActivityType.sleep: return l10n.translate('sleep') ?? '수면';
      case ActivityType.feeding: return l10n.translate('feeding') ?? '수유';
      case ActivityType.diaper: return l10n.translate('diaper') ?? '기저귀';
      case ActivityType.play: return l10n.translate('play') ?? '놀이';
      case ActivityType.health: return l10n.translate('health') ?? '건강';
    }
  }

  Color _getColor(ActivityType type) {
    switch (type) {
      case ActivityType.sleep: return AppTheme.sleepColor;
      case ActivityType.feeding: return AppTheme.feedingColor;
      case ActivityType.diaper: return AppTheme.diaperColor;
      case ActivityType.play: return AppTheme.playColor;
      case ActivityType.health: return AppTheme.healthColor;
    }
  }

  String _formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours > 0) {
      return '$hours시간 $mins분';
    }
    return '$mins분';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppTheme.surfaceDark,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceDark,
        elevation: 0,
        title: Text(
          l10n.translate('records_title') ?? '기록',
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_rounded, color: AppTheme.textSecondary),
            onPressed: () {
              // TODO: 캘린더 뷰 열기
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadTodayActivities,
        color: AppTheme.lavenderMist,
        child: Column(
          children: [
            // 날짜 필터
            _buildDateFilterChips(l10n),
            const SizedBox(height: 8),

            // 스크롤 가능한 컨텐츠
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🚀 원탭 기록 섹션
                    _buildQuickRecordSection(l10n),

                    const SizedBox(height: 24),

                    // 🍼😴 막수-밤잠 상관관계 카드
                    const FeedSleepCorrelationCard(),

                    // 📅 타임라인
                    _buildTimelineSection(l10n),

                    const SizedBox(height: 24),

                    // 💡 요약
                    _buildTodaySummary(l10n),

                    const SizedBox(height: 100), // 바텀 패딩
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateFilterChips(AppLocalizations l10n) {
    final bool isKorean = l10n.locale.languageCode == 'ko';

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: DateRangeFilter.values.map((DateRangeFilter filter) {
          final bool isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter.getLabel(isKorean)),
              selected: isSelected,
              onSelected: (bool selected) {
                if (selected) {
                  setState(() => _selectedFilter = filter);
                  _loadTodayActivities();
                }
              },
              backgroundColor: AppTheme.surfaceCard,
              selectedColor: AppTheme.lavenderMist.withOpacity(0.3),
              labelStyle: TextStyle(
                color: isSelected ? AppTheme.lavenderMist : Colors.white70,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected
                    ? AppTheme.lavenderMist
                    : Colors.white.withOpacity(0.2),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildQuickRecordSection(AppLocalizations l10n) {
    final isOngoingSleep = _ongoingActivity != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('🚀', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(
              l10n.translate('quick_record') ?? '원탭 기록',
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          l10n.translate('quick_record_hint') ?? '탭하면 즉시 기록, 길게 누르면 상세 입력',
          style: const TextStyle(
            color: AppTheme.textTertiary,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 16),

        // 주요 3개 버튼 (수면/수유/기저귀)
        Row(
          children: [
            Expanded(
              child: _QuickRecordButton(
                emoji: isOngoingSleep ? '⏹️' : '😴',
                label: isOngoingSleep
                    ? (l10n.translate('end_sleep') ?? '수면 종료')
                    : (l10n.translate('start_sleep') ?? '지금 재움'),
                sublabel: isOngoingSleep
                    ? _getOngoingDuration()
                    : null,
                color: AppTheme.sleepColor,
                isHighlighted: isOngoingSleep,
                onTap: () => _quickRecord(ActivityType.sleep),
                onLongPress: () => _openDetailScreen(ActivityType.sleep),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickRecordButton(
                emoji: '🍼',
                label: l10n.translate('now_feeding') ?? '지금 수유',
                sublabel: '+120ml',
                color: AppTheme.feedingColor,
                onTap: () => _quickRecord(ActivityType.feeding),
                onLongPress: () => _openDetailScreen(ActivityType.feeding),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickRecordButton(
                emoji: '🧷',
                label: l10n.translate('now_diaper') ?? '지금 기저귀',
                color: AppTheme.diaperColor,
                onTap: () => _quickRecord(ActivityType.diaper),
                onLongPress: () => _openDetailScreen(ActivityType.diaper),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // 보조 2개 버튼 (놀이/건강)
        Row(
          children: [
            Expanded(
              child: _QuickRecordButton(
                emoji: '🎮',
                label: l10n.translate('play_record') ?? '놀이 기록',
                color: AppTheme.playColor,
                isCompact: true,
                onTap: () => _openDetailScreen(ActivityType.play),
                onLongPress: () => _openDetailScreen(ActivityType.play),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickRecordButton(
                emoji: '🏥',
                label: l10n.translate('health_record') ?? '건강 기록',
                color: AppTheme.healthColor,
                isCompact: true,
                onTap: () => _openDetailScreen(ActivityType.health),
                onLongPress: () => _openDetailScreen(ActivityType.health),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getOngoingDuration() {
    if (_ongoingActivity == null) return '';
    final start = DateTime.parse(_ongoingActivity!.timestamp);
    final duration = DateTime.now().difference(start);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  Widget _buildTimelineSection(AppLocalizations l10n) {
    final bool isKorean = l10n.locale.languageCode == 'ko';

    // 필터에 따라 제목 변경
    String timelineTitle;
    switch (_selectedFilter) {
      case DateRangeFilter.today:
        timelineTitle = isKorean ? '오늘의 타임라인' : 'Today\'s Timeline';
        break;
      case DateRangeFilter.week:
        timelineTitle = isKorean ? '최근 7일' : 'Last 7 Days';
        break;
      case DateRangeFilter.month:
        timelineTitle = isKorean ? '최근 30일' : 'Last 30 Days';
        break;
      case DateRangeFilter.all:
        timelineTitle = isKorean ? '전체 기록' : 'All Records';
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text('📅', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text(
                  timelineTitle,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                _buildTypeFilterButton(isKorean),
                const SizedBox(width: 8),
                _buildSortButton(isKorean),
                TextButton(
                  onPressed: () {
                    // TODO: 전체 히스토리 화면
                  },
                  child: Text(
                    l10n.translate('view_all') ?? '전체보기',
                    style: const TextStyle(
                      color: AppTheme.lavenderMist,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else if (_todayActivities.isEmpty)
          _buildEmptyTimeline(l10n)
        else
          _buildTimeline(),
      ],
    );
  }

  /// 타입 필터 버튼 (드롭다운)
  Widget _buildTypeFilterButton(bool isKorean) {
    return PopupMenuButton<ActivityTypeFilter>(
      onSelected: (ActivityTypeFilter filter) {
        setState(() {
          _typeFilter = filter;
        });
        _loadTodayActivities();
      },
      color: AppTheme.surfaceDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppTheme.lavenderMist.withOpacity(0.3)),
      ),
      itemBuilder: (context) {
        return ActivityTypeFilter.values.map((ActivityTypeFilter filter) {
          final bool isSelected = _typeFilter == filter;
          return PopupMenuItem<ActivityTypeFilter>(
            value: filter,
            child: Row(
              children: [
                Text(filter.getEmoji(), style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Text(
                  filter.getLabel(isKorean),
                  style: TextStyle(
                    color: isSelected ? AppTheme.lavenderMist : AppTheme.textPrimary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (isSelected) ...[
                  const Spacer(),
                  const Icon(Icons.check, size: 16, color: AppTheme.lavenderMist),
                ],
              ],
            ),
          );
        }).toList();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _typeFilter == ActivityTypeFilter.all
                ? AppTheme.lavenderMist.withOpacity(0.3)
                : AppTheme.lavenderMist,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_typeFilter.getEmoji(), style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 4),
            Text(
              _typeFilter.getLabel(isKorean),
              style: TextStyle(
                color: _typeFilter == ActivityTypeFilter.all
                    ? AppTheme.lavenderMist.withOpacity(0.7)
                    : AppTheme.lavenderMist,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.arrow_drop_down,
              size: 16,
              color: AppTheme.lavenderMist.withOpacity(0.7),
            ),
          ],
        ),
      ),
    );
  }

  /// 정렬 버튼 (최신순 ↔ 오래된순)
  Widget _buildSortButton(bool isKorean) {
    final String label = _sortOrder == SortOrder.newest
        ? (isKorean ? '최신순' : 'Newest')
        : (isKorean ? '오래된순' : 'Oldest');
    final IconData icon = _sortOrder == SortOrder.newest
        ? Icons.arrow_downward
        : Icons.arrow_upward;

    return InkWell(
      onTap: () {
        setState(() {
          _sortOrder = _sortOrder == SortOrder.newest
              ? SortOrder.oldest
              : SortOrder.newest;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppTheme.lavenderMist.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppTheme.lavenderMist),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.lavenderMist,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyTimeline(AppLocalizations l10n) {
    final bool isKorean = l10n.locale.languageCode == 'ko';

    // 필터에 따라 메시지 변경
    String emptyMessage;
    switch (_selectedFilter) {
      case DateRangeFilter.today:
        emptyMessage = isKorean ? '오늘 기록이 없어요' : 'No records today';
        break;
      case DateRangeFilter.week:
        emptyMessage = isKorean ? '최근 7일 기록이 없어요' : 'No records in the last 7 days';
        break;
      case DateRangeFilter.month:
        emptyMessage = isKorean ? '최근 30일 기록이 없어요' : 'No records in the last 30 days';
        break;
      case DateRangeFilter.all:
        emptyMessage = isKorean ? '기록이 없어요' : 'No records yet';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.glassBorder),
      ),
      child: Column(
        children: [
          const Text('🌙', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(
            emptyMessage,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.translate('start_first_record_hint') ?? '위 버튼을 눌러 첫 기록을 시작하세요',
            style: const TextStyle(
              color: AppTheme.textTertiary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  /// 활동을 날짜별로 그룹핑
  Map<String, List<ActivityModel>> _groupActivitiesByDate(List<ActivityModel> activities) {
    final Map<String, List<ActivityModel>> grouped = {};

    for (final ActivityModel activity in activities) {
      final DateTime date = DateTime.parse(activity.timestamp);
      final String dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      grouped.putIfAbsent(dateKey, () => []);
      grouped[dateKey]!.add(activity);
    }

    // 각 그룹 내에서 시간순 정렬 (정렬 순서에 따라)
    for (final List<ActivityModel> group in grouped.values) {
      if (_sortOrder == SortOrder.newest) {
        group.sort((ActivityModel a, ActivityModel b) =>
            DateTime.parse(b.timestamp).compareTo(DateTime.parse(a.timestamp)));
      } else {
        group.sort((ActivityModel a, ActivityModel b) =>
            DateTime.parse(a.timestamp).compareTo(DateTime.parse(b.timestamp)));
      }
    }

    return grouped;
  }

  /// 날짜 키를 사람이 읽기 쉬운 형식으로 변환
  String _formatDateHeader(String dateKey, bool isKorean) {
    final DateTime date = DateTime.parse(dateKey);
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime yesterday = today.subtract(const Duration(days: 1));
    final DateTime dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return isKorean ? '오늘' : 'Today';
    } else if (dateOnly == yesterday) {
      return isKorean ? '어제' : 'Yesterday';
    } else {
      // 이번 주인지 확인
      final int daysAgo = today.difference(dateOnly).inDays;
      if (daysAgo < 7) {
        final List<String> weekdaysKo = ['월', '화', '수', '목', '금', '토', '일'];
        final List<String> weekdaysEn = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        final int weekday = date.weekday - 1; // 0-6

        if (isKorean) {
          return '${weekdaysKo[weekday]}요일 (${date.month}/${date.day})';
        } else {
          return '${weekdaysEn[weekday]}, ${date.month}/${date.day}';
        }
      }

      // 그 외
      if (isKorean) {
        return '${date.year}년 ${date.month}월 ${date.day}일';
      } else {
        final List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                                      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        return '${months[date.month - 1]} ${date.day}, ${date.year}';
      }
    }
  }

  Widget _buildTimeline() {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool isKorean = l10n.locale.languageCode == 'ko';

    // 날짜별 그룹핑
    final Map<String, List<ActivityModel>> groupedActivities =
        _groupActivitiesByDate(_todayActivities);

    // 날짜 키를 정렬 순서에 따라 정렬
    final List<String> sortedDateKeys = groupedActivities.keys.toList();
    if (_sortOrder == SortOrder.newest) {
      sortedDateKeys.sort((String a, String b) => b.compareTo(a)); // 최신순
    } else {
      sortedDateKeys.sort((String a, String b) => a.compareTo(b)); // 오래된순
    }

    if (sortedDateKeys.isEmpty) {
      return Container();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sortedDateKeys.map((String dateKey) {
        final List<ActivityModel> dayActivities = groupedActivities[dateKey]!;
        return _buildDateSection(dateKey, dayActivities, isKorean);
      }).toList(),
    );
  }

  Widget _buildDateSection(String dateKey, List<ActivityModel> activities, bool isKorean) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 날짜 섹션 헤더
        _buildDateHeader(dateKey, activities.length, isKorean),

        // 해당 날짜의 활동들
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.glassBorder),
          ),
          child: Column(
            children: activities.map((activity) => _buildTimelineItem(activity)).toList(),
          ),
        ),

        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDateHeader(String dateKey, int count, bool isKorean) {
    final String formattedDate = _formatDateHeader(dateKey, isKorean);
    final String countText = isKorean ? '$count개 기록' : '$count records';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.lavenderMist.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 16,
                color: AppTheme.lavenderMist.withOpacity(0.7),
              ),
              const SizedBox(width: 8),
              Text(
                formattedDate,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Text(
            countText,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(ActivityModel activity) {
    final time = DateTime.parse(activity.timestamp);
    final timeStr = DateFormat('HH:mm').format(time);
    final emoji = _getEmoji(activity.type);
    final color = _getColor(activity.type);

    String title = _getLabel(activity.type);
    String? subtitle;
    bool isOngoing = false;

    // 상세 정보 구성
    switch (activity.type) {
      case ActivityType.sleep:
        if (activity.endTime == null) {
          isOngoing = true;
          final duration = DateTime.now().difference(time);
          subtitle = '⏱️ 진행 중 (${duration.inHours}h ${duration.inMinutes % 60}m)';
        } else if (activity.durationMinutes != null) {
          subtitle = _formatDuration(activity.durationMinutes!);
        }
        break;
      case ActivityType.feeding:
        if (activity.amountMl != null) {
          subtitle = '${activity.amountMl}ml';
        }
        break;
      case ActivityType.diaper:
        subtitle = activity.diaperType == 'dirty' ? '대변' : '소변';
        break;
      default:
        break;
    }

    return Dismissible(
      key: Key(activity.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppTheme.errorSoft,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      confirmDismiss: (direction) async {
        HapticFeedback.mediumImpact();
        return await _showDeleteConfirmation(context, activity);
      },
      onDismissed: (direction) async {
        await _deleteActivity(activity);
      },
      child: InkWell(
        onTap: () => _navigateToDetailScreen(activity),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          // 시간
          SizedBox(
            width: 50,
            child: Text(
              timeStr,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // 타임라인 라인
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isOngoing ? color : color.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: isOngoing
                      ? Border.all(color: color, width: 2)
                      : null,
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 14)),
                ),
              ),
            ],
          ),

          const SizedBox(width: 12),

          // 내용
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isOngoing ? color : AppTheme.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: isOngoing ? color : AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
              ],
            ),
          ),

          // 편집 버튼
          IconButton(
            icon: const Icon(Icons.more_horiz, color: AppTheme.textTertiary, size: 20),
            onPressed: () => _navigateToDetailScreen(activity),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
        ),
      ),
    );
  }

  /// 상세 화면으로 이동
  Future<void> _navigateToDetailScreen(ActivityModel activity) async {
    HapticFeedback.lightImpact();

    final deletedActivity = await Navigator.push<ActivityModel>(
      context,
      MaterialPageRoute(
        builder: (context) => ActivityDetailScreen(activity: activity),
      ),
    );

    // 돌아올 때 목록 새로고침
    _loadTodayActivities();

    // 활동이 삭제된 경우 Snackbar 표시
    if (deletedActivity != null && mounted) {
      _showDeletedSnackbar(deletedActivity);
    }
  }

  /// 활동 삭제 Snackbar 표시 (Undo 기능 포함)
  void _showDeletedSnackbar(ActivityModel deletedActivity) {
    final babyProvider = Provider.of<BabyProvider>(context, listen: false);
    final homeDataProvider = Provider.of<HomeDataProvider>(context, listen: false);
    final sweetSpotProvider = Provider.of<SweetSpotProvider>(context, listen: false);
    final currentBaby = babyProvider.currentBaby;
    if (currentBaby == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('활동이 삭제되었습니다'),
        backgroundColor: AppTheme.errorSoft,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: '취소',
          textColor: Colors.white,
          onPressed: () async {
            // Undo delete - restore the activity
            await _storage.saveActivity(deletedActivity);
            await WidgetService().updateAllWidgets();

            // ✅ Update HomeDataProvider
            await homeDataProvider.refreshDailySummary(currentBaby.id);

            // ✅ Update SweetSpotProvider (if sleep activity)
            if (deletedActivity.type == ActivityType.sleep) {
              final activities = await _storage.getActivities();
              final sleepActivities = activities
                  .where((a) => a.babyId == currentBaby.id && a.type == ActivityType.sleep && a.endTime != null)
                  .toList();

              DateTime? lastWakeTime;
              if (sleepActivities.isNotEmpty) {
                sleepActivities.sort((a, b) => b.timestamp.compareTo(a.timestamp));
                final endTimeStr = sleepActivities.first.endTime;
                lastWakeTime = endTimeStr != null ? DateTime.parse(endTimeStr) : DateTime.parse(sleepActivities.first.timestamp);
              }

              await sweetSpotProvider.initialize(
                baby: currentBaby,
                lastWakeUpTime: lastWakeTime,
              );
            }

            // Refresh the list
            _loadTodayActivities();

            HapticFeedback.lightImpact();
          },
        ),
      ),
    );
  }

  /// 삭제 확인 다이얼로그
  Future<bool?> _showDeleteConfirmation(BuildContext context, ActivityModel activity) {
    final l10n = AppLocalizations.of(context);
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: const Text(
          '활동 삭제',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: Text(
          '${_getLabel(activity.type)} 기록을 삭제하시겠습니까?\n삭제된 기록은 복구할 수 없습니다.',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              l10n.translate('cancel') ?? 'Cancel',
              style: const TextStyle(color: AppTheme.textTertiary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              l10n.translate('delete') ?? 'Delete',
              style: const TextStyle(
                color: AppTheme.errorSoft,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 활동 삭제 (다이얼로그 확인 후 호출됨)
  Future<void> _deleteActivity(ActivityModel activity) async {
    // 1. UI에서 즉시 제거
    setState(() {
      _todayActivities.remove(activity);
    });

    // 2. 실제 삭제 실행
    await _storage.deleteActivity(activity.id);
    await WidgetService().updateAllWidgets();

    // 3. HomeDataProvider의 dailySummary 업데이트
    final homeDataProvider = Provider.of<HomeDataProvider>(context, listen: false);
    final babyProvider = Provider.of<BabyProvider>(context, listen: false);
    final currentBaby = babyProvider.currentBaby;
    if (currentBaby != null) {
      await homeDataProvider.refreshDailySummary(currentBaby.id);
    }

    // 4. Haptic 피드백
    HapticFeedback.lightImpact();
  }

  Widget _buildTodaySummary(AppLocalizations l10n) {
    // 오늘 통계 계산
    int sleepCount = 0;
    int totalSleepMinutes = 0;
    int feedingCount = 0;
    int totalFeedingMl = 0;
    int diaperCount = 0;

    for (final activity in _todayActivities) {
      switch (activity.type) {
        case ActivityType.sleep:
          if (activity.durationMinutes != null) {
            sleepCount++;
            totalSleepMinutes += activity.durationMinutes!;
          }
          break;
        case ActivityType.feeding:
          feedingCount++;
          if (activity.amountMl != null) {
            totalFeedingMl += activity.amountMl!.toInt();
          }
          break;
        case ActivityType.diaper:
          diaperCount++;
          break;
        default:
          break;
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.lavenderMist.withOpacity(0.2),
            AppTheme.primaryDark.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('💡', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                l10n.translate('today_summary') ?? '오늘 요약',
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(
                '😴',
                '$sleepCount회',
                _formatDuration(totalSleepMinutes),
              ),
              Container(width: 1, height: 40, color: AppTheme.glassBorder),
              _buildSummaryItem(
                '🍼',
                '$feedingCount회',
                '${totalFeedingMl}ml',
              ),
              Container(width: 1, height: 40, color: AppTheme.glassBorder),
              _buildSummaryItem(
                '🧷',
                '$diaperCount회',
                '',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String emoji, String value, String subtitle) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (subtitle.isNotEmpty)
          Text(
            subtitle,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
            ),
          ),
      ],
    );
  }
}

/// 원탭 기록 버튼 위젯
class _QuickRecordButton extends StatelessWidget {
  final String emoji;
  final String label;
  final String? sublabel;
  final Color color;
  final bool isCompact;
  final bool isHighlighted;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _QuickRecordButton({
    required this.emoji,
    required this.label,
    required this.color,
    required this.onTap,
    required this.onLongPress,
    this.sublabel,
    this.isCompact = false,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          vertical: isCompact ? 12 : 16,
          horizontal: 12,
        ),
        decoration: BoxDecoration(
          color: isHighlighted
              ? color.withOpacity(0.3)
              : AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isHighlighted ? color : AppTheme.glassBorder,
            width: isHighlighted ? 2 : 1,
          ),
          boxShadow: isHighlighted
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              emoji,
              style: TextStyle(fontSize: isCompact ? 24 : 32),
            ),
            SizedBox(height: isCompact ? 4 : 8),
            Text(
              label,
              style: TextStyle(
                color: isHighlighted ? color : AppTheme.textPrimary,
                fontSize: isCompact ? 12 : 13,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (sublabel != null && !isCompact) ...[
              const SizedBox(height: 2),
              Text(
                sublabel!,
                style: TextStyle(
                  color: isHighlighted ? color : AppTheme.textTertiary,
                  fontSize: 11,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
