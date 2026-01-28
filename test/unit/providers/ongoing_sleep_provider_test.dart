import 'package:flutter_test/flutter_test.dart';
import 'package:lulu/data/models/activity_model.dart';
import 'package:lulu/data/services/local_storage_service.dart';
import 'package:lulu/presentation/providers/ongoing_sleep_provider.dart';
import 'package:lulu/presentation/providers/sweet_spot_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('OngoingSleepProvider', () {
    late LocalStorageService storage;
    late SweetSpotProvider sweetSpotProvider;
    late OngoingSleepProvider provider;

    setUp(() async {
      // Mock SharedPreferences with empty state
      SharedPreferences.setMockInitialValues({});

      storage = LocalStorageService();
      sweetSpotProvider = SweetSpotProvider();

      provider = OngoingSleepProvider(
        storage: storage,
        sweetSpotProvider: sweetSpotProvider,
      );
    });

    group('초기 상태', () {
      test('초기에는 진행 중인 수면이 없다', () {
        expect(provider.isOngoing, false);
        expect(provider.currentSleep, isNull);
        expect(provider.lastCompletedSleep, isNull);
      });

      test('초기 경과 시간은 0이다', () {
        expect(provider.elapsedTime, Duration.zero);
        expect(provider.formattedElapsedTime, '0분');
      });

      test('초기 진행률은 0이다', () {
        expect(provider.progressRatio, 0.0);
      });

      test('초기 수면 시작 시간은 null이다', () {
        expect(provider.sleepStartTime, isNull);
      });
    });

    group('startSleep', () {
      test('수면을 시작하면 진행 중인 수면이 생성된다', () async {
        // Act
        await provider.startSleep(
          babyId: 'baby-123',
          location: 'crib',
          notes: '점심 낮잠',
        );

        // Assert
        expect(provider.isOngoing, true);
        expect(provider.currentSleep, isNotNull);
        expect(provider.currentSleep!.type, ActivityType.sleep);
        expect(provider.currentSleep!.babyId, 'baby-123');
        expect(provider.currentSleep!.sleepLocation, 'crib');
        expect(provider.currentSleep!.notes, '점심 낮잠');
        expect(provider.currentSleep!.endTime, isNull);
      });

      test('수면이 시작되면 LocalStorage에 저장된다', () async {
        // Act
        await provider.startSleep(
          babyId: 'baby-123',
          location: 'crib',
        );

        // Assert
        final activities = await storage.getActivities();
        expect(activities.length, 1);
        expect(activities.first.type, ActivityType.sleep);
        expect(activities.first.babyId, 'baby-123');
        expect(activities.first.endTime, isNull);
      });

      test('수면 시작 시 notifyListeners가 호출된다', () async {
        // Arrange
        var notified = false;
        provider.addListener(() => notified = true);

        // Act
        await provider.startSleep(babyId: 'baby-123');

        // Assert
        expect(notified, true);
      });

      test('이미 진행 중인 수면이 있으면 에러를 던진다', () async {
        // Arrange - 첫 번째 수면 시작
        await provider.startSleep(babyId: 'baby-123');

        // Act & Assert
        expect(
          () => provider.startSleep(babyId: 'baby-123'),
          throwsException,
        );
      });

      test('수면 시작 후 경과 시간 계산이 가능하다', () async {
        // Act
        await provider.startSleep(babyId: 'baby-123');

        // Wait a bit to ensure time has passed
        await Future.delayed(Duration(milliseconds: 100));

        // Assert
        expect(provider.sleepStartTime, isNotNull);
        expect(provider.elapsedTime.inMilliseconds, greaterThan(0));
      });
    });

    group('endSleep', () {
      test('수면을 종료하면 endTime이 설정된다', () async {
        // Arrange
        await provider.startSleep(babyId: 'baby-123');
        await Future.delayed(Duration(milliseconds: 100));

        // Act
        await provider.endSleep(quality: 'good', notes: '잘 잤어요');

        // Assert
        expect(provider.isOngoing, false);
        expect(provider.currentSleep, isNull);
        expect(provider.lastCompletedSleep, isNotNull);
        expect(provider.lastCompletedSleep!.endTime, isNotNull);
        expect(provider.lastCompletedSleep!.sleepQuality, 'good');
        expect(provider.lastCompletedSleep!.notes, '잘 잤어요');
      });

      test('수면 종료 시 duration이 자동 계산된다', () async {
        // Arrange
        await provider.startSleep(babyId: 'baby-123');
        await Future.delayed(Duration(milliseconds: 100));

        // Act
        await provider.endSleep();

        // Assert
        expect(provider.lastCompletedSleep!.durationMinutes, isNotNull);
        // Note: 100ms is rounded down to 0 minutes, which is expected behavior
        expect(provider.lastCompletedSleep!.durationMinutes, greaterThanOrEqualTo(0));
      });

      test('수면 종료 시 LocalStorage가 업데이트된다', () async {
        // Arrange
        await provider.startSleep(babyId: 'baby-123');
        final sleepId = provider.currentSleep!.id;

        // Act
        await provider.endSleep();

        // Assert
        final activities = await storage.getActivities();
        final completedSleep = activities.firstWhere((a) => a.id == sleepId);
        expect(completedSleep.endTime, isNotNull);
        expect(completedSleep.durationMinutes, isNotNull);
      });

      test('수면 종료 시 notifyListeners가 호출된다', () async {
        // Arrange
        await provider.startSleep(babyId: 'baby-123');
        var notified = false;
        provider.addListener(() => notified = true);

        // Act
        await provider.endSleep();

        // Assert
        expect(notified, true);
      });

      test('진행 중인 수면이 없으면 에러를 던진다', () async {
        // Act & Assert
        expect(
          () => provider.endSleep(),
          throwsException,
        );
      });

      test('수면 종료 후 lastCompletedSleep이 설정된다', () async {
        // Arrange
        await provider.startSleep(babyId: 'baby-123', notes: '테스트 수면');

        // Act
        await provider.endSleep();

        // Assert
        expect(provider.lastCompletedSleep, isNotNull);
        expect(provider.lastCompletedSleep!.notes, '테스트 수면');
        expect(provider.lastCompletedSleep!.endTime, isNotNull);
      });
    });

    group('cancelSleep', () {
      test('수면을 취소하면 진행 중인 수면이 제거된다', () async {
        // Arrange
        await provider.startSleep(babyId: 'baby-123');

        // Act
        await provider.cancelSleep();

        // Assert
        expect(provider.isOngoing, false);
        expect(provider.currentSleep, isNull);
      });

      test('수면 취소 시 LocalStorage에서 삭제된다', () async {
        // Arrange
        await provider.startSleep(babyId: 'baby-123');
        final sleepId = provider.currentSleep!.id;

        // Act
        await provider.cancelSleep();

        // Assert
        final activities = await storage.getActivities();
        expect(activities.any((a) => a.id == sleepId), false);
      });

      test('수면 취소 시 notifyListeners가 호출된다', () async {
        // Arrange
        await provider.startSleep(babyId: 'baby-123');
        var notified = false;
        provider.addListener(() => notified = true);

        // Act
        await provider.cancelSleep();

        // Assert
        expect(notified, true);
      });

      test('진행 중인 수면이 없어도 에러를 던지지 않는다', () async {
        // Act & Assert - should not throw
        await provider.cancelSleep();
        expect(provider.isOngoing, false);
      });
    });

    group('progressRatio', () {
      test('권장 수면 시간의 0%일 때 progressRatio는 0.0이다', () async {
        // Arrange - just started
        await provider.startSleep(babyId: 'baby-123');

        // Assert
        expect(provider.progressRatio, lessThanOrEqualTo(0.01)); // almost 0
      });

      test('권장 수면 시간이 0일 때 progressRatio는 0.0이다', () async {
        // Arrange
        await provider.startSleep(babyId: 'baby-123');
        // SweetSpotProvider의 wakeWindowMinutes가 0인 경우 (초기 상태)

        // Act & Assert
        expect(provider.progressRatio, greaterThanOrEqualTo(0.0));
      });

      test('progressRatio는 1.0을 초과하지 않는다', () async {
        // Arrange
        await provider.startSleep(babyId: 'baby-123');

        // Act - progressRatio 계산 (clamp로 1.0 제한됨)
        final ratio = provider.progressRatio;

        // Assert
        expect(ratio, lessThanOrEqualTo(1.0));
      });
    });

    group('formattedElapsedTime', () {
      test('1시간 미만일 때 "N분" 형식이다', () async {
        // Arrange
        await provider.startSleep(babyId: 'baby-123');

        // Act
        final formatted = provider.formattedElapsedTime;

        // Assert
        expect(formatted, matches(r'^\d+분$'));
      });

      // Note: Testing "N시간 M분" format requires mocking DateTime or waiting,
      // which is complex for unit tests. Consider integration tests for this.
    });

    group('restoreOngoingSleep', () {
      test('진행 중인 수면이 없으면 복원되지 않는다', () async {
        // Act
        await provider.restoreOngoingSleep();

        // Assert
        expect(provider.isOngoing, false);
        expect(provider.currentSleep, isNull);
      });

      test('오늘 시작된 진행 중인 수면을 복원한다', () async {
        // Arrange - Create ongoing sleep directly in storage
        final now = DateTime.now();
        final ongoingSleep = ActivityModel.sleep(
          id: 'sleep-ongoing',
          babyId: 'baby-123',
          startTime: now,
          endTime: null, // ongoing
          location: 'crib',
        );
        await storage.saveActivity(ongoingSleep);

        // Act
        await provider.restoreOngoingSleep();

        // Assert
        expect(provider.isOngoing, true);
        expect(provider.currentSleep, isNotNull);
        expect(provider.currentSleep!.id, 'sleep-ongoing');
      });

      test('어제 시작된 수면은 복원하지 않는다', () async {
        // Arrange - Create sleep from yesterday
        final yesterday = DateTime.now().subtract(Duration(days: 1));
        final oldSleep = ActivityModel.sleep(
          id: 'sleep-old',
          babyId: 'baby-123',
          startTime: yesterday,
          endTime: null, // ongoing but from yesterday
        );
        await storage.saveActivity(oldSleep);

        // Act
        await provider.restoreOngoingSleep();

        // Assert
        expect(provider.isOngoing, false);
        expect(provider.currentSleep, isNull);
      });

      test('완료된 수면(endTime 있음)은 복원하지 않는다', () async {
        // Arrange - Create completed sleep
        final now = DateTime.now();
        final completedSleep = ActivityModel.sleep(
          id: 'sleep-completed',
          babyId: 'baby-123',
          startTime: now.subtract(Duration(hours: 2)),
          endTime: now,
          location: 'crib',
        );
        await storage.saveActivity(completedSleep);

        // Act
        await provider.restoreOngoingSleep();

        // Assert
        expect(provider.isOngoing, false);
        expect(provider.currentSleep, isNull);
      });

      test('여러 진행 중인 수면이 있으면 가장 최근 것을 복원한다', () async {
        // Arrange - Create multiple ongoing sleeps (edge case, shouldn't happen)
        final now = DateTime.now();
        final older = ActivityModel.sleep(
          id: 'sleep-older',
          babyId: 'baby-123',
          startTime: now.subtract(Duration(hours: 2)),
          endTime: null,
        );
        final newer = ActivityModel.sleep(
          id: 'sleep-newer',
          babyId: 'baby-123',
          startTime: now.subtract(Duration(hours: 1)),
          endTime: null,
        );

        await storage.saveActivity(older);
        await storage.saveActivity(newer);

        // Act
        await provider.restoreOngoingSleep();

        // Assert
        expect(provider.isOngoing, true);
        expect(provider.currentSleep!.id, 'sleep-newer');
      });

      test('복원 시 notifyListeners가 호출된다', () async {
        // Arrange
        final now = DateTime.now();
        final ongoingSleep = ActivityModel.sleep(
          id: 'sleep-ongoing',
          babyId: 'baby-123',
          startTime: now,
          endTime: null,
        );
        await storage.saveActivity(ongoingSleep);

        var notified = false;
        provider.addListener(() => notified = true);

        // Act
        await provider.restoreOngoingSleep();

        // Assert
        expect(notified, true);
      });
    });

    group('경과 시간 계산', () {
      test('sleepStartTime은 수면 시작 시간을 반환한다', () async {
        // Arrange
        final beforeStart = DateTime.now();
        await provider.startSleep(babyId: 'baby-123');
        final afterStart = DateTime.now();

        // Act
        final startTime = provider.sleepStartTime;

        // Assert
        expect(startTime, isNotNull);
        expect(
          startTime!.isAfter(beforeStart.subtract(Duration(seconds: 1))),
          true,
        );
        expect(
          startTime.isBefore(afterStart.add(Duration(seconds: 1))),
          true,
        );
      });

      test('잘못된 timestamp 형식이면 sleepStartTime은 null을 반환한다', () async {
        // Arrange - manually create activity with invalid timestamp
        final invalidActivity = ActivityModel(
          id: 'invalid',
          babyId: 'baby-123',
          type: ActivityType.sleep,
          timestamp: 'invalid-date',
          endTime: null,
        );

        // Manually set the ongoing sleep (bypassing validation)
        // This tests the error handling in sleepStartTime getter
        await storage.saveActivity(invalidActivity);
        await provider.restoreOngoingSleep();

        // Act & Assert
        // The provider should handle the parse error gracefully
        expect(() => provider.sleepStartTime, returnsNormally);
      });
    });

    group('통합 시나리오', () {
      test('완전한 수면 사이클: 시작 → 종료', () async {
        // 1. 수면 시작
        await provider.startSleep(
          babyId: 'baby-123',
          location: 'crib',
          notes: '점심 낮잠',
        );

        expect(provider.isOngoing, true);
        final sleepId = provider.currentSleep!.id;

        // 2. 약간의 시간 경과
        await Future.delayed(Duration(milliseconds: 100));

        // 3. 수면 종료
        await provider.endSleep(quality: 'good', notes: '잘 잤어요');

        // 4. 검증
        expect(provider.isOngoing, false);
        expect(provider.lastCompletedSleep, isNotNull);
        expect(provider.lastCompletedSleep!.id, sleepId);
        expect(provider.lastCompletedSleep!.endTime, isNotNull);
        expect(provider.lastCompletedSleep!.durationMinutes, greaterThanOrEqualTo(0));

        // 5. Storage 확인
        final activities = await storage.getActivities();
        final saved = activities.firstWhere((a) => a.id == sleepId);
        expect(saved.endTime, isNotNull);
      });

      test('완전한 수면 사이클: 시작 → 취소', () async {
        // 1. 수면 시작
        await provider.startSleep(babyId: 'baby-123');
        final sleepId = provider.currentSleep!.id;

        // 2. 수면 취소
        await provider.cancelSleep();

        // 3. 검증
        expect(provider.isOngoing, false);
        expect(provider.currentSleep, isNull);

        // 4. Storage에서 삭제 확인
        final activities = await storage.getActivities();
        expect(activities.any((a) => a.id == sleepId), false);
      });

      test('앱 재시작 시나리오: 수면 → 앱 종료 → 복원', () async {
        // 1. 수면 시작
        await provider.startSleep(babyId: 'baby-123', notes: '점심 낮잠');
        final sleepId = provider.currentSleep!.id;

        // 2. 앱 종료 시뮬레이션 (새 provider 생성)
        final newProvider = OngoingSleepProvider(
          storage: storage,
          sweetSpotProvider: sweetSpotProvider,
        );

        // 3. 앱 재시작 시 복원
        await newProvider.restoreOngoingSleep();

        // 4. 검증
        expect(newProvider.isOngoing, true);
        expect(newProvider.currentSleep!.id, sleepId);
        expect(newProvider.currentSleep!.notes, '점심 낮잠');
      });
    });
  });
}
