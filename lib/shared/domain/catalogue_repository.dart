import '../../core/errors/result.dart';
import 'catalogue.dart';

/// The products a member can share.
abstract interface class CatalogueRepository {
  Future<Result<List<Product>>> products();
}
