import '../../core/errors/result.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/utils/json_reader.dart';
import '../domain/catalogue.dart';
import '../domain/catalogue_repository.dart';

/// [CatalogueRepository] over the API. The catalogue changes by the day, not
/// the minute, so it is cached and served stale when the backend is down —
/// a member can still share what they saw an hour ago.
final class CatalogueApi implements CatalogueRepository {
  const CatalogueApi(this._client);

  static const Duration _maxAge = Duration(minutes: 30);

  final ApiClient _client;

  @override
  Future<Result<List<Product>>> products() =>
      _client.get(ApiEndpoints.products, parse: parseProducts, maxAge: _maxAge);

  static List<Product> parseProducts(Object? json) =>
      JsonReader.listOf(json, _product);

  static Product _product(JsonReader item) {
    final badge = item.optionalString('badge');
    return Product(
      name: item.string('name'),
      blurb: item.string('blurb'),
      price: item.string('price'),
      points: item.integer('points'),
      imageUrl: item.string('image_url'),
      badge: badge == null
          ? null
          : item.enumerated('badge', ProductBadge.values),
      storeLinks: _storeLinks(item.optionalObject('store_links')),
    );
  }

  /// Links keyed by platform name. A platform the app does not know is
  /// skipped rather than refused — stores come and go.
  static Map<SharePlatform, String> _storeLinks(JsonReader? links) {
    if (links == null) return const {};
    return {
      for (final platform in SharePlatform.values)
        platform: ?links.optionalString(platform.name),
    };
  }
}
