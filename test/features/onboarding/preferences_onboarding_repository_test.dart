import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/features/onboarding/data/repositories/preferences_onboarding_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('la primera vez no se ha visto', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = PreferencesOnboardingRepository(
      preferences: preferences,
    );

    expect(repository.hasSeen, isFalse);
  });

  test('markSeen lo recuerda, también en otro repositorio', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = PreferencesOnboardingRepository(
      preferences: preferences,
    );

    await repository.markSeen();

    expect(repository.hasSeen, isTrue);
    // Simula cerrar y abrir la app: otro repositorio sobre las mismas
    // preferencias.
    expect(
      PreferencesOnboardingRepository(preferences: preferences).hasSeen,
      isTrue,
    );
  });
}
