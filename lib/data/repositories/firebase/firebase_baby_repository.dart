import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../domain/repositories/i_baby_repository.dart';
import '../../../domain/entities/baby_entity.dart';
import '../../models/baby_model.dart';

/// Firebase Firestore 기반 Baby Repository 구현
class FirebaseBabyRepository implements IBabyRepository {
  final FirebaseFirestore _firestore;
  static const String _currentBabyIdKey = 'current_baby_id';

  FirebaseBabyRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // ============================================================
  // Collection References
  // ============================================================

  CollectionReference<Map<String, dynamic>> get _babiesCollection =>
      _firestore.collection('babies');

  // ============================================================
  // CRUD Operations
  // ============================================================

  @override
  Future<void> saveBaby({
    required String userId,
    required BabyEntity baby,
  }) async {
    try {
      final model = BabyModel.fromEntity(baby);
      await _babiesCollection.doc(baby.id).set(model.toJson());
    } catch (e) {
      throw Exception('Failed to save baby: $e');
    }
  }

  @override
  Future<BabyEntity?> getBaby({required String babyId}) async {
    try {
      final doc = await _babiesCollection.doc(babyId).get();
      if (!doc.exists) return null;
      return BabyModel.fromJson({...doc.data()!, 'id': doc.id}).toEntity();
    } catch (e) {
      throw Exception('Failed to get baby: $e');
    }
  }

  @override
  Future<List<BabyEntity>> getBabiesByUser({required String userId}) async {
    try {
      final snapshot =
          await _babiesCollection.where('userId', isEqualTo: userId).get();

      return snapshot.docs
          .map((doc) =>
              BabyModel.fromJson({...doc.data(), 'id': doc.id}).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Failed to get babies by user: $e');
    }
  }

  @override
  Future<void> updateBaby({required BabyEntity baby}) async {
    try {
      final model = BabyModel.fromEntity(baby);
      await _babiesCollection.doc(baby.id).update(model.toJson());
    } catch (e) {
      throw Exception('Failed to update baby: $e');
    }
  }

  @override
  Future<void> deleteBaby({required String babyId}) async {
    try {
      await _babiesCollection.doc(babyId).delete();

      // 현재 선택된 아기가 삭제되면 로컬 캐시도 제거
      final currentId = await getCurrentBabyId();
      if (currentId == babyId) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_currentBabyIdKey);
      }
    } catch (e) {
      throw Exception('Failed to delete baby: $e');
    }
  }

  // ============================================================
  // Local Cache Operations
  // ============================================================

  @override
  Future<BabyEntity?> getCurrentBaby() async {
    try {
      final babyId = await getCurrentBabyId();
      if (babyId == null) return null;
      return getBaby(babyId: babyId);
    } catch (e) {
      throw Exception('Failed to get current baby: $e');
    }
  }

  @override
  Future<void> setCurrentBaby(BabyEntity baby) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currentBabyIdKey, baby.id);
    } catch (e) {
      throw Exception('Failed to set current baby: $e');
    }
  }

  @override
  Future<String?> getCurrentBabyId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_currentBabyIdKey);
    } catch (e) {
      throw Exception('Failed to get current baby ID: $e');
    }
  }

  // ============================================================
  // Stream Operations
  // ============================================================

  @override
  Stream<BabyEntity?> watchBaby({required String babyId}) {
    try {
      return _babiesCollection.doc(babyId).snapshots().map((doc) {
        if (!doc.exists) return null;
        return BabyModel.fromJson({...doc.data()!, 'id': doc.id}).toEntity();
      });
    } catch (e) {
      throw Exception('Failed to watch baby: $e');
    }
  }

  @override
  Stream<List<BabyEntity>> watchBabies({required String userId}) {
    try {
      return _babiesCollection
          .where('userId', isEqualTo: userId)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) =>
                  BabyModel.fromJson({...doc.data(), 'id': doc.id}).toEntity())
              .toList());
    } catch (e) {
      throw Exception('Failed to watch babies: $e');
    }
  }
}
