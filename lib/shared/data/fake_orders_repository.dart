import '../../core/errors/result.dart';
import '../domain/orders.dart';

/// Orders that go nowhere, numbered in turn for the session.
final class FakeOrdersRepository implements OrdersRepository {
  FakeOrdersRepository();

  int _placed = 0;

  @override
  Future<Result<OrderReceipt>> place({
    required String productId,
    required int quantity,
  }) async {
    _placed += 1;
    final number = _placed.toString().padLeft(4, '0');
    return Success(OrderReceipt(reference: 'FC-DEMO$number', total: '—'));
  }
}
