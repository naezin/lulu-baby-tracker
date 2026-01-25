import 'package:flutter_test/flutter_test.dart';
import 'package:lulu/data/models/activity_model.dart';

void main() {
  group('ActivityModel', () {
    group('fromJson', () {
      test('수면 활동을 JSON에서 올바르게 파싱한다', () {
        // Arrange
        final json = {
          'id': 'sleep-123',
          'type': 'sleep',
          'timestamp': '2026-01-26T14:30:00.000Z',
          'endTime': '2026-01-26T16:30:00.000Z',
          'durationMinutes': 120,
          'notes': '점심 낮잠',
          'sleepLocation': 'crib',
          'sleepQuality': 'good',
        };

        // Act
        final activity = ActivityModel.fromJson(json);

        // Assert
        expect(activity.id, 'sleep-123');
        expect(activity.type, ActivityType.sleep);
        expect(activity.timestamp, '2026-01-26T14:30:00.000Z');
        expect(activity.endTime, '2026-01-26T16:30:00.000Z');
        expect(activity.durationMinutes, 120);
        expect(activity.notes, '점심 낮잠');
        expect(activity.sleepLocation, 'crib');
        expect(activity.sleepQuality, 'good');
      });

      test('수유 활동을 JSON에서 올바르게 파싱한다', () {
        // Arrange
        final json = {
          'id': 'feeding-456',
          'type': 'feeding',
          'timestamp': '2026-01-26T10:00:00.000Z',
          'feedingType': 'bottle',
          'amountMl': 120.0,
          'amountOz': 4.0,
          'notes': '아침 수유',
        };

        // Act
        final activity = ActivityModel.fromJson(json);

        // Assert
        expect(activity.id, 'feeding-456');
        expect(activity.type, ActivityType.feeding);
        expect(activity.feedingType, 'bottle');
        expect(activity.amountMl, 120.0);
        expect(activity.amountOz, 4.0);
        expect(activity.notes, '아침 수유');
      });

      test('기저귀 활동을 JSON에서 올바르게 파싱한다', () {
        // Arrange
        final json = {
          'id': 'diaper-789',
          'type': 'diaper',
          'timestamp': '2026-01-26T11:00:00.000Z',
          'diaperType': 'both',
          'notes': '점심 전 교체',
        };

        // Act
        final activity = ActivityModel.fromJson(json);

        // Assert
        expect(activity.id, 'diaper-789');
        expect(activity.type, ActivityType.diaper);
        expect(activity.diaperType, 'both');
        expect(activity.notes, '점심 전 교체');
      });

      test('건강 활동(체온)을 JSON에서 올바르게 파싱한다', () {
        // Arrange
        final json = {
          'id': 'health-temp-111',
          'type': 'health',
          'timestamp': '2026-01-26T18:00:00.000Z',
          'temperatureCelsius': 37.2,
          'temperatureUnit': 'celsius',
          'notes': '저녁 체온 측정',
        };

        // Act
        final activity = ActivityModel.fromJson(json);

        // Assert
        expect(activity.id, 'health-temp-111');
        expect(activity.type, ActivityType.health);
        expect(activity.temperatureCelsius, 37.2);
        expect(activity.temperatureUnit, 'celsius');
      });

      test('건강 활동(약물)을 JSON에서 올바르게 파싱한다', () {
        // Arrange
        final json = {
          'id': 'health-med-222',
          'type': 'health',
          'timestamp': '2026-01-26T20:00:00.000Z',
          'medicationType': 'fever_reducer',
          'medicationName': 'acetaminophen',
          'dosageAmount': 5.0,
          'dosageUnit': 'ml',
          'nextDoseTime': '2026-01-27T00:00:00.000Z',
        };

        // Act
        final activity = ActivityModel.fromJson(json);

        // Assert
        expect(activity.id, 'health-med-222');
        expect(activity.type, ActivityType.health);
        expect(activity.medicationType, 'fever_reducer');
        expect(activity.medicationName, 'acetaminophen');
        expect(activity.dosageAmount, 5.0);
        expect(activity.dosageUnit, 'ml');
        expect(activity.nextDoseTime, isNotNull);
      });

      test('놀이 활동을 JSON에서 올바르게 파싱한다', () {
        // Arrange
        final json = {
          'id': 'play-333',
          'type': 'play',
          'timestamp': '2026-01-26T15:00:00.000Z',
          'durationMinutes': 30,
          'playActivityType': 'tummy_time',
          'developmentTags': ['motor', 'cognitive'],
          'notes': '즐거운 놀이 시간',
        };

        // Act
        final activity = ActivityModel.fromJson(json);

        // Assert
        expect(activity.id, 'play-333');
        expect(activity.type, ActivityType.play);
        expect(activity.playActivityType, 'tummy_time');
        expect(activity.developmentTags, ['motor', 'cognitive']);
        expect(activity.durationMinutes, 30);
      });

      test('필수 필드만 있는 최소 JSON을 파싱한다', () {
        // Arrange
        final json = {
          'id': 'minimal-001',
          'type': 'sleep',
          'timestamp': '2026-01-26T12:00:00.000Z',
        };

        // Act
        final activity = ActivityModel.fromJson(json);

        // Assert
        expect(activity.id, 'minimal-001');
        expect(activity.type, ActivityType.sleep);
        expect(activity.timestamp, '2026-01-26T12:00:00.000Z');
        expect(activity.notes, isNull);
        expect(activity.durationMinutes, isNull);
      });
    });

    group('toJson', () {
      test('수면 활동을 JSON으로 올바르게 변환한다', () {
        // Arrange
        final activity = ActivityModel(
          id: 'sleep-test',
          type: ActivityType.sleep,
          timestamp: '2026-01-26T14:00:00.000Z',
          endTime: '2026-01-26T15:00:00.000Z',
          durationMinutes: 60,
          sleepLocation: 'crib',
          sleepQuality: 'good',
          notes: '좋은 낮잠',
        );

        // Act
        final json = activity.toJson();

        // Assert
        expect(json['id'], 'sleep-test');
        expect(json['type'], 'sleep');
        expect(json['timestamp'], '2026-01-26T14:00:00.000Z');
        expect(json['endTime'], '2026-01-26T15:00:00.000Z');
        expect(json['durationMinutes'], 60);
        expect(json['sleepLocation'], 'crib');
        expect(json['sleepQuality'], 'good');
        expect(json['notes'], '좋은 낮잠');
      });

      test('수유 활동을 JSON으로 올바르게 변환한다', () {
        // Arrange
        final activity = ActivityModel(
          id: 'feeding-test',
          type: ActivityType.feeding,
          timestamp: '2026-01-26T10:00:00.000Z',
          feedingType: 'breast',
          breastSide: 'left',
          durationMinutes: 15,
          notes: '왼쪽 모유 수유',
        );

        // Act
        final json = activity.toJson();

        // Assert
        expect(json['id'], 'feeding-test');
        expect(json['type'], 'feeding');
        expect(json['feedingType'], 'breast');
        expect(json['breastSide'], 'left');
        expect(json['durationMinutes'], 15);
      });

      test('null 필드도 JSON에 포함된다 (현재 구현)', () {
        // Arrange
        final activity = ActivityModel(
          id: 'minimal-test',
          type: ActivityType.diaper,
          timestamp: '2026-01-26T12:00:00.000Z',
          diaperType: 'wet',
        );

        // Act
        final json = activity.toJson();

        // Assert - 현재 구현은 모든 필드를 포함 (null이어도)
        expect(json.containsKey('notes'), isTrue);
        expect(json['notes'], isNull);
        expect(json.containsKey('durationMinutes'), isTrue);
        expect(json['durationMinutes'], isNull);
        // 필수 필드는 값이 있음
        expect(json['id'], 'minimal-test');
        expect(json['type'], 'diaper');
        expect(json['timestamp'], '2026-01-26T12:00:00.000Z');
        expect(json['diaperType'], 'wet');
      });
    });

    group('fromJson → toJson 왕복 변환', () {
      test('JSON → Model → JSON 변환이 일관성 있다', () {
        // Arrange
        final originalJson = {
          'id': 'roundtrip-test',
          'type': 'sleep',
          'timestamp': '2026-01-26T14:00:00.000Z',
          'endTime': '2026-01-26T16:00:00.000Z',
          'durationMinutes': 120,
          'sleepLocation': 'bed',
          'sleepQuality': 'fair',
          'notes': '점심 낮잠',
        };

        // Act
        final model = ActivityModel.fromJson(originalJson);
        final resultJson = model.toJson();

        // Assert
        expect(resultJson['id'], originalJson['id']);
        expect(resultJson['type'], originalJson['type']);
        expect(resultJson['timestamp'], originalJson['timestamp']);
        expect(resultJson['endTime'], originalJson['endTime']);
        expect(resultJson['durationMinutes'], originalJson['durationMinutes']);
        expect(resultJson['sleepLocation'], originalJson['sleepLocation']);
        expect(resultJson['sleepQuality'], originalJson['sleepQuality']);
        expect(resultJson['notes'], originalJson['notes']);
      });
    });

    // copyWith 메서드는 현재 ActivityModel에 구현되지 않음
    // 필요 시 향후 추가 가능
  });
}
