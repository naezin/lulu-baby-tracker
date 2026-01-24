import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/utils/sweet_spot_calculator.dart';
import '../providers/sweet_spot_provider.dart';
import '../../core/localization/app_localizations.dart';

/// Sweet Spot 상태를 표시하는 카드 위젯
class SweetSpotCard extends StatelessWidget {
  const SweetSpotCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SweetSpotProvider>(
      builder: (context, provider, child) {
        final sweetSpot = provider.currentSweetSpot;

        if (sweetSpot == null) {
          return _buildEmptyState(context);
        }

        return _buildSweetSpotContent(context, sweetSpot);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.bedtime_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              l10n.translate('empty_state_track_sleep_sweet_spot'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.translate('empty_state_wake_up_hint_detailed'),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSweetSpotContent(BuildContext context, SweetSpotResult sweetSpot) {
    final l10n = AppLocalizations.of(context)!;
    final urgency = sweetSpot.urgencyLevel;
    final colorScheme = _getColorScheme(urgency);

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      color: colorScheme.backgroundColor,
      child: Column(
        children: [
          // Header with urgency indicator
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.accentColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Text(
                  urgency.emoji,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        urgency.displayName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        sweetSpot.userFriendlyMessage,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Sweet Spot Time Range
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.access_time, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      l10n.translate('sweet_spot_title_window'),
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  sweetSpot.getFormattedTimeRange(),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.accentColor,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.translate('sweet_spot_label_wake_window_value').replaceAll('{range}', sweetSpot.wakeWindowData.displayRange),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),

                const SizedBox(height: 24),

                // Progress Indicator
                _buildProgressIndicator(context, sweetSpot),

                const SizedBox(height: 16),

                // Additional Info
                _buildAdditionalInfo(context, sweetSpot),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(BuildContext context, SweetSpotResult sweetSpot) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final totalWindow = sweetSpot.sweetSpotEnd.difference(sweetSpot.lastWakeUpTime).inMinutes;
    final elapsed = now.difference(sweetSpot.lastWakeUpTime).inMinutes;
    final progress = (elapsed / totalWindow).clamp(0.0, 1.0);

    return Column(
      children: [
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(
            _getColorScheme(sweetSpot.urgencyLevel).accentColor,
          ),
          minHeight: 8,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.translate('sweet_spot_progress_awake_minutes').replaceAll('{minutes}', '${sweetSpot.minutesSinceWakeUp}'),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (!sweetSpot.isActive)
              Text(
                l10n.translate('sweet_spot_progress_in_minutes').replaceAll('{minutes}', '${sweetSpot.minutesUntilSweetSpot}'),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              )
            else
              Text(
                l10n.translate('sweet_spot_progress_minutes_left').replaceAll('{minutes}', '${sweetSpot.minutesUntilSweetSpotEnd}'),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildAdditionalInfo(BuildContext context, SweetSpotResult sweetSpot) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoItem(
            context,
            icon: Icons.child_care,
            label: l10n.translate('sweet_spot_info_age'),
            value: '${sweetSpot.ageInMonths}mo',
          ),
          if (sweetSpot.napNumber != null)
            _buildInfoItem(
              context,
              icon: Icons.hotel,
              label: l10n.translate('sweet_spot_info_nap'),
              value: '#${sweetSpot.napNumber}',
            ),
          _buildInfoItem(
            context,
            icon: Icons.repeat,
            label: l10n.translate('sweet_spot_info_daily_naps'),
            value: '${sweetSpot.wakeWindowData.recommendedNaps}',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }

  _ColorScheme _getColorScheme(UrgencyLevel urgency) {
    switch (urgency) {
      case UrgencyLevel.tooEarly:
        return _ColorScheme(
          accentColor: Colors.blue,
          backgroundColor: Colors.blue.shade50,
        );
      case UrgencyLevel.approaching:
        return _ColorScheme(
          accentColor: Colors.amber,
          backgroundColor: Colors.amber.shade50,
        );
      case UrgencyLevel.optimal:
        return _ColorScheme(
          accentColor: Colors.green,
          backgroundColor: Colors.green.shade50,
        );
      case UrgencyLevel.overtired:
        return _ColorScheme(
          accentColor: Colors.red,
          backgroundColor: Colors.red.shade50,
        );
    }
  }
}

class _ColorScheme {
  final Color accentColor;
  final Color backgroundColor;

  _ColorScheme({
    required this.accentColor,
    required this.backgroundColor,
  });
}
