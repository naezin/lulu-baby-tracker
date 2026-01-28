import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:csv/csv.dart';
import '../models/activity_model.dart';
import '../models/baby_model.dart';
import 'local_storage_service.dart';

/// 데이터 내보내기 서비스
/// 사용자 데이터를 JSON, CSV 형식으로 내보내기 지원
class DataExportService {
  final LocalStorageService _storage = LocalStorageService();

  /// 전체 데이터를 JSON으로 내보내기
  ///
  /// 포함 데이터:
  /// - 모든 아기 프로필
  /// - 모든 활동 기록
  /// - 내보내기 메타데이터 (버전, 날짜)
  Future<DataExportResult> exportToJson() async {
    try {
      // 데이터 수집
      final babies = await _storage.getAllBabies();
      final activities = await _storage.getActivities();

      // JSON 구조 생성
      final exportData = {
        'metadata': {
          'exportVersion': '1.0.0',
          'exportDate': DateTime.now().toIso8601String(),
          'appVersion': '1.0.0',
          'dataType': 'lulu_full_backup',
        },
        'babies': babies.map((b) => b.toJson()).toList(),
        'activities': activities.map((a) => a.toJson()).toList(),
        'statistics': {
          'totalBabies': babies.length,
          'totalActivities': activities.length,
          'activitiesByType': _groupActivitiesByType(activities),
        },
      };

      // JSON 문자열 변환 (pretty print)
      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);

      // 파일 저장
      final file = await _writeToFile(
        jsonString,
        'lulu_backup_${_formatDateForFilename(DateTime.now())}.json',
      );

      if (kDebugMode) {
        print('✅ [Export] JSON export successful: ${file.path}');
      }

      return DataExportResult.success(
        filePath: file.path,
        fileSize: await file.length(),
        recordCount: activities.length,
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ [Export] JSON export failed: $e');
      }
      return DataExportResult.failure('Failed to export JSON: $e');
    }
  }

  /// 활동 기록을 CSV로 내보내기
  ///
  /// CSV 컬럼:
  /// - Date, Time, Baby Name, Activity Type, Duration, Notes
  Future<DataExportResult> exportActivitiesToCsv() async {
    try {
      final activities = await _storage.getActivities();
      final babies = await _storage.getAllBabies();

      // Baby ID -> Name 매핑
      final babyNameMap = {
        for (var baby in babies) baby.id: baby.name,
      };

      // CSV 데이터 생성
      final rows = <List<String>>[];

      // 헤더
      rows.add([
        'Date',
        'Time',
        'Baby Name',
        'Activity Type',
        'Duration (min)',
        'Details',
        'Notes',
      ]);

      // 데이터 행
      for (var activity in activities) {
        final timestamp = DateTime.parse(activity.timestamp);
        final babyName = babyNameMap[activity.babyId] ?? 'Unknown';

        rows.add([
          _formatDate(timestamp),
          _formatTime(timestamp),
          babyName,
          _formatActivityType(activity.type),
          _calculateDuration(activity),
          _formatDetails(activity),
          activity.notes ?? '',
        ]);
      }

      // CSV 문자열 변환
      final csvString = const ListToCsvConverter().convert(rows);

      // 파일 저장
      final file = await _writeToFile(
        csvString,
        'lulu_activities_${_formatDateForFilename(DateTime.now())}.csv',
      );

      if (kDebugMode) {
        print('✅ [Export] CSV export successful: ${file.path}');
      }

      return DataExportResult.success(
        filePath: file.path,
        fileSize: await file.length(),
        recordCount: activities.length,
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ [Export] CSV export failed: $e');
      }
      return DataExportResult.failure('Failed to export CSV: $e');
    }
  }

  /// 파일 공유 (시스템 공유 시트 표시)
  ///
  /// [filePath]: 공유할 파일 경로
  /// [subject]: 공유 시 제목 (선택)
  Future<void> shareFile(String filePath, {String? subject}) async {
    try {
      final file = File(filePath);

      if (!await file.exists()) {
        throw Exception('File not found: $filePath');
      }

      await Share.shareXFiles(
        [XFile(filePath)],
        subject: subject ?? 'Lulu Baby Data Export',
      );

      if (kDebugMode) {
        print('✅ [Export] File shared: $filePath');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [Export] Share failed: $e');
      }
      rethrow;
    }
  }

  // ==================== Helper Methods ====================

  /// 파일 쓰기
  Future<File> _writeToFile(String content, String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$filename');
    return await file.writeAsString(content);
  }

  /// 활동 타입별 그룹화
  Map<String, int> _groupActivitiesByType(List<ActivityModel> activities) {
    final grouped = <String, int>{};
    for (var activity in activities) {
      final type = activity.type.toString().split('.').last;
      grouped[type] = (grouped[type] ?? 0) + 1;
    }
    return grouped;
  }

  /// 날짜 포맷 (파일명용)
  String _formatDateForFilename(DateTime date) {
    return '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
  }

  /// 날짜 포맷 (CSV용)
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// 시간 포맷 (CSV용)
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  /// 활동 타입 포맷
  String _formatActivityType(ActivityType type) {
    switch (type) {
      case ActivityType.sleep:
        return 'Sleep';
      case ActivityType.feeding:
        return 'Feeding';
      case ActivityType.diaper:
        return 'Diaper';
      case ActivityType.play:
        return 'Play';
      case ActivityType.health:
        return 'Health';
    }
  }

  /// 활동 지속 시간 계산 (분)
  String _calculateDuration(ActivityModel activity) {
    if (activity.endTime == null) return '-';

    final start = DateTime.parse(activity.timestamp);
    final end = DateTime.parse(activity.endTime!);
    final duration = end.difference(start).inMinutes;

    return duration.toString();
  }

  /// 활동 상세 정보 포맷
  String _formatDetails(ActivityModel activity) {
    final details = <String>[];

    switch (activity.type) {
      case ActivityType.sleep:
        if (activity.sleepQuality != null) {
          details.add('Quality: ${activity.sleepQuality}');
        }
        break;
      case ActivityType.feeding:
        if (activity.feedingType != null) {
          details.add('Type: ${activity.feedingType}');
        }
        if (activity.amountMl != null) {
          details.add('Amount: ${activity.amountMl}ml');
        }
        break;
      case ActivityType.diaper:
        if (activity.diaperType != null) {
          details.add('Type: ${activity.diaperType}');
        }
        break;
      case ActivityType.health:
        if (activity.temperatureCelsius != null) {
          details.add('Temp: ${activity.temperatureCelsius}°${activity.temperatureUnit == 'celsius' ? 'C' : 'F'}');
        }
        if (activity.weightKg != null) {
          details.add('Weight: ${activity.weightKg}kg');
        }
        if (activity.lengthCm != null) {
          details.add('Height: ${activity.lengthCm}cm');
        }
        break;
      case ActivityType.play:
        if (activity.playActivityType != null) {
          details.add('Type: ${activity.playActivityType}');
        }
        break;
    }

    return details.join(', ');
  }
}

/// 데이터 내보내기 결과
class DataExportResult {
  final bool success;
  final String? filePath;
  final int? fileSize;
  final int? recordCount;
  final String? errorMessage;

  DataExportResult.success({
    required this.filePath,
    required this.fileSize,
    required this.recordCount,
  })  : success = true,
        errorMessage = null;

  DataExportResult.failure(this.errorMessage)
      : success = false,
        filePath = null,
        fileSize = null,
        recordCount = null;

  /// 파일 크기 (KB)
  double get fileSizeKB => (fileSize ?? 0) / 1024;

  /// 사용자 친화적인 파일 크기 문자열
  String get fileSizeFormatted {
    if (fileSize == null) return '-';
    if (fileSizeKB < 1024) {
      return '${fileSizeKB.toStringAsFixed(1)} KB';
    } else {
      return '${(fileSizeKB / 1024).toStringAsFixed(1)} MB';
    }
  }
}
