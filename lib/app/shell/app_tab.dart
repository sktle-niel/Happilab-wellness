import 'package:flutter/material.dart';

/// The five destinations that live behind the bottom bar.
///
/// Everything else in the app is pushed on top of a tab and has a back button;
/// these are the places a member returns to.
enum AppTab {
  home('Home', Icons.home_outlined),
  feed('Feed', Icons.explore_outlined),
  refer('Refer', Icons.card_giftcard_rounded),
  products('Products', Icons.storefront_outlined),
  profile('Profile', Icons.person_outline_rounded);

  const AppTab(this.label, this.icon);

  final String label;
  final IconData icon;

  /// The raised centre button in the design.
  bool get isFeature => this == AppTab.refer;
}
