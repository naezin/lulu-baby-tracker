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
}
