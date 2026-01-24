import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// 🔍 Records Filter Bar
/// 날짜 필터와 검색 기능을 제공하는 바
class RecordsFilterBar extends StatelessWidget {
  final DateTimeRange? dateRange;
  final VoidCallback onDateFilterTap;
  final VoidCallback? onSearchTap;
  final String? searchQuery;

  const RecordsFilterBar({
    Key? key,
    this.dateRange,
    required this.onDateFilterTap,
    this.onSearchTap,
    this.searchQuery,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.lavenderMist.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // 날짜 필터 버튼
          Expanded(
            child: _buildFilterChip(
              icon: Icons.calendar_today_outlined,
              label: _getDateRangeLabel(),
              onTap: onDateFilterTap,
              isActive: dateRange != null,
            ),
          ),
          const SizedBox(width: 12),

          // 검색 버튼 (선택사항)
          if (onSearchTap != null)
            _buildFilterChip(
              icon: Icons.search,
              label: searchQuery ?? '검색',
              onTap: onSearchTap!,
              isActive: searchQuery != null && searchQuery!.isNotEmpty,
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.lavenderMist.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive
                ? AppTheme.lavenderMist
                : AppTheme.lavenderMist.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? AppTheme.lavenderMist : AppTheme.textSecondary,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: isActive ? AppTheme.lavenderMist : AppTheme.textSecondary,
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDateRangeLabel() {
    if (dateRange == null) return '전체 기간';

    final start = dateRange!.start;
    final end = dateRange!.end;

    // 같은 날
    if (start.year == end.year &&
        start.month == end.month &&
        start.day == end.day) {
      return '${start.month}/${start.day}';
    }

    // 같은 달
    if (start.year == end.year && start.month == end.month) {
      return '${start.month}/${start.day}-${end.day}';
    }

    // 다른 달
    return '${start.month}/${start.day} - ${end.month}/${end.day}';
  }
}

/// 날짜 범위 선택 다이얼로그
Future<DateTimeRange?> showDateRangePicker({
  required BuildContext context,
  DateTimeRange? initialDateRange,
}) async {
  final now = DateTime.now();

  return await showDateRangePicker(
    context: context,
    firstDate: DateTime(now.year - 1),
    lastDate: now,
    initialDateRange: initialDateRange ??
        DateTimeRange(
          start: DateTime(now.year, now.month, 1),
          end: now,
        ),
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppTheme.lavenderMist,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: AppTheme.textPrimary,
          ),
        ),
        child: child!,
      );
    },
  );
}
