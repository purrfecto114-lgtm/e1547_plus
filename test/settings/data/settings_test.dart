import 'package:e1547/settings/settings.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notified_preferences/notified_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('a fresh install starts muted and on stable updates', () async {
    SharedPreferences.setMockInitialValues({});
    final settings = await Settings.getInstance();

    expect(settings.muteVideos.value, isTrue);
    expect(settings.updatePrereleases.value, isFalse);
  });

  test('a stale unmuted leftover resets to the muted default', () async {
    // Installs from before the mute default flipped carry the old default
    // in storage; the migration clears it so videos start muted again.
    SharedPreferences.setMockInitialValues({'muteVideos': false});
    final settings = await Settings.getInstance();

    expect(settings.muteVideos.value, isTrue);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('legacyDefaultsMigrated'), isTrue);
    expect(prefs.getBool('muteVideos'), isNull);
  });

  test(
    'a deliberately chosen sound preference survives the migration',
    () async {
      SharedPreferences.setMockInitialValues({
        'muteVideos': false,
        'legacyDefaultsMigrated': true,
      });
      final settings = await Settings.getInstance();

      expect(settings.muteVideos.value, isFalse);
    },
  );

  test('the migration runs only once', () async {
    SharedPreferences.setMockInitialValues({'muteVideos': false});
    await Settings.getInstance();

    // A later unmute is the user's choice and must not be reset again.
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('muteVideos', false);
    await Settings.getInstance();

    expect(prefs.getBool('muteVideos'), isFalse);
  });
}
