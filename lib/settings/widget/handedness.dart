import 'package:e1547/l10n/app_localizations.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';

enum Handedness {
  left,
  right;

  /// Localized display name for pickers.
  String title(AppLocalizations l10n) => switch (this) {
    Handedness.right => l10n.handRight,
    Handedness.left => l10n.handLeft,
  };

  HorizontalDirection get side => switch (this) {
    Handedness.right => HorizontalDirection.right,
    Handedness.left => HorizontalDirection.left,
  };

  FloatingActionButtonLocation get floatingActionButtonLocation =>
      switch (this) {
        Handedness.right => FloatingActionButtonLocation.endFloat,
        Handedness.left => FloatingActionButtonLocation.startFloat,
      };

  static Handedness of(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<_HandednessProvider>()
          ?.notifier
          ?.value ??
      Handedness.right;
}

class HandednessScope extends StatelessWidget {
  const HandednessScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => _HandednessProvider(
    notifier: context.watch<Settings>().handedness,
    child: child,
  );
}

class _HandednessProvider extends InheritedNotifier<ValueNotifier<Handedness>> {
  const _HandednessProvider({required super.notifier, required super.child});
}

class HandednessSettingsTile extends StatelessWidget {
  const HandednessSettingsTile({super.key, required this.state, this.onChange});

  final Handedness state;
  final void Function(Handedness state)? onChange;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListTile(
      title: Text(l10n.settingsHandedness),
      subtitle: Text(state.title(l10n)),
      leading: const Icon(Icons.front_hand),
      onTap: () => showDialog(
        context: context,
        builder: (context) =>
            HandednessDialog(state: state, onChange: onChange),
      ),
    );
  }
}

/// Picks the hand that quick actions gather towards.
///
/// Each option previews where buttons land for that choice, so the
/// effect of the setting is visible without trying it out.
class HandednessDialog extends StatelessWidget {
  const HandednessDialog({super.key, required this.state, this.onChange});

  final Handedness state;
  final void Function(Handedness state)? onChange;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SimpleDialog(
      title: Text(l10n.settingsHandedness),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Text(
            l10n.settingsHandednessHint,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            children: Handedness.values
                .map(
                  (value) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: HandednessOption(
                        value: value,
                        selected: value == state,
                        onTap: () {
                          onChange!(value);
                          Navigator.of(context).maybePop();
                        },
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class HandednessOption extends StatelessWidget {
  const HandednessOption({
    super.key,
    required this.value,
    required this.selected,
    this.onTap,
  });

  final Handedness value;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color accent = theme.colorScheme.secondary;
    final BorderRadius radius = BorderRadius.circular(12);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: Material(
            color: theme.cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: radius,
              side: BorderSide(
                color: selected ? accent : theme.dividerColor,
                width: selected ? 2 : 1,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Transform.flip(
                    flipX: value == Handedness.left,
                    child: Icon(
                      Icons.front_hand,
                      size: 40,
                      color: selected ? accent : theme.iconTheme.color,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // A miniature of where quick actions land for this hand,
                  // mirroring the floating button corner it picks.
                  _HandednessPreview(hand: value, accent: accent),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value.title(AppLocalizations.of(context)),
          style: selected
              ? theme.textTheme.bodyMedium?.copyWith(color: accent)
              : theme.textTheme.bodyMedium,
        ),
      ],
    );
  }
}

/// A small screen outline whose dot sits on the corner quick actions use.
class _HandednessPreview extends StatelessWidget {
  const _HandednessPreview({required this.hand, required this.accent});

  final Handedness hand;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: 4,
            // The end corner of the preview follows the reading direction,
            // so it stays truthful in rtl locales.
            right: hand == Handedness.right ? 4 : null,
            left: hand == Handedness.left ? 4 : null,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(shape: BoxShape.circle, color: accent),
            ),
          ),
        ],
      ),
    );
  }
}
