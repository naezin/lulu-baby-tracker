import 'package:flutter/foundation.dart';
import '../../data/models/baby_model.dart';
import '../../data/services/local_storage_service.dart';
import '../../data/services/widget_service.dart';
import '../../domain/repositories/i_baby_repository.dart';

/// 현재 선택된 아기 정보를 관리하는 Provider (단일 아기)
class BabyProvider extends ChangeNotifier {
  final IBabyRepository _babyRepository;
  final LocalStorageService _localStorage;
  final WidgetService _widgetService;

  BabyModel? _currentBaby;
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
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasBaby => _currentBaby != null;

  /// 첫 번째 아기 로드 (단일 아기)
  Future<void> loadBabies(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Repository에서 아기 목록 로드
      final entities = await _babyRepository.getBabiesByUser(userId: userId);
      final babies = entities.map((e) => BabyModel.fromEntity(e)).toList();

      // 2. Repository가 비어있으면 로컬 스토리지에서 직접 로드 (호환성)
      if (babies.isEmpty) {
        final localBabies = await _localStorage.getAllBabies();
        if (localBabies.isNotEmpty) {
          _currentBaby = localBabies.first;
          print('✅ [BabyProvider] Loaded baby from local storage: ${_currentBaby?.name}');
        }
      } else {
        // 첫 번째 아기만 사용
        _currentBaby = babies.first;
        print('✅ [BabyProvider] Single-baby mode: using ${_currentBaby?.name}');
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 현재 아기 설정 (온보딩용)
  void setCurrentBaby(BabyModel baby) {
    _currentBaby = baby;
    notifyListeners();
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
