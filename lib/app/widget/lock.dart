import 'dart:async';
import 'package:animations/animations.dart';
import 'package:e1547/l10n/app_localizations.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';
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
      lock = ScreenLock(
        title: _LockTitle(text: AppLocalizations.of(context).lockEnterPin),
        correctString: pin!,
        customizedButtonChild: biometrics
            ? Icon(
                Icons.fingerprint,
                size: 32,
                color: Theme.of(context).colorScheme.onSurface,
              )
            : null,
        customizedButtonTap: biometrics
            ? () => tryLocalAuth(context: context, onSuccess: unlock)
            : null,
        onOpened: biometrics
            ? () => tryLocalAuth(context: context, onSuccess: unlock)
            : null,
        onUnlocked: unlock,
        config: _screenLockConfig(context),
        secretsConfig: SecretsConfig(
          spacing: 16,
          padding: const EdgeInsets.only(top: 28, bottom: 40),
          secretConfig: SecretConfig(
            size: 18,
            borderSize: 2,
            borderColor: Theme.of(context).colorScheme.onSurfaceVariant,
            enabledColor: Theme.of(context).colorScheme.primary,
            erroredColor: Theme.of(context).colorScheme.error,
            erroredBorderColor: Theme.of(context).colorScheme.error,
          ),
        ),
        keyPadConfig: KeyPadConfig(
          buttonConfig: KeyPadButtonConfig(
            buttonStyle: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onSurface,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest,
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          actionButtonConfig: KeyPadButtonConfig(
            buttonStyle: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
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

/// The look shared by the lock and PIN registration prompts.
ScreenLockConfig _screenLockConfig(BuildContext context) {
  final theme = Theme.of(context);
  return ScreenLockConfig(
    themeData: theme,
    backgroundColor: theme.colorScheme.surface,
    titleTextStyle: theme.textTheme.titleLarge,
    textStyle: theme.textTheme.bodyLarge,
  );
}

/// A lock glyph above the prompt, so the screen reads as a lock
/// instead of a bare keypad.
class _LockTitle extends StatelessWidget {
  const _LockTitle({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.lock_outline,
          size: 36,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: 12),
        Text(text),
      ],
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
    return Scaffold(
      body: Center(
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
  await localAuth.stopAuthentication();
  try {
    bool success = await localAuth.authenticate(
      localizedReason: l10n.lockBiometricReason,
      persistAcrossBackgrounding: true,
    );
    if (success) {
      onSuccess?.call();
    } else {
      onFailure?.call();
    }
  } on LocalAuthException {
    messenger.showSnackBar(
      SnackBar(
        content: Text(l10n.lockBiometricFailure),
        duration: const Duration(milliseconds: 300),
      ),
    );
    onFailure?.call();
  }
}

Future<String?> registerPin(BuildContext context) async {
  Completer<String?> completer = Completer();
  await screenLockCreate(
    title: _LockTitle(text: AppLocalizations.of(context).lockEnterNewPin),
    confirmTitle: _LockTitle(
      text: AppLocalizations.of(context).lockConfirmNewPin,
    ),
    context: context,
    onConfirmed: (result) {
      completer.complete(result);
      Navigator.of(context).pop();
    },
    onCancelled: () {
      completer.complete(null);
      Navigator.of(context).pop();
    },
    config: _screenLockConfig(context),
  );

  return completer.future;
}
