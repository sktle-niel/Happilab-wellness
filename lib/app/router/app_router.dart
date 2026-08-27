import 'package:flutter/material.dart';

import '../../features/auth/presentation/create_account_screen.dart';
import '../../features/auth/presentation/sign_in_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/onboarding/presentation/product_intro_screen.dart';
import '../../features/onboarding/presentation/splash_screen.dart';
import '../../features/referrals/presentation/how_it_works_screen.dart';
import '../../features/referrals/presentation/my_referrals_screen.dart';
import '../../shared/widgets/app_scaffold.dart';
import 'app_routes.dart';

/// Central route table.
///
/// Navigation lives here rather than inside screens: a feature stays unaware of
/// what comes before or after it, and an unknown deep link lands somewhere sane
/// instead of crashing.
abstract final class AppRouter {
  static Route<void> onGenerateRoute(RouteSettings settings) =>
      MaterialPageRoute<void>(
        settings: settings,
        builder: switch (settings.name) {
          AppRoutes.splash => (_) => const SplashScreen(),
          AppRoutes.productIntro => (_) => const ProductIntroScreen(),
          AppRoutes.onboarding => (_) => const OnboardingScreen(),
          AppRoutes.signIn => (_) => const SignInScreen(),
          AppRoutes.createAccount => (_) => const CreateAccountScreen(),
          AppRoutes.home => (_) => const HomeScreen(),
          AppRoutes.howItWorks => (_) => const HowItWorksScreen(),
          AppRoutes.myReferrals => (_) => const MyReferralsScreen(),
          _ => (_) => const _RouteNotFoundScreen(),
        },
      );
}

class _RouteNotFoundScreen extends StatelessWidget {
  const _RouteNotFoundScreen();

  @override
  Widget build(BuildContext context) => const AppScaffold(
    title: 'Not found',
    body: Center(child: Text('This screen does not exist.')),
  );
}
