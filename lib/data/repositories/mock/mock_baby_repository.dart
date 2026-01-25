import '../../../domain/repositories/i_baby_repository.dart';
import '../../../domain/entities/baby.dart';

/// Mock Baby Repository (In-Memory)
class MockBabyRepository implements IBabyRepository {
  final Map<String, Baby> _babies = {};

  @override
  Future<Baby?> getBabyByUserId(String userId) async {
    return _babies[userId];
  }

  @override
  Future<void> saveBaby(Baby baby) async {
    _babies[baby.userId] = baby;
  }

  @override
  Future<void> updateBaby(Baby baby) async {
    _babies[baby.userId] = baby;
  }

  @override
  Future<void> deleteBaby(String userId) async {
    _babies.remove(userId);
  }

  @override
  Stream<Baby?> watchBaby(String userId) {
    return Stream.value(_babies[userId]);
  }
}
