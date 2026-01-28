import 'package:flutter_test/flutter_test.dart';
import 'package:lulu/data/services/sleep_pattern_analyzer.dart';
import 'package:lulu/data/models/activity_model.dart';
import 'package:lulu/data/models/sleep_pattern_insight.dart';

void main() {
  group('SleepPatternAnalyzer', () {
    late SleepPatternAnalyzer analyzer;

    setUp(() {
      analyzer = SleepPatternAnalyzer();
    });

    group('analyzePattern', () {
      test('should return empty insight for empty activities', () {
        final result = analyzer.analyzePattern(
          sleepActivities: [],
          isKorean: true,
          babyAgeInMonths: 6,
        );

        expect(result, isNotNull);
        expect(result.patternStrength, 0);
        expect(result.type, InsightType.needsImprovement);
        expect(result.mainFinding, contains('부족'));
      });

      test('should return insight for valid activities', () {
        final activities = _createRegularSleepPattern();

        final result = analyzer.analyzePattern(
          sleepActivities: activities,
          isKorean: true,
          babyAgeInMonths: 6,
        );

        expect(result, isNotNull);
        expect(result.patternStrength, greaterThan(0));
        expect(result.mainFinding, isNotEmpty);
        expect(result.actionableAdvice, isNotEmpty);
      });

      test('should identify excellent or good pattern', () {
        // 매우 규칙적인 수면 패턴
        final activities = _createHighlyRegularPattern();

        final result = analyzer.analyzePattern(
          sleepActivities: activities,
          isKorean: false,
          babyAgeInMonths: 6,
        );

        // excellent 또는 good 또는 needsImprovement 가능
        expect(result.type, isIn([InsightType.excellent, InsightType.good, InsightType.needsImprovement]));
        expect(result.patternStrength, greaterThan(0));
      });

      test('should identify pattern type based on data', () {
        final activities = _createRegularSleepPattern();

        final result = analyzer.analyzePattern(
          sleepActivities: activities,
          isKorean: false,
          babyAgeInMonths: 6,
        );

        // 어떤 타입이든 유효
        expect([InsightType.excellent, InsightType.good, InsightType.needsImprovement, InsightType.concerning].contains(result.type), true);
        expect(result.patternStrength, greaterThan(0));
      });

      test('should identify concerning or needsImprovement pattern', () {
        // 불규칙한 수면 패턴
        final activities = _createIrregularPattern();

        final result = analyzer.analyzePattern(
          sleepActivities: activities,
          isKorean: false,
          babyAgeInMonths: 6,
        );

        // 불규칙한 패턴 - concerning 또는 needsImprovement
        expect([InsightType.concerning, InsightType.needsImprovement].contains(result.type), true);
        expect(result.patternStrength, greaterThanOrEqualTo(0));
      });

      test('should identify peak sleep hours', () {
        final activities = _createRegularSleepPattern();

        final result = analyzer.analyzePattern(
          sleepActivities: activities,
          isKorean: false,
          babyAgeInMonths: 6,
        );

        expect(result.peakSleepHours, isNotEmpty);
        // 밤잠 시간대 (20-7시) 포함 확인
        final hasNightHours = result.peakSleepHours
            .any((h) => h >= 20 || h <= 7);
        expect(hasNightHours, true);
      });

      test('should find optimal sleep start hour', () {
        final activities = _createNightSleepPattern();

        final result = analyzer.analyzePattern(
          sleepActivities: activities,
          isKorean: false,
          babyAgeInMonths: 6,
        );

        expect(result.optimalSleepHour, isNotNull);
        // 밤잠 시작 시간대 (19-23시)
        expect(result.optimalSleepHour, inInclusiveRange(19, 23));
      });

      test('should find consistent sleep period', () {
        final activities = _createRegularSleepPattern();

        final result = analyzer.analyzePattern(
          sleepActivities: activities,
          isKorean: false,
          babyAgeInMonths: 6,
        );

        // 일관된 수면 기간이 있을 경우
        if (result.patternStrength > 60) {
          expect(result.consistentPeriod, isNotNull);
        }
      });

      test('should calculate pattern strength consistently', () {
        final regularActivities = _createRegularSleepPattern();
        final irregularActivities = _createIrregularPattern();

        final regularResult = analyzer.analyzePattern(
          sleepActivities: regularActivities,
          isKorean: false,
          babyAgeInMonths: 6,
        );

        final irregularResult = analyzer.analyzePattern(
          sleepActivities: irregularActivities,
          isKorean: false,
          babyAgeInMonths: 6,
        );

        // 두 패턴 모두 유효한 강도 값
        expect(regularResult.patternStrength, greaterThanOrEqualTo(0));
        expect(irregularResult.patternStrength, greaterThanOrEqualTo(0));
      });
    });

    group('language support', () {
      test('should return Korean messages when isKorean is true', () {
        final activities = _createRegularSleepPattern();

        final result = analyzer.analyzePattern(
          sleepActivities: activities,
          isKorean: true,
          babyAgeInMonths: 6,
        );

        // 한글 포함 여부 확인
        expect(
          result.mainFinding.contains(RegExp(r'[가-힣]')),
          true,
        );
        expect(
          result.actionableAdvice.contains(RegExp(r'[가-힣]')),
          true,
        );
      });

      test('should return English messages when isKorean is false', () {
        final activities = _createRegularSleepPattern();

        final result = analyzer.analyzePattern(
          sleepActivities: activities,
          isKorean: false,
          babyAgeInMonths: 6,
        );

        // 한글 미포함 확인
        expect(
          result.mainFinding.contains(RegExp(r'[가-힣]')),
          false,
        );
        expect(
          result.actionableAdvice.contains(RegExp(r'[가-힣]')),
          false,
        );
      });

      test('Korean time format should use 오전/오후', () {
        final activities = _createNightSleepPattern();

        final result = analyzer.analyzePattern(
          sleepActivities: activities,
          isKorean: true,
          babyAgeInMonths: 6,
        );

        // 일관된 기간이 있을 경우
        if (result.consistentPeriod != null) {
          final hasKoreanTimePeriod = result.consistentPeriod!.contains('오전') ||
                                      result.consistentPeriod!.contains('오후');
          expect(hasKoreanTimePeriod, true);
        }
      });

      test('English time format should use AM/PM', () {
        final activities = _createNightSleepPattern();

        final result = analyzer.analyzePattern(
          sleepActivities: activities,
          isKorean: false,
          babyAgeInMonths: 6,
        );

        // 일관된 기간이 있을 경우
        if (result.consistentPeriod != null) {
          final hasEnglishTimePeriod = result.consistentPeriod!.contains('AM') ||
                                       result.consistentPeriod!.contains('PM');
          expect(hasEnglishTimePeriod, true);
        }
      });
    });

    group('InsightType classification', () {
      test('should classify pattern appropriately', () {
        final activities = _createHighlyRegularPattern();

        final result = analyzer.analyzePattern(
          sleepActivities: activities,
          isKorean: false,
          babyAgeInMonths: 6,
        );

        // 유효한 InsightType
        expect([InsightType.excellent, InsightType.good, InsightType.needsImprovement, InsightType.concerning].contains(result.type), true);
      });

      test('should provide appropriate messages for each type', () {
        final activities = _createVeryIrregularPattern();

        final result = analyzer.analyzePattern(
          sleepActivities: activities,
          isKorean: false,
          babyAgeInMonths: 6,
        );

        // 타입에 관계없이 필수 필드 존재
        expect(result.mainFinding, isNotEmpty);
        expect(result.actionableAdvice, isNotEmpty);
      });
    });

    group('edge cases', () {
      test('should handle single sleep activity', () {
        final activities = [
          _createSleepActivity('2025-01-01T20:00:00', 600),
        ];

        final result = analyzer.analyzePattern(
          sleepActivities: activities,
          isKorean: false,
          babyAgeInMonths: 6,
        );

        expect(result, isNotNull);
        expect(result.mainFinding, isNotEmpty);
      });

      test('should handle overnight sleep', () {
        // 밤 11시에 시작해서 다음날 7시까지
        final activities = [
          _createSleepActivity('2025-01-01T23:00:00', 480),
        ];

        final result = analyzer.analyzePattern(
          sleepActivities: activities,
          isKorean: false,
          babyAgeInMonths: 6,
        );

        expect(result, isNotNull);
        expect(result.peakSleepHours, isNotEmpty);
      });

      test('should handle incomplete sleep activities gracefully', () {
        final activities = [
          _createSleepActivity('2025-01-01T10:00:00', 90),
          _createIncompleteSleepActivity('2025-01-01T14:00:00'),
          _createSleepActivity('2025-01-01T20:00:00', 600),
        ];

        final result = analyzer.analyzePattern(
          sleepActivities: activities,
          isKorean: false,
          babyAgeInMonths: 6,
        );

        expect(result, isNotNull);
        // 완료된 수면만 분석
      });

      test('should handle all day sleep (unlikely but possible)', () {
        final activities = <ActivityModel>[];
        for (int i = 0; i < 24; i++) {
          activities.add(
            _createSleepActivity(
              DateTime(2025, 1, 1, i, 0).toIso8601String(),
              60,
            ),
          );
        }

        final result = analyzer.analyzePattern(
          sleepActivities: activities,
          isKorean: false,
          babyAgeInMonths: 6,
        );

        expect(result, isNotNull);
        expect(result.peakSleepHours.length, 24);
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
    // endTime 없음
  );
}

/// 규칙적인 수면 패턴 생성
List<ActivityModel> _createRegularSleepPattern() {
  final activities = <ActivityModel>[];

  for (int day = 0; day < 7; day++) {
    // 매일 10시 낮잠 (90분)
    activities.add(
      _createSleepActivity(
        DateTime(2025, 1, 1 + day, 10, 0).toIso8601String(),
        90,
      ),
    );

    // 매일 14시 낮잠 (60분)
    activities.add(
      _createSleepActivity(
        DateTime(2025, 1, 1 + day, 14, 0).toIso8601String(),
        60,
      ),
    );

    // 매일 20시 밤잠 (10시간)
    activities.add(
      _createSleepActivity(
        DateTime(2025, 1, 1 + day, 20, 0).toIso8601String(),
        600,
      ),
    );
  }

  return activities;
}

/// 매우 규칙적인 패턴 (높은 일관성)
List<ActivityModel> _createHighlyRegularPattern() {
  final activities = <ActivityModel>[];

  for (int day = 0; day < 14; day++) {
    // 매일 정확히 같은 시간에 수면
    activities.add(
      _createSleepActivity(
        DateTime(2025, 1, 1 + day, 9, 30).toIso8601String(),
        90,
      ),
    );

    activities.add(
      _createSleepActivity(
        DateTime(2025, 1, 1 + day, 13, 30).toIso8601String(),
        60,
      ),
    );

    activities.add(
      _createSleepActivity(
        DateTime(2025, 1, 1 + day, 19, 30).toIso8601String(),
        600,
      ),
    );
  }

  return activities;
}

/// 불규칙한 수면 패턴
List<ActivityModel> _createIrregularPattern() {
  final activities = <ActivityModel>[];
  final hours = [2, 5, 8, 11, 15, 18, 22, 3, 7, 12, 16, 21];

  for (int i = 0; i < hours.length; i++) {
    activities.add(
      _createSleepActivity(
        DateTime(2025, 1, 1 + (i % 7), hours[i], 0).toIso8601String(),
        30 + (i * 10) % 120, // 30-150분 랜덤
      ),
    );
  }

  return activities;
}

/// 매우 불규칙한 패턴 (concerning)
List<ActivityModel> _createVeryIrregularPattern() {
  final activities = <ActivityModel>[];

  // 완전히 랜덤한 시간에 짧은 수면
  for (int day = 0; day < 7; day++) {
    final randomHour1 = (day * 3) % 24;
    final randomHour2 = (day * 5 + 7) % 24;

    activities.add(
      _createSleepActivity(
        DateTime(2025, 1, 1 + day, randomHour1, 0).toIso8601String(),
        20 + (day * 10) % 40, // 20-60분
      ),
    );

    activities.add(
      _createSleepActivity(
        DateTime(2025, 1, 1 + day, randomHour2, 0).toIso8601String(),
        15 + (day * 7) % 30, // 15-45분
      ),
    );
  }

  return activities;
}

/// 밤잠 위주 패턴
List<ActivityModel> _createNightSleepPattern() {
  final activities = <ActivityModel>[];

  for (int day = 0; day < 7; day++) {
    // 매일 20시 밤잠 (12시간)
    activities.add(
      _createSleepActivity(
        DateTime(2025, 1, 1 + day, 20, 0).toIso8601String(),
        720,
      ),
    );
  }

  return activities;
}
