import 'package:uuid/uuid.dart';
import '../models/baby_model.dart';
import '../models/activity_model.dart';

/// 샘플 데이터 서비스 - 조이(Joy)의 실제 데이터
///
/// 목적: 앱 데모/테스트를 위한 실제 사용자 데이터 제공
///
/// 조이 프로필:
/// - 이름: 조이 (Joy)
/// - 생년월일: 2025-11-11
/// - 예정일: 2025-11-26 (15일 조산)
/// - 성별: 여아
/// - 출생 체중: 2.3kg (저체중아)
/// - 현재: 생후 74일 (교정 59일)
class SampleDataService {
  static const _uuid = Uuid();

  /// 조이 베이비 프로필 생성
  static BabyModel createJoiBaby({String? userId}) {
    return BabyModel(
      id: 'baby_joi_001',
      userId: userId ?? 'user_sample_001',
      name: '조이',
      birthDate: '2025-11-11T00:00:00.000Z',
      dueDate: '2025-11-26T00:00:00.000Z',
      isPremature: true,
      gender: 'female',
      photoUrl: null,
      weightKg: 2.3,
      weightUnit: 'kg',
      sleepGoals: SleepGoals(
        nightSleepHours: 10,
        napCount: 3,
        totalDailySleepHours: 15,
      ),
      createdAt: '2025-11-11T00:00:00.000Z',
      updatedAt: DateTime.now().toIso8601String(),
    );
  }

  /// 조이의 22일간 일별 통계 데이터
  ///
  /// 날짜: 2025-12-03 ~ 2025-12-24 (22일간)
  /// 포함 데이터: 수면, 수유, 기저귀, 메모 횟수
  static final List<Map<String, dynamic>> _joiDailyStats = [
    {'date': '2025-12-03', 'sleep': 4, 'feeding': 8, 'diaper': 7, 'notes': 2},
    {'date': '2025-12-04', 'sleep': 5, 'feeding': 7, 'diaper': 6, 'notes': 1},
    {'date': '2025-12-05', 'sleep': 3, 'feeding': 9, 'diaper': 8, 'notes': 0},
    {'date': '2025-12-06', 'sleep': 6, 'feeding': 8, 'diaper': 7, 'notes': 3},
    {'date': '2025-12-07', 'sleep': 4, 'feeding': 7, 'diaper': 6, 'notes': 1},
    {'date': '2025-12-08', 'sleep': 5, 'feeding': 8, 'diaper': 8, 'notes': 2},
    {'date': '2025-12-09', 'sleep': 7, 'feeding': 9, 'diaper': 7, 'notes': 1},
    {'date': '2025-12-10', 'sleep': 4, 'feeding': 7, 'diaper': 6, 'notes': 0},
    {'date': '2025-12-11', 'sleep': 6, 'feeding': 8, 'diaper': 7, 'notes': 2},
    {'date': '2025-12-12', 'sleep': 5, 'feeding': 8, 'diaper': 8, 'notes': 1},
    {'date': '2025-12-13', 'sleep': 4, 'feeding': 7, 'diaper': 6, 'notes': 3},
    {'date': '2025-12-14', 'sleep': 6, 'feeding': 9, 'diaper': 7, 'notes': 0},
    {'date': '2025-12-15', 'sleep': 5, 'feeding': 8, 'diaper': 8, 'notes': 2},
    {'date': '2025-12-16', 'sleep': 7, 'feeding': 7, 'diaper': 6, 'notes': 1},
    {'date': '2025-12-17', 'sleep': 4, 'feeding': 8, 'diaper': 7, 'notes': 0},
    {'date': '2025-12-18', 'sleep': 6, 'feeding': 9, 'diaper': 8, 'notes': 2},
    {'date': '2025-12-19', 'sleep': 5, 'feeding': 7, 'diaper': 7, 'notes': 1},
    {'date': '2025-12-20', 'sleep': 4, 'feeding': 8, 'diaper': 6, 'notes': 3},
    {'date': '2025-12-21', 'sleep': 6, 'feeding': 8, 'diaper': 7, 'notes': 0},
    {'date': '2025-12-22', 'sleep': 5, 'feeding': 7, 'diaper': 8, 'notes': 2},
    {'date': '2025-12-23', 'sleep': 7, 'feeding': 9, 'diaper': 7, 'notes': 1},
    {'date': '2025-12-24', 'sleep': 4, 'feeding': 8, 'diaper': 6, 'notes': 0},
  ];

  /// 최근 N일간의 활동 기록 생성
  ///
  /// [days]: 생성할 일수 (기본값: 7일)
  /// [babyId]: 베이비 ID (기본값: 조이 ID)
  ///
  /// 반환: 생성된 ActivityModel 리스트 (시간 역순 정렬)
  static List<ActivityModel> generateRecentActivities({
    int days = 7,
    String? babyId,
  }) {
    final activities = <ActivityModel>[];
    final baby = createJoiBaby();
    final targetBabyId = babyId ?? baby.id;

    // 최근 N일의 통계 데이터 추출
    final recentStats = _joiDailyStats.reversed.take(days).toList().reversed.toList();

    for (final dayStat in recentStats) {
      final dateStr = dayStat['date'] as String;
      final date = DateTime.parse(dateStr);

      // 수면 기록 생성
      final sleepCount = dayStat['sleep'] as int;
      activities.addAll(_generateSleepActivities(
        targetBabyId,
        date,
        sleepCount,
      ));

      // 수유 기록 생성
      final feedingCount = dayStat['feeding'] as int;
      activities.addAll(_generateFeedingActivities(
        targetBabyId,
        date,
        feedingCount,
      ));

      // 기저귀 기록 생성
      final diaperCount = dayStat['diaper'] as int;
      activities.addAll(_generateDiaperActivities(
        targetBabyId,
        date,
        diaperCount,
      ));

      // 메모 기록 생성
      final notesCount = dayStat['notes'] as int;
      activities.addAll(_generateNoteActivities(
        targetBabyId,
        date,
        notesCount,
      ));
    }

    // 시간 역순 정렬 (최신순)
    activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return activities;
  }

  /// 수면 활동 생성
  static List<ActivityModel> _generateSleepActivities(
    String babyId,
    DateTime date,
    int count,
  ) {
    final activities = <ActivityModel>[];
    final sleepPatterns = [
      {'hour': 1, 'duration': 180}, // 새벽 3시간
      {'hour': 5, 'duration': 120}, // 아침 2시간
      {'hour': 10, 'duration': 90}, // 오전 낮잠 1.5시간
      {'hour': 14, 'duration': 120}, // 오후 낮잠 2시간
      {'hour': 18, 'duration': 60}, // 저녁 낮잠 1시간
      {'hour': 21, 'duration': 240}, // 밤잠 4시간
      {'hour': 23, 'duration': 150}, // 늦은 밤잠 2.5시간
    ];

    for (var i = 0; i < count && i < sleepPatterns.length; i++) {
      final pattern = sleepPatterns[i];
      final startTime = DateTime(
        date.year,
        date.month,
        date.day,
        pattern['hour'] as int,
        _randomMinute(),
      );

      activities.add(ActivityModel.sleep(
        id: _uuid.v4(),
        startTime: startTime,
        endTime: startTime.add(Duration(minutes: pattern['duration'] as int)),
        location: 'crib',
        quality: 'good',
        notes: _getRandomSleepNote(),
      ));
    }

    return activities;
  }

  /// 수유 활동 생성
  static List<ActivityModel> _generateFeedingActivities(
    String babyId,
    DateTime date,
    int count,
  ) {
    final activities = <ActivityModel>[];
    final feedingHours = [0, 3, 6, 9, 12, 15, 18, 21, 23]; // 3시간 간격

    for (var i = 0; i < count && i < feedingHours.length; i++) {
      final hour = feedingHours[i];
      final time = DateTime(
        date.year,
        date.month,
        date.day,
        hour,
        _randomMinute(),
      );

      final isBottle = i % 3 != 0; // 2/3는 분유, 1/3은 모유

      activities.add(ActivityModel.feeding(
        id: _uuid.v4(),
        time: time,
        feedingType: isBottle ? 'bottle' : 'breast',
        amountMl: isBottle ? _randomAmount().toDouble() : null,
        breastSide: !isBottle ? _randomBreastSide() : null,
        notes: _getRandomFeedingNote(isBottle),
      ));
    }

    return activities;
  }

  /// 기저귀 활동 생성
  static List<ActivityModel> _generateDiaperActivities(
    String babyId,
    DateTime date,
    int count,
  ) {
    final activities = <ActivityModel>[];
    final diaperHours = [1, 4, 7, 10, 13, 16, 19, 22]; // 분산 배치

    for (var i = 0; i < count && i < diaperHours.length; i++) {
      final hour = diaperHours[i];
      final time = DateTime(
        date.year,
        date.month,
        date.day,
        hour,
        _randomMinute(),
      );

      const hasWet = true; // 대부분 소변
      final hasPoop = i % 3 == 0; // 1/3 확률로 대변

      String diaperType;
      if (hasWet && hasPoop) {
        diaperType = 'both';
      } else if (hasPoop) {
        diaperType = 'dirty';
      } else {
        diaperType = 'wet';
      }

      activities.add(ActivityModel.diaper(
        id: _uuid.v4(),
        time: time,
        diaperType: diaperType,
        notes: _getRandomDiaperNote(hasWet, hasPoop),
      ));
    }

    return activities;
  }

  /// 메모 활동 생성 (Play 타입으로 대체)
  static List<ActivityModel> _generateNoteActivities(
    String babyId,
    DateTime date,
    int count,
  ) {
    final activities = <ActivityModel>[];
    final noteHours = [8, 14, 20]; // 아침, 점심, 저녁

    final noteTemplates = [
      '오늘 처음으로 눈을 맞추며 웃었어요 😊',
      '목을 잘 가누기 시작했어요!',
      '소아과 검진 - 체중 증가 양호',
      '배앓이가 있었지만 금방 진정됨',
      '오늘따라 잠투정이 심했어요',
      '새로운 장난감에 관심을 보임',
    ];

    for (var i = 0; i < count && i < noteHours.length; i++) {
      final hour = noteHours[i];
      final time = DateTime(
        date.year,
        date.month,
        date.day,
        hour,
        _randomMinute(),
      );

      // Play 타입으로 메모 기록 (notes 필드 활용)
      activities.add(ActivityModel.play(
        id: _uuid.v4(),
        startTime: time,
        playActivityType: 'observation',
        durationMinutes: 0,
        notes: noteTemplates[i % noteTemplates.length],
      ));
    }

    return activities;
  }

  // === 헬퍼 함수들 ===

  static int _randomMinute() {
    const minutes = [0, 15, 30, 45];
    return minutes[DateTime.now().microsecond % 4];
  }

  static int _randomAmount() {
    final amounts = [60, 70, 80, 90, 100, 110, 120];
    return amounts[DateTime.now().microsecond % amounts.length];
  }

  static String _randomBreastSide() {
    final sides = ['left', 'right', 'both'];
    return sides[DateTime.now().microsecond % sides.length];
  }

  static String? _getRandomSleepNote() {
    final notes = [
      null,
      '푹 잤어요',
      '중간에 깼어요',
      '잠투정 있었음',
      '잘 재웠어요',
    ];
    return notes[DateTime.now().microsecond % notes.length];
  }

  static String? _getRandomFeedingNote(bool isMilk) {
    final milkNotes = [
      null,
      '잘 먹었어요',
      '조금 남김',
      '트림 잘함',
    ];
    final breastNotes = [
      null,
      '양쪽 다 먹음',
      '금방 배불러함',
      '잘 빨아요',
    ];
    final notes = isMilk ? milkNotes : breastNotes;
    return notes[DateTime.now().microsecond % notes.length];
  }

  static String? _getRandomDiaperNote(bool hasWet, bool hasPoop) {
    if (hasWet && hasPoop) {
      final notes = [null, '양호함', '묽은 변'];
      return notes[DateTime.now().microsecond % notes.length];
    } else if (hasPoop) {
      return '대변만';
    } else {
      return null;
    }
  }

  // === 통계 함수들 ===

  /// 오늘 요약 통계
  static Map<String, int> getTodaySummary() {
    final today = DateTime.now();
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final todayStat = _joiDailyStats.firstWhere(
      (stat) => stat['date'] == todayStr,
      orElse: () => _joiDailyStats.last,
    );

    return {
      'sleep': todayStat['sleep'] as int,
      'feeding': todayStat['feeding'] as int,
      'diaper': todayStat['diaper'] as int,
      'notes': todayStat['notes'] as int,
    };
  }

  /// 주간 평균 통계
  static Map<String, double> getWeeklyAverages() {
    final recentWeek = _joiDailyStats.reversed.take(7).toList();

    final totalSleep = recentWeek.fold<int>(0, (sum, day) => sum + (day['sleep'] as int));
    final totalFeeding = recentWeek.fold<int>(0, (sum, day) => sum + (day['feeding'] as int));
    final totalDiaper = recentWeek.fold<int>(0, (sum, day) => sum + (day['diaper'] as int));

    final count = recentWeek.length;

    return {
      'sleep': totalSleep / count,
      'feeding': totalFeeding / count,
      'diaper': totalDiaper / count,
    };
  }

  /// 전체 기간 통계
  static Map<String, dynamic> getAllTimeStats() {
    final totalDays = _joiDailyStats.length;
    final totalSleep = _joiDailyStats.fold<int>(0, (sum, day) => sum + (day['sleep'] as int));
    final totalFeeding = _joiDailyStats.fold<int>(0, (sum, day) => sum + (day['feeding'] as int));
    final totalDiaper = _joiDailyStats.fold<int>(0, (sum, day) => sum + (day['diaper'] as int));
    final totalNotes = _joiDailyStats.fold<int>(0, (sum, day) => sum + (day['notes'] as int));

    return {
      'totalDays': totalDays,
      'totalActivities': totalSleep + totalFeeding + totalDiaper + totalNotes,
      'avgSleepPerDay': totalSleep / totalDays,
      'avgFeedingPerDay': totalFeeding / totalDays,
      'avgDiaperPerDay': totalDiaper / totalDays,
    };
  }
}
