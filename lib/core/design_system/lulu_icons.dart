import 'package:flutter/material.dart';

/// Lulu Design System - Icons
///
/// Material Icons Rounded를 사용한 일관된 아이콘 시스템

class LuluIcons {
  // ========================================
  // 활동 타입 (Activity Types)
  // ========================================

  static const IconData sleep = Icons.bedtime_rounded;
  static const IconData feeding = Icons.local_drink_rounded;
  static const IconData diaper = Icons.baby_changing_station_rounded;
  static const IconData play = Icons.toys_rounded;
  static const IconData health = Icons.favorite_rounded;

  // ========================================
  // 네비게이션 (Navigation)
  // ========================================

  static const IconData home = Icons.home_rounded;
  static const IconData records = Icons.list_alt_rounded;
  static const IconData insights = Icons.insights_rounded;
  static const IconData settings = Icons.settings_rounded;
  static const IconData chat = Icons.chat_bubble_rounded;

  // ========================================
  // 액션 (Actions)
  // ========================================

  static const IconData add = Icons.add_rounded;
  static const IconData edit = Icons.edit_rounded;
  static const IconData delete = Icons.delete_outline_rounded;
  static const IconData save = Icons.check_rounded;
  static const IconData close = Icons.close_rounded;
  static const IconData back = Icons.arrow_back_rounded;
  static const IconData forward = Icons.arrow_forward_rounded;
  static const IconData time = Icons.access_time_rounded;
  static const IconData calendar = Icons.calendar_today_rounded;
  static const IconData search = Icons.search_rounded;
  static const IconData filter = Icons.filter_list_rounded;
  static const IconData sort = Icons.sort_rounded;
  static const IconData share = Icons.share_rounded;
  static const IconData download = Icons.download_rounded;
  static const IconData upload = Icons.upload_rounded;

  // ========================================
  // 수면 상세 (Sleep Details)
  // ========================================

  static const IconData sleepCrib = Icons.crib_rounded;
  static const IconData sleepBed = Icons.bed_rounded;
  static const IconData sleepStroller = Icons.stroller_rounded;
  static const IconData sleepCar = Icons.drive_eta_rounded;
  static const IconData sleepArms = Icons.child_care_rounded;

  // ========================================
  // 수유 상세 (Feeding Details)
  // ========================================

  static const IconData feedingBottle = Icons.local_drink_rounded;
  static const IconData feedingBreast = Icons.child_friendly_rounded;
  static const IconData feedingSolid = Icons.restaurant_rounded;

  // ========================================
  // 기저귀 상세 (Diaper Details)
  // ========================================

  static const IconData diaperWet = Icons.water_drop_rounded;
  static const IconData diaperDirty = Icons.sanitizer_rounded;
  static const IconData diaperBoth = Icons.baby_changing_station_rounded;

  // ========================================
  // 상태 (Status)
  // ========================================

  static const IconData success = Icons.check_circle_rounded;
  static const IconData warning = Icons.warning_rounded;
  static const IconData error = Icons.error_rounded;
  static const IconData info = Icons.info_rounded;

  // ========================================
  // UI 요소 (UI Elements)
  // ========================================

  static const IconData notification = Icons.notifications_rounded;
  static const IconData notificationOff = Icons.notifications_off_rounded;
  static const IconData moon = Icons.nightlight_rounded;
  static const IconData sun = Icons.wb_sunny_rounded;
  static const IconData star = Icons.star_rounded;
  static const IconData heart = Icons.favorite_rounded;
  static const IconData note = Icons.note_outlined;
  static const IconData tips = Icons.tips_and_updates_rounded;
  static const IconData celebration = Icons.celebration_rounded;

  // ========================================
  // 아이콘 크기 (Icon Sizes)
  // ========================================

  static const double sizeXS = 16;
  static const double sizeSM = 20;
  static const double sizeMD = 24;
  static const double sizeLG = 32;
  static const double sizeXL = 48;

  // ========================================
  // 헬퍼 메서드 (Helper Methods)
  // ========================================

  /// 활동 타입으로 아이콘 가져오기
  static IconData forType(String type) {
    switch (type.toLowerCase()) {
      case 'sleep':
        return sleep;
      case 'feeding':
        return feeding;
      case 'diaper':
        return diaper;
      case 'play':
        return play;
      case 'health':
      case 'temperature':
      case 'medication':
        return health;
      default:
        return Icons.circle_rounded;
    }
  }

  /// 수면 장소로 아이콘 가져오기
  static IconData forSleepLocation(String? location) {
    if (location == null) return sleepBed;
    switch (location.toLowerCase()) {
      case 'crib':
        return sleepCrib;
      case 'bed':
        return sleepBed;
      case 'stroller':
        return sleepStroller;
      case 'car':
        return sleepCar;
      case 'arms':
        return sleepArms;
      default:
        return sleepBed;
    }
  }

  /// 수유 타입으로 아이콘 가져오기
  static IconData forFeedingType(String? type) {
    if (type == null) return feedingBottle;
    switch (type.toLowerCase()) {
      case 'bottle':
        return feedingBottle;
      case 'breast':
        return feedingBreast;
      case 'solid':
        return feedingSolid;
      default:
        return feedingBottle;
    }
  }

  /// 기저귀 타입으로 아이콘 가져오기
  static IconData forDiaperType(String? type) {
    if (type == null) return diaperBoth;
    switch (type.toLowerCase()) {
      case 'wet':
        return diaperWet;
      case 'dirty':
        return diaperDirty;
      case 'both':
        return diaperBoth;
      default:
        return diaperBoth;
    }
  }
}
