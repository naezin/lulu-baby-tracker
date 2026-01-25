import '../../../domain/repositories/i_preference_repository.dart';
import '../../../domain/entities/user_preference.dart';

/// Mock Preference Repository (In-Memory)
class MockPreferenceRepository implements IPreferenceRepository {
  final List<UserPreference> _preferences = [];

  @override
  Future<List<UserPreference>> getPreferencesByUserId(String userId) async {
    return _preferences.where((p) => p.userId == userId).toList();
  }

  @override
  Future<void> savePreference(UserPreference preference) async {
    _preferences.add(preference);
  }

  @override
  Future<void> deletePreference(String preferenceId) async {
    _preferences.removeWhere((p) => p.id == preferenceId);
  }

  @override
  Future<UserPreference?> getPreferenceById(String preferenceId) async {
    try {
      return _preferences.firstWhere((p) => p.id == preferenceId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<UserPreference>> getPreferencesByCategory(
    String userId,
    String category,
  ) async {
    return _preferences
        .where((p) => p.userId == userId && p.category == category)
        .toList();
  }

  @override
  Stream<List<UserPreference>> watchPreferences(String userId) {
    return Stream.value(_preferences.where((p) => p.userId == userId).toList());
  }
}
