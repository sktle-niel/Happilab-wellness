import '../../core/errors/result.dart';

/// What an order may be, up to ten of one product at a time.
abstract final class OrderLimits {
  static const int minQuantity = 1;
  static const int maxQuantity = 10;
}

/// What the programme answers once an order is placed.
class OrderReceipt {
  const OrderReceipt({required this.reference, required this.total});

  /// The order number the member quotes to the desk.
  final String reference;

  /// The amount, formatted by the programme.
  final String total;
}

/// The programme's orders, wherever they are kept.
abstract interface class OrdersRepository {
  /// Places an order for [quantity] of the product, delivered to the member's
  /// saved address. Refused when no address is set.
  Future<Result<OrderReceipt>> place({
    required String productId,
    required int quantity,
  });
}
