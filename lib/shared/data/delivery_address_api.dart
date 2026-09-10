import '../../core/errors/result.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/utils/json_reader.dart';
import '../domain/delivery_address.dart';

/// [DeliveryAddressRepository] over the API.
final class DeliveryAddressApi implements DeliveryAddressRepository {
  const DeliveryAddressApi(this._client);

  final ApiClient _client;

  @override
  Future<Result<DeliveryAddress?>> read() =>
      _client.get(ApiEndpoints.myAddress, parse: parseAddress);

  @override
  Future<Result<void>> save(DeliveryAddress address) => _client.put(
    ApiEndpoints.myAddress,
    body: {
      'full_name': address.fullName,
      'email': address.email,
      'mobile': address.mobile,
      'street': address.street,
      'purok': address.purok,
      'barangay': address.barangay,
      'city': address.city,
      'province': address.province,
      'postal_code': address.postalCode,
      'landmark': address.landmark,
    },
    parse: (_) {},
  );

  /// `{ address: {...} | null }` — null while the member has set none.
  static DeliveryAddress? parseAddress(Object? json) {
    final address = JsonReader.of(json).optionalObject('address');
    if (address == null) return null;
    return DeliveryAddress(
      fullName: address.string('full_name'),
      email: address.string('email'),
      mobile: address.string('mobile'),
      street: address.string('street'),
      purok: address.optionalString('purok') ?? '',
      barangay: address.string('barangay'),
      city: address.string('city'),
      province: address.string('province'),
      postalCode: address.string('postal_code'),
      landmark: address.optionalString('landmark') ?? '',
    );
  }
}
