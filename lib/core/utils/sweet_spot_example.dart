/// SweetSpot Calculator 사용 예제
library;

import 'sweet_spot_calculator.dart';

void main() {
  // ========================================
  // 예제 1: 3개월 아기의 다음 낮잠 시간 계산
  // ========================================
  print('=== Example 1: 3-month-old baby ===');

  const babyAge = 3; // 3개월
  final lastWakeUp = DateTime.now().subtract(const Duration(hours: 1, minutes: 30));

  final sweetSpot = SweetSpotCalculator.calculate(
    ageInMonths: babyAge,
    lastWakeUpTime: lastWakeUp,
    napNumber: 2, // 오늘의 두 번째 낮잠
  );

  print('Baby Age: $babyAge months');
  print('Last Wake-up Time: ${_formatDateTime(lastWakeUp)}');
  print('Sweet Spot Window: ${sweetSpot.getFormattedTimeRange()}');
  print('Wake Window Range: ${sweetSpot.wakeWindowData.displayRange}');
  print('Recommended Daily Naps: ${sweetSpot.wakeWindowData.recommendedNaps}');
  print('Current Status: ${sweetSpot.urgencyLevel.displayName} ${sweetSpot.urgencyLevel.emoji}');
  print('Message: ${sweetSpot.userFriendlyMessage}');
  print('Is Active Now: ${sweetSpot.isActive}');

  if (!sweetSpot.isActive) {
    print('Minutes until Sweet Spot: ${sweetSpot.minutesUntilSweetSpot}');
  }

  print('\n');

  // ========================================
  // 예제 2: 6개월 아기의 하루 낮잠 스케줄 계획
  // ========================================
  print('=== Example 2: Daily Nap Schedule for 6-month-old ===');

  final morningWakeUp = DateTime(2026, 1, 22, 7, 0); // 오전 7시 기상
  final dailySchedule = SweetSpotCalculator.calculateDailyNapSchedule(
    ageInMonths: 6,
    morningWakeUpTime: morningWakeUp,
  );

  print('Morning Wake-up: ${_formatDateTime(morningWakeUp)}');
  print('Recommended naps for today: ${dailySchedule.length}\n');

  for (int i = 0; i < dailySchedule.length; i++) {
    final nap = dailySchedule[i];
    print('Nap ${i + 1}:');
    print('  Sweet Spot: ${nap.getFormattedTimeRange()}');
    print('  Wake Window: ${nap.wakeWindowData.displayRange}');
    print('');
  }

  // ========================================
  // 예제 3: 신생아 (1개월) 케이스
  // ========================================
  print('=== Example 3: Newborn (1 month old) ===');

  const newbornAge = 1;
  final newbornLastWakeUp = DateTime.now().subtract(const Duration(minutes: 45));

  final newbornSweetSpot = SweetSpotCalculator.calculate(
    ageInMonths: newbornAge,
    lastWakeUpTime: newbornLastWakeUp,
  );

  print('Baby Age: $newbornAge month');
  print('Last Wake-up: ${_formatDateTime(newbornLastWakeUp)}');
  print('Sweet Spot: ${newbornSweetSpot.getFormattedTimeRange()}');
  print('Wake Window: ${newbornSweetSpot.wakeWindowData.displayRange}');
  print('Recommended Daily Naps: ${newbornSweetSpot.wakeWindowData.recommendedNaps}');
  print('Status: ${newbornSweetSpot.userFriendlyMessage}');

  print('\n');

  // ========================================
  // 예제 4: 과도하게 깨어있는 경우 (Overtired)
  // ========================================
  print('=== Example 4: Overtired Baby ===');

  final overtiredLastWakeUp = DateTime.now().subtract(const Duration(hours: 4));

  final overtiredResult = SweetSpotCalculator.calculate(
    ageInMonths: 4,
    lastWakeUpTime: overtiredLastWakeUp,
  );

  print('Last Wake-up: ${_formatDateTime(overtiredLastWakeUp)}');
  print('Minutes since wake-up: ${overtiredResult.minutesSinceWakeUp}');
  print('Is Overtired: ${overtiredResult.isOvertired}');
  print('Urgency: ${overtiredResult.urgencyLevel.displayName}');
  print('Message: ${overtiredResult.userFriendlyMessage}');

  print('\n');

  // ========================================
  // 예제 5: JSON 변환
  // ========================================
  print('=== Example 5: JSON Export ===');

  final jsonData = sweetSpot.toJson();
  print('JSON Output:');
  jsonData.forEach((key, value) {
    print('  $key: $value');
  });
}

String _formatDateTime(DateTime dt) {
  final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
  final period = dt.hour >= 12 ? 'PM' : 'AM';
  return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
         '$hour:${dt.minute.toString().padLeft(2, '0')} $period';
}
