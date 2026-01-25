import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../../core/localization/app_localizations.dart';

/// Sweet Spot 알림 서비스
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// 알림 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Timezone 초기화
    tz.initializeTimeZones();

    // Android 설정
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS 설정
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _isInitialized = true;
  }

  /// 알림 권한 요청
  Future<bool> requestPermission() async {
    // iOS
    final iosImplementation = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    final iosGranted = await iosImplementation?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Android (13 이상)
    final androidImplementation = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    final androidGranted =
        await androidImplementation?.requestNotificationsPermission();

    return iosGranted ?? androidGranted ?? true;
  }

  /// Sweet Spot 알림 스케줄링
  Future<void> scheduleSweetSpotNotification({
    required DateTime sweetSpotTime,
    required String babyName,
    required AppLocalizations l10n,
    int notificationId = 0,
  }) async {
    await initialize();

    // Sweet Spot 15분 전
    final notificationTime = sweetSpotTime.subtract(const Duration(minutes: 15));

    // 과거 시간이면 스케줄링하지 않음
    if (notificationTime.isBefore(DateTime.now())) {
      return;
    }

    // 알림 메시지 생성
    final message = _generateNotificationMessage(babyName);

    // Android 알림 설정
    final androidDetails = AndroidNotificationDetails(
      'sweet_spot_channel',
      l10n.translate('notification_channel_name_sweet_spot'),
      channelDescription: l10n.translate('notification_channel_desc_sweet_spot'),
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      sound: const RawResourceAndroidNotificationSound('notification'),
      enableVibration: true,
      playSound: true,
    );

    // iOS 알림 설정
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'notification.aiff',
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // 알림 스케줄링
    await _notifications.zonedSchedule(
      notificationId,
      '🌙 Sweet Spot Alert!',
      message,
      tz.TZDateTime.from(notificationTime, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// 여러 개의 Sweet Spot 알림 스케줄링 (하루 전체)
  Future<void> scheduleDailySweetSpots({
    required List<DateTime> sweetSpotTimes,
    required String babyName,
    required AppLocalizations l10n,
  }) async {
    // 기존 알림 모두 취소
    await cancelAllNotifications();

    // 각 Sweet Spot마다 알림 설정
    for (int i = 0; i < sweetSpotTimes.length; i++) {
      await scheduleSweetSpotNotification(
        sweetSpotTime: sweetSpotTimes[i],
        babyName: babyName,
        l10n: l10n,
        notificationId: i,
      );
    }
  }

  /// 알림 메시지 생성
  String _generateNotificationMessage(String babyName) {
    final messages = [
      '🌙 Lulu가 $babyName의 잠 신호를 읽었어요! 15분 뒤에 수면 의식을 시작할 시간입니다.',
      '✨ Perfect timing! $babyName가 졸려할 시간이 다가오고 있어요. 곧 재울 준비를 해주세요.',
      '💤 Sweet Spot이 곧 시작돼요! $babyName가 가장 편안하게 잠들 수 있는 시간입니다.',
      '🌟 Lulu의 예측: $babyName는 곧 낮잠 시간이에요. 조용한 환경을 준비해주세요.',
      '😴 $babyName의 골든타임이 15분 후! 수면 루틴을 시작하면 좋을 것 같아요.',
    ];

    // 랜덤 메시지 선택
    final index = DateTime.now().millisecond % messages.length;
    return messages[index];
  }

  /// 즉시 알림 표시 (테스트용)
  Future<void> showImmediateNotification({
    required String title,
    required String body,
    required AppLocalizations l10n,
    int notificationId = 999,
  }) async {
    await initialize();

    final androidDetails = AndroidNotificationDetails(
      'sweet_spot_channel',
      l10n.translate('notification_channel_name_sweet_spot'),
      channelDescription: l10n.translate('notification_channel_desc_sweet_spot'),
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      notificationId,
      title,
      body,
      notificationDetails,
    );
  }

  /// 특정 알림 취소
  Future<void> cancelNotification(int notificationId) async {
    await _notifications.cancel(notificationId);
  }

  /// 모든 알림 취소
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// 예약된 알림 목록 조회
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  /// 알림 탭 처리
  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - navigate to relevant screen based on payload
    print('Notification tapped: ${response.payload}');
  }

  // === 수유 알림 ===

  /// 수유 알림 스케줄링
  /// [intervalHours]: 수유 간격 (시간)
  /// [babyName]: 아기 이름
  /// [startFromNow]: true면 지금부터 시작, false면 마지막 수유 시간부터 계산
  Future<void> scheduleFeedingReminders({
    required int intervalHours,
    required String babyName,
    required AppLocalizations l10n,
    bool startFromNow = true,
    DateTime? lastFeedingTime,
  }) async {
    await initialize();

    // 기존 수유 알림 취소 (ID 100-109)
    for (int i = 100; i < 110; i++) {
      await cancelNotification(i);
    }

    DateTime nextFeedingTime;
    if (startFromNow) {
      nextFeedingTime = DateTime.now().add(Duration(hours: intervalHours));
    } else {
      nextFeedingTime = (lastFeedingTime ?? DateTime.now())
          .add(Duration(hours: intervalHours));
    }

    // 향후 24시간 동안의 수유 알림 설정
    for (int i = 0; i < 8; i++) {
      // 최대 8개 (3시간 간격 = 24시간)
      final notificationTime = nextFeedingTime.add(Duration(hours: intervalHours * i));

      // 24시간 이내만 스케줄링
      if (notificationTime.difference(DateTime.now()).inHours > 24) break;

      await _scheduleSingleFeedingNotification(
        notificationTime: notificationTime,
        babyName: babyName,
        l10n: l10n,
        notificationId: 100 + i,
      );
    }
  }

  Future<void> _scheduleSingleFeedingNotification({
    required DateTime notificationTime,
    required String babyName,
    required AppLocalizations l10n,
    required int notificationId,
  }) async {
    // 과거 시간이면 스케줄링하지 않음
    if (notificationTime.isBefore(DateTime.now())) return;

    final messages = [
      '🍼 $babyName의 수유 시간이에요! 배고픈 신호를 보이고 있을 수 있어요.',
      '👶 수유 시간 알림! $babyName가 밥 먹을 시간입니다.',
      '🥛 $babyName에게 수유할 시간이에요. 준비해주세요!',
      '💝 수유 타이머 알림! $babyName의 식사 시간입니다.',
    ];

    final message = messages[notificationId % messages.length];

    final androidDetails = AndroidNotificationDetails(
      'feeding_channel',
      l10n.translate('notification_channel_feeding') ?? '수유 알림',
      channelDescription: l10n.translate('notification_channel_feeding_desc') ?? '수유 시간 알림',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      sound: const RawResourceAndroidNotificationSound('notification'),
      enableVibration: true,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'notification.aiff',
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      notificationId,
      '🍼 수유 시간 알림',
      message,
      tz.TZDateTime.from(notificationTime, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'feeding',
    );
  }

  /// 수유 알림 취소
  Future<void> cancelFeedingReminders() async {
    for (int i = 100; i < 110; i++) {
      await cancelNotification(i);
    }
  }

  // === 기저귀 알림 ===

  /// 기저귀 알림 스케줄링
  /// [intervalHours]: 기저귀 체크 간격 (시간)
  /// [babyName]: 아기 이름
  Future<void> scheduleDiaperReminders({
    required int intervalHours,
    required String babyName,
    required AppLocalizations l10n,
    bool startFromNow = true,
    DateTime? lastDiaperChange,
  }) async {
    await initialize();

    // 기존 기저귀 알림 취소 (ID 200-209)
    for (int i = 200; i < 210; i++) {
      await cancelNotification(i);
    }

    DateTime nextDiaperTime;
    if (startFromNow) {
      nextDiaperTime = DateTime.now().add(Duration(hours: intervalHours));
    } else {
      nextDiaperTime = (lastDiaperChange ?? DateTime.now())
          .add(Duration(hours: intervalHours));
    }

    // 향후 24시간 동안의 기저귀 알림 설정
    for (int i = 0; i < 10; i++) {
      // 최대 10개
      final notificationTime = nextDiaperTime.add(Duration(hours: intervalHours * i));

      // 24시간 이내만 스케줄링
      if (notificationTime.difference(DateTime.now()).inHours > 24) break;

      await _scheduleSingleDiaperNotification(
        notificationTime: notificationTime,
        babyName: babyName,
        l10n: l10n,
        notificationId: 200 + i,
      );
    }
  }

  Future<void> _scheduleSingleDiaperNotification({
    required DateTime notificationTime,
    required String babyName,
    required AppLocalizations l10n,
    required int notificationId,
  }) async {
    // 과거 시간이면 스케줄링하지 않음
    if (notificationTime.isBefore(DateTime.now())) return;

    final messages = [
      '🧷 $babyName의 기저귀를 확인해주세요!',
      '👶 기저귀 체크 시간이에요! $babyName가 불편해할 수 있어요.',
      '💙 $babyName의 기저귀를 갈아줄 시간입니다.',
      '🌟 기저귀 알림! $babyName를 확인해주세요.',
    ];

    final message = messages[notificationId % messages.length];

    final androidDetails = AndroidNotificationDetails(
      'diaper_channel',
      l10n.translate('notification_channel_diaper') ?? '기저귀 알림',
      channelDescription: l10n.translate('notification_channel_diaper_desc') ?? '기저귀 체크 알림',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
      sound: const RawResourceAndroidNotificationSound('notification'),
      enableVibration: true,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'notification.aiff',
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      notificationId,
      '🧷 기저귀 체크 알림',
      message,
      tz.TZDateTime.from(notificationTime, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'diaper',
    );
  }

  /// 기저귀 알림 취소
  Future<void> cancelDiaperReminders() async {
    for (int i = 200; i < 210; i++) {
      await cancelNotification(i);
    }
  }

  // === 알림 상태 확인 ===

  /// 수유 알림이 활성화되어 있는지 확인
  Future<bool> isFeedingReminderActive() async {
    final pending = await getPendingNotifications();
    return pending.any((n) => n.id >= 100 && n.id < 110);
  }

  /// 기저귀 알림이 활성화되어 있는지 확인
  Future<bool> isDiaperReminderActive() async {
    final pending = await getPendingNotifications();
    return pending.any((n) => n.id >= 200 && n.id < 210);
  }

  /// Sweet Spot 알림이 활성화되어 있는지 확인
  Future<bool> isSweetSpotActive() async {
    final pending = await getPendingNotifications();
    return pending.any((n) => n.id >= 0 && n.id < 100);
  }

  /// 범용 알림 스케줄링 (AlertChainManager용)
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    await initialize();

    // 과거 시간이면 스케줄링하지 않음
    if (scheduledTime.isBefore(DateTime.now())) {
      return;
    }

    // Android 알림 설정
    const androidDetails = AndroidNotificationDetails(
      'alert_chain_channel',
      'Alert Chain Notifications',
      channelDescription: 'Notifications for alert chains (bedtime, nap, feeding)',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      sound: RawResourceAndroidNotificationSound('notification'),
      enableVibration: true,
      playSound: true,
    );

    // iOS 알림 설정
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'notification.aiff',
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
