import 'package:flutter/material.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/widget_service.dart';

/// Widget Settings Screen
/// Configure home screen widgets with Apple-inspired UI
class WidgetSettingsScreen extends StatefulWidget {
  const WidgetSettingsScreen({super.key});

  @override
  State<WidgetSettingsScreen> createState() => _WidgetSettingsScreenState();
}

class _WidgetSettingsScreenState extends State<WidgetSettingsScreen> {
  final _widgetService = WidgetService();
  bool _isUpdating = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('widget_settings') ?? 'Widget Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(context, l10n),
            const SizedBox(height: 32),

            // Small Widget Preview
            _buildWidgetPreview(
              context,
              l10n,
              l10n.translate('widget_small_title') ?? 'Small Widget (2×2)',
              l10n.translate('widget_small_desc') ??
                  'Shows time until next Sweet Spot',
              _buildSmallWidgetMockup(context),
            ),
            const SizedBox(height: 24),

            // Medium Widget Preview
            _buildWidgetPreview(
              context,
              l10n,
              l10n.translate('widget_medium_title') ?? 'Medium Widget (4×2)',
              l10n.translate('widget_medium_desc') ??
                  'Today\'s summary + Sweet Spot countdown',
              _buildMediumWidgetMockup(context),
            ),
            const SizedBox(height: 24),

            // Lock Screen Widget Preview
            _buildWidgetPreview(
              context,
              l10n,
              l10n.translate('widget_lockscreen_title') ?? 'Lock Screen Widget',
              l10n.translate('widget_lockscreen_desc') ??
                  'Quick glance without unlocking',
              _buildLockScreenWidgetMockup(context),
            ),
            const SizedBox(height: 32),

            // Update Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isUpdating ? null : _updateWidgets,
                icon: _isUpdating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                label: Text(
                  _isUpdating
                      ? (l10n.translate('updating') ?? 'Updating...')
                      : (l10n.translate('update_widgets') ?? 'Update Widgets'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.lavenderMist,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Instructions
            _buildInstructions(context, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.lavenderMist.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.widgets_rounded,
                color: AppTheme.lavenderMist,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.translate('widget_settings') ?? 'Home Screen Widgets',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.translate('widget_subtitle') ??
                        'Keep track of your baby at a glance',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWidgetPreview(
    BuildContext context,
    AppLocalizations l10n,
    String title,
    String description,
    Widget mockup,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // Glassmorphism background
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.08),
            Colors.white.withOpacity(0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFE8D5B7), // Champagne Gold
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          mockup,
        ],
      ),
    );
  }

  Widget _buildSmallWidgetMockup(BuildContext context) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A1F3A).withOpacity(0.95),
            const Color(0xFF2D3351).withOpacity(0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lavenderMist.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    value: 0.65,
                    strokeWidth: 4,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppTheme.lavenderMist,
                    ),
                  ),
                ),
                const Text(
                  '52m',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Next Sweet Spot',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
              ),
            ),
            const Text(
              '14:30',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediumWidgetMockup(BuildContext context) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A1F3A).withOpacity(0.95),
            const Color(0xFF2D3351).withOpacity(0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lavenderMist.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStatRow(Icons.bedtime, '8.5h', 'Sleep'),
                  const SizedBox(height: 8),
                  _buildStatRow(Icons.restaurant, '640ml', 'Feeding'),
                  const SizedBox(height: 8),
                  _buildStatRow(Icons.baby_changing_station, '6', 'Diapers'),
                ],
              ),
            ),
            Container(
              width: 1,
              color: Colors.white.withOpacity(0.2),
            ),
            const SizedBox(width: 16),
            const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.bedtime_rounded,
                  color: AppTheme.lavenderMist,
                  size: 32,
                ),
                SizedBox(height: 8),
                Text(
                  'Sleep',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
                Text(
                  'in 20m',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String value, String label) {
    return Row(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.7), size: 16),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildLockScreenWidgetMockup(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: const Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant,
              color: Colors.white,
              size: 16,
            ),
            SizedBox(width: 8),
            Text(
              'Next Feed: ',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            Text(
              '02:30',
              style: TextStyle(
                color: AppTheme.lavenderMist,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructions(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.lavenderMist.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: AppTheme.lavenderMist,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.translate('widget_how_to_add') ?? 'How to Add',
                style: const TextStyle(
                  color: AppTheme.lavenderMist,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '1. Long press on your home screen\n'
            '2. Tap the "+" button in the top corner\n'
            '3. Search for "Lulu"\n'
            '4. Choose your preferred widget size\n'
            '5. Tap "Add Widget"',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateWidgets() async {
    setState(() {
      _isUpdating = true;
    });

    try {
      await _widgetService.updateAllWidgets();

      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.translate('widgets_updated') ?? 'Widgets updated successfully!',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating widgets: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }
}
