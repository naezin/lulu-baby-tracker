import '../../../domain/repositories/i_baby_repository.dart';
import '../../../domain/entities/baby_entity.dart';

/// Mock Baby Repository (In-Memory)
class MockBabyRepository implements IBabyRepository {
  final Map<String, BabyEntity> _babies = {};
  final Map<String, List<String>> _userBabies = {};
  BabyEntity? _currentBaby;

  @override
  Future<void> saveBaby({
    required String userId,
    required BabyEntity baby,
  }) async {
    _babies[baby.id] = baby;
    _userBabies.putIfAbsent(userId, () => []);
    if (!_userBabies[userId]!.contains(baby.id)) {
      _userBabies[userId]!.add(baby.id);
    }
  }

  @override
  Future<BabyEntity?> getBaby({required String babyId}) async {
    return _babies[babyId];
  }

  @override
  Future<List<BabyEntity>> getBabiesByUser({required String userId}) async {
    final babyIds = _userBabies[userId] ?? [];
    return babyIds
        .map((id) => _babies[id])
        .where((baby) => baby != null)
        .cast<BabyEntity>()
        .toList();
  }

  @override
  Future<void> updateBaby({required BabyEntity baby}) async {
    _babies[baby.id] = baby;
  }

  @override
  Future<void> deleteBaby({required String babyId}) async {
    _babies.remove(babyId);
    _userBabies.forEach((userId, babyIds) {
      babyIds.remove(babyId);
    });
  }

  @override
  Future<BabyEntity?> getCurrentBaby() async {
    return _currentBaby;
  }

  @override
  Future<void> setCurrentBaby(BabyEntity baby) async {
    _currentBaby = baby;
  }

  @override
  Future<String?> getCurrentBabyId() async {
    return _currentBaby?.id;
  }

  @override
  Stream<BabyEntity?> watchBaby({required String babyId}) {
    return Stream.value(_babies[babyId]);
  }

  @override
  Stream<List<BabyEntity>> watchBabies({required String userId}) async* {
    final babies = await getBabiesByUser(userId: userId);
    yield babies;
  }
}
