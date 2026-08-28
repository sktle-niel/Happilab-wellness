import 'package:flutter/material.dart';

import '../../features/auth/presentation/create_account_screen.dart';
import '../../features/auth/presentation/sign_in_screen.dart';
import '../../features/community/presentation/news_feed_screen.dart';
import '../../features/community/presentation/suggestions_screen.dart';
import '../../features/community/presentation/testimonials_screen.dart';
import '../../features/notifications/presentation/notifications_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/onboarding/presentation/product_intro_screen.dart';
import '../../features/onboarding/presentation/splash_screen.dart';
import '../../features/profile/presentation/account_activity_screen.dart';
import '../../features/profile/presentation/edit_profile_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/referrals/presentation/how_it_works_screen.dart';
import '../../features/referrals/presentation/my_referrals_screen.dart';
import '../../features/rewards/presentation/edit_payout_number_screen.dart';
import '../../features/rewards/presentation/rewards_screen.dart';
import '../../features/support/presentation/help_center_screen.dart';
import '../../features/support/presentation/terms_screen.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../shell/app_shell.dart';
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
          AppRoutes.home => (_) => const AppShell(),
          AppRoutes.howItWorks => (_) => const HowItWorksScreen(),
          AppRoutes.myReferrals => (_) => const MyReferralsScreen(),
          AppRoutes.rewards => (_) => const RewardsScreen(),
          AppRoutes.editPayoutNumber => (_) => const EditPayoutNumberScreen(),
          AppRoutes.newsFeed => (_) => const NewsFeedScreen(),
          AppRoutes.testimonials => (_) => const TestimonialsScreen(),
          AppRoutes.suggestions => (_) => const SuggestionsScreen(),
          AppRoutes.notifications => (_) => const NotificationsScreen(),
          AppRoutes.profile => (_) => const ProfileScreen(),
          AppRoutes.editProfile => (_) => const EditProfileScreen(),
          AppRoutes.accountActivity => (_) => const AccountActivityScreen(),
          AppRoutes.helpCenter => (_) => const HelpCenterScreen(),
          AppRoutes.terms => (_) => const TermsScreen(),
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
