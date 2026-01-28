import 'package:flutter_test/flutter_test.dart';
import 'package:lulu/core/utils/insight_calculator.dart';
import 'package:lulu/data/models/activity_model.dart';
import 'package:lulu/data/services/local_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('InsightCalculator', () {
    late LocalStorageService storage;
    late InsightCalculator calculator;

    setUp(() async {
      // Mock SharedPreferences
      SharedPreferences.setMockInitialValues({});

      storage = LocalStorageService();
      calculator = InsightCalculator(storage);

      // Clear cache before each test
      InsightCalculator.invalidateCache();
    });

    group('calculateTodayInsight', () {
      test('활동이 없으면 모든 카운트가 0이다', () async {
        // Act
        final insight = await calculator.calculateTodayInsight();

        // Assert
        expect(insight.activityCounts, isEmpty);
        expect(insight.totalSleepDuration, Duration.zero);
        expect(insight.ongoingSleepCount, 0);
      });

      test('오늘의 활동 타입별 카운트를 정확히 계산한다', () async {
        // Arrange
        final now = DateTime.now();
        await storage.saveActivity(ActivityModel.sleep(
          id: 'sleep-1',
          babyId: 'baby-123',
          startTime: now.subtract(Duration(hours: 2)),
          endTime: now,
        ));
        await storage.saveActivity(ActivityModel.sleep(
          id: 'sleep-2',
          babyId: 'baby-123',
          startTime: now.subtract(Duration(hours: 4)),
          endTime: now.subtract(Duration(hours: 3)),
        ));
        await storage.saveActivity(ActivityModel.feeding(
          id: 'feeding-1',
          babyId: 'baby-123',
          time: now,
          feedingType: 'breast',
        ));
        await storage.saveActivity(ActivityModel.diaper(
          id: 'diaper-1',
          babyId: 'baby-123',
          time: now,
          diaperType: 'wet',
        ));

        // Act
        final insight = await calculator.calculateTodayInsight();

        // Assert
        expect(insight.activityCounts[ActivityType.sleep], 2);
        expect(insight.activityCounts[ActivityType.feeding], 1);
        expect(insight.activityCounts[ActivityType.diaper], 1);
        expect(insight.activityCounts[ActivityType.play], isNull);
      });

      test('완료된 수면의 총 시간을 정확히 계산한다', () async {
        // Arrange
        final now = DateTime.now();

        // 2시간 수면
        await storage.saveActivity(ActivityModel.sleep(
          id: 'sleep-1',
          babyId: 'baby-123',
          startTime: now.subtract(Duration(hours: 2)),
          endTime: now,
        ));

        // 1시간 30분 수면
        await storage.saveActivity(ActivityModel.sleep(
          id: 'sleep-2',
          babyId: 'baby-123',
          startTime: now.subtract(Duration(hours: 5)),
          endTime: now.subtract(Duration(hours: 3, minutes: 30)),
        ));

        // Act
        final insight = await calculator.calculateTodayInsight();

        // Assert
        // Total: 2h + 1.5h = 3.5h = 210 minutes
        expect(insight.totalSleepDuration.inMinutes, 210);
      });

      test('진행 중인 수면은 총 시간에 포함하지 않는다', () async {
        // Arrange
        final now = DateTime.now();

        // 완료된 수면
        await storage.saveActivity(ActivityModel.sleep(
          id: 'sleep-completed',
          babyId: 'baby-123',
          startTime: now.subtract(Duration(hours: 2)),
          endTime: now,
        ));

        // 진행 중인 수면
        await storage.saveActivity(ActivityModel.sleep(
          id: 'sleep-ongoing',
          babyId: 'baby-123',
          startTime: now.subtract(Duration(minutes: 30)),
          endTime: null, // ongoing
        ));

        // Act
        final insight = await calculator.calculateTodayInsight();

        // Assert
        expect(insight.totalSleepDuration.inMinutes, 120); // Only completed sleep
        expect(insight.ongoingSleepCount, 1);
      });

      test('진행 중인 수면 개수를 정확히 센다', () async {
        // Arrange
        final now = DateTime.now();

        await storage.saveActivity(ActivityModel.sleep(
          id: 'sleep-1',
          babyId: 'baby-123',
          startTime: now.subtract(Duration(minutes: 30)),
          endTime: null,
        ));

        await storage.saveActivity(ActivityModel.sleep(
          id: 'sleep-2',
          babyId: 'baby-123',
          startTime: now.subtract(Duration(minutes: 20)),
          endTime: null,
        ));

        // Act
        final insight = await calculator.calculateTodayInsight();

        // Assert
        expect(insight.ongoingSleepCount, 2);
      });

      test('음수 duration을 가진 수면은 무시한다', () async {
        // Arrange
        final activity = ActivityModel(
          id: 'invalid-sleep',
          babyId: 'baby-123',
          type: ActivityType.sleep,
          timestamp: DateTime.now().toIso8601String(),
          endTime: DateTime.now().toIso8601String(),
          durationMinutes: -10, // Invalid negative duration
        );

        await storage.saveActivity(activity);

        // Act
        final insight = await calculator.calculateTodayInsight();

        // Assert
        expect(insight.totalSleepDuration, Duration.zero);
      });
    });

    group('캐싱 동작', () {
      test('두 번째 호출 시 캐시를 사용한다', () async {
        // Arrange
        final now = DateTime.now();
        await storage.saveActivity(ActivityModel.feeding(
          id: 'feeding-1',
          babyId: 'baby-123',
          time: now,
          feedingType: 'breast',
        ));

        // Act - First call (cache miss)
        final insight1 = await calculator.calculateTodayInsight();

        // Add more activities after first call
        await storage.saveActivity(ActivityModel.feeding(
          id: 'feeding-2',
          babyId: 'baby-123',
          time: now,
          feedingType: 'bottle',
        ));

        // Act - Second call (cache hit, should not see feeding-2)
        final insight2 = await calculator.calculateTodayInsight();

        // Assert - Cache is used, so count should still be 1
        expect(insight1.activityCounts[ActivityType.feeding], 1);
        expect(insight2.activityCounts[ActivityType.feeding], 1);
      });

      test('invalidateCache 호출 후 캐시가 무효화된다', () async {
        // Arrange
        final now = DateTime.now();
        await storage.saveActivity(ActivityModel.feeding(
          id: 'feeding-1',
          babyId: 'baby-123',
          time: now,
          feedingType: 'breast',
        ));

        // Act - First call
        final insight1 = await calculator.calculateTodayInsight();

        // Add more and invalidate cache
        await storage.saveActivity(ActivityModel.feeding(
          id: 'feeding-2',
          babyId: 'baby-123',
          time: now,
          feedingType: 'bottle',
        ));
        InsightCalculator.invalidateCache();

        // Second call after invalidation
        final insight2 = await calculator.calculateTodayInsight();

        // Assert - Cache invalidated, should see new activity
        expect(insight1.activityCounts[ActivityType.feeding], 1);
        expect(insight2.activityCounts[ActivityType.feeding], 2);
      });

      test('캐시된 데이터의 Map은 독립적이다 (deep copy)', () async {
        // Arrange
        final now = DateTime.now();
        await storage.saveActivity(ActivityModel.feeding(
          id: 'feeding-1',
          babyId: 'baby-123',
          time: now,
          feedingType: 'breast',
        ));

        // Act
        final insight1 = await calculator.calculateTodayInsight();
        final insight2 = await calculator.calculateTodayInsight();

        // Mutate first result's map
        insight1.activityCounts[ActivityType.feeding] = 999;

        // Assert - Second result should not be affected
        expect(insight2.activityCounts[ActivityType.feeding], 1);
      });
    });

    group('generateInsightMessage', () {
      test('수면 완료 시 총 시간을 표시한다', () {
        // Arrange
        final data = TodayInsightData(
          activityCounts: {ActivityType.sleep: 3},
          totalSleepDuration: Duration(hours: 5, minutes: 30),
          ongoingSleepCount: 0,
        );

        // Act
        final message = calculator.generateInsightMessage(ActivityType.sleep, data);

        // Assert
        expect(message, '오늘 총 5시간 30분 잠을 잤어요');
      });

      test('진행 중인 수면이 있으면 해당 메시지를 표시한다', () {
        // Arrange
        final data = TodayInsightData(
          activityCounts: {ActivityType.sleep: 2},
          totalSleepDuration: Duration(hours: 3),
          ongoingSleepCount: 1,
        );

        // Act
        final message = calculator.generateInsightMessage(ActivityType.sleep, data);

        // Assert
        expect(message, '진행 중인 수면이 1건 있어요');
      });

      test('수유 메시지를 올바르게 생성한다', () {
        // Arrange
        final data = TodayInsightData(
          activityCounts: {ActivityType.feeding: 8},
          totalSleepDuration: Duration.zero,
          ongoingSleepCount: 0,
        );

        // Act
        final message = calculator.generateInsightMessage(ActivityType.feeding, data);

        // Assert
        expect(message, '오늘 8번째 수유를 기록했어요');
      });

      test('기저귀 메시지를 올바르게 생성한다', () {
        // Arrange
        final data = TodayInsightData(
          activityCounts: {ActivityType.diaper: 5},
          totalSleepDuration: Duration.zero,
          ongoingSleepCount: 0,
        );

        // Act
        final message = calculator.generateInsightMessage(ActivityType.diaper, data);

        // Assert
        expect(message, '오늘 5번째 기저귀를 갈아주셨어요');
      });

      test('놀이 메시지를 올바르게 생성한다', () {
        // Arrange
        final data = TodayInsightData(
          activityCounts: {ActivityType.play: 3},
          totalSleepDuration: Duration.zero,
          ongoingSleepCount: 0,
        );

        // Act
        final message = calculator.generateInsightMessage(ActivityType.play, data);

        // Assert
        expect(message, '오늘 3번째 놀이 활동을 했어요');
      });

      test('건강 메시지를 올바르게 생성한다', () {
        // Arrange
        final data = TodayInsightData(
          activityCounts: {ActivityType.health: 2},
          totalSleepDuration: Duration.zero,
          ongoingSleepCount: 0,
        );

        // Act
        final message = calculator.generateInsightMessage(ActivityType.health, data);

        // Assert
        expect(message, '오늘 2번째 건강 기록이에요');
      });

      test('활동 카운트가 0일 때도 메시지를 생성한다', () {
        // Arrange
        final data = TodayInsightData(
          activityCounts: {},
          totalSleepDuration: Duration.zero,
          ongoingSleepCount: 0,
        );

        // Act
        final message = calculator.generateInsightMessage(ActivityType.feeding, data);

        // Assert
        expect(message, '오늘 0번째 수유를 기록했어요');
      });
    });

    group('TodayInsightData', () {
      test('데이터 클래스가 올바르게 생성된다', () {
        // Arrange & Act
        final data = TodayInsightData(
          activityCounts: {
            ActivityType.sleep: 3,
            ActivityType.feeding: 8,
          },
          totalSleepDuration: Duration(hours: 12),
          ongoingSleepCount: 1,
        );

        // Assert
        expect(data.activityCounts[ActivityType.sleep], 3);
        expect(data.activityCounts[ActivityType.feeding], 8);
        expect(data.totalSleepDuration.inHours, 12);
        expect(data.ongoingSleepCount, 1);
      });
    });

    group('엣지 케이스', () {
      test('어제 기록은 오늘 인사이트에 포함되지 않는다', () async {
        // Arrange
        final yesterday = DateTime.now().subtract(Duration(days: 1));
        await storage.saveActivity(ActivityModel.feeding(
          id: 'feeding-yesterday',
          babyId: 'baby-123',
          time: yesterday,
          feedingType: 'breast',
        ));

        // Act
        final insight = await calculator.calculateTodayInsight();

        // Assert
        expect(insight.activityCounts[ActivityType.feeding], isNull);
      });

      test('durationMinutes가 null인 완료된 수면은 무시한다', () async {
        // Arrange
        final activity = ActivityModel(
          id: 'invalid-sleep',
          babyId: 'baby-123',
          type: ActivityType.sleep,
          timestamp: DateTime.now().toIso8601String(),
          endTime: DateTime.now().toIso8601String(),
          durationMinutes: null, // Invalid: endTime exists but duration is null
        );

        await storage.saveActivity(activity);

        // Act
        final insight = await calculator.calculateTodayInsight();

        // Assert
        expect(insight.totalSleepDuration, Duration.zero);
      });

      test('여러 타입의 활동이 섞여있어도 정확히 계산한다', () async {
        // Arrange
        final now = DateTime.now();

        // Mix of all activity types
        for (int i = 0; i < 3; i++) {
          await storage.saveActivity(ActivityModel.sleep(
            id: 'sleep-$i',
            babyId: 'baby-123',
            startTime: now.subtract(Duration(hours: 2)),
            endTime: now,
          ));
        }

        for (int i = 0; i < 8; i++) {
          await storage.saveActivity(ActivityModel.feeding(
            id: 'feeding-$i',
            babyId: 'baby-123',
            time: now,
            feedingType: 'breast',
          ));
        }

        for (int i = 0; i < 5; i++) {
          await storage.saveActivity(ActivityModel.diaper(
            id: 'diaper-$i',
            babyId: 'baby-123',
            time: now,
            diaperType: 'wet',
          ));
        }

        // Act
        final insight = await calculator.calculateTodayInsight();

        // Assert
        expect(insight.activityCounts[ActivityType.sleep], 3);
        expect(insight.activityCounts[ActivityType.feeding], 8);
        expect(insight.activityCounts[ActivityType.diaper], 5);
      });
    });
  });
}
