import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:happilab/core/errors/result.dart';
import 'package:happilab/features/shop/presentation/checkout_controller.dart';
import 'package:happilab/shared/data/fake_delivery_address_repository.dart';
import 'package:happilab/shared/domain/catalogue.dart';
import 'package:happilab/shared/domain/delivery_address.dart';
import 'package:happilab/shared/domain/orders.dart';

const home = DeliveryAddress(
  fullName: 'Ivy Santos',
  email: 'ivy@example.com',
  mobile: '09171231234',
  street: '12 Mabini St',
  barangay: 'San Isidro',
  city: 'Bacolod City',
  province: 'Negros Occidental',
  postalCode: '6100',
);

/// Orders that settle only when the test says so.
final class _HeldOrders implements OrdersRepository {
  final List<(String, int)> placed = [];
  final Completer<Result<OrderReceipt>> pending = Completer();

  @override
  Future<Result<OrderReceipt>> place({
    required String productId,
    required int quantity,
  }) {
    placed.add((productId, quantity));
    return pending.future;
  }
}

void main() {
  final product = Product.showcase.first;

  CheckoutController build({
    DeliveryAddress? address,
    OrdersRepository? orders,
  }) {
    final store = DeliveryAddressStore(
      FakeDeliveryAddressRepository(initial: address),
    );
    final controller = CheckoutController(
      product: product,
      addresses: store,
      orders: orders ?? _HeldOrders(),
    );
    addTearDown(() {
      controller.dispose();
      store.dispose();
    });
    return controller;
  }

  group('CheckoutController', () {
    test('counts between one and ten', () {
      final checkout = build();

      expect(checkout.quantity, 1);
      expect(checkout.canRemoveOne, isFalse);
      checkout.removeOne();
      expect(checkout.quantity, 1);

      for (var i = 0; i < 12; i++) {
        checkout.addOne();
      }
      expect(checkout.quantity, OrderLimits.maxQuantity);
      expect(checkout.canAddOne, isFalse);
      expect(checkout.priceLine, '${product.price} × 10');
    });

    test('waits for an address before an order can go', () async {
      final checkout = build();
      expect(checkout.canPlace, isFalse);
      expect(checkout.isAddressLoaded, isFalse);

      await checkout.loadAddress();
      expect(checkout.isAddressLoaded, isTrue);
      expect(checkout.canPlace, isFalse);
      expect(await checkout.place(), isNull);
    });

    test('follows the address store without a reload', () async {
      final store = DeliveryAddressStore(FakeDeliveryAddressRepository());
      addTearDown(store.dispose);
      final checkout = CheckoutController(
        product: product,
        addresses: store,
        orders: _HeldOrders(),
      );
      addTearDown(checkout.dispose);
      await checkout.loadAddress();
      var notified = 0;
      checkout.addListener(() => notified += 1);

      await store.save(home);

      expect(checkout.address, home);
      expect(checkout.canPlace, isTrue);
      expect(notified, 1);
    });

    test('places once, and stays inert while the order is in flight', () async {
      final orders = _HeldOrders();
      final checkout = build(address: home, orders: orders);
      await checkout.loadAddress();
      checkout.addOne();

      final first = checkout.place();
      expect(checkout.isPlacing, isTrue);
      expect(checkout.canPlace, isFalse);
      expect(await checkout.place(), isNull);
      expect(orders.placed, [(product.id, 2)]);

      orders.pending.complete(
        const Success(OrderReceipt(reference: 'FC-1', total: '₱300')),
      );
      final outcome = await first;
      expect(outcome?.valueOrNull?.reference, 'FC-1');
      expect(checkout.isPlacing, isFalse);
      expect(checkout.canPlace, isTrue);
    });
  });
}
