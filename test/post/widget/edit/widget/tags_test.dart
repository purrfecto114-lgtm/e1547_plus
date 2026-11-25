import 'package:e1547/post/post.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../_support/environment.dart';
import '../../../../_support/harness.dart';

/// Locks in the tag editor's preview mode: toggling it fetches a live
/// preview for the typed tags and renders them as cards — known names
/// with their post count, unknown ones flagged as new — instead of
/// erroring against an endpoint the fake did not serve.
void main() {
  setUpAll(initializeTestApp);

  late TestEnvironment env;

  setUp(() async {
    // The editor's tag input rides the typeahead package, whose
    // keyboard visibility stream has no host implementation to listen
    // to under the test binding.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('flutter_keyboard_visibility'),
          (call) async => null,
        );
    env = await TestEnvironment.start();
  });

  tearDown(() => env.dispose());

  displayTest('the tag editor previews the typed tags', (tester) async {
    final controller = TextEditingController(text: 'tag_1 made_up_tag');
    addTearDown(controller.dispose);

    await tester.runAsync(() async {
      await tester.pumpWidget(
        env.app(Scaffold(body: TagsEditDisplay(controller: controller))),
      );
    });
    await env.settle(tester);

    // Before the toggle, the editor edits raw text.
    expect(find.byType(TagInput), findsOneWidget);
    expect(find.byType(TagPreviewCard), findsNothing);

    await tester.tap(find.byTooltip('Preview'));
    await env.settle(tester);

    // The preview replaces the raw input with one card per tag.
    expect(find.byType(TagInput), findsNothing);
    expect(find.byType(TagPreviewCard), findsNWidgets(2));

    // The recorded tag shows its live post count; the unknown one comes
    // back bare and is flagged as a new tag.
    expect(find.text('4.4m'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(TagPreviewCard).at(1),
        matching: find.text('new'),
      ),
      findsOneWidget,
    );
  });
}
