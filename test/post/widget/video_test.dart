import 'package:e1547/post/post.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../_support/video.dart';

void main() {
  const duration = Duration(minutes: 1);
  const step = Duration(seconds: 10);

  Duration seek(Duration position, Duration offset, {Duration? total}) =>
      videoSeekTarget(
        position: position,
        duration: total ?? duration,
        offset: offset,
      );

  group('videoSeekTarget', () {
    test('holds at the start when the offset reaches past it', () {
      expect(seek(step - const Duration(seconds: 1), -step), Duration.zero);
    });

    test('holds at the end when the offset reaches past it', () {
      expect(
        seek(duration - step + const Duration(seconds: 1), step),
        duration,
      );
    });

    test('holds where it is when there is nowhere left to go', () {
      expect(seek(Duration.zero, -step), Duration.zero);
      expect(seek(duration, step), duration);
    });

    test('moves by the offset while both ends are clear', () {
      const middle = Duration(seconds: 30);
      expect(seek(middle, -step), middle - step);
      expect(seek(middle, step), middle + step);
    });

    test('moves forward while the duration is still unknown', () {
      expect(seek(step, step, total: Duration.zero), step * 2);
    });
  });

  Widget wrap(Widget child) =>
      MaterialApp(home: Scaffold(body: Center(child: child)));

  Future<void> pumpVideoGesture(
    WidgetTester tester, {
    required FakePlatformPlayer platform,
    bool forward = true,
  }) async {
    await tester.pumpWidget(
      wrap(
        SizedBox.expand(
          child: VideoGesture(
            forward: forward,
            player: VideoPlayer(platformPlayer: platform),
          ),
        ),
      ),
    );
  }

  Future<void> doubleTap(WidgetTester tester) async {
    await tester.tap(find.byType(VideoGesture));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.byType(VideoGesture));
    await tester.pump();
  }

  group('VideoGesture', () {
    testWidgets('seeks by ten seconds per double tap', (tester) async {
      final platform = FakePlatformPlayer()
        ..setDuration(duration)
        ..setPosition(step);
      await pumpVideoGesture(tester, platform: platform);

      await doubleTap(tester);
      await tester.pumpAndSettle(const Duration(milliseconds: 16));
      // let the combo reset timer elapse while the gesture is still mounted
      await tester.pump(const Duration(milliseconds: 500));

      expect(platform.seeks, [step * 2]);
    });

    testWidgets('does nothing when the offset cannot move the position', (
      tester,
    ) async {
      final platform = FakePlatformPlayer()
        ..setDuration(duration)
        ..setPosition(Duration.zero);
      await pumpVideoGesture(tester, platform: platform, forward: false);

      await doubleTap(tester);
      await tester.pumpAndSettle(const Duration(milliseconds: 16));
      // let any pending gesture recognizer timers elapse
      await tester.pump(const Duration(milliseconds: 500));

      expect(platform.seeks, isEmpty);
      expect(tester.takeException(), isNull);
    });

    testWidgets('releases its animation when unmounted mid-flight', (
      tester,
    ) async {
      final platform = FakePlatformPlayer()
        ..setDuration(duration)
        ..setPosition(step);
      await pumpVideoGesture(tester, platform: platform);

      await doubleTap(tester);
      // the forward animation is now running
      await tester.pump(const Duration(milliseconds: 50));

      await tester.pumpWidget(wrap(const SizedBox()));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(platform.seeks, [step * 2]);
    });

    testWidgets('cancels its combo timer when unmounted after the animation', (
      tester,
    ) async {
      final platform = FakePlatformPlayer()
        ..setDuration(duration)
        ..setPosition(step);
      await pumpVideoGesture(tester, platform: platform);

      await doubleTap(tester);
      // the 400ms forward and reverse animations settle inside the 900ms
      // combo window, which leaves the combo timer armed
      await tester.pumpAndSettle(const Duration(milliseconds: 16));

      await tester.pumpWidget(wrap(const SizedBox()));
      await tester.pump(const Duration(seconds: 2));

      expect(tester.takeException(), isNull);
    });
  });
}
