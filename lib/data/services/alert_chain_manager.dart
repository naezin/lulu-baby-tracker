import '../models/alert_chain.dart';
import '../models/scheduled_alert.dart';
import 'notification_service.dart';

/// 알림 체인 매니저 - 체인 스케줄링 및 관리
class AlertChainManager {
  final NotificationService _notificationService = NotificationService();

  // 활성 체인 저장 (메모리 캐시)
  final Map<String, AlertChain> _activeChains = {};

  /// 체인 스케줄링
  Future<void> scheduleChain(AlertChain chain) async {
    // 기존 같은 타입 체인 취소
    await cancelChainsByType(chain.type);

    // 새 체인 저장
    _activeChains[chain.id] = chain;

    // 각 알림 스케줄링
    for (final alert in chain.alerts) {
      final alertTime = chain.getAlertTime(alert);

      // 과거 시간은 스킵
      if (alertTime.isBefore(DateTime.now())) continue;

      try {
        await _notificationService.scheduleNotification(
          id: alert.id.hashCode,
          title: alert.title,
          body: alert.body,
          scheduledTime: alertTime,
        );
      } catch (e) {
        print('⚠️ [AlertChainManager] Failed to schedule notification: $e');
      }
    }
  }

  /// 특정 타입의 체인 취소
  Future<void> cancelChainsByType(AlertChainType type) async {
    final chainsToCancel = _activeChains.values
        .where((c) => c.type == type)
        .toList();

    for (final chain in chainsToCancel) {
      await cancelChain(chain.id);
    }
  }

  /// 특정 체인 취소
  Future<void> cancelChain(String chainId) async {
    final chain = _activeChains[chainId];
    if (chain == null) return;

    for (final alert in chain.alerts) {
      try {
        await _notificationService.cancelNotification(alert.id.hashCode);
      } catch (e) {
        print('⚠️ [AlertChainManager] Failed to cancel notification: $e');
      }
    }

    _activeChains.remove(chainId);
  }

  /// 모든 체인 취소
  Future<void> cancelAllChains() async {
    for (final chainId in _activeChains.keys.toList()) {
      await cancelChain(chainId);
    }
  }

  /// 활성 체인 목록
  List<AlertChain> get activeChains => _activeChains.values.toList();

  /// 특정 체인 가져오기
  AlertChain? getChain(String chainId) => _activeChains[chainId];

  /// 다음 알림 가져오기 (모든 체인 통합)
  ScheduledAlert? getNextAlert() {
    ScheduledAlert? nextAlert;
    DateTime? nextAlertTime;

    for (final chain in _activeChains.values) {
      final chainNextAlert = chain.nextAlert;
      if (chainNextAlert != null) {
        final alertTime = chain.getAlertTime(chainNextAlert);
        if (nextAlertTime == null || alertTime.isBefore(nextAlertTime)) {
          nextAlert = chainNextAlert;
          nextAlertTime = alertTime;
        }
      }
    }

    return nextAlert;
  }

  /// 알림 발송 완료 처리
  void markAlertAsSent(String chainId, String alertId) {
    final chain = _activeChains[chainId];
    if (chain == null) return;

    final updatedAlerts = chain.alerts.map((alert) {
      if (alert.id == alertId) {
        return alert.copyWith(isSent: true, sentAt: DateTime.now());
      }
      return alert;
    }).toList();

    _activeChains[chainId] = chain.copyWith(alerts: updatedAlerts);
  }
}
