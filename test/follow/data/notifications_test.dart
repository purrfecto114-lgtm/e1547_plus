import 'package:e1547/follow/follow.dart';
import 'package:e1547/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../_support/harness.dart';

Follow follow({
  String name = 'big cat',
  String? thumbnail = 'https://example.test/thumb.jpg',
}) => Follow(
  id: 1,
  tags: 'big_cat',
  title: name,
  alias: null,
  type: FollowType.notify,
  latest: 1000,
  unseen: 2,
  thumbnail: thumbnail,
  updated: null,
);
void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    await initializeTestApp();
    l10n = await AppLocalizations.delegate.load(const Locale('en'));
  });

  group('describeFollowNotification', () {
    test('shows the follow name and thumbnail by default', () {
      final content = describeFollowNotification(
        follow: follow(),
        unseen: 3,
        localizations: l10n,
        hideContent: false,
      );

      expect(content.title, 'big cat');
      expect(content.body, l10n.followNotificationBody(3));
      expect(content.showThumbnail, isTrue);
    });

    test('hides content when the setting is enabled', () {
      // The screen saver only covers the app window; this is what keeps
      // followed tags off the system notification preview.
      final content = describeFollowNotification(
        follow: follow(),
        unseen: 3,
        localizations: l10n,
        hideContent: true,
      );

      expect(content.title, l10n.followNotificationSummary);
      expect(content.title.contains('big cat'), isFalse);
      expect(content.body, l10n.followNotificationHiddenBody);
      expect(content.body.contains('3'), isFalse);
      expect(content.showThumbnail, isFalse);
    });
  });
}
