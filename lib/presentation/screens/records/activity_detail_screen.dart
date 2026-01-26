import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/activity_model.dart';
import '../../../data/services/local_storage_service.dart';
import '../../../data/services/widget_service.dart';
import '../../providers/sweet_spot_provider.dart';
import '../../providers/baby_provider.dart';

/// 활동 상세/수정/삭제 화면
///
/// 기능:
/// - 활동 상세 보기
/// - 수정 모드 전환
/// - 삭제 (확인 다이얼로그 + Undo 토스트)
/// - Haptic Feedback
class ActivityDetailScreen extends StatefulWidget {
  final ActivityModel activity;

  const ActivityDetailScreen({
    super.key,
    required this.activity,
  });

  @override
  State<ActivityDetailScreen> createState() => _ActivityDetailScreenState();
}

class _ActivityDetailScreenState extends State<ActivityDetailScreen> {
  late ActivityModel _activity;
  bool _isEditMode = false;
  final _storage = LocalStorageService();

  // Form controllers
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _notesController;
  late DateTime _selectedTime;
  DateTime? _selectedEndTime;

  // Sleep specific
  String? _sleepLocation;
  String? _sleepQuality;

  // Feeding specific
  String? _feedingType;
  double? _amountMl;
  String? _breastSide;

  // Diaper specific
  String? _diaperType;

  @override
  void initState() {
    super.initState();
    _activity = widget.activity;
    _initializeFormData();
  }

  void _initializeFormData() {
    _notesController = TextEditingController(text: _activity.notes);
    _selectedTime = DateTime.parse(_activity.timestamp);
    _selectedEndTime = _activity.endTime != null
        ? DateTime.parse(_activity.endTime!)
        : null;

    // Initialize type-specific fields
    _sleepLocation = _activity.sleepLocation;
    _sleepQuality = _activity.sleepQuality;
    _feedingType = _activity.feedingType;
    _amountMl = _activity.amountMl;
    _breastSide = _activity.breastSide;
    _diaperType = _activity.diaperType;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceDark,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: _isEditMode ? _buildEditMode() : _buildViewMode(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.surfaceDark,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        _getActivityTitle(),
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        if (!_isEditMode) ...[
          IconButton(
            icon: const Icon(Icons.edit, color: AppTheme.lavenderMist),
            onPressed: () {
              HapticFeedback.lightImpact();
              setState(() => _isEditMode = true);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: AppTheme.errorSoft),
            onPressed: _showDeleteConfirmation,
          ),
        ] else ...[
          TextButton(
            onPressed: () {
              setState(() {
                _isEditMode = false;
                _initializeFormData(); // Reset form
              });
            },
            child: const Text(
              '취소',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          TextButton(
            onPressed: _saveChanges,
            child: const Text(
              '저장',
              style: TextStyle(
                color: AppTheme.lavenderMist,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildViewMode() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time info card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surfaceCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.glassBorder.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _getActivityIcon(),
                      color: _getActivityColor(),
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                _getActivityTitle(),
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (_selectedEndTime == null && _activity.type == ActivityType.sleep) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppTheme.lavenderMist.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    '진행 중',
                                    style: TextStyle(
                                      color: AppTheme.lavenderMist,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatDateTime(_selectedTime),
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (_selectedEndTime != null) ...[
                  const SizedBox(height: 16),
                  const Divider(color: AppTheme.glassBorder),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        color: AppTheme.textTertiary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '지속 시간: ${_activity.durationMinutes}분',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Type-specific details
          _buildTypeSpecificDetails(),

          const SizedBox(height: 16),

          // Notes
          if (_activity.notes != null && _activity.notes!.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surfaceCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.glassBorder.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.note_outlined,
                        color: AppTheme.lavenderMist,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        '메모',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _activity.notes!,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

          // End Sleep Button (진행 중인 수면만 표시)
          if (_selectedEndTime == null && _activity.type == ActivityType.sleep) ...[
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _endOngoingSleep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.lavenderMist,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.stop_circle_outlined, size: 24),
                    SizedBox(width: 12),
                    Text(
                      '수면 종료',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypeSpecificDetails() {
    switch (_activity.type) {
      case ActivityType.sleep:
        return _buildSleepDetails();
      case ActivityType.feeding:
        return _buildFeedingDetails();
      case ActivityType.diaper:
        return _buildDiaperDetails();
      case ActivityType.play:
        return _buildPlayDetails();
      case ActivityType.health:
        return _buildHealthDetails();
    }
  }

  Widget _buildSleepDetails() {
    // 진행 중인 수면의 경우, location과 quality가 없어도 기본 정보 표시
    final bool hasAnyData = _sleepLocation != null || _sleepQuality != null;
    final bool isOngoing = _selectedEndTime == null;

    // 진행 중이고 데이터가 없으면 상태 정보만 표시
    if (isOngoing && !hasAnyData) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.glassBorder.withOpacity(0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.bedtime_outlined,
                  color: AppTheme.lavenderMist,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  '수면 진행 중',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${_formatDateTime(_selectedTime)}에 시작되었습니다.',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '아래 "수면 종료" 버튼을 눌러 수면을 종료하고 상세 정보를 추가할 수 있습니다.',
              style: const TextStyle(
                color: AppTheme.textTertiary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
      );
    }

    // 종료되었지만 상세 정보가 없는 경우
    if (!isOngoing && !hasAnyData) {
      final durationMinutes = _selectedEndTime != null
          ? _selectedEndTime!.difference(_selectedTime).inMinutes
          : 0;

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.glassBorder.withOpacity(0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: AppTheme.lavenderMist,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  '수면 완료',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '총 수면 시간: ${durationMinutes}분',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '수면 장소나 수면 질을 추가하려면 각 항목을 선택해주세요.',
              style: const TextStyle(
                color: AppTheme.textTertiary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
      );
    }

    // 데이터가 있으면 원래대로 표시
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.glassBorder.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_sleepLocation != null)
            _buildDetailRow(
              icon: Icons.bed,
              label: '장소',
              value: _getSleepLocationLabel(_sleepLocation!),
            ),
          if (_sleepQuality != null) ...[
            if (_sleepLocation != null) const SizedBox(height: 12),
            _buildDetailRow(
              icon: Icons.star,
              label: '수면 질',
              value: _getSleepQualityLabel(_sleepQuality!),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFeedingDetails() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.glassBorder.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow(
            icon: Icons.restaurant,
            label: '수유 방법',
            value: _getFeedingTypeLabel(_feedingType ?? ''),
          ),
          if (_amountMl != null) ...[
            const SizedBox(height: 12),
            _buildDetailRow(
              icon: Icons.local_drink,
              label: '양',
              value: '${_amountMl!.toInt()}ml',
            ),
          ],
          if (_breastSide != null) ...[
            const SizedBox(height: 12),
            _buildDetailRow(
              icon: Icons.favorite,
              label: '수유 위치',
              value: _getBreastSideLabel(_breastSide!),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDiaperDetails() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.glassBorder.withOpacity(0.3),
        ),
      ),
      child: _buildDetailRow(
        icon: Icons.child_care,
        label: '기저귀 종류',
        value: _getDiaperTypeLabel(_diaperType ?? ''),
      ),
    );
  }

  Widget _buildPlayDetails() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.glassBorder.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow(
            icon: Icons.toys,
            label: '놀이 종류',
            value: _activity.playActivityType ?? '관찰',
          ),
          if (_activity.developmentTags != null &&
              _activity.developmentTags!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _activity.developmentTags!
                  .map((tag) => Chip(
                        label: Text(
                          tag,
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor: AppTheme.lavenderMist.withOpacity(0.2),
                        side: BorderSide.none,
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHealthDetails() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.glassBorder.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_activity.temperatureCelsius != null)
            _buildDetailRow(
              icon: Icons.thermostat,
              label: '체온',
              value: '${_activity.temperatureCelsius!.toStringAsFixed(1)}°C',
            ),
          if (_activity.medicationName != null) ...[
            const SizedBox(height: 12),
            _buildDetailRow(
              icon: Icons.medication,
              label: '약물',
              value: _activity.medicationName!,
            ),
          ],
          if (_activity.dosageAmount != null) ...[
            const SizedBox(height: 12),
            _buildDetailRow(
              icon: Icons.colorize,
              label: '용량',
              value: '${_activity.dosageAmount}${_activity.dosageUnit ?? ""}',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.lavenderMist, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.textTertiary,
                  fontSize: 14,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEditMode() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time picker
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surfaceCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.glassBorder.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '시작 시간',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () => _pickDateTime(isStartTime: true),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceDark,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.glassBorder,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDateTime(_selectedTime),
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 14,
                            ),
                          ),
                          const Icon(
                            Icons.calendar_today,
                            color: AppTheme.lavenderMist,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_selectedEndTime != null) ...[
                    const SizedBox(height: 16),
                    const Text(
                      '종료 시간',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () => _pickDateTime(isStartTime: false),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceDark,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.glassBorder,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDateTime(_selectedEndTime!),
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 14,
                              ),
                            ),
                            const Icon(
                              Icons.calendar_today,
                              color: AppTheme.lavenderMist,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Type-specific edit fields
            _buildTypeSpecificEditFields(),

            const SizedBox(height: 16),

            // Notes
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surfaceCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.glassBorder.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '메모',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _notesController,
                    maxLines: 3,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: InputDecoration(
                      hintText: '메모를 입력하세요...',
                      hintStyle: const TextStyle(
                        color: AppTheme.textTertiary,
                      ),
                      filled: true,
                      fillColor: AppTheme.surfaceDark,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppTheme.glassBorder,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppTheme.glassBorder,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppTheme.lavenderMist,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSpecificEditFields() {
    switch (_activity.type) {
      case ActivityType.feeding:
        return _buildFeedingEditFields();
      case ActivityType.diaper:
        return _buildDiaperEditFields();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildFeedingEditFields() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.glassBorder.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '수유 정보',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (_feedingType == 'bottle') ...[
            TextFormField(
              initialValue: _amountMl?.toInt().toString() ?? '',
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                labelText: '양 (ml)',
                labelStyle: const TextStyle(color: AppTheme.textTertiary),
                filled: true,
                fillColor: AppTheme.surfaceDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.glassBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.lavenderMist),
                ),
              ),
              onChanged: (value) {
                _amountMl = double.tryParse(value);
              },
            ),
          ],
          if (_feedingType == 'breast') ...[
            DropdownButtonFormField<String>(
              value: _breastSide,
              dropdownColor: AppTheme.surfaceDark,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                labelText: '수유 위치',
                labelStyle: const TextStyle(color: AppTheme.textTertiary),
                filled: true,
                fillColor: AppTheme.surfaceDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.glassBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.lavenderMist),
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'left', child: Text('왼쪽')),
                DropdownMenuItem(value: 'right', child: Text('오른쪽')),
                DropdownMenuItem(value: 'both', child: Text('양쪽')),
              ],
              onChanged: (value) {
                setState(() => _breastSide = value);
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDiaperEditFields() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.glassBorder.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '기저귀 종류',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _diaperType,
            dropdownColor: AppTheme.surfaceDark,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppTheme.surfaceDark,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.glassBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.lavenderMist),
              ),
            ),
            items: const [
              DropdownMenuItem(value: 'wet', child: Text('소변')),
              DropdownMenuItem(value: 'dirty', child: Text('대변')),
              DropdownMenuItem(value: 'both', child: Text('둘 다')),
            ],
            onChanged: (value) {
              setState(() => _diaperType = value);
            },
          ),
        ],
      ),
    );
  }

  // === Helper Methods ===

  Future<void> _pickDateTime({required bool isStartTime}) async {
    final initialDate = isStartTime ? _selectedTime : (_selectedEndTime ?? _selectedTime);

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.lavenderMist,
              surface: AppTheme.surfaceDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date == null) return;

    if (!context.mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.lavenderMist,
              surface: AppTheme.surfaceDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (time == null) return;

    final newDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    setState(() {
      if (isStartTime) {
        _selectedTime = newDateTime;
      } else {
        _selectedEndTime = newDateTime;
      }
    });
  }

  Future<void> _endOngoingSleep() async {
    HapticFeedback.mediumImpact();

    // 현재 시각으로 종료 시간 설정
    final now = DateTime.now();
    final babyProvider = Provider.of<BabyProvider>(context, listen: false);
    final babyId = babyProvider.currentBaby?.id ?? _activity.babyId;

    // 수면 활동 업데이트
    final updatedActivity = ActivityModel.sleep(
      id: _activity.id,
      babyId: babyId,
      startTime: _selectedTime,
      endTime: now,
      location: _sleepLocation,
      quality: _sleepQuality,
      notes: _activity.notes,
    );

    // 저장
    await _storage.updateActivity(updatedActivity);
    await WidgetService().updateAllWidgets();

    // SweetSpotProvider 업데이트 - 수면 종료 시각을 기상 시각으로 설정
    if (mounted) {
      final provider = Provider.of<SweetSpotProvider>(context, listen: false);
      provider.updateLastSleepActivity(now);
      print('✅ [ActivityDetail] SweetSpot updated with wake time: $now');
    }

    setState(() {
      _activity = updatedActivity;
      _selectedEndTime = now;
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('수면이 종료되었습니다'),
        backgroundColor: AppTheme.successSoft,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    HapticFeedback.mediumImpact();

    final babyProvider = Provider.of<BabyProvider>(context, listen: false);
    final babyId = babyProvider.currentBaby?.id ?? _activity.babyId;

    // Create updated activity based on type
    ActivityModel updatedActivity;

    switch (_activity.type) {
      case ActivityType.sleep:
        updatedActivity = ActivityModel.sleep(
          id: _activity.id,
          babyId: babyId,
          startTime: _selectedTime,
          endTime: _selectedEndTime,
          location: _sleepLocation,
          quality: _sleepQuality,
          notes: _notesController.text.isEmpty ? null : _notesController.text,
        );
        break;

      case ActivityType.feeding:
        updatedActivity = ActivityModel.feeding(
          id: _activity.id,
          babyId: babyId,
          time: _selectedTime,
          feedingType: _feedingType!,
          amountMl: _amountMl,
          breastSide: _breastSide,
          notes: _notesController.text.isEmpty ? null : _notesController.text,
        );
        break;

      case ActivityType.diaper:
        updatedActivity = ActivityModel.diaper(
          id: _activity.id,
          babyId: babyId,
          time: _selectedTime,
          diaperType: _diaperType!,
          notes: _notesController.text.isEmpty ? null : _notesController.text,
        );
        break;

      default:
        // For other types, keep the original
        updatedActivity = _activity;
    }

    // Update via storage service
    await _storage.updateActivity(updatedActivity);
    await WidgetService().updateAllWidgets();

    setState(() {
      _activity = updatedActivity;
      _isEditMode = false;
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('변경사항이 저장되었습니다'),
        backgroundColor: AppTheme.successSoft,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showDeleteConfirmation() {
    HapticFeedback.mediumImpact();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: const Text(
          '활동 삭제',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: const Text(
          '이 활동을 삭제하시겠습니까?\n삭제 후 3초 내에 취소할 수 있습니다.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              '취소',
              style: TextStyle(color: AppTheme.textTertiary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              _deleteActivity();
            },
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

  Future<void> _deleteActivity() async {
    final deletedActivity = _activity;

    // Delete activity
    await _storage.deleteActivity(_activity.id);
    await WidgetService().updateAllWidgets();

    if (!mounted) return;

    // Close screen
    Navigator.pop(context);

    // Show undo snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('활동이 삭제되었습니다'),
        backgroundColor: AppTheme.errorSoft,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: '취소',
          textColor: Colors.white,
          onPressed: () async {
            // Undo delete
            await _storage.saveActivity(deletedActivity);
            await WidgetService().updateAllWidgets();
            HapticFeedback.lightImpact();
          },
        ),
      ),
    );
  }

  String _getActivityTitle() {
    switch (_activity.type) {
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

  IconData _getActivityIcon() {
    switch (_activity.type) {
      case ActivityType.sleep:
        return Icons.bedtime;
      case ActivityType.feeding:
        return Icons.restaurant;
      case ActivityType.diaper:
        return Icons.child_care;
      case ActivityType.play:
        return Icons.toys;
      case ActivityType.health:
        return Icons.health_and_safety;
    }
  }

  Color _getActivityColor() {
    switch (_activity.type) {
      case ActivityType.sleep:
        return AppTheme.lavenderMist;
      case ActivityType.feeding:
        return AppTheme.successSoft;
      case ActivityType.diaper:
        return AppTheme.warningSoft;
      case ActivityType.play:
        return AppTheme.infoSoft;
      case ActivityType.health:
        return AppTheme.errorSoft;
    }
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.year}년 ${dt.month}월 ${dt.day}일 '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String _getSleepLocationLabel(String location) {
    switch (location) {
      case 'crib':
        return '아기침대';
      case 'bed':
        return '부모 침대';
      case 'stroller':
        return '유모차';
      default:
        return location;
    }
  }

  String _getSleepQualityLabel(String quality) {
    switch (quality) {
      case 'good':
        return '좋음';
      case 'fair':
        return '보통';
      case 'poor':
        return '나쁨';
      default:
        return quality;
    }
  }

  String _getFeedingTypeLabel(String type) {
    switch (type) {
      case 'bottle':
        return '분유';
      case 'breast':
        return '모유';
      case 'solid':
        return '이유식';
      default:
        return type;
    }
  }

  String _getBreastSideLabel(String side) {
    switch (side) {
      case 'left':
        return '왼쪽';
      case 'right':
        return '오른쪽';
      case 'both':
        return '양쪽';
      default:
        return side;
    }
  }

  String _getDiaperTypeLabel(String type) {
    switch (type) {
      case 'wet':
        return '소변';
      case 'dirty':
        return '대변';
      case 'both':
        return '둘 다';
      default:
        return type;
    }
  }
}
