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

  /// The age confirmation page. It opens the pager: on an adults-only
  /// site nothing, not even the language picker, may come before it,
  /// and every way into the login step — the next buttons, swiping —
  /// leads through it, which stays out of reach until confirmed.
  static const int gatePage = 0;
  bool adultConfirmed = false;

  void complete() => context.read<Settings>().onboardingSeen.value = true;

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
                          AdultGateStep(onConfirm: confirmAge),
                          const WelcomeLanguageStep(),
                          const ThemeStep(),
                          const QualityStep(),
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
                        // The gate page keeps the next button hidden
                        // while it is unconfirmed — its own buttons
                        // lead the way; after confirming, the pager
                        // button returns for users who swipe back.
                        if (!isLast && (!onGate || adultConfirmed))
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
