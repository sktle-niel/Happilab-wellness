import '../../core/errors/result.dart';
import '../domain/catalogue.dart';
import '../domain/catalogue_repository.dart';

/// The bundled showcase, until the API serves the catalogue.
final class FakeCatalogueRepository implements CatalogueRepository {
  const FakeCatalogueRepository();

  @override
  Future<Result<List<Product>>> products() async =>
      const Success(Product.showcase);
}
