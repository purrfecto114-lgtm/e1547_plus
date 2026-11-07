import 'package:e1547/app/app.dart';
import 'package:e1547/identity/identity.dart';
import 'package:e1547/l10n/app_localizations.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';

/// Introduces the app and picks its language in one step.
///
/// The welcome text cross-fades through the language chips below it, so
/// the choice previews itself; unsupported system languages resolve to
/// english before this page ever renders them. The languages sit in a
/// compact chip grid instead of a tall list, so all of them stay on
/// screen instead of hiding behind the bottom bar, and a scrollbar
/// stands by for screens that still cannot fit everything.
class WelcomeLanguageStep extends StatefulWidget {
  const WelcomeLanguageStep({super.key});

  @override
  State<WelcomeLanguageStep> createState() => _WelcomeLanguageStepState();
}

class _WelcomeLanguageStepState extends State<WelcomeLanguageStep> {
  final ScrollController scroll = ScrollController();

  @override
  void dispose() {
    scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Settings settings = context.watch<Settings>();
    final l10n = AppLocalizations.of(context);
    final List<({String? value, String label})> choices = [
      (value: null, label: l10n.languageSystemDefault),
      ...appLanguages.map(
        (language) => (value: language.value, label: language.label),
      ),
    ];
    return Center(
      child: Scrollbar(
        controller: scroll,
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: scroll,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _EntranceAnimation(child: AppIcon(radius: 44)),
              const SizedBox(height: 20),
              AnimatedSwitcher(
                duration: defaultAnimationDuration,
                child: Column(
                  // The locale keys the switch child, so a language choice
                  // fades the introduction into its new language instead
                  // of snapping.
                  key: ValueKey(Localizations.localeOf(context)),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.onboardingWelcomeTitle(AppInfo.instance.appName),
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.onboardingWelcomeBody,
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: Theme.of(context).dividerColor,
                      endIndent: 8,
                    ),
                  ),
                  Text(
                    l10n.onboardingLanguageTitle,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: Theme.of(context).dividerColor,
                      indent: 8,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ValueListenableBuilder<String?>(
                valueListenable: settings.language,
                builder: (context, value, child) => Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final (:value, :label) in choices)
                      ChoiceChip(
                        label: Text(label),
                        selected: value == settings.language.value,
                        onSelected: (_) => settings.language.value = value,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Plays a gentle scale and fade entrance once when first built.
class _EntranceAnimation extends StatelessWidget {
  const _EntranceAnimation({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutBack,
      builder: (context, value, child) => Opacity(
        opacity: value.clamp(0, 1),
        child: Transform.scale(scale: 0.7 + 0.3 * value, child: child),
      ),
      child: child,
    );
  }
}

/// Picks the default quality of videos and thumbnails.
///
/// Both pickers read as the same three tiers, mirroring the settings
/// they preselect.
class QualityStep extends StatelessWidget {
  const QualityStep({super.key});

  @override
  Widget build(BuildContext context) {
    Settings settings = context.watch<Settings>();
    final l10n = AppLocalizations.of(context);
    return OnboardingScroll(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.video_settings, size: 48),
          const SizedBox(height: 16),
          Text(
            l10n.onboardingQualityTitle,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.onboardingQualityBody,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ValueListenableBuilder<VideoResolution>(
            valueListenable: settings.videoResolution,
            builder: (context, value, child) => _QualityPicker(
              label: l10n.videoQuality,
              options: [
                for (final resolution in VideoResolution.values)
                  (
                    value: resolution,
                    label: resolution.localizedTitle(context),
                  ),
              ],
              selected: value,
              onSelect: (tier) =>
                  settings.videoResolution.value = tier as VideoResolution,
            ),
          ),
          const SizedBox(height: 16),
          ValueListenableBuilder<TileSize>(
            valueListenable: settings.tileSize,
            builder: (context, value, child) => _QualityPicker(
              label: l10n.thumbnailQuality,
              options: [
                for (final size in TileSize.values)
                  (value: size, label: size.localizedTitle(context)),
              ],
              selected: value,
              onSelect: (tier) => settings.tileSize.value = tier as TileSize,
            ),
          ),
        ],
      ),
    );
  }
}

/// A centered scroll view with a visible thumb, like the welcome step
/// uses one. The scrollbar gets its own controller: the onboarding page
/// nests scroll views, and a scrollbar on the primary controller would
/// find more than one scroll position attached to it.
class OnboardingScroll extends StatefulWidget {
  const OnboardingScroll({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  State<OnboardingScroll> createState() => _OnboardingScrollState();
}

class _OnboardingScrollState extends State<OnboardingScroll> {
  final ScrollController scroll = ScrollController();

  @override
  void dispose() {
    scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Scrollbar(
        controller: scroll,
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: scroll,
          padding: widget.padding,
          child: widget.child,
        ),
      ),
    );
  }
}

/// A labeled row of tier choices.
class _QualityPicker extends StatelessWidget {
  const _QualityPicker({
    required this.label,
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  final String label;
  final List<({Object value, String label})> options;
  final Object selected;
  final ValueChanged<Object> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Row(
          children: [
            for (final option in options) ...[
              Expanded(
                child: Material(
                  color: option.value == selected
                      ? theme.colorScheme.secondaryContainer
                      : theme.cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: option.value == selected
                          ? theme.colorScheme.secondary
                          : theme.dividerColor,
                      width: option.value == selected ? 2 : 1,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => onSelect(option.value),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Center(child: Text(option.label)),
                    ),
                  ),
                ),
              ),
              if (option != options.last) const SizedBox(width: 8),
            ],
          ],
        ),
      ],
    );
  }
}

class ThemeStep extends StatelessWidget {
  const ThemeStep({super.key});

  @override
  Widget build(BuildContext context) {
    Settings settings = context.watch<Settings>();
    final l10n = AppLocalizations.of(context);
    // Like the other steps, the swatch grid scrolls when a short or
    // landscape screen cannot fit it, instead of overflowing.
    return OnboardingScroll(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              l10n.onboardingThemeTitle,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.onboardingThemeBody,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ValueListenableBuilder(
              valueListenable: settings.theme,
              builder: (context, current, child) => Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: AppTheme.values
                    .map(
                      (theme) => _ThemeSwatch(
                        theme: theme,
                        selected: theme == current,
                        onTap: () => settings.theme.value = theme,
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeSwatch extends StatelessWidget {
  const _ThemeSwatch({
    required this.theme,
    required this.selected,
    required this.onTap,
  });

  final AppTheme theme;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    Color border = selected
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).dividerColor;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 56,
              width: 56,
              decoration: theme.swatch.copyWith(
                border: Border.all(color: border, width: selected ? 3 : 1),
              ),
              child: selected
                  ? Icon(
                      Icons.check,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : null,
            ),
            const SizedBox(height: 8),
            Text(localizedThemeName(context, theme)),
          ],
        ),
      ),
    );
  }
}

class LoginStep extends StatelessWidget {
  const LoginStep({
    super.key,
    required this.initialHost,
    required this.onComplete,
  });

  final String initialHost;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    return OnboardingScroll(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppLocalizations.of(context).onboardingLoginTitle,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          AccountForm(initialHost: initialHost, onSubmitted: onComplete),
        ],
      ),
    );
  }
}
