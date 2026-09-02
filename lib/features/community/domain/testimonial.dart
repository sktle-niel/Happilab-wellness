import '../../../shared/domain/catalogue.dart';

/// A member's story, as shown on Member stories.
///
/// Three shapes come out of one model: words alone, a clip alone, or a clip
/// with the words underneath. What a story carries decides how it is drawn, so
/// a card never has to be told which kind it is.
class Testimonial {
  const Testimonial({
    required this.name,
    required this.credential,
    required this.date,
    this.headline,
    this.quote,
    this.videoAsset,
    this.source,
    this.rating = 5,
  }) : assert(
         headline != null || videoAsset != null,
         'A story needs words, a clip, or both',
       );

  final String name;

  /// What earns them the hearing — their standing in the programme.
  final String credential;

  /// Display copy, like every other date in the app until an API sends one.
  final String date;

  /// The line the card leads with, set bold.
  final String? headline;

  /// The rest of the quote, under the headline.
  final String? quote;

  /// A clip in `assets/video/`. Null for a story told in words alone.
  final String? videoAsset;

  /// Where the member posted it, when they posted it somewhere.
  final SharePlatform? source;

  final int rating;

  bool get hasVideo => videoAsset != null;

  bool get hasWords => headline != null;

  static const List<Testimonial> placeholder = [
    Testimonial(
      name: 'Maria Cruz',
      credential: '₱4,200 earned',
      date: '12 Aug 2026',
      headline: 'I only shared my code in our family group chat.',
      quote: 'Three orders later I had enough for a week of groceries.',
    ),
    Testimonial(
      name: 'Jen Reyes',
      credential: '₱7,800 earned',
      date: '4 Aug 2026',
      headline: 'The soap sells itself, honestly.',
      quote: 'I just post my routine and people ask me for the code.',
      videoAsset: 'assets/video/onboarding-routine.mp4',
      source: SharePlatform.tiktok,
    ),
    Testimonial(
      name: 'Ana Villanueva',
      credential: '₱2,600 earned',
      date: '28 Jul 2026',
      videoAsset: 'assets/video/onboarding-lotion.mp4',
      source: SharePlatform.tiktok,
    ),
    Testimonial(
      name: 'Paolo Mendoza',
      credential: '₱1,950 earned',
      date: '19 Jul 2026',
      headline: 'Cash out went to my GCash the same day.',
      quote: 'That is when I started taking this seriously.',
    ),
    Testimonial(
      name: 'Kim Bautista',
      credential: '₱3,400 earned',
      date: '2 Jul 2026',
      videoAsset: 'assets/video/onboarding-coffee.mp4',
      source: SharePlatform.shopee,
    ),
  ];
}
