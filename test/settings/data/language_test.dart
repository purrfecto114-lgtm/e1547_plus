import 'dart:ui';

import 'package:e1547/l10n/app_localizations.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notified_preferences/notified_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const Locale traditional = Locale.fromSubtags(
    languageCode: 'zh',
    scriptCode: 'Hant',
  );

  group('resolveAppLocale', () {
    test('matches supported locales and falls back to the first one', () {
      expect(resolveAppLocale(const [Locale('en')]), const Locale('en'));
      expect(resolveAppLocale(const [Locale('zh')]), const Locale('zh'));
      expect(resolveAppLocale(const [traditional]), traditional);
      expect(resolveAppLocale(const [Locale('en', 'US')]), const Locale('en'));
      expect(resolveAppLocale(const [Locale('zh', 'CN')]), const Locale('zh'));
      expect(resolveAppLocale(const [Locale('de')]), const Locale('en'));
      expect(resolveAppLocale(const [Locale('de', 'DE')]), const Locale('en'));
      expect(resolveAppLocale(null), const Locale('en'));
      expect(resolveAppLocale(const []), const Locale('en'));
    });

    test(
      'upgrades generic zh to the traditional script for regions using it',
      () {
        expect(resolveAppLocale(const [Locale('zh', 'TW')]), traditional);
        expect(resolveAppLocale(const [Locale('zh', 'HK')]), traditional);
        expect(resolveAppLocale(const [Locale('zh', 'MO')]), traditional);
        expect(
          resolveAppLocale(const [Locale('zh', 'CN')]),
          const Locale('zh'),
        );
        expect(
          resolveAppLocale(const [Locale('zh', 'SG')]),
          const Locale('zh'),
        );
      },
    );
  });

  group('loadPreferenceLocalizations', () {
    test('loads the stored language', () async {
      SharedPreferences.setMockInitialValues({'language': 'en'});
      AppLocalizations localizations = await loadPreferenceLocalizations();
      expect(localizations.followNotificationBody(1), 'has a new post!');
      expect(localizations.followNotificationBody(2), 'has 2 new posts!');
      expect(localizations.followNotificationSummary, 'New posts!');
      expect(localizations.followChannelName, 'Followed Tags');

      SharedPreferences.setMockInitialValues({'language': 'zh'});
      localizations = await loadPreferenceLocalizations();
      expect(localizations.followNotificationBody(3), '有 3 条新帖子！');
      expect(localizations.followChannelName, '已关注标签');

      SharedPreferences.setMockInitialValues({'language': 'zh_Hant'});
      localizations = await loadPreferenceLocalizations();
      expect(localizations.followNotificationBody(1), '有 1 則新貼文！');
      expect(localizations.followChannelName, '已追蹤標籤');
    });

    test('falls back to the platform locales when nothing is stored', () async {
      SharedPreferences.setMockInitialValues({});
      final List<Locale> platformLocales = PlatformDispatcher.instance.locales
          .toList();
      final AppLocalizations expected = await AppLocalizations.delegate.load(
        resolveAppLocale(platformLocales),
      );
      final AppLocalizations localizations =
          await loadPreferenceLocalizations();
      expect(
        localizations.followNotificationSummary,
        expected.followNotificationSummary,
      );
    });
  });
}
