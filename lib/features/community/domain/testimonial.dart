/// A member's story, as shown on Member stories.
class Testimonial {
  const Testimonial({
    required this.quote,
    required this.name,
    required this.detail,
    this.rating = 5,
  });

  final String quote;
  final String name;

  /// What they have earned or how long they have been a member.
  final String detail;
  final int rating;

  static const List<Testimonial> placeholder = [
    Testimonial(
      quote:
          'I only shared my code in our family group chat. Three orders later '
          'I had enough for a week of groceries.',
      name: 'Maria C.',
      detail: 'Member since March · ₱4,200 earned',
    ),
    Testimonial(
      quote:
          'The soap sells itself, honestly. I just post my routine and people '
          'ask for the code.',
      name: 'Jen R.',
      detail: 'Member since January · ₱7,800 earned',
    ),
    Testimonial(
      quote:
          'Cash out went to my GCash the same day. That is when I started '
          'taking it seriously.',
      name: 'Paolo M.',
      detail: 'Member since June · ₱1,950 earned',
    ),
  ];
}
