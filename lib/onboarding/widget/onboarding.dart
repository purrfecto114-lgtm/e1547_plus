import 'package:e1547/identity/identity.dart';
import 'package:e1547/l10n/app_localizations.dart';
import 'package:e1547/onboarding/onboarding.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Needs its own navigator for overlay widgets.
    return Navigator(
      onGenerateRoute: (_) =>
          MaterialPageRoute(builder: (context) => const _OnboardingPager()),
    );
  }
}

class _OnboardingPager extends StatefulWidget {
  const _OnboardingPager();

  @override
  State<_OnboardingPager> createState() => _OnboardingPagerState();
}

class _OnboardingPagerState extends State<_OnboardingPager> {
  final PageController controller = PageController();
  int page = 0;
  static const int pages = 5;

  /// The age confirmation page. Every way into the login step — the next
  /// buttons, swiping, the skip shortcut — leads through it, and the
  /// login step itself stays out of reach until it has been confirmed.
  static const int gatePage = pages - 2;
  bool adultConfirmed = false;

  void complete() => context.read<Settings>().onboardingSeen.value = true;

  /// Skipping ends up browsing as an anonymous guest on an adults-only
  /// site, so the shortcut leads onto the age confirmation page like
  /// every other way to the login does.
  void skip() => controller.jumpToPage(gatePage);

  void next() {
    // The page's own buttons already hide the way forward; the pager
    // repeats the requirement in depth.
    if (page == gatePage && !adultConfirmed) return;
    controller.nextPage(duration: defaultAnimationDuration, curve: Curves.ease);
  }

  void back() => controller.previousPage(
    duration: defaultAnimationDuration,
    curve: Curves.ease,
  );

  void confirmAge() {
    setState(() => adultConfirmed = true);
    next();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    String host = context.watch<IdentityClient>().identity.host;
    bool isLast = page == pages - 1;
    bool onGate = page == gatePage;
    return KeyboardDismisser(
      child: LimitedWidthLayout(
        child: Scaffold(
          body: SafeArea(
            child: Center(
              child: LimitedWidthChild(
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: onGate || adultConfirmed
                            ? null
                            : TextButton(
                                onPressed: skip,
                                child: Text(l10n.onboardingSkip),
                              ),
                      ),
                    ),
                    Expanded(
                      child: PageView(
                        controller: controller,
                        // Until the age page has been confirmed the pager
                        // only moves through its own buttons, so neither
                        // a swipe nor a fling can slip past the gate.
                        physics: adultConfirmed
                            ? null
                            : const NeverScrollableScrollPhysics(),
                        onPageChanged: (value) => setState(() => page = value),
                        children: [
                          const WelcomeLanguageStep(),
                          const ThemeStep(),
                          const QualityStep(),
                          AdultGateStep(onConfirm: confirmAge, onDeny: back),
                          LoginStep(initialHost: host, onComplete: complete),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar: SafeArea(
            child: LimitedWidthChild(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _PageDots(count: pages, active: page),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (page > 0)
                          TextButton(
                            onPressed: back,
                            child: Text(l10n.onboardingBack),
                          ),
                        const Spacer(),
                        if (!isLast && !onGate)
                          ElevatedButton(
                            onPressed: next,
                            child: Text(l10n.onboardingNext),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.active});

  final int count;
  final int active;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count,
        (index) => AnimatedContainer(
          duration: defaultAnimationDuration,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index == active
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).dividerColor,
          ),
        ),
      ),
    );
  }
}
