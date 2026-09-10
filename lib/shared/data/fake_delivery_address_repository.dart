import '../../core/errors/result.dart';
import '../domain/delivery_address.dart';

/// An address kept for the session, starting with none — the way a new
/// member starts — or with whatever a test seeds.
final class FakeDeliveryAddressRepository implements DeliveryAddressRepository {
  FakeDeliveryAddressRepository({DeliveryAddress? initial})
    : _address = initial;

  DeliveryAddress? _address;

  @override
  Future<Result<DeliveryAddress?>> read() async => Success(_address);

  @override
  Future<Result<void>> save(DeliveryAddress address) async {
    _address = address;
    return const Success<void>(null);
  }
}
