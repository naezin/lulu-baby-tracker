import 'package:flutter/material.dart';
import '../models/activity_model.dart';
import '../../presentation/widgets/insights/qa_insight_card.dart';
import 'local_storage_service.dart';

/// 📊 Insights Service
/// 질문-답변 형식의 인사이트 생성
class InsightsService {
  final LocalStorageService _storage = LocalStorageService();

  /// 주요 인사이트 목록 가져오기
  Future<List<QAInsight>> getMainInsights({
    required int babyAgeInDays,
  }) async {
    final insights = <QAInsight>[];

    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final weekAgo = today.subtract(const Duration(days: 7));

      final allActivities = await _storage.getActivities();

      final todayActivities = allActivities.where((a) {
        final time = DateTime.parse(a.timestamp);
        return time.isAfter(today);
      }).toList();

      final yesterdayActivities = allActivities.where((a) {
        final time = DateTime.parse(a.timestamp);
        return time.isAfter(yesterday) && time.isBefore(today);
      }).toList();

      final weekActivities = allActivities.where((a) {
        final time = DateTime.parse(a.timestamp);
        return time.isAfter(weekAgo);
      }).toList();

      // 1. 수면 패턴 분석
      final sleepInsight = _analyzeSleepPattern(
        todayActivities,
        yesterdayActivities,
        weekActivities,
      );
      if (sleepInsight != null) insights.add(sleepInsight);

      // 2. 수유 패턴 분석
      final feedingInsight = _analyzeFeedingPattern(
        todayActivities,
        yesterdayActivities,
      );
      if (feedingInsight != null) insights.add(feedingInsight);

      // 3. 먹-놀-잠 루틴 분석
      final routineInsight = _analyzeRoutinePattern(todayActivities);
      if (routineInsight != null) insights.add(routineInsight);

      // 4. 야간 수면 분석
      final nightSleepInsight = _analyzeNightSleep(
        todayActivities,
        weekActivities,
      );
      if (nightSleepInsight != null) insights.add(nightSleepInsight);

      // 5. 발달 활동 분석
      final developmentInsight = _analyzeDevelopmentActivity(
        todayActivities,
        weekActivities,
      );
      if (developmentInsight != null) insights.add(developmentInsight);
    } catch (e) {
      // 에러 시 빈 목록 반환
    }

    return insights;
  }

  /// 1. 수면 패턴 분석
  QAInsight? _analyzeSleepPattern(
    List<ActivityModel> today,
    List<ActivityModel> yesterday,
    List<ActivityModel> week,
  ) {
    try {
      final todaySleeps = today.where((a) => a.type == ActivityType.sleep).toList();
      final yesterdaySleeps = yesterday.where((a) => a.type == ActivityType.sleep).toList();

      if (todaySleeps.isEmpty) return null;

      final todayTotal = todaySleeps.fold<int>(0, (sum, a) => sum + (a.durationMinutes ?? 0));
      final yesterdayTotal = yesterdaySleeps.fold<int>(0, (sum, a) => sum + (a.durationMinutes ?? 0));
      final todayCount = todaySleeps.length;

      final diff = todayTotal - yesterdayTotal;
      final avgSleepDuration = todayTotal > 0 ? (todayTotal / todayCount).round() : 0;

      // 수면이 충분한지 판단
      if (todayTotal >= 840) {
        // 14시간 이상
        return QAInsight(
          question: '우리 아기 수면 시간이 정상인가요?',
          answer: InsightAnswer.positive(
            title: '충분히 자고 있어요!',
            subtitle: '하루 총 수면 시간이 권장량을 충족해요',
          ),
          metrics: [
            InsightMetric(
              label: '오늘 총 수면',
              value: '${todayTotal ~/ 60}h ${todayTotal % 60}m',
              trend: diff > 0 ? '+$diff분' : diff < 0 ? '$diff분' : null,
              trendColor: diff > 0 ? Colors.green : diff < 0 ? Colors.orange : null,
            ),
            InsightMetric(
              label: '수면 횟수',
              value: '$todayCount회',
            ),
            InsightMetric(
              label: '평균 수면 시간',
              value: '$avgSleepDuration분',
            ),
          ],
          actionLabel: '수면 패턴 자세히 보기',
        );
      } else if (todayTotal >= 600) {
        // 10시간 이상
        return QAInsight(
          question: '우리 아기 수면 시간이 정상인가요?',
          answer: InsightAnswer.neutral(
            title: '평균 수준이에요',
            subtitle: '조금 더 재울 수 있는지 확인해보세요',
          ),
          metrics: [
            InsightMetric(
              label: '오늘 총 수면',
              value: '${todayTotal ~/ 60}h ${todayTotal % 60}m',
              trend: diff > 0 ? '+$diff분' : diff < 0 ? '$diff분' : null,
              trendColor: diff > 0 ? Colors.green : diff < 0 ? Colors.orange : null,
            ),
            const InsightMetric(
              label: '권장 수면 시간',
              value: '14-17시간',
            ),
          ],
          actionLabel: '수면 늘리는 팁 보기',
        );
      } else {
        return QAInsight(
          question: '우리 아기 수면 시간이 정상인가요?',
          answer: InsightAnswer.caution(
            title: '수면이 부족할 수 있어요',
            subtitle: '권장 수면 시간보다 적게 자고 있어요',
          ),
          metrics: [
            InsightMetric(
              label: '오늘 총 수면',
              value: '${todayTotal ~/ 60}h ${todayTotal % 60}m',
              trend: diff > 0 ? '+$diff분' : diff < 0 ? '$diff분' : null,
              trendColor: diff > 0 ? Colors.green : diff < 0 ? Colors.orange : null,
            ),
            const InsightMetric(
              label: '권장 수면 시간',
              value: '14-17시간',
              color: Colors.orange,
            ),
          ],
          actionLabel: '수면 개선 방법 보기',
        );
      }
    } catch (e) {
      return null;
    }
  }

  /// 2. 수유 패턴 분석
  QAInsight? _analyzeFeedingPattern(
    List<ActivityModel> today,
    List<ActivityModel> yesterday,
  ) {
    try {
      final todayFeedings = today.where((a) => a.type == ActivityType.feeding).toList();
      final yesterdayFeedings = yesterday.where((a) => a.type == ActivityType.feeding).toList();

      if (todayFeedings.isEmpty) return null;

      final todayMl = todayFeedings.fold<int>(0, (sum, a) => sum + (a.amountMl?.toInt() ?? 0));
      final yesterdayMl = yesterdayFeedings.fold<int>(0, (sum, a) => sum + (a.amountMl?.toInt() ?? 0));
      final todayCount = todayFeedings.length;

      final diff = todayMl - yesterdayMl;
      final avgFeedingAmount = todayMl > 0 ? (todayMl / todayCount).round() : 0;

      // 수유량 판단 (신생아 기준 대략 600-900ml)
      if (todayMl >= 600 && todayMl <= 1000) {
        return QAInsight(
          question: '수유량이 적절한가요?',
          answer: InsightAnswer.positive(
            title: '적절한 수유량이에요!',
            subtitle: '하루 권장량을 잘 맞추고 있어요',
          ),
          metrics: [
            InsightMetric(
              label: '오늘 총 수유량',
              value: '${todayMl}ml',
              trend: diff > 0 ? '+${diff}ml' : diff < 0 ? '${diff}ml' : null,
              trendColor: diff.abs() > 100
                  ? Colors.orange
                  : diff > 0
                      ? Colors.green
                      : null,
            ),
            InsightMetric(
              label: '수유 횟수',
              value: '$todayCount회',
            ),
            InsightMetric(
              label: '평균 수유량',
              value: '${avgFeedingAmount}ml',
            ),
          ],
        );
      } else if (todayMl < 600) {
        return QAInsight(
          question: '수유량이 적절한가요?',
          answer: InsightAnswer.caution(
            title: '수유량이 부족할 수 있어요',
            subtitle: '권장량보다 적게 먹고 있어요',
          ),
          metrics: [
            InsightMetric(
              label: '오늘 총 수유량',
              value: '${todayMl}ml',
              color: Colors.orange,
            ),
            const InsightMetric(
              label: '권장 수유량',
              value: '600-900ml',
            ),
          ],
          actionLabel: '수유 가이드 보기',
        );
      } else {
        return QAInsight(
          question: '수유량이 적절한가요?',
          answer: InsightAnswer.neutral(
            title: '평소보다 많이 먹고 있어요',
            subtitle: '성장기일 수 있으니 체중과 함께 관찰하세요',
          ),
          metrics: [
            InsightMetric(
              label: '오늘 총 수유량',
              value: '${todayMl}ml',
              trend: diff > 0 ? '+${diff}ml' : null,
              trendColor: Colors.blue,
            ),
            InsightMetric(
              label: '평균 수유량',
              value: '${avgFeedingAmount}ml',
            ),
          ],
        );
      }
    } catch (e) {
      return null;
    }
  }

  /// 3. 먹-놀-잠 루틴 분석
  QAInsight? _analyzeRoutinePattern(List<ActivityModel> today) {
    try {
      final sorted = today.toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

      if (sorted.length < 3) return null;

      // 먹-놀-잠 패턴 체크
      int eatPlaySleepCount = 0;
      int eatSleepCount = 0;

      for (int i = 0; i < sorted.length - 2; i++) {
        final first = sorted[i].type;
        final second = sorted[i + 1].type;
        final third = sorted[i + 2].type;

        if (first == ActivityType.feeding &&
            second == ActivityType.play &&
            third == ActivityType.sleep) {
          eatPlaySleepCount++;
        }

        if (first == ActivityType.feeding && second == ActivityType.sleep) {
          eatSleepCount++;
        }
      }

      if (eatPlaySleepCount >= 2) {
        return QAInsight(
          question: '먹-놀-잠 루틴을 잘 지키고 있나요?',
          answer: InsightAnswer.success(
            title: '루틴을 잘 지키고 있어요!',
            subtitle: '먹-놀-잠 패턴이 $eatPlaySleepCount회 반복됐어요',
          ),
          metrics: [
            InsightMetric(
              label: '먹-놀-잠 패턴',
              value: '$eatPlaySleepCount회',
              color: Colors.green,
            ),
          ],
        );
      } else if (eatSleepCount >= 2) {
        return QAInsight(
          question: '먹-놀-잠 루틴을 잘 지키고 있나요?',
          answer: InsightAnswer.tip(
            title: '수유 후 바로 재우고 있어요',
            subtitle: '먹-놀-잠 순서를 시도해보세요',
          ),
          metrics: [
            InsightMetric(
              label: '먹→잠 패턴',
              value: '$eatSleepCount회',
              color: Colors.purple,
            ),
          ],
          actionLabel: '루틴 가이드 보기',
        );
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// 4. 야간 수면 분석
  QAInsight? _analyzeNightSleep(
    List<ActivityModel> today,
    List<ActivityModel> week,
  ) {
    try {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));

      // 어젯밤 수면 (오후 7시 ~ 오전 7시)
      final lastNightSleeps = today.where((a) {
        if (a.type != ActivityType.sleep) return false;
        final time = DateTime.parse(a.timestamp);
        final isLastNight = (time.day == yesterday.day && time.hour >= 19) ||
            (time.day == now.day && time.hour <= 7);
        return isLastNight;
      }).toList();

      if (lastNightSleeps.isEmpty) return null;

      final nightWakings = lastNightSleeps.length;
      final longestSleep = lastNightSleeps
          .map((a) => a.durationMinutes ?? 0)
          .fold<int>(0, (max, val) => val > max ? val : max);

      if (longestSleep >= 360) {
        // 6시간 이상
        return QAInsight(
          question: '밤잠을 잘 자나요?',
          answer: InsightAnswer.success(
            title: '밤잠을 아주 잘 자요!',
            subtitle: '최장 ${longestSleep ~/ 60}시간 연속으로 잤어요',
          ),
          metrics: [
            InsightMetric(
              label: '최장 수면',
              value: '${longestSleep ~/ 60}h ${longestSleep % 60}m',
              color: Colors.green,
            ),
            InsightMetric(
              label: '밤에 깬 횟수',
              value: '$nightWakings회',
            ),
          ],
        );
      } else if (nightWakings > 4) {
        return QAInsight(
          question: '밤잠을 잘 자나요?',
          answer: InsightAnswer.caution(
            title: '밤에 자주 깨고 있어요',
            subtitle: '어젯밤 $nightWakings회 깼어요',
          ),
          metrics: [
            InsightMetric(
              label: '밤에 깬 횟수',
              value: '$nightWakings회',
              color: Colors.orange,
            ),
            InsightMetric(
              label: '최장 수면',
              value: '${longestSleep ~/ 60}h ${longestSleep % 60}m',
            ),
          ],
          actionLabel: '수면 개선 팁 보기',
        );
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// 5. 발달 활동 분석
  QAInsight? _analyzeDevelopmentActivity(
    List<ActivityModel> today,
    List<ActivityModel> week,
  ) {
    try {
      final todayPlays = today.where((a) => a.type == ActivityType.play).toList();
      final weekPlays = week.where((a) => a.type == ActivityType.play).toList();

      if (todayPlays.isEmpty && weekPlays.isEmpty) return null;

      final todayTummyTime = todayPlays
          .where((a) => a.notes?.toLowerCase().contains('tummy') == true)
          .fold<int>(0, (sum, a) => sum + (a.durationMinutes ?? 0));

      final weekTummyTime = weekPlays
          .where((a) => a.notes?.toLowerCase().contains('tummy') == true)
          .fold<int>(0, (sum, a) => sum + (a.durationMinutes ?? 0));

      if (todayTummyTime >= 30) {
        return QAInsight(
          question: '터미타임을 충분히 하고 있나요?',
          answer: InsightAnswer.success(
            title: '터미타임 목표 달성!',
            subtitle: '오늘 $todayTummyTime분 완료했어요',
          ),
          metrics: [
            InsightMetric(
              label: '오늘 터미타임',
              value: '$todayTummyTime분',
              color: Colors.green,
            ),
            InsightMetric(
              label: '이번 주 평균',
              value: '${(weekTummyTime / 7).round()}분',
            ),
          ],
        );
      } else if (weekTummyTime > 0) {
        return QAInsight(
          question: '터미타임을 충분히 하고 있나요?',
          answer: InsightAnswer.tip(
            title: '조금만 더 해보세요',
            subtitle: '하루 30분 목표까지 ${30 - todayTummyTime}분 남았어요',
          ),
          metrics: [
            InsightMetric(
              label: '오늘 터미타임',
              value: '$todayTummyTime분',
              color: Colors.purple,
            ),
            const InsightMetric(
              label: '목표',
              value: '30분',
            ),
          ],
          actionLabel: '터미타임 가이드 보기',
        );
      }

      return null;
    } catch (e) {
      return null;
    }
  }
}

/// QA Insight 데이터 모델
class QAInsight {
  final String question;
  final InsightAnswer answer;
  final List<InsightMetric> metrics;
  final String? actionLabel;
  final VoidCallback? onAction;

  const QAInsight({
    required this.question,
    required this.answer,
    required this.metrics,
    this.actionLabel,
    this.onAction,
  });
}
