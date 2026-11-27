import 'package:pokedex/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Guarda en el teléfono (SharedPreferences) si la introducción ya se vio.
/// Es una preferencia del dispositivo, no un dato del catálogo.
class PreferencesOnboardingRepository implements OnboardingRepository {
  PreferencesOnboardingRepository({required this._preferences});

  static const String _key = 'onboarding_seen';

  final SharedPreferences _preferences;

  @override
  bool get hasSeen => _preferences.getBool(_key) ?? false;

  @override
  Future<void> markSeen() async {
    await _preferences.setBool(_key, true);
  }
}
