/// The badge a product carries over its photo, in the design's wording.
enum ProductBadge {
  topSale('TOP SALE'),
  newArrival('NEW'),
  comingSoon('SOON');

  const ProductBadge(this.label);

  final String label;
}

/// Storefronts a product can be shared to, in the order the sheet shows them.
enum SharePlatform {
  tiktok('TikTok', 'tiktok', 'https://www.tiktok.com/search?q='),
  shopee('Shopee', 'shopee', 'https://shopee.ph/search?keyword='),
  lazada('Lazada', 'lazada', 'https://www.lazada.com.ph/catalog/?q=');

  const SharePlatform(this.label, this._logo, this._searchUrl);

  final String label;
  final String _logo;
  final String _searchUrl;

  String get logoAsset => 'assets/images/share/$_logo.png';
}

/// A product in the catalogue, as the intro showcase and the home grid
/// both present it.
class Product {
  const Product({
    required this.name,
    required this.blurb,
    required this.price,
    required this.pointsRange,
    required this.imageUrl,
    this.badge,
    this.storeLinks = const {},
  });

  /// Listing URLs per storefront, once the catalogue has them. A store search
  /// for the product name stands in for any that are missing.
  final Map<SharePlatform, String> storeLinks;

  /// Where a share lands on [platform], with the member's code attached so
  /// the sale is credited to them.
  Uri shareLink(SharePlatform platform, String referralCode) {
    final base = Uri.parse(
      storeLinks[platform] ??
          '${platform._searchUrl}${Uri.encodeQueryComponent(name)}',
    );
    return base.replace(
      queryParameters: {...base.queryParameters, 'ref': referralCode},
    );
  }

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

  /// Compact form for the two-column home grid.
  String get earnShort => 'Earn $pointsRange pts';

  final ProductBadge? badge;

  /// The catalogue, in the order the design lists it.
  static const List<Product> showcase = [
    Product(
      name: 'Sakura Glow Soap',
      blurb: 'Gentle wellness soap with sunscreen benefits',
      price: '₱150',
      pointsRange: '7–11',
      badge: ProductBadge.topSale,
      imageUrl: 'https://images.unsplash.com/photo-1584305574647-0cc949a2bb9f?w=400&q=80',
    ),
    Product(
      name: 'Sunscreen SPF50',
      blurb: 'Daily protection made for everyday glow',
      price: '₱380',
      pointsRange: '19–27',
      badge: ProductBadge.newArrival,
      imageUrl: 'https://images.unsplash.com/photo-1526947425960-945c6e72858f?w=400&q=80',
    ),
    Product(
      name: 'Falcon Coffee',
      blurb: 'Wellness blend with real benefits — coming soon',
      price: '₱520',
      pointsRange: '26–36',
      badge: ProductBadge.comingSoon,
      imageUrl: 'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=400&q=80',
    ),
    Product(
      name: 'Herbal Tea',
      blurb: 'Tea with benefits for everyday balance — coming soon',
      price: '₱450',
      pointsRange: '23–32',
      badge: ProductBadge.comingSoon,
      imageUrl: 'https://images.unsplash.com/photo-1544787219-7f47ccb76574?w=400&q=80',
    ),
  ];
}
