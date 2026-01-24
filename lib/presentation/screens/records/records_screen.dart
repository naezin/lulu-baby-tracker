import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart'; // Temporarily disabled for web
import '../../../data/services/firestore_stub.dart';
import 'package:intl/intl.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/activity_model.dart';
import '../../../data/services/insights_service.dart';
import '../../../data/services/local_storage_service.dart';
import '../../widgets/insights/qa_insight_card.dart';
import '../activities/log_sleep_screen.dart';
import '../activities/log_feeding_screen.dart';
import '../activities/log_diaper_screen.dart';
import '../activities/log_play_screen.dart';
import '../activities/log_health_screen.dart';

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({Key? key}) : super(key: key);

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  ActivityType _selectedType = ActivityType.sleep;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          switch (_tabController.index) {
            case 0:
              _selectedType = ActivityType.sleep;
              break;
            case 1:
              _selectedType = ActivityType.feeding;
              break;
            case 2:
              _selectedType = ActivityType.play;
              break;
            case 3:
              _selectedType = ActivityType.diaper;
              break;
            case 4:
              _selectedType = ActivityType.health;
              break;
            case 5:
              _selectedType = ActivityType.sleep; // All
              break;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navRecords),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(icon: Icon(Icons.bedtime), text: l10n.translate('records_sleep')),
            Tab(icon: Icon(Icons.restaurant), text: l10n.translate('records_feeding')),
            Tab(icon: Icon(Icons.toys_outlined), text: l10n.translate('records_play')),
            Tab(icon: Icon(Icons.baby_changing_station), text: l10n.translate('records_diaper')),
            Tab(icon: Icon(Icons.medication), text: l10n.translate('records_health')),
            Tab(icon: Icon(Icons.list), text: l10n.translate('records_all')),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRecordsList(ActivityType.sleep),
          _buildRecordsList(ActivityType.feeding),
          _buildRecordsList(ActivityType.play),
          _buildRecordsList(ActivityType.diaper),
          _buildRecordsList(ActivityType.health),
          _buildRecordsList(null), // All types
        ],
      ),
      floatingActionButton: _tabController.index < 5 ? FloatingActionButton(
        onPressed: () => _navigateToAddScreen(context, _selectedType),
        child: Icon(Icons.add),
        tooltip: l10n.translate('add_record'),
      ) : null,
    );
  }

  Widget _buildRecordsList(ActivityType? type) {
    final l10n = AppLocalizations.of(context)!;

    // Demo user ID - in production, get from auth
    const userId = 'demo-user';

    Query query = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('activities')
        .orderBy('timestamp', descending: true)
        .limit(100);

    if (type != null) {
      query = query.where('type', isEqualTo: type.toString().split('.').last);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                SizedBox(height: 16),
                Text(l10n.translate('error_loading_records'), style: TextStyle(color: Colors.red)),
                SizedBox(height: 8),
                Text(snapshot.error.toString(), style: TextStyle(fontSize: 12)),
              ],
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getIconForType(type),
                  size: 64,
                  color: Colors.grey[400],
                ),
                SizedBox(height: 16),
                Text(
                  l10n.translate('records_empty'),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  l10n.translate('records_empty_subtitle'),
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        final activities = snapshot.data!.docs
            .map((doc) => ActivityModel.fromJson({
                  'id': doc.id,
                  ...doc.data() as Map<String, dynamic>,
                }))
            .toList();

        return CustomScrollView(
          slivers: [
            // Insights Section
            SliverToBoxAdapter(
              child: FutureBuilder<List<QAInsight>>(
                future: _loadInsights(type),
                builder: (context, insightSnapshot) {
                  if (insightSnapshot.hasData && insightSnapshot.data!.isNotEmpty) {
                    final insights = insightSnapshot.data!;
                    final relevantInsight = _getRelevantInsight(insights, type);

                    if (relevantInsight != null) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: QAInsightCard(
                          question: relevantInsight.question,
                          answer: relevantInsight.answer,
                          metrics: relevantInsight.metrics,
                          actionLabel: relevantInsight.actionLabel,
                          onAction: relevantInsight.onAction,
                        ),
                      );
                    }
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),

            // Activity List
            SliverPadding(
              padding: EdgeInsets.all(8),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final activity = activities[index];
                    return _buildActivityCard(activity);
                  },
                  childCount: activities.length,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Load insights based on baby age
  Future<List<QAInsight>> _loadInsights(ActivityType? type) async {
    final insightsService = InsightsService();
    // Default baby age - in production, get from user profile
    const babyAgeInDays = 60; // 2 months old
    return await insightsService.getMainInsights(babyAgeInDays: babyAgeInDays);
  }

  /// Get most relevant insight for the current tab
  QAInsight? _getRelevantInsight(List<QAInsight> insights, ActivityType? type) {
    if (type == null) {
      // "All" tab - show first insight
      return insights.isNotEmpty ? insights.first : null;
    }

    // Find insight most relevant to the current activity type
    for (final insight in insights) {
      switch (type) {
        case ActivityType.sleep:
          if (insight.question.contains('수면') || insight.question.contains('밤잠')) {
            return insight;
          }
          break;
        case ActivityType.feeding:
          if (insight.question.contains('수유')) {
            return insight;
          }
          break;
        case ActivityType.play:
          if (insight.question.contains('터미타임') || insight.question.contains('발달')) {
            return insight;
          }
          break;
        default:
          break;
      }
    }

    // If no type-specific insight found, show the first one
    return insights.isNotEmpty ? insights.first : null;
  }

  Widget _buildActivityCard(ActivityModel activity) {
    final time = DateTime.parse(activity.timestamp);
    final timeStr = DateFormat('MMM dd, yyyy HH:mm').format(time);

    IconData icon;
    Color color;
    String title;
    String subtitle = '';

    switch (activity.type) {
      case ActivityType.sleep:
        icon = Icons.bedtime;
        color = Colors.purple;
        title = AppLocalizations.of(context)!.translate('sleep');
        if (activity.durationMinutes != null) {
          final hours = activity.durationMinutes! ~/ 60;
          final minutes = activity.durationMinutes! % 60;
          subtitle = '${hours}h ${minutes}m';
          if (activity.sleepQuality != null) {
            subtitle += ' • ${activity.sleepQuality}';
          }
        }
        break;
      case ActivityType.feeding:
        icon = Icons.restaurant;
        color = Colors.orange;
        title = AppLocalizations.of(context)!.translate('feeding');
        subtitle = activity.feedingType ?? '';
        if (activity.amountMl != null) {
          subtitle += ' • ${activity.amountMl}ml';
        }
        break;
      case ActivityType.diaper:
        icon = Icons.baby_changing_station;
        color = Colors.green;
        title = AppLocalizations.of(context)!.translate('diaper');
        subtitle = activity.diaperType ?? '';
        break;
      case ActivityType.health:
        if (activity.temperatureCelsius != null) {
          icon = Icons.thermostat;
          final temp = activity.temperatureUnit == 'fahrenheit'
              ? activity.temperatureCelsius! * 9 / 5 + 32
              : activity.temperatureCelsius;
          final unit = activity.temperatureUnit == 'fahrenheit' ? '℉' : '℃';
          final isFever = activity.temperatureCelsius! >= 38.0;
          color = isFever ? Colors.red : Colors.blue;
          title = AppLocalizations.of(context)!.translate('temperature');
          subtitle = '${temp!.toStringAsFixed(1)}$unit${isFever ? AppLocalizations.of(context)!.translate('fever_high') : ''}';
        } else if (activity.medicationName != null) {
          icon = Icons.medication;
          color = Colors.teal;
          title = AppLocalizations.of(context)!.translate('medication');
          subtitle = activity.medicationName ?? '';
          if (activity.dosageAmount != null) {
            subtitle += ' • ${activity.dosageAmount}${activity.dosageUnit ?? ''}';
          }
        } else {
          icon = Icons.health_and_safety;
          color = Colors.teal;
          title = AppLocalizations.of(context)!.translate('health');
        }
        break;
      default:
        icon = Icons.circle;
        color = Colors.grey;
        title = AppLocalizations.of(context)!.translate('activity');
    }

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (subtitle.isNotEmpty) Text(subtitle),
            SizedBox(height: 4),
            Text(
              timeStr,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            if (activity.notes != null && activity.notes!.isNotEmpty) ...[
              SizedBox(height: 4),
              Text(
                activity.notes!,
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete_outline, color: Colors.red[300]),
          onPressed: () => _deleteActivity(activity.id),
        ),
      ),
    );
  }

  IconData _getIconForType(ActivityType? type) {
    switch (type) {
      case ActivityType.sleep:
        return Icons.bedtime;
      case ActivityType.feeding:
        return Icons.restaurant;
      case ActivityType.diaper:
        return Icons.baby_changing_station;
      case ActivityType.health:
        return Icons.medication;
      default:
        return Icons.list;
    }
  }

  Future<void> _deleteActivity(String activityId) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.translate('delete_record')),
        content: Text(l10n.translate('confirm_delete_record')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.translate('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.translate('delete'), style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        const userId = 'demo-user';
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('activities')
            .doc(activityId)
            .delete();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.translate('record_deleted'))),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.translate('failed_to_delete').replaceAll('{error}', e.toString()))),
          );
        }
      }
    }
  }

  void _navigateToAddScreen(BuildContext context, ActivityType type) async {
    Widget screen;
    switch (type) {
      case ActivityType.sleep:
        screen = LogSleepScreen();
        break;
      case ActivityType.feeding:
        screen = LogFeedingScreen();
        break;
      case ActivityType.play:
        screen = LogPlayScreen();
        break;
      case ActivityType.diaper:
        screen = LogDiaperScreen();
        break;
      case ActivityType.health:
        screen = LogHealthScreen();
        break;
      default:
        return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }
}
