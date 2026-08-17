/// Reduce-motion support (`F-A11Y-005`, docs/24-DESIGN-SYSTEM.md
/// §accessibility-baseline).
///
/// The system setting arrives as `MediaQuery.disableAnimations`, which Flutter
/// populates from "Remove animations" on Android and "Reduce Motion" on iOS.
/// Every animation in the app is expected to route through here rather than
/// reading the flag itself, so that honouring it is one decision made once
/// instead of a rule each new widget has to remember.
///
/// Note what is *not* here: nothing removes a state change, only its
/// transition. Reduce motion means arriving instantly, never arriving less.
library;

import 'package:flutter/material.dart';

/// Whether the system asks for reduced motion.
bool prefersReducedMotion(BuildContext context) =>
    MediaQuery.maybeDisableAnimationsOf(context) ?? false;

/// [duration], or zero when the system asks for reduced motion.
Duration motionDuration(BuildContext context, Duration duration) =>
    prefersReducedMotion(context) ? Duration.zero : duration;

/// Route transitions, honouring the same setting app-wide.
///
/// A [PageTransitionsBuilder] rather than per-route configuration: routes are
/// declared in one router (`F-NAV-002`) but pushed from everywhere, and a rule
/// each call site has to opt into is a rule that decays. [delegate] keeps the
/// platform's own transition for everyone who has not asked for less.
class ReduceMotionPageTransitionsBuilder extends PageTransitionsBuilder {
  const ReduceMotionPageTransitionsBuilder(this.delegate);

  final PageTransitionsBuilder delegate;

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (prefersReducedMotion(context)) return child;
    return delegate.buildTransitions<T>(
      route,
      context,
      animation,
      secondaryAnimation,
      child,
    );
  }
}
