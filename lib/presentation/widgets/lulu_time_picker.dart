import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_theme.dart';

/// Lulu 앱 전용 iOS 스타일 시간 피커
///
/// 특징:
/// - 실시간 상대 시간 표시 ("11분 전", "2시간 전")
/// - CupertinoPicker 기반 드럼 스크롤
/// - "오늘" 날짜 하이라이트
/// - Midnight Blue 테마
/// - 한/영 다국어 지원
class LuluTimePicker extends StatefulWidget {
  final DateTime initialTime;
  final ValueChanged<DateTime>? onTimeSelected;
  final int dateRangeDays;
  final bool allowFutureTime;

  const LuluTimePicker({
    Key? key,
    required this.initialTime,
    this.onTimeSelected,
    this.dateRangeDays = 7,
    this.allowFutureTime = false,
  }) : super(key: key);

  /// 편의 메서드: BottomSheet로 표시
  ///
  /// 사용 예시:
  /// ```dart
  /// final selectedTime = await LuluTimePicker.show(
  ///   context: context,
  ///   initialTime: DateTime.now(),
  /// );
  /// ```
  static Future<DateTime?> show({
    required BuildContext context,
    DateTime? initialTime,
    int dateRangeDays = 7,
    bool allowFutureTime = false,
  }) async {
    return showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LuluTimePicker(
        initialTime: initialTime ?? DateTime.now(),
        dateRangeDays: dateRangeDays,
        allowFutureTime: allowFutureTime,
        onTimeSelected: (time) => Navigator.pop(context, time),
      ),
    );
  }

  @override
  State<LuluTimePicker> createState() => _LuluTimePickerState();
}

class _LuluTimePickerState extends State<LuluTimePicker> {
  late FixedExtentScrollController _dateController;
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;

  late DateTime _selectedDateTime;
  late List<DateTime> _availableDates;

  @override
  void initState() {
    super.initState();
    _selectedDateTime = widget.initialTime;
    _generateAvailableDates();

    // 초기 선택 인덱스 계산
    final initialDateIndex = _getDateIndex(_selectedDateTime);
    _dateController = FixedExtentScrollController(initialItem: initialDateIndex);
    _hourController = FixedExtentScrollController(initialItem: _selectedDateTime.hour);
    _minuteController = FixedExtentScrollController(initialItem: _selectedDateTime.minute);
  }

  @override
  void dispose() {
    _dateController.dispose();
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  /// 선택 가능한 날짜 목록 생성
  void _generateAvailableDates() {
    _availableDates = [];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (int i = widget.dateRangeDays - 1; i >= 0; i--) {
      _availableDates.add(today.subtract(Duration(days: i)));
    }

    // 미래 시간 허용 시 내일 추가
    if (widget.allowFutureTime) {
      _availableDates.add(today.add(const Duration(days: 1)));
    }
  }

  /// 날짜의 인덱스 찾기
  int _getDateIndex(DateTime dateTime) {
    final targetDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final index = _availableDates.indexWhere(
      (date) => date.year == targetDate.year &&
          date.month == targetDate.month &&
          date.day == targetDate.day,
    );
    return index >= 0 ? index : _availableDates.length - 1;
  }

  /// 상대 시간 텍스트 생성
  String _getRelativeTimeText(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final diff = now.difference(_selectedDateTime);

    // 미래 시간
    if (diff.isNegative) {
      final futureDiff = _selectedDateTime.difference(now);
      if (futureDiff.inMinutes < 60) {
        return '${futureDiff.inMinutes}${l10n.translate('time_minutes_later')}';
      }
      return '${futureDiff.inHours}${l10n.translate('time_hours_later')}';
    }

    // 과거 시간
    if (diff.inSeconds < 60) {
      return l10n.translate('time_now');
    }

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}${l10n.translate('time_minutes_ago')}';
    }

    if (diff.inHours < 24) {
      final hours = diff.inHours;
      final minutes = diff.inMinutes % 60;

      if (minutes == 0) {
        return '$hours${l10n.translate('time_hours_ago')}';
      }
      return '$hours${l10n.translate('time_hours_ago')} $minutes${l10n.translate('time_minutes_ago')}';
    }

    if (diff.inHours < 48) {
      return l10n.translate('time_yesterday');
    }

    final days = diff.inDays;
    return '$days${l10n.translate('time_days_ago')}';
  }

  /// 날짜 변경 핸들러
  void _onDateChanged(int index) {
    setState(() {
      _selectedDateTime = DateTime(
        _availableDates[index].year,
        _availableDates[index].month,
        _availableDates[index].day,
        _selectedDateTime.hour,
        _selectedDateTime.minute,
      );
    });
  }

  /// 시간 변경 핸들러
  void _onHourChanged(int hour) {
    setState(() {
      _selectedDateTime = DateTime(
        _selectedDateTime.year,
        _selectedDateTime.month,
        _selectedDateTime.day,
        hour,
        _selectedDateTime.minute,
      );
    });
  }

  /// 분 변경 핸들러
  void _onMinuteChanged(int minute) {
    setState(() {
      _selectedDateTime = DateTime(
        _selectedDateTime.year,
        _selectedDateTime.month,
        _selectedDateTime.day,
        _selectedDateTime.hour,
        minute,
      );
    });
  }

  /// 확인 버튼 핸들러
  void _onConfirm() {
    widget.onTimeSelected?.call(_selectedDateTime);
  }

  /// 취소 버튼 핸들러
  void _onCancel() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      height: 360,
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag Handle
          _buildDragHandle(),

          // Relative Time Header
          _buildRelativeTimeHeader(context),

          // Picker Row
          Expanded(
            child: _buildPickerRow(context),
          ),

          // Action Buttons
          _buildActionButtons(l10n),
        ],
      ),
    );
  }

  /// Drag Handle 위젯
  Widget _buildDragHandle() {
    return Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: AppTheme.softBlue.withOpacity(0.3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  /// 상대 시간 헤더
  Widget _buildRelativeTimeHeader(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      alignment: Alignment.center,
      child: Text(
        _getRelativeTimeText(context),
        style: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppTheme.lavenderMist,
        ),
      ),
    );
  }

  /// 피커 행 (날짜/시간/분)
  Widget _buildPickerRow(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Stack(
      children: [
        // Selection Overlay (중앙 하이라이트)
        Center(
          child: Container(
            height: 40,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: AppTheme.lavenderMist.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),

        // Pickers
        Row(
          children: [
            // Date Picker (flex: 2)
            Expanded(
              flex: 2,
              child: CupertinoPicker(
                scrollController: _dateController,
                itemExtent: 40,
                diameterRatio: 1.1,
                onSelectedItemChanged: _onDateChanged,
                children: _availableDates.map((date) {
                  return _buildDatePickerItem(context, date);
                }).toList(),
              ),
            ),

            // Hour Picker (flex: 1)
            Expanded(
              child: CupertinoPicker(
                scrollController: _hourController,
                itemExtent: 40,
                diameterRatio: 1.1,
                onSelectedItemChanged: _onHourChanged,
                children: List.generate(24, (hour) {
                  return Center(
                    child: Text(
                      hour.toString().padLeft(2, '0'),
                      style: const TextStyle(
                        fontSize: 20,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Minute Picker (flex: 1)
            Expanded(
              child: CupertinoPicker(
                scrollController: _minuteController,
                itemExtent: 40,
                diameterRatio: 1.1,
                onSelectedItemChanged: _onMinuteChanged,
                children: List.generate(60, (minute) {
                  return Center(
                    child: Text(
                      minute.toString().padLeft(2, '0'),
                      style: const TextStyle(
                        fontSize: 20,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 날짜 피커 아이템
  Widget _buildDatePickerItem(BuildContext context, DateTime date) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final tomorrow = today.add(const Duration(days: 1));

    final isToday = date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;

    final isYesterday = date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;

    final isTomorrow = date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day;

    String label;
    Color textColor;

    if (isToday) {
      label = l10n.translate('time_today');
      textColor = AppTheme.lavenderMist; // 하이라이트
    } else if (isYesterday) {
      label = l10n.translate('time_yesterday');
      textColor = AppTheme.textPrimary;
    } else if (isTomorrow) {
      label = l10n.translate('time_tomorrow');
      textColor = AppTheme.textPrimary;
    } else {
      // "1월 23일" 형식
      final locale = Localizations.localeOf(context).languageCode;
      if (locale == 'ko') {
        label = '${date.month}월 ${date.day}일';
      } else {
        final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        label = '${months[date.month - 1]} ${date.day}';
      }
      textColor = AppTheme.textTertiary;
    }

    return Center(
      child: Text(
        label,
        style: TextStyle(
          fontSize: 20,
          fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
          color: textColor,
        ),
      ),
    );
  }

  /// 액션 버튼 (취소/확인)
  Widget _buildActionButtons(AppLocalizations l10n) {
    return Container(
      height: 88,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // 취소 버튼
          Expanded(
            child: SizedBox(
              height: 52,
              child: OutlinedButton(
                onPressed: _onCancel,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: AppTheme.softBlue.withOpacity(0.3),
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  l10n.translate('cancel'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // 확인 버튼
          Expanded(
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _onConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.lavenderMist,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  l10n.translate('confirm'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.midnightNavy,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
