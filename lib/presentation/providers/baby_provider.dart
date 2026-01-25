import 'package:flutter/foundation.dart';
import '../../data/models/baby_model.dart';
import '../../data/services/local_storage_service.dart';

/// 현재 선택된 아기 정보를 관리하는 Provider
class BabyProvider extends ChangeNotifier {
  final LocalStorageService _storageService;

  BabyModel? _currentBaby;
  List<BabyModel> _babies = [];
  bool _isLoading = false;
  String? _errorMessage;

  BabyProvider({LocalStorageService? storageService})
      : _storageService = storageService ?? LocalStorageService();

  // Getters
  BabyModel? get currentBaby => _currentBaby;
  List<BabyModel> get babies => List.unmodifiable(_babies);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasBaby => _currentBaby != null;

  /// 아기 정보 로드
  Future<void> loadBabies() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final baby = await _storageService.getBaby();
      if (baby != null) {
        _babies = [baby];
        _currentBaby = baby;
      } else {
        _babies = [];
        _currentBaby = null;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 현재 아기 설정
  void setCurrentBaby(BabyModel baby) {
    _currentBaby = baby;
    notifyListeners();
  }

  /// 아기 추가
  Future<void> addBaby(BabyModel baby) async {
    try {
      await _storageService.saveBaby(baby);
      _babies.add(baby);
      if (_currentBaby == null) {
        _currentBaby = baby;
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// 현재 아기의 월령 (개월)
  int get currentBabyAgeInMonths {
    if (_currentBaby == null) return 0;

    final birthDate = DateTime.parse(_currentBaby!.birthDate);
    final now = DateTime.now();

    int months = (now.year - birthDate.year) * 12 + now.month - birthDate.month;
    if (now.day < birthDate.day) months--;

    return months > 0 ? months : 0;
  }

  /// 현재 아기의 교정 월령 (조산아용)
  int get currentBabyCorrectedAgeInMonths {
    if (_currentBaby == null) return 0;
    if (!_currentBaby!.isPremature || _currentBaby!.dueDate == null) {
      return currentBabyAgeInMonths;
    }

    final birthDate = DateTime.parse(_currentBaby!.birthDate);
    final dueDate = DateTime.parse(_currentBaby!.dueDate!);
    final prematureWeeks = dueDate.difference(birthDate).inDays ~/ 7;

    final correctedBirthDate = birthDate.add(Duration(days: prematureWeeks * 7));
    final now = DateTime.now();

    int months = (now.year - correctedBirthDate.year) * 12 +
                 now.month - correctedBirthDate.month;
    if (now.day < correctedBirthDate.day) months--;

    return months > 0 ? months : 0;
  }
}
