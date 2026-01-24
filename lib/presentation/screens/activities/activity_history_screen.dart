import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/activity_model.dart';
import '../../../data/services/local_storage_service.dart';
import '../../../core/localization/app_localizations.dart';

/// 활동 히스토리 화면
class ActivityHistoryScreen extends StatefulWidget {
  const ActivityHistoryScreen({Key? key}) : super(key: key);

  @override
  State<ActivityHistoryScreen> createState() => _ActivityHistoryScreenState();
}

class _ActivityHistoryScreenState extends State<ActivityHistoryScreen> {
  final _storage = LocalStorageService();
  List<ActivityModel> _activities = [];
  ActivityType? _filterType;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    setState(() {
      _isLoading = true;
    });

    final activities = await _storage.getActivities();

    // 최신순 정렬
    activities.sort((a, b) =>
        DateTime.parse(b.timestamp).compareTo(DateTime.parse(a.timestamp)));

    setState(() {
      _activities = activities;
      _isLoading = false;
    });
  }

  List<ActivityModel> get _filteredActivities {
    if (_filterType == null) return _activities;
    return _activities.where((a) => a.type == _filterType).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('activity_history')),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadActivities,
            tooltip: l10n.translate('refresh'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Buttons
          Container(
            height: 60,
            padding: EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(
                bottom: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 12),
              children: [
                _buildFilterChip(null, l10n.translate('all'), Icons.list),
                SizedBox(width: 8),
                _buildFilterChip(ActivityType.sleep, l10n.translate('sleep'), Icons.bedtime),
                SizedBox(width: 8),
                _buildFilterChip(
                    ActivityType.feeding, l10n.translate('feeding'), Icons.restaurant),
                SizedBox(width: 8),
                _buildFilterChip(ActivityType.diaper, l10n.translate('diaper'),
                    Icons.baby_changing_station),
                SizedBox(width: 8),
                _buildFilterChip(ActivityType.play, l10n.translate('play'), Icons.toys),
              ],
            ),
          ),

          // Activity List
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _filteredActivities.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadActivities,
                        child: ListView.builder(
                          padding: EdgeInsets.all(16),
                          itemCount: _filteredActivities.length,
                          itemBuilder: (context, index) {
                            final activity = _filteredActivities[index];
                            return _buildActivityItem(activity, index);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(ActivityType? type, String label, IconData icon) {
    final isSelected = _filterType == type;

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          SizedBox(width: 6),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filterType = type;
        });
      },
      selectedColor: _getTypeColor(type)?.withOpacity(0.2),
      checkmarkColor: _getTypeColor(type),
    );
  }

  Widget _buildActivityItem(ActivityModel activity, int index) {
    final l10n = AppLocalizations.of(context)!;
    final timestamp = DateTime.parse(activity.timestamp);
    final isToday = _isToday(timestamp);
    final showDate = index == 0 ||
        !_isSameDay(
            timestamp,
            DateTime.parse(
                _filteredActivities[index - 1].timestamp));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date Header
        if (showDate)
          Padding(
            padding: EdgeInsets.only(top: index == 0 ? 0 : 16, bottom: 12),
            child: Text(
              isToday ? l10n.translate('today') : DateFormat('EEEE, MMM d').format(timestamp),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),

        // Activity Card
        InkWell(
          onLongPress: () => _showActivityMenu(activity),
          child: Container(
            margin: EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getTypeColor(activity.type)?.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getTypeIcon(activity.type),
                      color: _getTypeColor(activity.type),
                      size: 24,
                    ),
                  ),

                  SizedBox(width: 16),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _getTypeName(activity.type),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              DateFormat('h:mm a').format(timestamp),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        _buildActivityDetails(activity),
                        if (activity.notes != null) ...[
                          SizedBox(height: 8),
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.note, size: 14, color: Colors.grey[600]),
                                SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    activity.notes!,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[700],
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityDetails(ActivityModel activity) {
    switch (activity.type) {
      case ActivityType.sleep:
        final duration = activity.durationMinutes;
        final location = activity.sleepLocation;
        final quality = activity.sleepQuality;

        return Wrap(
          spacing: 12,
          runSpacing: 6,
          children: [
            if (duration != null)
              _buildDetailChip(
                Icons.timer,
                '${duration ~/ 60}h ${duration % 60}m',
                Colors.purple,
              ),
            if (location != null)
              _buildDetailChip(Icons.location_on, location, Colors.blue),
            if (quality != null)
              _buildDetailChip(
                quality == 'good'
                    ? Icons.mood
                    : quality == 'fair'
                        ? Icons.sentiment_neutral
                        : Icons.mood_bad,
                quality,
                quality == 'good'
                    ? Colors.green
                    : quality == 'fair'
                        ? Colors.orange
                        : Colors.red,
              ),
          ],
        );

      case ActivityType.feeding:
        final type = activity.feedingType;
        final amountMl = activity.amountMl;
        final amountOz = activity.amountOz;
        final breastSide = activity.breastSide;

        return Wrap(
          spacing: 12,
          runSpacing: 6,
          children: [
            if (type != null)
              _buildDetailChip(
                type == 'bottle'
                    ? Icons.local_drink
                    : type == 'breast'
                        ? Icons.favorite
                        : Icons.restaurant_menu,
                type,
                Colors.orange,
              ),
            if (amountMl != null && amountOz != null)
              _buildDetailChip(
                Icons.water_drop,
                '${amountMl.toInt()}ml (${amountOz.toStringAsFixed(1)}oz)',
                Colors.blue,
              ),
            if (breastSide != null)
              _buildDetailChip(Icons.info, breastSide, Colors.pink),
          ],
        );

      case ActivityType.diaper:
        final type = activity.diaperType;
        return _buildDetailChip(
          Icons.info,
          type ?? 'diaper change',
          Colors.green,
        );

      case ActivityType.play:
        final duration = activity.durationMinutes;
        return duration != null
            ? _buildDetailChip(
                Icons.timer,
                '${duration}m',
                Colors.amber,
              )
            : SizedBox.shrink();

      case ActivityType.health:
        final temp = activity.temperatureCelsius;
        final med = activity.medicationName;

        return Wrap(
          spacing: 12,
          runSpacing: 6,
          children: [
            if (temp != null)
              _buildDetailChip(
                Icons.thermostat,
                '${temp.toStringAsFixed(1)}°C',
                temp >= 38.0 ? Colors.red : Colors.blue,
              ),
            if (med != null)
              _buildDetailChip(
                Icons.medication,
                med,
                Colors.teal,
              ),
          ],
        );
    }
  }

  Widget _buildDetailChip(IconData icon, String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            _filterType == null
                ? l10n.translate('no_activities_yet')
                : l10n.translate('no_activities_type').replaceAll('{type}', _getTypeName(_filterType!).toLowerCase()),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            l10n.translate('start_logging'),
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  void _showActivityMenu(ActivityModel activity) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red),
              title: Text(l10n.translate('delete')),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(activity);
              },
            ),
            // Edit functionality can be added in future updates
            // ListTile(
            //   leading: Icon(Icons.edit, color: Colors.blue),
            //   title: Text('Edit'),
            //   onTap: () {
            //     Navigator.pop(context);
            //     _editActivity(activity);
            //   },
            // ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(ActivityModel activity) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.translate('delete_activity')),
        content: Text(
            l10n.translate('confirm_delete_activity').replaceAll('{type}', _getTypeName(activity.type).toLowerCase())),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.translate('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.translate('delete')),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _storage.deleteActivity(activity.id);
      await _loadActivities();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.translate('activity_deleted')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  IconData _getTypeIcon(ActivityType type) {
    switch (type) {
      case ActivityType.sleep:
        return Icons.bedtime;
      case ActivityType.feeding:
        return Icons.restaurant;
      case ActivityType.diaper:
        return Icons.baby_changing_station;
      case ActivityType.play:
        return Icons.toys;
      case ActivityType.health:
        return Icons.medication;
    }
  }

  Color? _getTypeColor(ActivityType? type) {
    if (type == null) return Colors.grey[700];
    switch (type) {
      case ActivityType.sleep:
        return Colors.purple;
      case ActivityType.feeding:
        return Colors.orange;
      case ActivityType.diaper:
        return Colors.green;
      case ActivityType.play:
        return Colors.amber;
      case ActivityType.health:
        return Colors.teal;
    }
  }

  String _getTypeName(ActivityType type) {
    final l10n = AppLocalizations.of(context)!;
    switch (type) {
      case ActivityType.sleep:
        return l10n.translate('sleep');
      case ActivityType.feeding:
        return l10n.translate('feeding');
      case ActivityType.diaper:
        return l10n.translate('diaper');
      case ActivityType.play:
        return l10n.translate('play');
      case ActivityType.health:
        return l10n.translate('health');
    }
  }
}
