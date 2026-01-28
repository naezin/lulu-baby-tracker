import 'package:flutter_test/flutter_test.dart';
import 'package:lulu/core/utils/insight_calculator.dart';
import 'package:lulu/core/utils/smart_cta_decider.dart';
import 'package:lulu/data/models/activity_model.dart';

void main() {
  group('SmartCTADecider', () {
    late TodayInsightData emptyData;

    setUp(() {
      emptyData = TodayInsightData(
        activityCounts: {},
        totalSleepDuration: Duration.zero,
        ongoingSleepCount: 0,
      );
    });

    group('decide', () {
      test('수면 완료 후 → 수유 제안', () {
        // Act
        final cta = SmartCTADecider.decide(
          lastActivity: ActivityType.sleep,
          todayData: emptyData,
        );

        // Assert
        expect(cta, isNotNull);
        expect(cta!.text, '수유 기록하기');
        expect(cta.route, '/log/feeding');
        expect(cta.reason, '방금 일어났으니 배가 고플 수 있어요');
      });

      test('수유 완료 후 → 기저귀 확인 제안', () {
        // Act
        final cta = SmartCTADecider.decide(
          lastActivity: ActivityType.feeding,
          todayData: emptyData,
        );

        // Assert
        expect(cta, isNotNull);
        expect(cta!.text, '기저귀 확인하기');
        expect(cta.route, '/log/diaper');
        expect(cta.reason, '수유 후에는 기저귀를 확인해주세요');
      });

      test('기저귀 교체 후 → 놀이 시간 제안', () {
        // Act
        final cta = SmartCTADecider.decide(
          lastActivity: ActivityType.diaper,
          todayData: emptyData,
        );

        // Assert
        expect(cta, isNotNull);
        expect(cta!.text, '놀이 시간 기록하기');
        expect(cta.route, '/log/play');
        expect(cta.reason, '기저귀를 갈고 즐거운 시간을 보내세요');
      });

      test('놀이 완료 후 → 수유 제안', () {
        // Act
        final cta = SmartCTADecider.decide(
          lastActivity: ActivityType.play,
          todayData: emptyData,
        );

        // Assert
        expect(cta, isNotNull);
        expect(cta!.text, '수유 기록하기');
        expect(cta.route, '/log/feeding');
        expect(cta.reason, '활동 후에는 배가 고플 수 있어요');
      });

      test('건강 기록 후 → 분석 화면 제안 (기본)', () {
        // Act
        final cta = SmartCTADecider.decide(
          lastActivity: ActivityType.health,
          todayData: emptyData,
        );

        // Assert
        expect(cta, isNotNull);
        expect(cta!.text, '분석 화면 보기');
        expect(cta.route, '/analysis');
        expect(cta.reason, '오늘의 기록을 한눈에 확인해보세요');
      });
    });

    group('SmartCTA 데이터 클래스', () {
      test('SmartCTA가 올바르게 생성된다', () {
        // Arrange & Act
        final cta = SmartCTA(
          text: '테스트 CTA',
          route: '/test',
          reason: '테스트 이유',
        );

        // Assert
        expect(cta.text, '테스트 CTA');
        expect(cta.route, '/test');
        expect(cta.reason, '테스트 이유');
      });
    });

    group('todayData와 상관없이 동작', () {
      test('오늘 데이터가 많아도 우선순위 로직은 동일하다', () {
        // Arrange - 많은 활동이 있는 날
        final busyDayData = TodayInsightData(
          activityCounts: {
            ActivityType.sleep: 5,
            ActivityType.feeding: 8,
            ActivityType.diaper: 10,
            ActivityType.play: 3,
          },
          totalSleepDuration: Duration(hours: 12),
          ongoingSleepCount: 0,
        );

        // Act - 수면 후 제안
        final cta = SmartCTADecider.decide(
          lastActivity: ActivityType.sleep,
          todayData: busyDayData,
        );

        // Assert - 여전히 수유 제안
        expect(cta!.text, '수유 기록하기');
        expect(cta.route, '/log/feeding');
      });

      test('오늘 데이터가 비어있어도 정상 동작한다', () {
        // Act
        final cta = SmartCTADecider.decide(
          lastActivity: ActivityType.feeding,
          todayData: emptyData,
        );

        // Assert
        expect(cta!.text, '기저귀 확인하기');
      });
    });

    group('모든 ActivityType 커버리지', () {
      test('각 ActivityType마다 CTA가 존재한다', () {
        final activityTypes = ActivityType.values;

        for (final type in activityTypes) {
          // Act
          final cta = SmartCTADecider.decide(
            lastActivity: type,
            todayData: emptyData,
          );

          // Assert - null이 아니어야 함
          expect(cta, isNotNull, reason: 'CTA should exist for $type');
          expect(cta!.text, isNotEmpty, reason: 'CTA text should not be empty for $type');
          expect(cta.route, isNotEmpty, reason: 'CTA route should not be empty for $type');
          expect(cta.reason, isNotEmpty, reason: 'CTA reason should not be empty for $type');
        }
      });

      test('모든 CTA 라우트가 유효한 형식이다', () {
        final activityTypes = ActivityType.values;

        for (final type in activityTypes) {
          // Act
          final cta = SmartCTADecider.decide(
            lastActivity: type,
            todayData: emptyData,
          );

          // Assert - 라우트는 /로 시작해야 함
          expect(
            cta!.route.startsWith('/'),
            true,
            reason: 'Route should start with / for $type',
          );
        }
      });
    });

    group('우선순위 체인 검증', () {
      test('수면 → 수유 → 기저귀 체인이 연결된다', () {
        // 1. 수면 후
        final sleepCTA = SmartCTADecider.decide(
          lastActivity: ActivityType.sleep,
          todayData: emptyData,
        );
        expect(sleepCTA!.route, '/log/feeding');

        // 2. 수유 후
        final feedingCTA = SmartCTADecider.decide(
          lastActivity: ActivityType.feeding,
          todayData: emptyData,
        );
        expect(feedingCTA!.route, '/log/diaper');

        // 3. 기저귀 후
        final diaperCTA = SmartCTADecider.decide(
          lastActivity: ActivityType.diaper,
          todayData: emptyData,
        );
        expect(diaperCTA!.route, '/log/play');

        // 4. 놀이 후 - 다시 수유로
        final playCTA = SmartCTADecider.decide(
          lastActivity: ActivityType.play,
          todayData: emptyData,
        );
        expect(playCTA!.route, '/log/feeding');
      });
    });

    group('실제 시나리오', () {
      test('아침 루틴: 기상(수면 종료) → 수유 → 기저귀 → 놀이', () {
        // 1. 밤잠에서 깨어남
        var cta = SmartCTADecider.decide(
          lastActivity: ActivityType.sleep,
          todayData: TodayInsightData(
            activityCounts: {ActivityType.sleep: 1},
            totalSleepDuration: Duration(hours: 8),
            ongoingSleepCount: 0,
          ),
        );
        expect(cta!.text, '수유 기록하기');

        // 2. 아침 수유 완료
        cta = SmartCTADecider.decide(
          lastActivity: ActivityType.feeding,
          todayData: TodayInsightData(
            activityCounts: {
              ActivityType.sleep: 1,
              ActivityType.feeding: 1,
            },
            totalSleepDuration: Duration(hours: 8),
            ongoingSleepCount: 0,
          ),
        );
        expect(cta!.text, '기저귀 확인하기');

        // 3. 기저귀 교체 완료
        cta = SmartCTADecider.decide(
          lastActivity: ActivityType.diaper,
          todayData: TodayInsightData(
            activityCounts: {
              ActivityType.sleep: 1,
              ActivityType.feeding: 1,
              ActivityType.diaper: 1,
            },
            totalSleepDuration: Duration(hours: 8),
            ongoingSleepCount: 0,
          ),
        );
        expect(cta!.text, '놀이 시간 기록하기');
      });

      test('낮잠 후: 수면 → 수유', () {
        // 오후 낮잠 후
        final cta = SmartCTADecider.decide(
          lastActivity: ActivityType.sleep,
          todayData: TodayInsightData(
            activityCounts: {
              ActivityType.sleep: 3, // 이미 여러 번 잠
              ActivityType.feeding: 5,
              ActivityType.diaper: 6,
            },
            totalSleepDuration: Duration(hours: 4),
            ongoingSleepCount: 0,
          ),
        );

        expect(cta!.text, '수유 기록하기');
        expect(cta.reason, contains('배가 고플'));
      });
    });
  });
}
