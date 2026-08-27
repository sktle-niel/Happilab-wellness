/// Headline numbers of the referral programme.
///
/// Constants for now because there is no backend to quote them from; when one
/// exists these become a fetched model and every screen reads it from here.
abstract final class ProgramTerms {
  /// Share of each referred sale that the referrer earns.
  static const String earnRate = '5–7%';

  static const String pointsConversion = '1,000 points = ₱1,000';
}

/// A product shown in the intro showcase.
class ProductHighlight {
  const ProductHighlight({
    required this.name,
    required this.blurb,
    required this.price,
    required this.pointsRange,
    required this.imageUrl,
  });

  final String name;
  final String blurb;

  /// Formatted for display — pricing is presentation copy until the catalogue
  /// comes from an API with a currency and an amount.
  final String price;
  final String pointsRange;

  /// Stock photography from the design canvas. Replace with product shots in
  /// `assets/images/` before shipping — a remote URL is a blank card offline.
  final String imageUrl;

  String get earnLine => '$price · Earn $pointsRange pts per sale';

  /// The showcase, in the order the design lists it.
  static const List<ProductHighlight> showcase = [
    ProductHighlight(
      name: 'Sakura Glow Soap',
      blurb: 'Gentle wellness soap with sunscreen benefits',
      price: '₱150',
      pointsRange: '7–11',
      imageUrl: 'https://images.unsplash.com/photo-1584305574647-0cc949a2bb9f?w=400&q=80',
    ),
    ProductHighlight(
      name: 'Sunscreen SPF50',
      blurb: 'Daily protection made for everyday glow',
      price: '₱380',
      pointsRange: '19–27',
      imageUrl: 'https://images.unsplash.com/photo-1526947425960-945c6e72858f?w=400&q=80',
    ),
    ProductHighlight(
      name: 'Faith Coffee',
      blurb: 'Wellness blend with real benefits — coming soon',
      price: '₱520',
      pointsRange: '26–36',
      imageUrl: 'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=400&q=80',
    ),
    ProductHighlight(
      name: 'Herbal Tea',
      blurb: 'Tea with benefits for everyday balance — coming soon',
      price: '₱450',
      pointsRange: '23–32',
      imageUrl: 'https://images.unsplash.com/photo-1544787219-7f47ccb76574?w=400&q=80',
    ),
  ];
}
