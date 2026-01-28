import 'package:flutter_test/flutter_test.dart';
import 'package:lulu/core/utils/sweet_spot_calculator.dart';

void main() {
  group('SweetSpotCalculator', () {
    group('calculate', () {
      test('should return valid sweet spot for 3-month baby', () {
        final lastWakeUp = DateTime(2025, 1, 1, 7, 0);

        final result = SweetSpotCalculator.calculate(
          ageInMonths: 3,
          lastWakeUpTime: lastWakeUp,
          napNumber: 1,
        );

        expect(result, isNotNull);
        expect(result.sweetSpotStart.isAfter(lastWakeUp), true);
        expect(result.sweetSpotEnd.isAfter(result.sweetSpotStart), true);
        expect(result.ageInMonths, 3);
      });

      test('신생아 (0개월)는 짧은 wake window', () {
        final lastWakeUp = DateTime(2025, 1, 1, 7, 0);

        final result = SweetSpotCalculator.calculate(
          ageInMonths: 0,
          lastWakeUpTime: lastWakeUp,
          napNumber: 1,
        );

        // 신생아: 0.5-1.0시간 wake window
        final wakeWindow = result.sweetSpotStart.difference(lastWakeUp);
        expect(wakeWindow.inMinutes, inInclusiveRange(20, 80)); // 0.5h * 0.9 ~ 1.0h 범위
      });

      test('6개월 아기는 긴 wake window', () {
        final lastWakeUp = DateTime(2025, 1, 1, 7, 0);

        final result = SweetSpotCalculator.calculate(
          ageInMonths: 6,
          lastWakeUpTime: lastWakeUp,
          napNumber: 1,
        );

        // 6개월: 2.25-3.0시간 wake window
        final wakeWindow = result.sweetSpotStart.difference(lastWakeUp);
        expect(wakeWindow.inMinutes, greaterThan(100)); // > 1.5시간
      });

      test('should handle overnight sweet spot', () {
        final lastWakeUp = DateTime(2025, 1, 1, 23, 0);

        final result = SweetSpotCalculator.calculate(
          ageInMonths: 6,
          lastWakeUpTime: lastWakeUp,
          napNumber: 3, // 밤잠
        );

        expect(result, isNotNull);
        // 다음날로 넘어갈 수 있음
        expect(result.sweetSpotStart.isAfter(lastWakeUp), true);
      });

      test('첫 번째 낮잠은 wake window 감소', () {
        final lastWakeUp = DateTime(2025, 1, 1, 7, 0);

        final firstNap = SweetSpotCalculator.calculate(
          ageInMonths: 6,
          lastWakeUpTime: lastWakeUp,
          napNumber: 1,
        );

        final normalNap = SweetSpotCalculator.calculate(
          ageInMonths: 6,
          lastWakeUpTime: lastWakeUp,
          napNumber: 2,
        );

        // 첫 번째 낮잠이 더 일찍 시작
        expect(
          firstNap.sweetSpotStart.isBefore(normalNap.sweetSpotStart),
          true,
        );
      });

      test('마지막 낮잠은 wake window 증가', () {
        final lastWakeUp = DateTime(2025, 1, 1, 15, 0);

        final normalNap = SweetSpotCalculator.calculate(
          ageInMonths: 6,
          lastWakeUpTime: lastWakeUp,
          napNumber: 2,
        );

        final lastNap = SweetSpotCalculator.calculate(
          ageInMonths: 6,
          lastWakeUpTime: lastWakeUp,
          napNumber: 3, // 권장 3회 낮잠 중 마지막
        );

        // 마지막 낮잠이 더 늦게 시작
        expect(
          lastNap.sweetSpotStart.isAfter(normalNap.sweetSpotStart),
          true,
        );
      });
    });

    group('urgencyLevel', () {
      test('should be tooEarly when far from sweet spot', () {
        final lastWakeUp = DateTime.now().subtract(const Duration(minutes: 10));

        final result = SweetSpotCalculator.calculate(
          ageInMonths: 6, // 2.25-3.0시간 wake window
          lastWakeUpTime: lastWakeUp,
        );

        expect(result.urgencyLevel, UrgencyLevel.tooEarly);
      });

      test('should be optimal when inside sweet spot', () {
        // Sweet spot 시작 시간으로 설정
        final lastWakeUp = DateTime.now().subtract(const Duration(hours: 2, minutes: 30));

        final result = SweetSpotCalculator.calculate(
          ageInMonths: 6, // 2.25-3.0시간 wake window
          lastWakeUpTime: lastWakeUp,
        );

        // 현재 시간이 sweet spot 범위 내에 있어야 함
        expect(
          [UrgencyLevel.optimal, UrgencyLevel.approaching].contains(result.urgencyLevel),
          true,
        );
      });

      test('should be overtired when past sweet spot', () {
        final lastWakeUp = DateTime.now().subtract(const Duration(hours: 4));

        final result = SweetSpotCalculator.calculate(
          ageInMonths: 6, // 2.25-3.0시간 wake window
          lastWakeUpTime: lastWakeUp,
        );

        expect(result.urgencyLevel, UrgencyLevel.overtired);
      });
    });

    group('isOvertired', () {
      test('should be true when past sweet spot end', () {
        final lastWakeUp = DateTime.now().subtract(const Duration(hours: 5));

        final result = SweetSpotCalculator.calculate(
          ageInMonths: 6,
          lastWakeUpTime: lastWakeUp,
        );

        expect(result.isOvertired, true);
      });

      test('should be false when within sweet spot', () {
        final lastWakeUp = DateTime.now().subtract(const Duration(hours: 2, minutes: 30));

        final result = SweetSpotCalculator.calculate(
          ageInMonths: 6,
          lastWakeUpTime: lastWakeUp,
        );

        // Sweet spot 범위 내 또는 아직 도달 안 함
        expect(result.isOvertired, false);
      });
    });

    group('minutesSinceWakeUp', () {
      test('should calculate minutes since wake up correctly', () {
        final lastWakeUp = DateTime.now().subtract(const Duration(minutes: 90));

        final result = SweetSpotCalculator.calculate(
          ageInMonths: 6,
          lastWakeUpTime: lastWakeUp,
        );

        expect(result.minutesSinceWakeUp, closeTo(90, 2)); // ±2분 허용
      });
    });

    group('userFriendlyMessage', () {
      test('should return appropriate message for each urgency level', () {
        final lastWakeUp = DateTime.now().subtract(const Duration(minutes: 10));

        final result = SweetSpotCalculator.calculate(
          ageInMonths: 6,
          lastWakeUpTime: lastWakeUp,
        );

        expect(result.userFriendlyMessage, isNotEmpty);
        expect(result.userFriendlyMessage, contains('Sweet spot'));
      });
    });

    group('getFormattedTimeRange', () {
      test('should format time range in 12-hour format', () {
        final lastWakeUp = DateTime(2025, 1, 1, 7, 0);

        final result = SweetSpotCalculator.calculate(
          ageInMonths: 6,
          lastWakeUpTime: lastWakeUp,
        );

        final formatted = result.getFormattedTimeRange(use24Hour: false);

        expect(formatted, contains('AM'));
        expect(formatted, contains('-'));
      });

      test('should format time range in 24-hour format', () {
        final lastWakeUp = DateTime(2025, 1, 1, 7, 0);

        final result = SweetSpotCalculator.calculate(
          ageInMonths: 6,
          lastWakeUpTime: lastWakeUp,
        );

        final formatted = result.getFormattedTimeRange(use24Hour: true);

        expect(formatted, contains(':'));
        expect(formatted, contains('-'));
        expect(formatted, isNot(contains('AM')));
        expect(formatted, isNot(contains('PM')));
      });
    });

    group('calculateDailyNapSchedule', () {
      test('should generate full day nap schedule', () {
        final morningWakeUp = DateTime(2025, 1, 1, 7, 0);

        final schedule = SweetSpotCalculator.calculateDailyNapSchedule(
          ageInMonths: 6,
          morningWakeUpTime: morningWakeUp,
        );

        // 6개월: 권장 낮잠 3회
        expect(schedule.length, 3);

        // 각 낮잠이 시간 순서대로 배열
        for (int i = 0; i < schedule.length - 1; i++) {
          expect(
            schedule[i].sweetSpotStart.isBefore(schedule[i + 1].sweetSpotStart),
            true,
          );
        }
      });

      test('should adjust wake windows by nap number', () {
        final morningWakeUp = DateTime(2025, 1, 1, 7, 0);

        final schedule = SweetSpotCalculator.calculateDailyNapSchedule(
          ageInMonths: 6,
          morningWakeUpTime: morningWakeUp,
        );

        // 첫 번째 낮잠 napNumber는 1
        expect(schedule[0].napNumber, 1);
        // 마지막 낮잠 napNumber는 권장 낮잠 횟수
        expect(schedule.last.napNumber, 3);
      });

      test('신생아는 5회 낮잠 스케줄', () {
        final morningWakeUp = DateTime(2025, 1, 1, 7, 0);

        final schedule = SweetSpotCalculator.calculateDailyNapSchedule(
          ageInMonths: 0,
          morningWakeUpTime: morningWakeUp,
        );

        expect(schedule.length, 5);
      });
    });

    group('WakeWindowData', () {
      test('should have correct data for each age', () {
        final result0m = SweetSpotCalculator.calculate(
          ageInMonths: 0,
          lastWakeUpTime: DateTime.now(),
        );
        expect(result0m.wakeWindowData.recommendedNaps, 5);

        final result6m = SweetSpotCalculator.calculate(
          ageInMonths: 6,
          lastWakeUpTime: DateTime.now(),
        );
        expect(result6m.wakeWindowData.recommendedNaps, 3);

        final result12m = SweetSpotCalculator.calculate(
          ageInMonths: 12,
          lastWakeUpTime: DateTime.now(),
        );
        expect(result12m.wakeWindowData.recommendedNaps, 2);
      });

      test('minMinutes and maxMinutes should be correct', () {
        final result = SweetSpotCalculator.calculate(
          ageInMonths: 6,
          lastWakeUpTime: DateTime.now(),
        );

        // 6개월: 2.25-3.0시간
        expect(result.wakeWindowData.minMinutes, closeTo(135, 5)); // 2.25 * 60
        expect(result.wakeWindowData.maxMinutes, closeTo(180, 5)); // 3.0 * 60
      });

      test('displayRange should format correctly', () {
        final result = SweetSpotCalculator.calculate(
          ageInMonths: 6,
          lastWakeUpTime: DateTime.now(),
        );

        final displayRange = result.wakeWindowData.displayRange;
        expect(displayRange, isNotEmpty);
        expect(displayRange, contains('-'));
      });
    });

    group('toJson', () {
      test('should serialize to JSON correctly', () {
        final lastWakeUp = DateTime(2025, 1, 1, 7, 0);

        final result = SweetSpotCalculator.calculate(
          ageInMonths: 6,
          lastWakeUpTime: lastWakeUp,
          napNumber: 2,
        );

        final json = result.toJson();

        expect(json['ageInMonths'], 6);
        expect(json['napNumber'], 2);
        expect(json['sweetSpotStart'], isNotNull);
        expect(json['sweetSpotEnd'], isNotNull);
        expect(json['isOvertired'], isA<bool>());
      });
    });

    group('edge cases', () {
      test('should handle age beyond table (24+ months)', () {
        final lastWakeUp = DateTime(2025, 1, 1, 7, 0);

        final result = SweetSpotCalculator.calculate(
          ageInMonths: 30, // 2.5년
          lastWakeUpTime: lastWakeUp,
        );

        // 가장 가까운 하위 월령 사용 (18개월)
        expect(result, isNotNull);
        expect(result.wakeWindowData.recommendedNaps, 1);
      });

      test('should handle past wake up time', () {
        final lastWakeUp = DateTime.now().subtract(const Duration(hours: 10));

        final result = SweetSpotCalculator.calculate(
          ageInMonths: 6,
          lastWakeUpTime: lastWakeUp,
        );

        expect(result, isNotNull);
        expect(result.isOvertired, true);
      });

      test('should handle napNumber beyond recommended', () {
        final lastWakeUp = DateTime(2025, 1, 1, 15, 0);

        // 6개월은 권장 3회 낮잠인데 4번째 요청
        final result = SweetSpotCalculator.calculate(
          ageInMonths: 6,
          lastWakeUpTime: lastWakeUp,
          napNumber: 4,
        );

        expect(result, isNotNull);
        // 마지막 낮잠으로 취급 (15% 증가)
      });
    });
  });
}
