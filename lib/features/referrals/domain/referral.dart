/// Where a referred person has got to.
enum ReferralStage {
  joined('Joined'),
  purchased('Purchased'),
  repeat('Repeat');

  const ReferralStage(this.label);

  final String label;
}

/// One person who signed up with the member's code.
class Referral {
  const Referral({
    required this.name,
    required this.stage,
    required this.when,
    required this.pointsEarned,
    this.avatarUrl,
  });

  final String name;
  final ReferralStage stage;
  final String when;
  final int pointsEarned;
  final String? avatarUrl;

  static const List<Referral> placeholder = [
    Referral(
      name: 'Maria Cruz',
      stage: ReferralStage.repeat,
      when: 'Ordered twice · 2 days ago',
      pointsEarned: 34,
    ),
    Referral(
      name: 'Paolo Mendoza',
      stage: ReferralStage.purchased,
      when: 'First order · 5 days ago',
      pointsEarned: 19,
    ),
    Referral(
      name: 'Jen Reyes',
      stage: ReferralStage.purchased,
      when: 'First order · 1 week ago',
      pointsEarned: 11,
    ),
    Referral(
      name: 'Kim Bautista',
      stage: ReferralStage.joined,
      when: 'Joined · 1 week ago',
      pointsEarned: 0,
    ),
    Referral(
      name: 'Ana Villanueva',
      stage: ReferralStage.joined,
      when: 'Joined · 2 weeks ago',
      pointsEarned: 0,
    ),
  ];
}
