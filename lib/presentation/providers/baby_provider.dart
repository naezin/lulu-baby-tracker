import 'package:flutter/foundation.dart';
import '../../data/models/baby_model.dart';
import '../../data/services/local_storage_service.dart';
import '../../data/services/widget_service.dart';
import '../../domain/repositories/i_baby_repository.dart';

/// 현재 선택된 아기 정보를 관리하는 Provider
class BabyProvider extends ChangeNotifier {
  final IBabyRepository _babyRepository;
  final LocalStorageService _localStorage;
  final WidgetService _widgetService;

  BabyModel? _currentBaby;
  String? _currentBabyId;
  List<BabyModel> _babies = [];
  bool _isLoading = false;
  String? _errorMessage;

  BabyProvider({
    required IBabyRepository babyRepository,
    required LocalStorageService localStorage,
    WidgetService? widgetService,
  })  : _babyRepository = babyRepository,
        _localStorage = localStorage,
        _widgetService = widgetService ?? WidgetService();

  // Getters
  BabyModel? get currentBaby => _currentBaby;
  String? get currentBabyId => _currentBabyId;
  List<BabyModel> get babies => List.unmodifiable(_babies);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasBaby => _currentBaby != null;
  bool get hasMultipleBabies => _babies.length > 1;

  /// 사용자의 모든 아기 로드
  Future<void> loadBabies(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Repository에서 아기 목록 로드
      final entities = await _babyRepository.getBabiesByUser(userId: userId);
      _babies = entities.map((e) => BabyModel.fromEntity(e)).toList();

      // 2. 마지막 선택 아기 복원
      final lastBabyId = await _localStorage.getCurrentBabyId();
      if (lastBabyId != null && _babies.any((b) => b.id == lastBabyId)) {
        _currentBabyId = lastBabyId;
        _currentBaby = _babies.firstWhere((b) => b.id == lastBabyId);
      } else if (_babies.isNotEmpty) {
        _currentBabyId = _babies.first.id;
        _currentBaby = _babies.first;
        await _localStorage.setCurrentBabyId(_currentBabyId!);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 아기 전환
  Future<void> switchBaby(String babyId) async {
    if (!_babies.any((b) => b.id == babyId)) {
      _errorMessage = '해당 아기를 찾을 수 없습니다';
      notifyListeners();
      return;
    }

    _currentBabyId = babyId;
    _currentBaby = _babies.firstWhere((b) => b.id == babyId);
    await _localStorage.setCurrentBabyId(babyId);
    notifyListeners();

    // 위젯 업데이트
    await _widgetService.updateAllWidgets();
  }

  /// 현재 아기 설정
  void setCurrentBaby(BabyModel baby) {
    _currentBaby = baby;
    _currentBabyId = baby.id;
    notifyListeners();
  }

  /// 아기 추가
  Future<void> addBaby(BabyModel baby, String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _babyRepository.saveBaby(
        userId: userId,
        baby: baby.toEntity(),
      );

      _babies.add(baby);
      _currentBaby = baby;
      _currentBabyId = baby.id;
      await _localStorage.setCurrentBabyId(baby.id);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 아기 정보 수정
  Future<void> updateBaby(BabyModel baby) async {
    try {
      await _babyRepository.updateBaby(baby: baby.toEntity());

      final index = _babies.indexWhere((b) => b.id == baby.id);
      if (index != -1) {
        _babies[index] = baby;
      }

      if (_currentBabyId == baby.id) {
        _currentBaby = baby;
      }

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// 아기 삭제
  Future<void> removeBaby(String babyId) async {
    try {
      await _babyRepository.deleteBaby(babyId: babyId);

      _babies.removeWhere((b) => b.id == babyId);

      // 삭제된 아기가 현재 아기면 다른 아기 선택
      if (_currentBabyId == babyId) {
        if (_babies.isNotEmpty) {
          _currentBabyId = _babies.first.id;
          _currentBaby = _babies.first;
          await _localStorage.setCurrentBabyId(_currentBabyId!);
        } else {
          _currentBabyId = null;
          _currentBaby = null;
        }
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
