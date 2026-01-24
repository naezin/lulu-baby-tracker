import 'package:flutter_test/flutter_test.dart';
import 'package:lulu/core/utils/sweet_spot_calculator.dart';

void main() {
  group('SweetSpotCalculator', () {
    test('should calculate correct sweet spot for 3-month-old baby', () {
      // Arrange
      const ageInMonths = 3;
      final lastWakeUp = DateTime(2026, 1, 22, 10, 0); // 10:00 AM

      // Act
      final result = SweetSpotCalculator.calculate(
        ageInMonths: ageInMonths,
        lastWakeUpTime: lastWakeUp,
      );

      // Assert
      // 3개월: Wake Window 1.5 - 2.0 시간
      expect(result.sweetSpotStart, DateTime(2026, 1, 22, 11, 30)); // 10:00 + 1.5h
      expect(result.sweetSpotEnd, DateTime(2026, 1, 22, 12, 0)); // 10:00 + 2.0h
      expect(result.wakeWindowData.recommendedNaps, 4);
    });

    test('should calculate correct sweet spot for 6-month-old baby', () {
      // Arrange
      const ageInMonths = 6;
      final lastWakeUp = DateTime(2026, 1, 22, 9, 0); // 9:00 AM

      // Act
      final result = SweetSpotCalculator.calculate(
        ageInMonths: ageInMonths,
        lastWakeUpTime: lastWakeUp,
      );

      // Assert
      // 6개월: Wake Window 2.25 - 3.0 시간
      expect(result.sweetSpotStart, DateTime(2026, 1, 22, 11, 15)); // 9:00 + 2.25h
      expect(result.sweetSpotEnd, DateTime(2026, 1, 22, 12, 0)); // 9:00 + 3.0h
      expect(result.wakeWindowData.recommendedNaps, 3);
    });

    test('should adjust wake window for first nap (10% reduction)', () {
      // Arrange
      const ageInMonths = 4;
      final lastWakeUp = DateTime(2026, 1, 22, 7, 0); // 7:00 AM
      const napNumber = 1;

      // Act
      final result = SweetSpotCalculator.calculate(
        ageInMonths: ageInMonths,
        lastWakeUpTime: lastWakeUp,
        napNumber: napNumber,
      );

      // Assert
      // 4개월 기본: 1.75 - 2.5h, 첫 낮잠은 10% 감소
      // 1.75 * 0.9 = 1.575h = 1h 34.5m ≈ 1h 35m
      // 2.5 * 0.9 = 2.25h = 2h 15m
      expect(result.wakeWindowData.minHours, closeTo(1.575, 0.01));
      expect(result.wakeWindowData.maxHours, closeTo(2.25, 0.01));
    });

    test('should adjust wake window for last nap (15% increase)', () {
      // Arrange
      const ageInMonths = 6;
      final lastWakeUp = DateTime(2026, 1, 22, 15, 0); // 3:00 PM
      const napNumber = 3; // 3번째 낮잠 (6개월은 권장 3회)

      // Act
      final result = SweetSpotCalculator.calculate(
        ageInMonths: ageInMonths,
        lastWakeUpTime: lastWakeUp,
        napNumber: napNumber,
      );

      // Assert
      // 6개월 기본: 2.25 - 3.0h, 마지막 낮잠은 15% 증가
      // 2.25 * 1.15 = 2.5875h
      // 3.0 * 1.15 = 3.45h
      expect(result.wakeWindowData.minHours, closeTo(2.5875, 0.01));
      expect(result.wakeWindowData.maxHours, closeTo(3.45, 0.01));
    });

    test('should detect urgency level: too early', () {
      // Arrange
      const ageInMonths = 5;
      final lastWakeUp = DateTime.now().subtract(const Duration(minutes: 30));

      // Act
      final result = SweetSpotCalculator.calculate(
        ageInMonths: ageInMonths,
        lastWakeUpTime: lastWakeUp,
      );

      // Assert
      // 5개월: 2.0 - 2.75h, 현재 30분 경과 → too early
      expect(result.urgencyLevel, UrgencyLevel.tooEarly);
      expect(result.isActive, false);
    });

    test('should detect urgency level: approaching', () {
      // Arrange
      const ageInMonths = 4;
      // Wake Window: 1.75 - 2.5h
      // 1.75h = 105분, approaching은 시작 30분 전부터
      // 따라서 105 - 30 = 75분 전에 깨어났다면 approaching
      final lastWakeUp = DateTime.now().subtract(const Duration(minutes: 90));

      // Act
      final result = SweetSpotCalculator.calculate(
        ageInMonths: ageInMonths,
        lastWakeUpTime: lastWakeUp,
      );

      // Assert
      expect(result.urgencyLevel, UrgencyLevel.approaching);
    });

    test('should detect urgency level: optimal', () {
      // Arrange
      const ageInMonths = 3;
      // Wake Window: 1.5 - 2.0h = 90 - 120분
      final lastWakeUp = DateTime.now().subtract(const Duration(minutes: 100));

      // Act
      final result = SweetSpotCalculator.calculate(
        ageInMonths: ageInMonths,
        lastWakeUpTime: lastWakeUp,
      );

      // Assert
      expect(result.urgencyLevel, UrgencyLevel.optimal);
      expect(result.isActive, true);
    });

    test('should detect urgency level: overtired', () {
      // Arrange
      const ageInMonths = 4;
      // Wake Window: 1.75 - 2.5h = 150분
      final lastWakeUp = DateTime.now().subtract(const Duration(minutes: 180));

      // Act
      final result = SweetSpotCalculator.calculate(
        ageInMonths: ageInMonths,
        lastWakeUpTime: lastWakeUp,
      );

      // Assert
      expect(result.urgencyLevel, UrgencyLevel.overtired);
      expect(result.isOvertired, true);
    });

    test('should generate daily nap schedule for 4-month-old', () {
      // Arrange
      const ageInMonths = 4;
      final morningWakeUp = DateTime(2026, 1, 22, 7, 0); // 7:00 AM

      // Act
      final schedule = SweetSpotCalculator.calculateDailyNapSchedule(
        ageInMonths: ageInMonths,
        morningWakeUpTime: morningWakeUp,
      );

      // Assert
      // 4개월: 권장 낮잠 3회
      expect(schedule.length, 3);
      expect(schedule[0].napNumber, 1);
      expect(schedule[1].napNumber, 2);
      expect(schedule[2].napNumber, 3);

      // 각 낮잠이 이전 낮잠보다 늦은 시간이어야 함
      expect(schedule[1].sweetSpotStart.isAfter(schedule[0].sweetSpotStart), true);
      expect(schedule[2].sweetSpotStart.isAfter(schedule[1].sweetSpotStart), true);
    });

    test('should generate daily nap schedule for newborn (0 month)', () {
      // Arrange
      const ageInMonths = 0;
      final morningWakeUp = DateTime(2026, 1, 22, 7, 0);

      // Act
      final schedule = SweetSpotCalculator.calculateDailyNapSchedule(
        ageInMonths: ageInMonths,
        morningWakeUpTime: morningWakeUp,
      );

      // Assert
      // 신생아: 권장 낮잠 5회
      expect(schedule.length, 5);
    });

    test('should handle age interpolation correctly', () {
      // Arrange
      const ageInMonths = 10; // 테이블에 없는 월령
      final lastWakeUp = DateTime(2026, 1, 22, 10, 0);

      // Act
      final result = SweetSpotCalculator.calculate(
        ageInMonths: ageInMonths,
        lastWakeUpTime: lastWakeUp,
      );

      // Assert
      // 10개월은 9개월 데이터를 사용해야 함
      expect(result.wakeWindowData.minHours, 3.0);
      expect(result.wakeWindowData.maxHours, 3.75);
      expect(result.wakeWindowData.recommendedNaps, 2);
    });

    test('should format time range correctly in 12-hour format', () {
      // Arrange
      const ageInMonths = 3;
      final lastWakeUp = DateTime(2026, 1, 22, 14, 30); // 2:30 PM

      // Act
      final result = SweetSpotCalculator.calculate(
        ageInMonths: ageInMonths,
        lastWakeUpTime: lastWakeUp,
      );

      // Assert
      final formattedRange = result.getFormattedTimeRange(use24Hour: false);
      expect(formattedRange.contains('PM'), true);
    });

    test('should format time range correctly in 24-hour format', () {
      // Arrange
      const ageInMonths = 3;
      final lastWakeUp = DateTime(2026, 1, 22, 14, 30); // 14:30

      // Act
      final result = SweetSpotCalculator.calculate(
        ageInMonths: ageInMonths,
        lastWakeUpTime: lastWakeUp,
      );

      // Assert
      final formattedRange = result.getFormattedTimeRange(use24Hour: true);
      expect(formattedRange.contains('16:00'), true); // 14:30 + 1.5h
    });

    test('should export to JSON correctly', () {
      // Arrange
      const ageInMonths = 6;
      final lastWakeUp = DateTime(2026, 1, 22, 9, 0);

      // Act
      final result = SweetSpotCalculator.calculate(
        ageInMonths: ageInMonths,
        lastWakeUpTime: lastWakeUp,
        napNumber: 2,
      );

      final json = result.toJson();

      // Assert
      expect(json['ageInMonths'], 6);
      expect(json['napNumber'], 2);
      expect(json['recommendedNaps'], 3);
      expect(json.containsKey('sweetSpotStart'), true);
      expect(json.containsKey('sweetSpotEnd'), true);
    });

    test('should provide user-friendly messages for each urgency level', () {
      // Test optimal
      final optimalResult = SweetSpotCalculator.calculate(
        ageInMonths: 3,
        lastWakeUpTime: DateTime.now().subtract(const Duration(minutes: 100)),
      );
      expect(optimalResult.userFriendlyMessage.contains('Perfect time'), true);

      // Test overtired
      final overtiredResult = SweetSpotCalculator.calculate(
        ageInMonths: 3,
        lastWakeUpTime: DateTime.now().subtract(const Duration(hours: 3)),
      );
      expect(overtiredResult.userFriendlyMessage.contains('overtired'), true);
    });

    test('should calculate minutes until sweet spot correctly', () {
      // Arrange
      final lastWakeUp = DateTime.now().subtract(const Duration(minutes: 30));

      // Act
      final result = SweetSpotCalculator.calculate(
        ageInMonths: 4,
        lastWakeUpTime: lastWakeUp,
      );

      // Assert
      // 4개월: 1.75h = 105분, 현재 30분 경과 → 75분 남음
      expect(result.minutesUntilSweetSpot, closeTo(75, 2));
    });
  });

  group('WakeWindowData', () {
    test('should format hours correctly', () {
      const wakeWindow = WakeWindowData(
        minHours: 1.5,
        maxHours: 2.25,
        recommendedNaps: 4,
        description: 'Test',
      );

      expect(wakeWindow.displayRange, '1h 30m - 2h 15m');
    });

    test('should convert hours to minutes correctly', () {
      const wakeWindow = WakeWindowData(
        minHours: 2.0,
        maxHours: 3.5,
        recommendedNaps: 3,
        description: 'Test',
      );

      expect(wakeWindow.minMinutes, 120);
      expect(wakeWindow.maxMinutes, 210);
    });
  });

  group('UrgencyLevel', () {
    test('should have correct display names', () {
      expect(UrgencyLevel.tooEarly.displayName, 'Too Early');
      expect(UrgencyLevel.approaching.displayName, 'Approaching');
      expect(UrgencyLevel.optimal.displayName, 'Optimal Window');
      expect(UrgencyLevel.overtired.displayName, 'Overtired');
    });

    test('should have correct emojis', () {
      expect(UrgencyLevel.tooEarly.emoji, '⏰');
      expect(UrgencyLevel.approaching.emoji, '⏳');
      expect(UrgencyLevel.optimal.emoji, '✨');
      expect(UrgencyLevel.overtired.emoji, '⚠️');
    });
  });
}
