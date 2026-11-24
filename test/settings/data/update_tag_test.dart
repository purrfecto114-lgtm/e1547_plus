import 'package:flutter_test/flutter_test.dart';
import 'package:pub_semver/pub_semver.dart';

void main() {
  // The deployment workflow's test_release path cuts tags of the form
  // 22.9.5-test.<run>+<build>. Whatever the updater offers has to come
  // from tags that outrank the installed version, so the shape below is
  // what keeps a manual test build invisible to every client.
  test('a test tag never outranks the released version', () {
    final Version current = Version.parse('22.9.5+241');
    final Version testTag = Version.parse('22.9.5-test.48+241');
    // filterNewVersions drops anything whose compareTo(current) < 1,
    // before the beta gate ever looks at it.
    expect(testTag.compareTo(current) < 1, isTrue);
    // The prioritize gate would reject it for non-beta users as well.
    expect(Version.prioritize(testTag, current) < 1, isTrue);
    // Sanity: the released rc does outrank the stable, so beta gating
    // still works as designed.
    final Version rc = Version.parse('22.10.0+242-rc.1');
    expect(rc.compareTo(current) > 0, isTrue);
  });
}
