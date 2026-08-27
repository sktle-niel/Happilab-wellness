import 'package:flutter/material.dart';

import '../../features/community/presentation/news_feed_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/referrals/presentation/my_referrals_screen.dart';
import '../../features/rewards/presentation/rewards_screen.dart';
import '../theme/app_colors.dart';
import 'app_shell_scope.dart';
import 'app_tab.dart';
import 'widgets/faith_nav_bar.dart';

/// The signed-in app: five destinations under one floating bar.
///
/// An [IndexedStack] rather than a swapped child, so a tab keeps its scroll
/// position and its in-progress form when the member looks at another one.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  AppTab _selected = AppTab.home;

  void _select(AppTab tab) {
    if (tab == _selected) return;
    setState(() => _selected = tab);
  }

  @override
  Widget build(BuildContext context) => AppShellScope(
    selectedTab: _selected,
    onSelect: _select,
    child: Scaffold(
      backgroundColor: AppColors.canvas,
      body: Stack(
        children: [
          IndexedStack(
            index: _selected.index,
            children: const [
              HomeScreen(),
              NewsFeedScreen(),
              MyReferralsScreen(),
              RewardsScreen(),
              ProfileScreen(),
            ],
          ),
          Positioned(
            left: 14,
            right: 14,
            bottom: 14,
            child: FaithNavBar(selected: _selected, onSelect: _select),
          ),
        ],
      ),
    ),
  );
}
