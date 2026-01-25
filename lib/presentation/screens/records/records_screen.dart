import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/activity_model.dart';
import '../../../data/services/local_storage_service.dart';
import '../../../data/services/widget_service.dart';
import '../../utils/snackbar_utils.dart';
import '../activities/log_sleep_screen.dart';
import '../activities/log_feeding_screen.dart';
import '../activities/log_diaper_screen.dart';
import '../activities/log_play_screen.dart';
import '../activities/log_health_screen.dart';
import 'activity_detail_screen.dart';

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

  // 진행 중인 활동 (수면 타이머 등)
  ActivityModel? _ongoingActivity;

  @override
  void initState() {
    super.initState();
    _loadTodayActivities();
  }

  Future<void> _loadTodayActivities() async {
    setState(() => _isLoading = true);

    final activities = await _storage.getActivities();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final todayActivities = activities.where((a) {
      final actDate = DateTime.parse(a.timestamp);
      return actDate.isAfter(today) || actDate.isAtSameMomentAs(today);
    }).toList();

    // 시간순 정렬 (최신이 아래로)
    todayActivities.sort((a, b) =>
        DateTime.parse(a.timestamp).compareTo(DateTime.parse(b.timestamp)));

    // 진행 중인 수면 찾기
    final ongoing = todayActivities.where((a) =>
        a.type == ActivityType.sleep && a.endTime == null).firstOrNull;

    setState(() {
      _todayActivities = todayActivities;
      _ongoingActivity = ongoing;
      _isLoading = false;
    });
  }

  /// 원탭 기록 - 즉시 저장
  Future<void> _quickRecord(ActivityType type) async {
    HapticFeedback.mediumImpact();

    final now = DateTime.now();

    // 수면인 경우: 진행 중이면 종료, 아니면 시작
    if (type == ActivityType.sleep) {
      if (_ongoingActivity != null) {
        await _endSleep();
        return;
      }
    }

    final activity = ActivityModel(
      id: now.millisecondsSinceEpoch.toString(),
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

    _showQuickFeedback(type);
    _loadTodayActivities();
  }

  /// 수면 종료
  Future<void> _endSleep() async {
    if (_ongoingActivity == null) return;

    final now = DateTime.now();
    final startTime = DateTime.parse(_ongoingActivity!.timestamp);
    final duration = now.difference(startTime).inMinutes;

    final updated = ActivityModel(
      id: _ongoingActivity!.id,
      type: ActivityType.sleep,
      timestamp: _ongoingActivity!.timestamp,
      endTime: now.toIso8601String(),
      durationMinutes: duration,
      sleepQuality: _ongoingActivity!.sleepQuality,
      sleepLocation: _ongoingActivity!.sleepLocation,
    );

    await _storage.updateActivity(updated);
    await WidgetService().updateAllWidgets();

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
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🚀 원탭 기록 섹션
              _buildQuickRecordSection(l10n),

              const SizedBox(height: 24),

              // 📅 오늘의 타임라인
              _buildTimelineSection(l10n),

              const SizedBox(height: 24),

              // 💡 오늘 요약
              _buildTodaySummary(l10n),

              const SizedBox(height: 100), // 바텀 패딩
            ],
          ),
        ),
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
                  l10n.translate('todays_timeline') ?? '오늘의 타임라인',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
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

  Widget _buildEmptyTimeline(AppLocalizations l10n) {
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
            l10n.translate('no_records_today') ?? '오늘 기록이 없어요',
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

  Widget _buildTimeline() {
    // 오전/오후로 그룹핑
    final morningActivities = _todayActivities.where((a) {
      final hour = DateTime.parse(a.timestamp).hour;
      return hour < 12;
    }).toList();

    final afternoonActivities = _todayActivities.where((a) {
      final hour = DateTime.parse(a.timestamp).hour;
      return hour >= 12;
    }).toList();

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (morningActivities.isNotEmpty) ...[
            _buildTimelineGroup('🌅 오전', morningActivities),
          ],
          if (afternoonActivities.isNotEmpty) ...[
            if (morningActivities.isNotEmpty)
              const Divider(height: 1, color: AppTheme.glassBorder),
            _buildTimelineGroup('🌞 오후', afternoonActivities),
          ],
        ],
      ),
    );
  }

  Widget _buildTimelineGroup(String title, List<ActivityModel> activities) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...activities.map((activity) => _buildTimelineItem(activity)),
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
        await _deleteActivityWithUndo(activity);
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

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ActivityDetailScreen(activity: activity),
      ),
    );

    // 돌아올 때 목록 새로고침
    _loadTodayActivities();
  }

  /// 삭제 확인 다이얼로그
  Future<bool?> _showDeleteConfirmation(BuildContext context, ActivityModel activity) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: const Text(
          '활동 삭제',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: Text(
          '${_getLabel(activity.type)} 기록을 삭제하시겠습니까?\n삭제 후 3초 내에 취소할 수 있습니다.',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              '취소',
              style: TextStyle(color: AppTheme.textTertiary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              '삭제',
              style: TextStyle(
                color: AppTheme.errorSoft,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 삭제 + Undo 기능
  Future<void> _deleteActivityWithUndo(ActivityModel activity) async {
    final l10n = AppLocalizations.of(context);
    final deletedActivity = activity;
    final deletedIndex = _todayActivities.indexOf(activity);

    // 1. Optimistic Update - UI에서 즉시 제거
    setState(() {
      _todayActivities.remove(activity);
    });

    if (!mounted) return;

    // 2. Undo 가능한 스낵바 표시
    final wasUndone = await LuluSnackBar.showDestructive(
      context,
      message: '${_getLabel(activity.type)} ${l10n.translate('activity_deleted')}',
      undoLabel: l10n.translate('undo'),
      duration: const Duration(seconds: 5),
      onUndo: () async {
        // 복원 로직
        setState(() {
          if (deletedIndex >= 0 && deletedIndex <= _todayActivities.length) {
            _todayActivities.insert(deletedIndex, deletedActivity);
          } else {
            _todayActivities.add(deletedActivity);
            _todayActivities.sort((a, b) =>
              DateTime.parse(b.timestamp).compareTo(DateTime.parse(a.timestamp)));
          }
        });
        HapticFeedback.lightImpact();
      },
    );

    // 3. Undo하지 않은 경우에만 실제 삭제
    if (!wasUndone) {
      await _storage.deleteActivity(activity.id);
      await WidgetService().updateAllWidgets();
    }
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
