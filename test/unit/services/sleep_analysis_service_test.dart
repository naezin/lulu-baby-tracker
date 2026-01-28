import 'package:flutter_test/flutter_test.dart';
import 'package:lulu/data/services/sleep_analysis_service.dart';
import 'package:lulu/data/models/activity_model.dart';
import 'package:lulu/data/models/sleep_analysis_data.dart';

void main() {
  group('SleepAnalysisService', () {
    late SleepAnalysisService service;

    setUp(() {
      service = SleepAnalysisService();
    });

    group('analyzeSleepPeriod', () {
      test('should return empty analysis for empty activities', () {
        final startDate = DateTime(2025, 1, 1);
        final endDate = DateTime(2025, 1, 7);

        final data = service.analyzeSleepPeriod(
          sleepActivities: [],
          startDate: startDate,
          endDate: endDate,
        );

        expect(data.totalSleepCount, 0);
        expect(data.averageSleepDurationMinutes, 0);
        expect(data.qualityRating, 0);
      });

      test('should calculate average duration correctly', () {
        final startDate = DateTime(2025, 1, 1);
        final endDate = DateTime(2025, 1, 7);

        final activities = [
          _createSleepActivity('2025-01-01T10:00:00', 60),
          _createSleepActivity('2025-01-01T14:00:00', 90),
          _createSleepActivity('2025-01-02T10:00:00', 120),
        ];

        final data = service.analyzeSleepPeriod(
          sleepActivities: activities,
          startDate: startDate,
          endDate: endDate,
        );

        expect(data.totalSleepCount, 3);
        expect(data.averageSleepDurationMinutes, 90); // (60 + 90 + 120) / 3
        expect(data.totalSleepMinutes, 270); // 60 + 90 + 120
      });

      test('should filter out incomplete sleep activities', () {
        final startDate = DateTime(2025, 1, 1);
        final endDate = DateTime(2025, 1, 7);

        final activities = [
          _createSleepActivity('2025-01-01T10:00:00', 60),
          _createIncompleteSleepActivity('2025-01-01T12:00:00'), // 진행 중
          _createSleepActivity('2025-01-01T14:00:00', 90),
        ];

        final data = service.analyzeSleepPeriod(
          sleepActivities: activities,
          startDate: startDate,
          endDate: endDate,
        );

        expect(data.totalSleepCount, 2); // 진행 중인 수면 제외
      });

      test('should classify naps and night sleeps correctly', () {
        final startDate = DateTime(2025, 1, 1);
        final endDate = DateTime(2025, 1, 7);

        final activities = [
          // 낮잠 (10시)
          _createSleepActivity('2025-01-01T10:00:00', 90),
          // 낮잠 (14시)
          _createSleepActivity('2025-01-01T14:00:00', 60),
          // 밤잠 (20시)
          _createSleepActivity('2025-01-01T20:00:00', 600),
          // 밤잠 (23시)
          _createSleepActivity('2025-01-01T23:00:00', 480),
        ];

        final data = service.analyzeSleepPeriod(
          sleepActivities: activities,
          startDate: startDate,
          endDate: endDate,
        );

        expect(data.napCount, 2);
        expect(data.nightSleepCount, 2);
        expect(data.averageNapMinutes, 75); // (90 + 60) / 2
        expect(data.averageNightSleepMinutes, 540); // (600 + 480) / 2
      });

      test('should calculate consistency score', () {
        final startDate = DateTime(2025, 1, 1);
        final endDate = DateTime(2025, 1, 7);

        // 매우 규칙적인 패턴
        final regularActivities = [
          _createSleepActivity('2025-01-01T10:00:00', 90),
          _createSleepActivity('2025-01-02T10:00:00', 90),
          _createSleepActivity('2025-01-03T10:00:00', 90),
          _createSleepActivity('2025-01-04T10:00:00', 90),
          _createSleepActivity('2025-01-05T10:00:00', 90),
        ];

        final data = service.analyzeSleepPeriod(
          sleepActivities: regularActivities,
          startDate: startDate,
          endDate: endDate,
        );

        // 일관성 높음 (표준편차 낮음)
        expect(data.consistencyScore, greaterThan(70));
      });

      test('should calculate quality rating', () {
        final startDate = DateTime(2025, 1, 1);
        final endDate = DateTime(2025, 1, 7);

        final activities = _createWeeklyPattern();

        final data = service.analyzeSleepPeriod(
          sleepActivities: activities,
          startDate: startDate,
          endDate: endDate,
        );

        // 품질 등급 1-5 범위
        expect(data.qualityRating, inInclusiveRange(1, 5));
      });

      test('should identify longest and shortest sleep', () {
        final startDate = DateTime(2025, 1, 1);
        final endDate = DateTime(2025, 1, 7);

        final activities = [
          _createSleepActivity('2025-01-01T10:00:00', 30),  // 최단
          _createSleepActivity('2025-01-01T14:00:00', 90),
          _createSleepActivity('2025-01-02T10:00:00', 180), // 최장
        ];

        final data = service.analyzeSleepPeriod(
          sleepActivities: activities,
          startDate: startDate,
          endDate: endDate,
        );

        expect(data.longestSleepMinutes, 180);
        expect(data.shortestSleepMinutes, 30);
      });

      test('should calculate change percentage with previous period', () {
        final startDate = DateTime(2025, 1, 8);
        final endDate = DateTime(2025, 1, 14);

        final currentActivities = [
          _createSleepActivity('2025-01-08T10:00:00', 120),
          _createSleepActivity('2025-01-09T10:00:00', 120),
        ];

        final previousActivities = [
          _createSleepActivity('2025-01-01T10:00:00', 60),
          _createSleepActivity('2025-01-02T10:00:00', 60),
        ];

        final data = service.analyzeSleepPeriod(
          sleepActivities: currentActivities,
          startDate: startDate,
          endDate: endDate,
          previousPeriodActivities: previousActivities,
        );

        // 60분 → 120분 = 100% 증가
        expect(data.changePercentage, 100);
        expect(data.trend, SleepTrend.improving);
      });

      test('should handle declining trend', () {
        final startDate = DateTime(2025, 1, 8);
        final endDate = DateTime(2025, 1, 14);

        final currentActivities = [
          _createSleepActivity('2025-01-08T10:00:00', 30),
          _createSleepActivity('2025-01-09T10:00:00', 30),
        ];

        final previousActivities = [
          _createSleepActivity('2025-01-01T10:00:00', 120),
          _createSleepActivity('2025-01-02T10:00:00', 120),
        ];

        final data = service.analyzeSleepPeriod(
          sleepActivities: currentActivities,
          startDate: startDate,
          endDate: endDate,
          previousPeriodActivities: previousActivities,
        );

        expect(data.changePercentage, lessThan(0));
        expect(data.trend, SleepTrend.declining);
      });
    });

    group('analyzeWeekly', () {
      test('should analyze last 7 days', () {
        final now = DateTime.now();
        final activities = _createWeeklyPattern();

        final data = service.analyzeWeekly(activities);

        expect(data, isNotNull);
        expect(data.startDate.isBefore(now), true);
      });

      test('should include previous week for comparison', () {
        // 2주치 데이터 생성
        final activities = <ActivityModel>[];
        for (int day = 0; day < 14; day++) {
          final date = DateTime.now().subtract(Duration(days: day));
          activities.add(
            _createSleepActivityAtDate(date, 90),
          );
        }

        final data = service.analyzeWeekly(activities);

        expect(data.changePercentage, isNotNull);
      });
    });

    group('analyzeMonthly', () {
      test('should analyze last 30 days', () {
        final now = DateTime.now();
        final activities = <ActivityModel>[];

        // 30일치 데이터 생성
        for (int day = 0; day < 30; day++) {
          final date = now.subtract(Duration(days: day));
          activities.add(_createSleepActivityAtDate(date, 90));
        }

        final data = service.analyzeMonthly(activities);

        expect(data, isNotNull);
        expect(data.totalSleepCount, greaterThan(0));
      });
    });

    group('edge cases', () {
      test('should handle single sleep activity', () {
        final startDate = DateTime(2025, 1, 1);
        final endDate = DateTime(2025, 1, 7);

        final activities = [
          _createSleepActivity('2025-01-01T10:00:00', 90),
        ];

        final data = service.analyzeSleepPeriod(
          sleepActivities: activities,
          startDate: startDate,
          endDate: endDate,
        );

        expect(data.totalSleepCount, 1);
        expect(data.averageSleepDurationMinutes, 90);
        expect(data.consistencyScore, 100.0); // 단일 데이터는 만점
      });

      test('should handle non-sleep activities gracefully', () {
        final startDate = DateTime(2025, 1, 1);
        final endDate = DateTime(2025, 1, 7);

        final activities = [
          ActivityModel(
            id: '1',
            babyId: 'test-baby',
            type: ActivityType.feeding,
            timestamp: '2025-01-01T10:00:00',
          ),
          _createSleepActivity('2025-01-01T14:00:00', 90),
        ];

        final data = service.analyzeSleepPeriod(
          sleepActivities: activities,
          startDate: startDate,
          endDate: endDate,
        );

        expect(data.totalSleepCount, 1); // 수면 활동만 카운트
      });

      test('should handle overnight sleep correctly', () {
        final startDate = DateTime(2025, 1, 1);
        final endDate = DateTime(2025, 1, 7);

        // 밤 11시에 시작해서 다음날 7시까지
        final activities = [
          _createSleepActivity('2025-01-01T23:00:00', 480), // 8시간
        ];

        final data = service.analyzeSleepPeriod(
          sleepActivities: activities,
          startDate: startDate,
          endDate: endDate,
        );

        expect(data.totalSleepCount, 1);
        expect(data.nightSleepCount, 1);
        expect(data.averageSleepDurationMinutes, 480);
      });
    });
  });
}

/// 수면 활동 생성 헬퍼 함수
ActivityModel _createSleepActivity(String timestamp, int durationMinutes) {
  final startTime = DateTime.parse(timestamp);
  final endTime = startTime.add(Duration(minutes: durationMinutes));

  return ActivityModel(
    id: 'test-${startTime.millisecondsSinceEpoch}',
    babyId: 'test-baby',
    type: ActivityType.sleep,
    timestamp: timestamp,
    endTime: endTime.toIso8601String(),
  );
}

/// 진행 중인 수면 활동 생성 (endTime 없음)
ActivityModel _createIncompleteSleepActivity(String timestamp) {
  return ActivityModel(
    id: 'test-incomplete-${DateTime.parse(timestamp).millisecondsSinceEpoch}',
    babyId: 'test-baby',
    type: ActivityType.sleep,
    timestamp: timestamp,
    // endTime 없음 - 진행 중인 수면
  );
}

/// 특정 날짜에 수면 활동 생성
ActivityModel _createSleepActivityAtDate(DateTime date, int durationMinutes) {
  final timestamp = date.toIso8601String();
  final endTime = date.add(Duration(minutes: durationMinutes)).toIso8601String();

  return ActivityModel(
    id: 'test-${date.millisecondsSinceEpoch}',
    babyId: 'test-baby',
    type: ActivityType.sleep,
    timestamp: timestamp,
    endTime: endTime,
  );
}

/// 주간 패턴 생성 (최근 7일)
List<ActivityModel> _createWeeklyPattern() {
  final now = DateTime.now();
  final activities = <ActivityModel>[];

  for (int day = 0; day < 7; day++) {
    final date = now.subtract(Duration(days: day));

    // 매일 10시 낮잠
    activities.add(
      _createSleepActivityAtDate(
        DateTime(date.year, date.month, date.day, 10, 0),
        90,
      ),
    );

    // 매일 14시 낮잠
    activities.add(
      _createSleepActivityAtDate(
        DateTime(date.year, date.month, date.day, 14, 0),
        60,
      ),
    );

    // 매일 20시 밤잠
    activities.add(
      _createSleepActivityAtDate(
        DateTime(date.year, date.month, date.day, 20, 0),
        600,
      ),
    );
  }

  return activities;
}
