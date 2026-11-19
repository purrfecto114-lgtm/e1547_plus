import 'dart:async';
import 'dart:math' show min, pi, sin;

import 'package:animations/animations.dart';
import 'package:e1547/app/data/biometrics.dart';
import 'package:e1547/app/data/pin.dart';
import 'package:e1547/l10n/app_localizations.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sub/flutter_sub.dart';
import 'package:local_auth/local_auth.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key, required this.child});

  final Widget child;

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  bool get biometricSetting => context.read<Settings>().biometricAuth.value;
  String? get pin => context.read<Settings>().appPin.value;
  bool get enabled => pin != null || biometricSetting;
  late bool locked = enabled;

  /// When the app was last hidden, used to tell a real absence from the
  /// brief backgrounding a biometric prompt can cause.
  DateTime? hiddenAt;

  late final AppLifecycleListener lifecycle;

  @override
  void initState() {
    super.initState();
    appLocked.value = enabled;
    lifecycle = AppLifecycleListener(
      onHide: () => hiddenAt = DateTime.now(),
      onShow: () {
        final DateTime? hidden = hiddenAt;
        hiddenAt = null;
        // Returning after a real absence re-arms the lock: whatever the
        // user left behind must not stay openable by anyone picking the
        // device up. The short backgrounding a biometric prompt can
        // cause is exempt, or every successful unlock would instantly
        // lock the app again.
        if (hidden != null &&
            enabled &&
            !locked &&
            DateTime.now().difference(hidden) > const Duration(seconds: 10)) {
          lock();
        }
      },
    );
  }

  @override
  void dispose() {
    lifecycle.dispose();
    super.dispose();
  }

  void lock() {
    // The lock screen covers the app, but does not stop it: whatever
    // plays keeps playing underneath, and an armed lock must also end
    // the sound it left running.
    VideoService.pauseAll();
    appLocked.value = true;
    setState(() => locked = true);
  }

  void unlock() {
    appLocked.value = false;
    setState(() => locked = false);
  }

  /// Verifies the entry against the stored pin and rehashes stale
  /// storage once it proves correct: a legacy plain text pin upgrades
  /// to the salted hash, and a hash pinned at a lower iteration count
  /// than the current default is lifted to it, both at the cost of the
  /// unlock the user just made.
  Future<bool> verifyPinEntry(String entry) async {
    final settings = context.read<Settings>();
    final stored = settings.appPin.value;
    if (stored == null) return false;
    final bool ok = await verifyPin(entry, stored);
    if (!ok) return false;
    // Defense in depth: the storage may have been rewritten while the
    // derivation ran, and overwriting that with our own rehash would
    // discard whatever the writer intended.
    if (settings.appPin.value != stored) return true;
    final int? storedIterations = pinHashIterationsOf(stored);
    final bool stale =
        storedIterations == null || storedIterations < pinHashIterations;
    if (stale) {
      settings.appPin.value = await hashPin(entry);
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<BiometricAvailability?>(
      valueListenable: context.watch<BiometricsWatcher>(),
      builder: (context, availability, child) {
        // The fingerprint shortcut only exists while the sensor actually
        // carries prints: enrollment changes in the system settings
        // while the app sits in the background, and the setting alone
        // kept offering a prompt that could only ever fail. An answer
        // that has not probed yet keeps the shortcut off as well.
        final bool biometrics =
            biometricSetting && availability == BiometricAvailability.ready;
        Widget? lock;

        if (pin != null) {
          lock = PinLock(
            title: AppLocalizations.of(context).lockEnterPin,
            verify: verifyPinEntry,
            attempts: context.read<Settings>().appPinFailures,
            lockedUntil: context.read<Settings>().appPinLockedUntil,
            biometrics: biometrics,
            autoBiometrics: biometrics,
            onBiometrics: biometrics
                ? () => tryLocalAuth(
                    context: context,
                    // A stronger factor clears the pin backoff as well:
                    // the owner just proved who they are, so punishing
                    // them for earlier typos after a restart reads as a
                    // bug rather than as a lockout.
                    onSuccess: () {
                      final settings = context.read<Settings>();
                      settings.appPinFailures.value = 0;
                      settings.appPinLockedUntil.value = 0;
                      unlock();
                    },
                  )
                : null,
            onCompleted: (_) => unlock(),
          );
        } else if (biometrics) {
          lock = BiometricsLockScreen(onSuccess: unlock);
        }

        bool showLock = lock != null && enabled && locked;

        return SubListener(
          listener: this.lock,
          listenable: Listenable.merge([
            context.read<Settings>().appPin,
            context.read<Settings>().biometricAuth,
          ]),
          builder: (context) => Stack(
            fit: StackFit.passthrough,
            children: [
              Visibility(
                visible: !showLock,
                maintainState: true,
                child: widget.child,
              ),
              PageTransitionSwitcher(
                transitionBuilder:
                    (child, primaryAnimation, secondaryAnimation) =>
                        FadeThroughTransition(
                          animation: primaryAnimation,
                          secondaryAnimation: secondaryAnimation,
                          child: child,
                        ),
                child: showLock ? lock! : null,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// The PIN entry screen shared by unlocking and registration.
///
/// A small lock glyph, the prompt, four filling dots and a circular
/// keypad replace the third party lock sheet: digits animate the dots
/// in, a wrong pin shakes and spells out why, and the keypad offers a
/// backspace next to an optional biometric shortcut. A cancel action
/// stays pinned below the scrollable content, so it remains reachable
/// on short screens instead of being pushed out by the keypad.
///
/// Unlocking goes through the async [PinLock.verify] callback against
/// the salted hash in the settings store, so the plain text pin never
/// exists in memory longer than one entry. Consecutive failures count
/// into a persisted backoff: from the third wrong pin onwards the
/// keypad locks itself for a doubling cooldown, and the counter only
/// clears on a correct entry.
class PinLock extends StatefulWidget {
  const PinLock({
    super.key,
    required this.title,
    this.confirmTitle,
    this.verify,
    this.attempts,
    this.lockedUntil,
    required this.onCompleted,
    this.biometrics = false,
    this.autoBiometrics = false,
    this.onBiometrics,
    this.onCancelled,
  });

  final String title;

  /// When set, the pin is collected twice: [title] prompts the first
  /// entry and [confirmTitle] the repeat, which must match.
  final String? confirmTitle;

  /// Async verdict for an entry, used by the unlock flow against the
  /// stored pin hash. When null, entries are collected instead.
  final Future<bool> Function(String pin)? verify;

  /// Persisted count of failed unlock attempts, driving the backoff.
  final ValueNotifier<int>? attempts;

  /// Persisted epoch millis until which entry stays locked out.
  final ValueNotifier<int>? lockedUntil;

  final ValueChanged<String> onCompleted;

  /// Whether the keypad offers a biometric shortcut.
  final bool biometrics;

  /// Whether the biometric prompt opens on its own.
  final bool autoBiometrics;

  final VoidCallback? onBiometrics;

  /// When set, a cancel action is offered, which is only sensible while
  /// collecting a new pin.
  final VoidCallback? onCancelled;

  @override
  State<PinLock> createState() => _PinLockState();
}

class _PinLockState extends State<PinLock> with SingleTickerProviderStateMixin {
  static const int digits = 4;

  late final AnimationController shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  );
  Timer? settleTimer;
  Timer? cooldownTimer;
  String entry = '';
  String? firstEntry;
  String? error;
  bool verifying = false;
  DateTime? cooldownUntil;

  /// When the fourth dot's entrance has drawn; the verdict waits for
  /// it (see [dotSettle]).
  DateTime? settleBy;

  /// Digits typed while a verification is still in flight, replayed
  /// into the fresh entry once the verdict lands.
  String buffer = '';

  bool get cooling => cooldownUntil != null;

  /// The fourth dot takes this long to grow in. A verdict that lands
  /// earlier waits for the entrance, so the dots never vanish mid
  /// growth while the derivation already ran underneath it.
  static const Duration dotSettle = Duration(milliseconds: 150);

  @override
  void initState() {
    super.initState();
    if (widget.autoBiometrics) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onBiometrics?.call();
      });
    }
    // A stored cooldown timestamp keeps its promise across restarts:
    // killing the app mid-timeout does not reset the wait. The stamp is
    // clamped to a single maximum cooldown, so a device clock set
    // backwards stretches the wait at most to that cap instead of
    // turning the backoff into a permanent lock.
    final int until = widget.lockedUntil?.value ?? 0;
    if (until > 0) {
      final int now = DateTime.now().millisecondsSinceEpoch;
      final int clamped = min(until, now + PinBackoff.maxDelay.inMilliseconds);
      if (clamped > now) {
        cooldownUntil = DateTime.fromMillisecondsSinceEpoch(clamped);
        _runCooldownTimer();
      }
    }
  }

  @override
  void dispose() {
    settleTimer?.cancel();
    cooldownTimer?.cancel();
    shake.dispose();
    super.dispose();
  }

  bool get confirming => firstEntry != null;

  void addDigit(int digit) {
    if (cooling) return;
    if (verifying) {
      // The keypad never drops a press: digits typed while a verdict is
      // still in flight are buffered and replayed into the fresh entry
      // once the verdict lands, so re-entering the pin the instant a
      // wrong verdict appears does not lose the leading digits to the
      // derivation window. The cooldown keeps swallowing input: the
      // backoff exists to make the keypad inert.
      if (buffer.length < digits) {
        HapticFeedback.selectionClick();
        setState(() => buffer += '$digit');
      }
      return;
    }
    if (entry.length >= digits) return;
    HapticFeedback.selectionClick();
    setState(() {
      entry += '$digit';
      error = null;
    });
    if (entry.length == digits) {
      if (widget.verify != null) {
        // The derivation starts now and overlaps the dot entrance; only
        // the verdict itself waits for the entrance (see verifyEntry).
        // The old fixed beat in front of the derivation added its whole
        // duration to every unlock instead of hiding behind it.
        settleBy = DateTime.now().add(dotSettle);
        verifyEntry();
      } else {
        settleTimer = Timer(dotSettle, submit);
      }
    }
  }

  void backspace() {
    if (cooling) return;
    if (verifying) {
      // The in flight entry is frozen, so a correction trims the buffer
      // instead; with nothing buffered there is nothing to reach.
      if (buffer.isNotEmpty) {
        HapticFeedback.selectionClick();
        setState(() => buffer = buffer.substring(0, buffer.length - 1));
      }
      return;
    }
    if (entry.isEmpty) return;
    settleTimer?.cancel();
    HapticFeedback.selectionClick();
    setState(() {
      entry = entry.substring(0, entry.length - 1);
      error = null;
    });
  }

  void submit() {
    if (!mounted || entry.length < digits || cooling) return;
    if (widget.verify != null) {
      verifyEntry();
      return;
    }
    final previous = firstEntry;
    if (previous == null) {
      setState(() {
        firstEntry = entry;
        entry = '';
      });
      return;
    }
    if (entry == previous) {
      complete();
    } else {
      setState(() => firstEntry = null);
      fail(AppLocalizations.of(context).lockPinMismatch);
    }
  }

  Future<void> verifyEntry() async {
    final candidate = entry;
    setState(() => verifying = true);
    bool ok;
    try {
      ok = await widget.verify!(candidate);
    } on Object {
      // A hash failure must lock the user out, not crash the screen.
      ok = false;
    }
    if (!mounted) return;
    // The derivation can beat the dot entrance; hold the verdict until
    // the entrance has drawn so the dots never vanish mid growth.
    final Duration? remaining = settleBy?.difference(DateTime.now());
    if (remaining != null && remaining > Duration.zero) {
      await Future<void>.delayed(remaining);
    }
    if (!mounted) return;
    setState(() => verifying = false);
    if (ok) {
      widget.attempts?.value = 0;
      widget.lockedUntil?.value = 0;
      complete();
      return;
    }
    registerFailure();
    fail(AppLocalizations.of(context).lockWrongPin);
    replayBuffer();
  }

  /// Pours the presses captured during the verification into the fresh
  /// entry. The error line stays up: the dots refill in its color and
  /// the next verdict replaces it. A replayed full entry starts its own
  /// verification right away, settling its dots from the verdict time.
  void replayBuffer() {
    if (buffer.isEmpty) return;
    final String replayed = buffer.substring(0, min(buffer.length, digits));
    buffer = '';
    setState(() => entry = replayed);
    if (entry.length == digits) {
      settleBy = DateTime.now().add(dotSettle);
      verifyEntry();
    }
  }

  void registerFailure() {
    final attempts = widget.attempts;
    if (attempts == null) return;
    final failures = attempts.value + 1;
    attempts.value = failures;
    final delay = PinBackoff.delayFor(failures);
    if (delay > Duration.zero) {
      final until = DateTime.now().add(delay);
      setState(() => cooldownUntil = until);
      widget.lockedUntil?.value = until.millisecondsSinceEpoch;
      _runCooldownTimer();
    }
  }

  void _runCooldownTimer() {
    cooldownTimer?.cancel();
    // One tick per second matches the resolution of the countdown
    // text; the previous half second period rebuilt the screen twice
    // as often for the same rendering.
    cooldownTimer = Timer(const Duration(seconds: 1), () {
      if (!mounted || cooldownUntil == null) return;
      if (DateTime.now().isAfter(cooldownUntil!)) {
        setState(() {
          cooldownUntil = null;
          if (error != null) error = null;
        });
      } else {
        // Rebuilds the countdown text once a second.
        setState(() {});
        _runCooldownTimer();
      }
    });
  }

  void complete() {
    HapticFeedback.mediumImpact();
    widget.onCompleted(entry);
  }

  void fail(String message) {
    HapticFeedback.heavyImpact();
    setState(() {
      error = message;
      entry = '';
    });
    shake.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final bool cooling = cooldownUntil != null;
    // The countdown replaces the wrong pin message while the backoff
    // runs, so the reserved line always explains what the keypad wants.
    String? status = error;
    if (cooling) {
      final int seconds = cooldownUntil!
          .difference(DateTime.now())
          .inSeconds
          .clamp(1, Duration.secondsPerDay);
      status = l10n.lockPinCooldown(seconds);
    }
    return SizedBox.expand(
      child: Material(
        color: scheme.surface,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // On short landscape screens the keypad shrinks as
                    // a whole instead of losing its lower rows behind
                    // the fold; the clamp keeps the keys tappable on
                    // any display while full size stays untouched on
                    // phones that fit it. The budget covers the icon,
                    // title, status line and dots plus the surface
                    // padding around them; the cancel button below
                    // sits outside this box, so the measured height
                    // already comes without it — the tightened budget
                    // is what lets the setup pad keep the unlock pad's
                    // full size on a 640dp screen.
                    const int reserved = 184;
                    const designHeight = 4.0 * 94.0;
                    final scale =
                        ((constraints.maxHeight - reserved) / designHeight)
                            .clamp(0.55, 1.0);
                    return Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // A small lock keeps the glyph symbolic:
                            // an oversized badge pushed the keypad and
                            // the cancel action off short screens.
                            Icon(
                              Icons.lock_outlined,
                              size: 28,
                              color: scheme.primary,
                            ),
                            const SizedBox(height: 12),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: Text(
                                confirming
                                    ? (widget.confirmTitle ?? widget.title)
                                    : widget.title,
                                key: ValueKey(confirming),
                                style: theme.textTheme.titleMedium,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 12),
                            // A reserved status line, so the layout
                            // does not jump. scaleDown keeps a long
                            // cooldown message inside its line instead
                            // of drawing it over the dots below.
                            SizedBox(
                              height: 20,
                              width: double.infinity,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: AnimatedOpacity(
                                  opacity: status == null ? 0 : 1,
                                  duration: const Duration(milliseconds: 150),
                                  child: Text(
                                    status ?? '',
                                    maxLines: 1,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: scheme.error,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            AnimatedBuilder(
                              animation: shake,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  for (int i = 0; i < digits; i++) ...[
                                    dot(i, scheme),
                                    if (i < digits - 1)
                                      const SizedBox(width: 24),
                                  ],
                                ],
                              ),
                              builder: (context, child) {
                                double t = shake.value;
                                double dx = sin(t * 3 * pi) * 12 * (1 - t);
                                return Transform.translate(
                                  offset: Offset(dx, 0),
                                  child: child,
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                            keypad(scheme, theme.textTheme, scale),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (widget.onCancelled != null)
                // The fixed height is the 56dp the scale budget above
                // reserves for this button.
                SizedBox(
                  height: 48,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 24, right: 24),
                    child: TextButton(
                      onPressed: widget.onCancelled,
                      child: Text(l10n.actionCancel),
                    ),
                  ),
                ),
              if (widget.onCancelled != null) const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget dot(int index, ColorScheme scheme) {
    bool filled = index < entry.length;
    // The circle grows inside a reserved box, so filling a dot never
    // changes the row height: the old free standing container pushed the
    // keypad and everything below it down on every keystroke.
    return SizedBox.square(
      dimension: 24,
      child: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(end: filled ? 1 : 0),
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          builder: (context, value, _) {
            double size = 14.0 + 6.0 * value;
            Color color = error != null ? scheme.error : scheme.primary;
            return Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: value > 0 ? color : Colors.transparent,
                border: Border.all(
                  width: 2,
                  color: error != null ? scheme.error : scheme.onSurfaceVariant,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget keypad(ColorScheme scheme, TextTheme textTheme, double scale) {
    // While a cooldown is running the keys dim and ignore presses; the
    // digit guard checks anyway. During a verification the keys stay
    // live: presses land in the buffer instead of being dropped.
    Widget key(int digit) => _KeyCell(
      size: scale,
      onPress: () => addDigit(digit),
      enabled: !cooling,
      child: Text(
        '$digit',
        style: textTheme.headlineMedium?.copyWith(color: scheme.onSurface),
      ),
    );
    Widget backspaceKey() => _KeyCell(
      size: scale,
      onPress: backspace,
      enabled: !cooling && (verifying ? buffer.isNotEmpty : entry.isNotEmpty),
      child: Icon(
        Icons.backspace_outlined,
        size: 28 * scale,
        color: scheme.onSurfaceVariant,
      ),
    );
    Widget biometricsKey() => _KeyCell(
      size: scale,
      onPress: widget.onBiometrics,
      child: Icon(Icons.fingerprint, size: 32 * scale, color: scheme.primary),
    );
    return Column(
      children: [
        for (List<int> row in const [
          [1, 2, 3],
          [4, 5, 6],
          [7, 8, 9],
        ])
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [for (int digit in row) key(digit)],
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.biometrics && widget.onBiometrics != null)
              biometricsKey()
            else
              SizedBox.square(dimension: 94 * scale),
            key(0),
            backspaceKey(),
          ],
        ),
      ],
    );
  }
}

/// One circular keypad key.
///
/// The digit registers the moment the finger touches down anywhere on
/// the cell: waiting for the lift dropped presses whenever the finger
/// drifted past the gesture slop before it came up, and the ring of
/// padding between the circles was dead space that ate grazing taps.
/// The press answers with a short scale down, so the key feels like it
/// fires instantly instead of waiting for a ripple to appear.
class _KeyCell extends StatefulWidget {
  const _KeyCell({
    required this.size,
    required this.child,
    this.onPress,
    this.enabled = true,
  });

  final double size;
  final Widget child;
  final VoidCallback? onPress;
  final bool enabled;

  @override
  State<_KeyCell> createState() => _KeyCellState();
}

class _KeyCellState extends State<_KeyCell> {
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedScale(
      scale: pressed ? 0.93 : 1.0,
      duration: const Duration(milliseconds: 80),
      curve: Curves.easeOut,
      child: GestureDetector(
        // Opaque covers the whole cell including the padding ring, so
        // the gap between two circles still belongs to one of them.
        behavior: HitTestBehavior.opaque,
        onTapDown: widget.enabled
            ? (_) {
                setState(() => pressed = true);
                widget.onPress?.call();
              }
            : null,
        onTapUp: widget.enabled ? (_) => setState(() => pressed = false) : null,
        onTapCancel: widget.enabled
            ? () => setState(() => pressed = false)
            : null,
        child: Padding(
          padding: EdgeInsets.all(7 * widget.size),
          child: Material(
            // Disabled keys keep their circle, only dimmed, so the
            // keypad silhouette stays stable instead of flashing a bare
            // glyph. A press tints the circle, which reads as the key
            // taking the finger.
            color: Color.lerp(
              scheme.surfaceContainerHighest,
              scheme.onSurface,
              pressed ? 0.08 : 0,
            )!.withValues(alpha: widget.enabled ? 1 : 0.4),
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: SizedBox.square(
              dimension: 80 * widget.size,
              child: Center(child: widget.child),
            ),
          ),
        ),
      ),
    );
  }
}

class BiometricsLockScreen extends StatefulWidget {
  const BiometricsLockScreen({super.key, required this.onSuccess});

  final VoidCallback onSuccess;

  @override
  State<BiometricsLockScreen> createState() => _BiometricsLockScreenState();
}

class _BiometricsLockScreenState extends State<BiometricsLockScreen> {
  bool failed = false;

  Future<void> tryAuth() async {
    setState(() => failed = false);
    await tryLocalAuth(
      context: context,
      onSuccess: widget.onSuccess,
      onFailure: () => setState(() => failed = true),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => tryAuth());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox.expand(
      child: Material(
        color: theme.colorScheme.surface,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.secondaryContainer,
                ),
                child: Icon(
                  Icons.fingerprint,
                  size: 56,
                  color: theme.colorScheme.onSecondaryContainer,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                failed
                    ? AppLocalizations.of(context).lockFailedAuth
                    : AppLocalizations.of(context).lockPleaseAuth,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              if (failed)
                FilledButton.tonalIcon(
                  onPressed: tryAuth,
                  icon: const Icon(Icons.refresh),
                  label: Text(AppLocalizations.of(context).lockRetry),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> tryLocalAuth({
  required BuildContext context,
  VoidCallback? onSuccess,
  VoidCallback? onFailure,
}) async {
  ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
  final LocalAuthentication localAuth = LocalAuthentication();
  final l10n = AppLocalizations.of(context);
  // Only the plugin boundary sits inside the guarded region: a bug in one
  // of the callbacks below must surface as a crash, not be rebranded as
  // a biometric failure that would also fire onFailure a second time.
  bool success;
  try {
    // Cancelling a stale prompt belongs inside the guarded region: on a
    // handful of devices even the no-op cancellation surfaced a platform
    // error that used to escape the handler below and left the lock
    // screen waiting for a prompt that never came.
    await localAuth.stopAuthentication();
    success = await localAuth.authenticate(
      localizedReason: l10n.lockBiometricReason,
      persistAcrossBackgrounding: true,
    );
  } on Object {
    // local_auth maps its own errors onto LocalAuthException, but driver
    // level PlatformExceptions have been observed in the wild; failing
    // closed into the retry path beats crashing into a stuck lock.
    messenger.showSnackBar(
      SnackBar(
        content: Text(l10n.lockBiometricFailure),
        duration: const Duration(milliseconds: 300),
      ),
    );
    onFailure?.call();
    return;
  }
  if (success) {
    onSuccess?.call();
  } else {
    onFailure?.call();
  }
}

Future<String?> registerPin(BuildContext context) async {
  final l10n = AppLocalizations.of(context);
  return Navigator.of(context, rootNavigator: true).push<String>(
    PageRouteBuilder<String>(
      pageBuilder: (context, animation, secondaryAnimation) => PinLock(
        title: l10n.lockEnterNewPin,
        confirmTitle: l10n.lockConfirmNewPin,
        onCompleted: (pin) => Navigator.of(context).pop(pin),
        onCancelled: () => Navigator.of(context).pop(),
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          FadeThroughTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            child: child,
          ),
    ),
  );
}
