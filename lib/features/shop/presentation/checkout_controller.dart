import 'package:flutter/foundation.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/errors/result.dart';
import '../../../shared/domain/catalogue.dart';
import '../../../shared/domain/delivery_address.dart';
import '../../../shared/domain/orders.dart';

/// One order in the making: the product, how many, and the address it goes
/// to — drawn from the store, so an address set on the way here shows up
/// without a reload.
class CheckoutController extends ChangeNotifier {
  CheckoutController({
    required this.product,
    required this._addresses,
    required this._orders,
  }) {
    _addresses.addListener(notifyListeners);
  }

  final Product product;
  final DeliveryAddressStore _addresses;
  final OrdersRepository _orders;

  int _quantity = OrderLimits.minQuantity;
  bool _isPlacing = false;

  int get quantity => _quantity;
  bool get isPlacing => _isPlacing;

  bool get canAddOne => _quantity < OrderLimits.maxQuantity;
  bool get canRemoveOne => _quantity > OrderLimits.minQuantity;

  DeliveryAddress? get address => _addresses.address;
  bool get hasAddress => _addresses.hasAddress;
  bool get isAddressLoaded => _addresses.isLoaded;

  /// Why the address could not be read, or null.
  AppException? get addressError => _addresses.error;

  /// The order can go once there is somewhere to send it and nothing is in
  /// flight — the button is inert otherwise.
  bool get canPlace => hasAddress && !_isPlacing;

  /// The price line: the unit price alone for one, the count beside it for
  /// more. The total is the programme's to state, on the receipt.
  String get priceLine =>
      _quantity == 1 ? product.price : '${product.price} × $_quantity';

  Future<void> loadAddress() => _addresses.load();

  void addOne() => _setQuantity(_quantity + 1);

  void removeOne() => _setQuantity(_quantity - 1);

  void _setQuantity(int next) {
    if (next < OrderLimits.minQuantity || next > OrderLimits.maxQuantity) {
      return;
    }
    _quantity = next;
    notifyListeners();
  }

  /// Places the order. A second call while one is in flight does nothing.
  Future<Result<OrderReceipt>?> place() async {
    if (!canPlace) return null;
    _isPlacing = true;
    notifyListeners();
    final outcome = await _orders.place(
      productId: product.id,
      quantity: _quantity,
    );
    _isPlacing = false;
    notifyListeners();
    return outcome;
  }

  @override
  void dispose() {
    _addresses.removeListener(notifyListeners);
    super.dispose();
  }
}
