import '../../core/errors/result.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/utils/json_reader.dart';
import '../domain/orders.dart';

/// [OrdersRepository] over the API.
final class OrdersApi implements OrdersRepository {
  const OrdersApi(this._client);

  final ApiClient _client;

  @override
  Future<Result<OrderReceipt>> place({
    required String productId,
    required int quantity,
  }) => _client.post(
    ApiEndpoints.myOrders,
    body: {'product_id': productId, 'quantity': quantity},
    parse: parseReceipt,
  );

  static OrderReceipt parseReceipt(Object? json) {
    final receipt = JsonReader.of(json);
    return OrderReceipt(
      reference: receipt.string('reference'),
      total: receipt.string('total'),
    );
  }
}
