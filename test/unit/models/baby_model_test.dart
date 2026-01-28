import 'package:flutter_test/flutter_test.dart';
import 'package:lulu/data/models/baby_model.dart';

void main() {
  group('BabyModel', () {
    group('pretermWeeks calculation', () {
      test('should return 0 for non-premature baby', () {
        final baby = BabyModel(
          id: '1',
          userId: 'user1',
          name: 'Test',
          birthDate: '2025-01-01',
          isPremature: false,
          createdAt: '2025-01-01T00:00:00Z',
          updatedAt: '2025-01-01T00:00:00Z',
        );

        expect(baby.pretermWeeks, 0);
      });

      test('should calculate correct preterm weeks', () {
        final baby = BabyModel(
          id: '1',
          userId: 'user1',
          name: 'Test',
          birthDate: '2025-01-01',
          dueDate: '2025-02-15', // 45일 후 (약 6주)
          isPremature: true,
          createdAt: '2025-01-01T00:00:00Z',
          updatedAt: '2025-01-01T00:00:00Z',
        );

        expect(baby.pretermWeeks, 7); // 45일 / 7 = 6.4 → ceil = 7
      });

      test('should return 0 when due date is in the past', () {
        final baby = BabyModel(
          id: '1',
          userId: 'user1',
          name: 'Test',
          birthDate: '2025-01-01',
          dueDate: '2024-12-01', // 출생 전
          isPremature: true,
          createdAt: '2025-01-01T00:00:00Z',
          updatedAt: '2025-01-01T00:00:00Z',
        );

        expect(baby.pretermWeeks, 0);
      });
    });

    group('effectiveAgeInMonths', () {
      test('should return actual age when not premature', () {
        final birthDate = DateTime.now()
            .subtract(const Duration(days: 90));

        final baby = BabyModel(
          id: '1',
          userId: 'user1',
          name: 'Test',
          birthDate: birthDate.toIso8601String().split('T')[0],
          isPremature: false,
          createdAt: '2025-01-01T00:00:00Z',
          updatedAt: '2025-01-01T00:00:00Z',
        );

        // 약 3개월
        expect(baby.effectiveAgeInMonths, closeTo(3.0, 0.5));
      });

      test('should return corrected age when premature and useCorrectedAge is true', () {
        final birthDate = DateTime.now().subtract(const Duration(days: 90));
        final dueDate = birthDate.add(const Duration(days: 42)); // 6주 후

        final baby = BabyModel(
          id: '1',
          userId: 'user1',
          name: 'Test',
          birthDate: birthDate.toIso8601String().split('T')[0],
          dueDate: dueDate.toIso8601String().split('T')[0],
          isPremature: true,
          useCorrectedAge: true,
          createdAt: '2025-01-01T00:00:00Z',
          updatedAt: '2025-01-01T00:00:00Z',
        );

        // 교정 연령: 약 1.5개월
        expect(baby.effectiveAgeInMonths, lessThan(baby.actualAgeInMonths));
        expect(baby.effectiveAgeInMonths, closeTo(1.5, 0.5));
      });

      test('should return actual age when useCorrectedAge is false', () {
        final birthDate = DateTime.now().subtract(const Duration(days: 90));
        final dueDate = birthDate.add(const Duration(days: 42));

        final baby = BabyModel(
          id: '1',
          userId: 'user1',
          name: 'Test',
          birthDate: birthDate.toIso8601String().split('T')[0],
          dueDate: dueDate.toIso8601String().split('T')[0],
          isPremature: true,
          useCorrectedAge: false,
          createdAt: '2025-01-01T00:00:00Z',
          updatedAt: '2025-01-01T00:00:00Z',
        );

        expect(baby.effectiveAgeInMonths, baby.actualAgeInMonths);
      });
    });

    group('ageInDays', () {
      test('should calculate correct age in days', () {
        final birthDate = DateTime.now().subtract(const Duration(days: 30));

        final baby = BabyModel(
          id: '1',
          userId: 'user1',
          name: 'Test',
          birthDate: birthDate.toIso8601String().split('T')[0],
          isPremature: false,
          createdAt: '2025-01-01T00:00:00Z',
          updatedAt: '2025-01-01T00:00:00Z',
        );

        expect(baby.ageInDays, 30);
      });
    });

    group('JSON serialization', () {
      test('should serialize to JSON correctly', () {
        final baby = BabyModel(
          id: '1',
          userId: 'user1',
          name: 'Test Baby',
          birthDate: '2025-01-01',
          dueDate: '2025-02-15',
          isPremature: true,
          useCorrectedAge: true,
          gender: 'male',
          birthWeightKg: 3.5,
          createdAt: '2025-01-01T00:00:00Z',
          updatedAt: '2025-01-01T00:00:00Z',
        );

        final json = baby.toJson();

        expect(json['id'], '1');
        expect(json['userId'], 'user1');
        expect(json['name'], 'Test Baby');
        expect(json['birthDate'], '2025-01-01');
        expect(json['dueDate'], '2025-02-15');
        expect(json['isPremature'], true);
        expect(json['useCorrectedAge'], true);
        expect(json['gender'], 'male');
        expect(json['birthWeightKg'], 3.5);
      });

      test('should deserialize from JSON correctly', () {
        final json = {
          'id': '1',
          'userId': 'user1',
          'name': 'Test Baby',
          'birthDate': '2025-01-01',
          'dueDate': '2025-02-15',
          'isPremature': true,
          'useCorrectedAge': true,
          'gender': 'female',
          'birthWeightKg': 2.8,
          'createdAt': '2025-01-01T00:00:00Z',
          'updatedAt': '2025-01-01T00:00:00Z',
        };

        final baby = BabyModel.fromJson(json);

        expect(baby.id, '1');
        expect(baby.userId, 'user1');
        expect(baby.name, 'Test Baby');
        expect(baby.isPremature, true);
        expect(baby.useCorrectedAge, true);
        expect(baby.gender, 'female');
        expect(baby.birthWeightKg, 2.8);
      });

      test('should handle missing useCorrectedAge (migration)', () {
        final json = {
          'id': '1',
          'userId': 'user1',
          'name': 'Old Baby',
          'birthDate': '2025-01-01',
          'isPremature': true,
          'createdAt': '2025-01-01T00:00:00Z',
          'updatedAt': '2025-01-01T00:00:00Z',
          // useCorrectedAge 없음 (마이그레이션 케이스)
        };

        final baby = BabyModel.fromJson(json);

        expect(baby.useCorrectedAge, true); // 기본값
      });

      test('should handle missing isPremature (migration)', () {
        final json = {
          'id': '1',
          'userId': 'user1',
          'name': 'Old Baby',
          'birthDate': '2025-01-01',
          'createdAt': '2025-01-01T00:00:00Z',
          'updatedAt': '2025-01-01T00:00:00Z',
          // isPremature 없음
        };

        final baby = BabyModel.fromJson(json);

        expect(baby.isPremature, false); // 기본값
      });
    });

    group('copyWith', () {
      test('should copy with updated useCorrectedAge', () {
        final baby = BabyModel(
          id: '1',
          userId: 'user1',
          name: 'Test',
          birthDate: '2025-01-01',
          isPremature: true,
          useCorrectedAge: true,
          createdAt: '2025-01-01T00:00:00Z',
          updatedAt: '2025-01-01T00:00:00Z',
        );

        final updated = baby.copyWith(useCorrectedAge: false);

        expect(updated.useCorrectedAge, false);
        expect(updated.id, baby.id); // 다른 필드 유지
        expect(updated.name, baby.name);
      });

      test('should copy with multiple fields updated', () {
        final baby = BabyModel(
          id: '1',
          userId: 'user1',
          name: 'Test',
          birthDate: '2025-01-01',
          isPremature: false,
          createdAt: '2025-01-01T00:00:00Z',
          updatedAt: '2025-01-01T00:00:00Z',
        );

        final updated = baby.copyWith(
          name: 'Updated Name',
          gender: 'male',
          birthWeightKg: 3.2,
        );

        expect(updated.name, 'Updated Name');
        expect(updated.gender, 'male');
        expect(updated.birthWeightKg, 3.2);
        expect(updated.id, baby.id); // 원본 유지
      });
    });

    group('SleepGoals', () {
      test('should serialize and deserialize correctly', () {
        final goals = SleepGoals(
          nightSleepHours: 11,
          napCount: 3,
          totalDailySleepHours: 14,
        );

        final json = goals.toJson();
        final restored = SleepGoals.fromJson(json);

        expect(restored.nightSleepHours, 11);
        expect(restored.napCount, 3);
        expect(restored.totalDailySleepHours, 14);
      });

      test('should be included in BabyModel JSON', () {
        final baby = BabyModel(
          id: '1',
          userId: 'user1',
          name: 'Test',
          birthDate: '2025-01-01',
          isPremature: false,
          sleepGoals: SleepGoals(
            nightSleepHours: 10,
            napCount: 2,
            totalDailySleepHours: 13,
          ),
          createdAt: '2025-01-01T00:00:00Z',
          updatedAt: '2025-01-01T00:00:00Z',
        );

        final json = baby.toJson();
        expect(json['sleepGoals'], isNotNull);
        expect(json['sleepGoals']['nightSleepHours'], 10);
      });
    });
  });
}
