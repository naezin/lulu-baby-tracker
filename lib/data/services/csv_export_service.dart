import 'dart:io';
import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/localization/app_localizations.dart';
import '../../domain/repositories/i_activity_repository.dart';
import '../../domain/entities/activity_entity.dart';

/// 진행률 콜백 타입
typedef ExportProgressCallback = void Function(double progress, String message);

/// CSV 내보내기 서비스 (✅ Repository 패턴 적용 완료)
class CsvExportService {
  final IActivityRepository _activityRepository;

  CsvExportService({
    required IActivityRepository activityRepository,
  }) : _activityRepository = activityRepository;

  /// 모든 데이터를 CSV로 내보내기
  Future<File> exportAllDataToCsv({
    required String babyId,
    required AppLocalizations l10n,
    ExportProgressCallback? onProgress,
  }) async {
    try {
      onProgress?.call(0.1, l10n.translate('export_progress_fetching_sleep'));

      // 1. 수면 기록 가져오기
      final sleepRecords = await fetchSleepRecords(babyId, l10n);
      onProgress?.call(0.3, l10n.translate('export_progress_fetching_feeding'));

      // 2. 수유 기록 가져오기
      final feedingRecords = await fetchFeedingRecords(babyId, l10n);
      onProgress?.call(0.5, l10n.translate('export_progress_fetching_diaper'));

      // 3. 기저귀 기록 가져오기
      final diaperRecords = await fetchDiaperRecords(babyId, l10n);
      onProgress?.call(0.7, l10n.translate('export_progress_creating_csv'));

      // 4. CSV 파일 생성
      final csvFile = await _createCsvFile(
        sleepRecords: sleepRecords,
        feedingRecords: feedingRecords,
        diaperRecords: diaperRecords,
        l10n: l10n,
      );
      onProgress?.call(1.0, l10n.translate('export_progress_completed'));

      return csvFile;
    } catch (e) {
      throw Exception('Failed to export data: $e');
    }
  }

  /// 수면 기록 가져오기
  Future<List<Map<String, dynamic>>> fetchSleepRecords(String babyId, AppLocalizations l10n) async {
    final activities = await _activityRepository.getActivities(
      babyId: babyId,
      type: ActivityType.sleep,
      limit: 10000, // Export all records
    );

    return activities.map((activity) {
      return {
        'id': activity.id,
        'type': l10n.translate('csv_type_sleep'),
        'start_time': activity.timestamp,
        'end_time': activity.endTime,
        'duration_minutes': activity.durationMinutes,
        'quality': activity.sleepQuality,
        'location': activity.sleepLocation,
        'notes': activity.notes,
      };
    }).toList();
  }

  /// 수유 기록 가져오기
  Future<List<Map<String, dynamic>>> fetchFeedingRecords(String babyId, AppLocalizations l10n) async {
    final activities = await _activityRepository.getActivities(
      babyId: babyId,
      type: ActivityType.feeding,
      limit: 10000, // Export all records
    );

    return activities.map((activity) {
      return {
        'id': activity.id,
        'type': l10n.translate('csv_type_feeding'),
        'time': activity.timestamp,
        'feeding_type': activity.feedingType,
        'amount_ml': activity.amountMl,
        'duration_minutes': activity.durationMinutes,
        'side': activity.breastSide,
        'notes': activity.notes,
      };
    }).toList();
  }

  /// 기저귀 기록 가져오기
  Future<List<Map<String, dynamic>>> fetchDiaperRecords(String babyId, AppLocalizations l10n) async {
    final activities = await _activityRepository.getActivities(
      babyId: babyId,
      type: ActivityType.diaper,
      limit: 10000, // Export all records
    );

    return activities.map((activity) {
      return {
        'id': activity.id,
        'type': l10n.translate('csv_type_diaper'),
        'time': activity.timestamp,
        'diaper_type': activity.diaperType,
        'notes': activity.notes,
      };
    }).toList();
  }

  /// CSV 파일 생성
  Future<File> _createCsvFile({
    required List<Map<String, dynamic>> sleepRecords,
    required List<Map<String, dynamic>> feedingRecords,
    required List<Map<String, dynamic>> diaperRecords,
    required AppLocalizations l10n,
  }) async {
    // CSV 데이터 준비
    List<List<dynamic>> csvData = [];

    // 헤더 추가
    csvData.add([
      l10n.translate('csv_header_type'),
      l10n.translate('csv_header_date'),
      l10n.translate('csv_header_time'),
      l10n.translate('csv_header_start_time'),
      l10n.translate('csv_header_end_time'),
      l10n.translate('csv_header_duration'),
      l10n.translate('csv_header_quality'),
      l10n.translate('csv_header_location'),
      l10n.translate('csv_header_feeding_type'),
      l10n.translate('csv_header_amount'),
      l10n.translate('csv_header_side'),
      l10n.translate('csv_header_diaper_type'),
      l10n.translate('csv_header_notes'),
    ]);

    final dateFormat = DateFormat('yyyy-MM-dd');
    final timeFormat = DateFormat('HH:mm');
    final dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm');

    // 수면 기록 추가
    for (var record in sleepRecords) {
      final startTime = record['start_time'] as DateTime?;
      final endTime = record['end_time'] as DateTime?;

      csvData.add([
        l10n.translate('csv_type_sleep'),
        startTime != null ? dateFormat.format(startTime) : '',
        startTime != null ? timeFormat.format(startTime) : '',
        startTime != null ? dateTimeFormat.format(startTime) : '',
        endTime != null ? dateTimeFormat.format(endTime) : '',
        record['duration_minutes'] ?? '',
        record['quality'] ?? '',
        record['location'] ?? '',
        '', // Feeding Type
        '', // Amount
        '', // Side
        '', // Diaper Type
        record['notes'] ?? '',
      ]);
    }

    // 수유 기록 추가
    for (var record in feedingRecords) {
      final time = record['time'] as DateTime?;

      csvData.add([
        l10n.translate('csv_type_feeding'),
        time != null ? dateFormat.format(time) : '',
        time != null ? timeFormat.format(time) : '',
        time != null ? dateTimeFormat.format(time) : '',
        '', // End Time
        record['duration_minutes'] ?? '',
        '', // Quality
        '', // Location
        record['feeding_type'] ?? '',
        record['amount_ml'] ?? '',
        record['side'] ?? '',
        '', // Diaper Type
        record['notes'] ?? '',
      ]);
    }

    // 기저귀 기록 추가
    for (var record in diaperRecords) {
      final time = record['time'] as DateTime?;

      csvData.add([
        l10n.translate('csv_type_diaper'),
        time != null ? dateFormat.format(time) : '',
        time != null ? timeFormat.format(time) : '',
        time != null ? dateTimeFormat.format(time) : '',
        '', // End Time
        '', // Duration
        '', // Quality
        '', // Location
        '', // Feeding Type
        '', // Amount
        '', // Side
        record['diaper_type'] ?? '',
        record['notes'] ?? '',
      ]);
    }

    // CSV 문자열 생성
    String csvString = const ListToCsvConverter().convert(csvData);

    // 파일명 생성
    final now = DateTime.now();
    final fileName = 'Lulu_Baby_Log_${dateFormat.format(now)}.csv';

    // 임시 디렉토리에 파일 저장
    final directory = await getTemporaryDirectory();
    final filePath = '${directory.path}/$fileName';
    final file = File(filePath);

    // CSV 파일 쓰기
    await file.writeAsString(csvString, encoding: utf8);

    return file;
  }

  /// CSV 파일 공유하기
  Future<void> shareCsvFile(File csvFile, AppLocalizations l10n) async {
    try {
      await Share.shareXFiles(
        [XFile(csvFile.path)],
        subject: l10n.translate('export_email_subject'),
        text: l10n.translate('export_email_body'),
      );
    } catch (e) {
      throw Exception('Failed to share file: $e');
    }
  }

  /// 요약 통계 생성
  Map<String, dynamic> generateSummary({
    required List<Map<String, dynamic>> sleepRecords,
    required List<Map<String, dynamic>> feedingRecords,
    required List<Map<String, dynamic>> diaperRecords,
    required AppLocalizations l10n,
  }) {
    // 총 수면 시간
    int totalSleepMinutes = 0;
    for (var record in sleepRecords) {
      totalSleepMinutes += (record['duration_minutes'] as int?) ?? 0;
    }

    // 평균 수면 시간
    final averageSleepMinutes =
        sleepRecords.isNotEmpty ? totalSleepMinutes / sleepRecords.length : 0;

    // 총 수유 횟수
    final totalFeedings = feedingRecords.length;

    // 모유/분유 비율
    int breastfeedingCount = 0;
    int bottleCount = 0;
    for (var record in feedingRecords) {
      final type = record['feeding_type'] as String?;
      if (type == l10n.translate('feeding_type_breastfeeding')) {
        breastfeedingCount++;
      } else if (type == l10n.translate('feeding_type_bottle')) {
        bottleCount++;
      }
    }

    // 총 기저귀 교체 횟수
    final totalDiapers = diaperRecords.length;

    return {
      'total_sleep_records': sleepRecords.length,
      'total_sleep_hours': (totalSleepMinutes / 60).toStringAsFixed(1),
      'average_sleep_minutes': averageSleepMinutes.round(),
      'total_feedings': totalFeedings,
      'breastfeeding_count': breastfeedingCount,
      'bottle_count': bottleCount,
      'total_diapers': totalDiapers,
      'date_range_start': sleepRecords.isNotEmpty
          ? sleepRecords.last['start_time']
          : feedingRecords.isNotEmpty
              ? feedingRecords.last['time']
              : diaperRecords.isNotEmpty
                  ? diaperRecords.last['time']
                  : DateTime.now(),
      'date_range_end': sleepRecords.isNotEmpty
          ? sleepRecords.first['start_time']
          : feedingRecords.isNotEmpty
              ? feedingRecords.first['time']
              : diaperRecords.isNotEmpty
                  ? diaperRecords.first['time']
                  : DateTime.now(),
    };
  }
}
