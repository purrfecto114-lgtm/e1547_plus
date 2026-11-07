import 'dart:async';
import 'dart:math' show pi, sin;

import 'package:animations/animations.dart';
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
  bool get biometrics => context.read<Settings>().biometricAuth.value;
  String? get pin => context.read<Settings>().appPin.value;
  bool get enabled => pin != null || biometrics;
  late bool locked = enabled;

  void lock() => setState(() => locked = true);
  void unlock() => setState(() => locked = false);

  @override
  Widget build(BuildContext context) {
    Widget? lock;

    if (pin != null) {
      lock = PinLock(
        title: AppLocalizations.of(context).lockEnterPin,
        correctString: pin!,
        biometrics: biometrics,
        autoBiometrics: biometrics,
        onBiometrics: biometrics
            ? () => tryLocalAuth(context: context, onSuccess: unlock)
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
            transitionBuilder: (child, primaryAnimation, secondaryAnimation) =>
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
class PinLock extends StatefulWidget {
  const PinLock({
    super.key,
    required this.title,
    this.confirmTitle,
    this.correctString,
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

  /// When set, entries are verified against it instead of collected.
  final String? correctString;

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
  Timer? submitTimer;
  String entry = '';
  String? firstEntry;
  String? error;

  @override
  void initState() {
    super.initState();
    if (widget.autoBiometrics) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onBiometrics?.call();
      });
    }
  }

  @override
  void dispose() {
    submitTimer?.cancel();
    shake.dispose();
    super.dispose();
  }

  bool get confirming => widget.correctString == null && firstEntry != null;

  void addDigit(int digit) {
    if (entry.length >= digits) return;
    HapticFeedback.selectionClick();
    setState(() {
      entry += '$digit';
      error = null;
    });
    if (entry.length == digits) {
      submitTimer = Timer(const Duration(milliseconds: 220), submit);
    }
  }

  void backspace() {
    if (entry.isEmpty) return;
    submitTimer?.cancel();
    HapticFeedback.selectionClick();
    setState(() {
      entry = entry.substring(0, entry.length - 1);
      error = null;
    });
  }

  void submit() {
    if (!mounted || entry.length < digits) return;
    if (widget.correctString != null) {
      if (entry == widget.correctString) {
        complete();
      } else {
        fail(AppLocalizations.of(context).lockWrongPin);
      }
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
    final bool setup = widget.correctString == null;
    return SizedBox.expand(
      child: Material(
        color: scheme.surface,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 24,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // A small lock instead of the oversized badge the
                        // setup screen used to carry: the glyph names the
                        // state without pushing the keypad or the cancel
                        // action off short screens.
                        Icon(
                          setup ? Icons.lock_outlined : Icons.lock_outline,
                          size: 36,
                          color: scheme.primary,
                        ),
                        const SizedBox(height: 14),
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
                        const SizedBox(height: 10),
                        // A reserved error line, so the layout does not jump.
                        SizedBox(
                          height: 20,
                          child: AnimatedOpacity(
                            opacity: error == null ? 0 : 1,
                            duration: const Duration(milliseconds: 150),
                            child: Text(
                              error ?? '',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: scheme.error,
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
                                if (i < digits - 1) const SizedBox(width: 20),
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
                        const SizedBox(height: 20),
                        keypad(scheme, theme.textTheme),
                      ],
                    ),
                  ),
                ),
              ),
              if (widget.onCancelled != null)
                Padding(
                  padding: const EdgeInsets.only(
                    left: 24,
                    right: 24,
                    bottom: 12,
                  ),
                  child: TextButton(
                    onPressed: widget.onCancelled,
                    child: Text(l10n.actionCancel),
                  ),
                ),
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

  Widget keypad(ColorScheme scheme, TextTheme textTheme) {
    Widget key(int digit) => cell(
      scheme: scheme,
      child: Text(
        '$digit',
        style: textTheme.headlineMedium?.copyWith(color: scheme.onSurface),
      ),
      onTap: () => addDigit(digit),
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
              cell(
                scheme: scheme,
                child: Icon(Icons.fingerprint, size: 30, color: scheme.primary),
                onTap: widget.onBiometrics,
              )
            else
              const SizedBox(width: 84, height: 84),
            key(0),
            cell(
              scheme: scheme,
              child: Icon(
                Icons.backspace_outlined,
                size: 26,
                color: scheme.onSurfaceVariant,
              ),
              onTap: entry.isEmpty ? null : backspace,
              enabled: entry.isNotEmpty,
            ),
          ],
        ),
      ],
    );
  }

  Widget cell({
    required ColorScheme scheme,
    required Widget child,
    VoidCallback? onTap,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Material(
        // Disabled keys keep their circle, only dimmed, so the keypad
        // silhouette stays stable instead of flashing a bare glyph.
        color: scheme.surfaceContainerHighest.withValues(
          alpha: enabled ? 1 : 0.4,
        ),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(width: 72, height: 72, child: Center(child: child)),
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
