import 'dart:io';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// CSV Import 결과
class ImportResult {
  final int sleepRecordsImported;
  final int feedingRecordsImported;
  final int diaperRecordsImported;
  final int duplicatesSkipped;
  final int errorsEncountered;
  final List<String> errorMessages;

  ImportResult({
    required this.sleepRecordsImported,
    required this.feedingRecordsImported,
    required this.diaperRecordsImported,
    required this.duplicatesSkipped,
    required this.errorsEncountered,
    this.errorMessages = const [],
  });

  int get totalImported =>
      sleepRecordsImported + feedingRecordsImported + diaperRecordsImported;
}

/// 진행률 콜백 타입
typedef ImportProgressCallback = void Function(double progress, String message);

/// CSV 가져오기 서비스
class CsvImportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// CSV 파일을 읽어서 Firestore로 가져오기
  Future<ImportResult> importFromCsv({
    required String userId,
    required File csvFile,
    ImportProgressCallback? onProgress,
  }) async {
    try {
      onProgress?.call(0.1, 'Reading CSV file...');

      // CSV 파일 읽기
      final csvString = await csvFile.readAsString();
      final csvData = const CsvToListConverter().convert(csvString);

      if (csvData.isEmpty) {
        throw Exception('CSV file is empty');
      }

      onProgress?.call(0.2, 'Analyzing headers...');

      // 헤더 분석
      final headers = csvData[0].map((e) => e.toString().trim()).toList();
      final dataRows = csvData.sublist(1);

      onProgress?.call(0.3, 'Classifying data...');

      // 데이터 분류
      final classifiedData = _classifyData(headers, dataRows);

      // 중복 체크용 기존 타임스탬프 가져오기
      onProgress?.call(0.4, 'Checking for duplicates...');
      final existingTimestamps = await _getExistingTimestamps(userId);

      // 카운터 초기화
      int sleepCount = 0;
      int feedingCount = 0;
      int diaperCount = 0;
      int duplicateCount = 0;
      int errorCount = 0;
      List<String> errors = [];

      // 수면 기록 가져오기
      if (classifiedData['sleep']!.isNotEmpty) {
        onProgress?.call(0.5, 'Importing sleep records...');
        final result = await _importSleepRecords(
          userId: userId,
          records: classifiedData['sleep']!,
          existingTimestamps: existingTimestamps['sleep']!,
        );
        sleepCount = result['imported'] as int;
        duplicateCount += result['duplicates'] as int;
        errorCount += result['errors'] as int;
        errors.addAll(result['errorMessages'] as List<String>);
      }

      // 수유 기록 가져오기
      if (classifiedData['feeding']!.isNotEmpty) {
        onProgress?.call(0.7, 'Importing feeding records...');
        final result = await _importFeedingRecords(
          userId: userId,
          records: classifiedData['feeding']!,
          existingTimestamps: existingTimestamps['feeding']!,
        );
        feedingCount = result['imported'] as int;
        duplicateCount += result['duplicates'] as int;
        errorCount += result['errors'] as int;
        errors.addAll(result['errorMessages'] as List<String>);
      }

      // 기저귀 기록 가져오기
      if (classifiedData['diaper']!.isNotEmpty) {
        onProgress?.call(0.9, 'Importing diaper records...');
        final result = await _importDiaperRecords(
          userId: userId,
          records: classifiedData['diaper']!,
          existingTimestamps: existingTimestamps['diaper']!,
        );
        diaperCount = result['imported'] as int;
        duplicateCount += result['duplicates'] as int;
        errorCount += result['errors'] as int;
        errors.addAll(result['errorMessages'] as List<String>);
      }

      onProgress?.call(1.0, 'Import completed!');

      return ImportResult(
        sleepRecordsImported: sleepCount,
        feedingRecordsImported: feedingCount,
        diaperRecordsImported: diaperCount,
        duplicatesSkipped: duplicateCount,
        errorsEncountered: errorCount,
        errorMessages: errors,
      );
    } catch (e) {
      throw Exception('Failed to import CSV: $e');
    }
  }

  /// 헤더 분석 및 데이터 분류
  Map<String, List<Map<String, dynamic>>> _classifyData(
    List<dynamic> headers,
    List<List<dynamic>> dataRows,
  ) {
    final sleepRecords = <Map<String, dynamic>>[];
    final feedingRecords = <Map<String, dynamic>>[];
    final diaperRecords = <Map<String, dynamic>>[];

    // 헤더 인덱스 매핑
    final typeIndex = _findHeaderIndex(headers, ['type', 'activity', 'record type']);
    final dateIndex = _findHeaderIndex(headers, ['date', 'day']);
    final timeIndex = _findHeaderIndex(headers, ['time', 'timestamp']);
    final startTimeIndex = _findHeaderIndex(headers, ['start time', 'start', 'start_time']);
    final endTimeIndex = _findHeaderIndex(headers, ['end time', 'end', 'end_time']);
    final durationIndex = _findHeaderIndex(headers, ['duration', 'duration (min)', 'duration_minutes']);
    final qualityIndex = _findHeaderIndex(headers, ['quality', 'sleep quality']);
    final locationIndex = _findHeaderIndex(headers, ['location', 'place']);
    final feedingTypeIndex = _findHeaderIndex(headers, ['feeding type', 'feed type', 'feeding_type']);
    final amountIndex = _findHeaderIndex(headers, ['amount', 'amount (ml)', 'amount_ml']);
    final sideIndex = _findHeaderIndex(headers, ['side', 'breast side']);
    final diaperTypeIndex = _findHeaderIndex(headers, ['diaper type', 'diaper_type', 'change type']);
    final notesIndex = _findHeaderIndex(headers, ['notes', 'note', 'memo']);

    // 각 행 처리
    for (var row in dataRows) {
      if (row.isEmpty || row.every((cell) => cell == null || cell.toString().trim().isEmpty)) {
        continue; // 빈 행 건너뛰기
      }

      final type = _getCellValue(row, typeIndex)?.toLowerCase() ?? '';

      final rowData = <String, dynamic>{
        'date': _getCellValue(row, dateIndex),
        'time': _getCellValue(row, timeIndex),
        'start_time': _getCellValue(row, startTimeIndex),
        'end_time': _getCellValue(row, endTimeIndex),
        'duration': _getCellValue(row, durationIndex),
        'quality': _getCellValue(row, qualityIndex),
        'location': _getCellValue(row, locationIndex),
        'feeding_type': _getCellValue(row, feedingTypeIndex),
        'amount': _getCellValue(row, amountIndex),
        'side': _getCellValue(row, sideIndex),
        'diaper_type': _getCellValue(row, diaperTypeIndex),
        'notes': _getCellValue(row, notesIndex),
      };

      // 타입별로 분류
      if (type.contains('sleep') || type.contains('nap')) {
        sleepRecords.add(rowData);
      } else if (type.contains('feed') || type.contains('bottle') || type.contains('breast')) {
        feedingRecords.add(rowData);
      } else if (type.contains('diaper') || type.contains('change')) {
        diaperRecords.add(rowData);
      }
    }

    return {
      'sleep': sleepRecords,
      'feeding': feedingRecords,
      'diaper': diaperRecords,
    };
  }

  /// 헤더 인덱스 찾기 (여러 가능한 이름 지원)
  int _findHeaderIndex(List<dynamic> headers, List<String> possibleNames) {
    for (int i = 0; i < headers.length; i++) {
      final header = headers[i].toString().toLowerCase().trim();
      for (var name in possibleNames) {
        if (header == name.toLowerCase()) {
          return i;
        }
      }
    }
    return -1;
  }

  /// 셀 값 가져오기
  String? _getCellValue(List<dynamic> row, int index) {
    if (index < 0 || index >= row.length) return null;
    final value = row[index];
    if (value == null || value.toString().trim().isEmpty) return null;
    return value.toString().trim();
  }

  /// 기존 타임스탬프 가져오기 (중복 체크용)
  Future<Map<String, Set<String>>> _getExistingTimestamps(String userId) async {
    final sleepTimestamps = <String>{};
    final feedingTimestamps = <String>{};
    final diaperTimestamps = <String>{};

    // 수면 기록
    final sleepSnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('sleep_records')
        .get();
    for (var doc in sleepSnapshot.docs) {
      final data = doc.data();
      final timestamp = (data['start_time'] as Timestamp?)?.toDate();
      if (timestamp != null) {
        sleepTimestamps.add(timestamp.toIso8601String());
      }
    }

    // 수유 기록
    final feedingSnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('feeding_records')
        .get();
    for (var doc in feedingSnapshot.docs) {
      final data = doc.data();
      final timestamp = (data['time'] as Timestamp?)?.toDate();
      if (timestamp != null) {
        feedingTimestamps.add(timestamp.toIso8601String());
      }
    }

    // 기저귀 기록
    final diaperSnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('diaper_records')
        .get();
    for (var doc in diaperSnapshot.docs) {
      final data = doc.data();
      final timestamp = (data['time'] as Timestamp?)?.toDate();
      if (timestamp != null) {
        diaperTimestamps.add(timestamp.toIso8601String());
      }
    }

    return {
      'sleep': sleepTimestamps,
      'feeding': feedingTimestamps,
      'diaper': diaperTimestamps,
    };
  }

  /// 수면 기록 가져오기
  Future<Map<String, dynamic>> _importSleepRecords({
    required String userId,
    required List<Map<String, dynamic>> records,
    required Set<String> existingTimestamps,
  }) async {
    int imported = 0;
    int duplicates = 0;
    int errors = 0;
    List<String> errorMessages = [];

    for (var record in records) {
      try {
        final startTime = _parseDateTime(record['start_time'] ?? record['time']);
        if (startTime == null) {
          errors++;
          errorMessages.add('Invalid start time in sleep record');
          continue;
        }

        // 중복 체크
        if (existingTimestamps.contains(startTime.toIso8601String())) {
          duplicates++;
          continue;
        }

        final endTime = _parseDateTime(record['end_time']);
        final duration = _parseDuration(record['duration']);

        // Firestore에 저장
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('sleep_records')
            .add({
          'start_time': Timestamp.fromDate(startTime),
          'end_time': endTime != null ? Timestamp.fromDate(endTime) : null,
          'duration_minutes': duration,
          'quality': record['quality'],
          'location': record['location'],
          'notes': record['notes'],
        });

        imported++;
      } catch (e) {
        errors++;
        errorMessages.add('Error importing sleep record: $e');
      }
    }

    return {
      'imported': imported,
      'duplicates': duplicates,
      'errors': errors,
      'errorMessages': errorMessages,
    };
  }

  /// 수유 기록 가져오기
  Future<Map<String, dynamic>> _importFeedingRecords({
    required String userId,
    required List<Map<String, dynamic>> records,
    required Set<String> existingTimestamps,
  }) async {
    int imported = 0;
    int duplicates = 0;
    int errors = 0;
    List<String> errorMessages = [];

    for (var record in records) {
      try {
        final time = _parseDateTime(record['start_time'] ?? record['time']);
        if (time == null) {
          errors++;
          errorMessages.add('Invalid time in feeding record');
          continue;
        }

        // 중복 체크
        if (existingTimestamps.contains(time.toIso8601String())) {
          duplicates++;
          continue;
        }

        final amount = _parseAmount(record['amount']);
        final duration = _parseDuration(record['duration']);

        // Firestore에 저장
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('feeding_records')
            .add({
          'time': Timestamp.fromDate(time),
          'type': record['feeding_type'] ?? 'Unknown',
          'amount_ml': amount,
          'duration_minutes': duration,
          'side': record['side'],
          'notes': record['notes'],
        });

        imported++;
      } catch (e) {
        errors++;
        errorMessages.add('Error importing feeding record: $e');
      }
    }

    return {
      'imported': imported,
      'duplicates': duplicates,
      'errors': errors,
      'errorMessages': errorMessages,
    };
  }

  /// 기저귀 기록 가져오기
  Future<Map<String, dynamic>> _importDiaperRecords({
    required String userId,
    required List<Map<String, dynamic>> records,
    required Set<String> existingTimestamps,
  }) async {
    int imported = 0;
    int duplicates = 0;
    int errors = 0;
    List<String> errorMessages = [];

    for (var record in records) {
      try {
        final time = _parseDateTime(record['start_time'] ?? record['time']);
        if (time == null) {
          errors++;
          errorMessages.add('Invalid time in diaper record');
          continue;
        }

        // 중복 체크
        if (existingTimestamps.contains(time.toIso8601String())) {
          duplicates++;
          continue;
        }

        // Firestore에 저장
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('diaper_records')
            .add({
          'time': Timestamp.fromDate(time),
          'type': record['diaper_type'] ?? 'Unknown',
          'notes': record['notes'],
        });

        imported++;
      } catch (e) {
        errors++;
        errorMessages.add('Error importing diaper record: $e');
      }
    }

    return {
      'imported': imported,
      'duplicates': duplicates,
      'errors': errors,
      'errorMessages': errorMessages,
    };
  }

  /// DateTime 파싱 (여러 형식 지원)
  DateTime? _parseDateTime(String? value) {
    if (value == null || value.isEmpty) return null;

    try {
      // ISO 8601 형식
      return DateTime.parse(value);
    } catch (_) {
      // 다양한 날짜 형식 시도
      final formats = [
        'yyyy-MM-dd HH:mm',
        'yyyy-MM-dd HH:mm:ss',
        'MM/dd/yyyy HH:mm',
        'dd/MM/yyyy HH:mm',
        'yyyy/MM/dd HH:mm',
      ];

      for (var format in formats) {
        try {
          final dateFormat = DateFormat(format);
          return dateFormat.parse(value);
        } catch (_) {
          continue;
        }
      }
    }

    return null;
  }

  /// Duration 파싱 (분 단위)
  int? _parseDuration(String? value) {
    if (value == null || value.isEmpty) return null;

    try {
      return int.parse(value.replaceAll(RegExp(r'[^0-9]'), ''));
    } catch (_) {
      return null;
    }
  }

  /// Amount 파싱 (ml)
  int? _parseAmount(String? value) {
    if (value == null || value.isEmpty) return null;

    try {
      return int.parse(value.replaceAll(RegExp(r'[^0-9]'), ''));
    } catch (_) {
      return null;
    }
  }
}
