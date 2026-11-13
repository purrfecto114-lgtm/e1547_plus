import 'package:e1547/app/app.dart';
import 'package:e1547/identity/identity.dart';
import 'package:flutter_test/flutter_test.dart';

Identity identity(int id, {String host = 'https://e621.net'}) =>
    Identity(id: id, host: host, username: null, headers: null);

void main() {
  group('planNotificationIdentity', () {
    test('the active identity shows the page directly', () {
      expect(
        planNotificationIdentity(identity: identity(3), activeIdentityId: 3),
        NotificationIdentityAction.show,
      );
    });

    test('another existing identity is switched to first', () {
      // A notification created by account A must not load with the client
      // of account B: their hosts can differ, and the same post id can
      // point to different content on each.
      expect(
        planNotificationIdentity(
          identity: identity(2, host: 'https://e926.net'),
          activeIdentityId: 7,
        ),
        NotificationIdentityAction.switchIdentity,
      );
    });

    test('a removed identity makes the notification stale', () {
      expect(
        planNotificationIdentity(identity: null, activeIdentityId: 7),
        NotificationIdentityAction.stale,
      );
    });
  });
}
