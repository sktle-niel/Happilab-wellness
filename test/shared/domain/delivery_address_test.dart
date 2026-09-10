import 'package:flutter_test/flutter_test.dart';
import 'package:happilab/core/errors/app_exception.dart';
import 'package:happilab/core/errors/result.dart';
import 'package:happilab/shared/data/fake_delivery_address_repository.dart';
import 'package:happilab/shared/domain/delivery_address.dart';

const home = DeliveryAddress(
  fullName: 'Ivy Santos',
  email: 'ivy@example.com',
  mobile: '09171231234',
  street: '12 Mabini St',
  purok: 'Purok 3',
  barangay: 'San Isidro',
  city: 'Bacolod City',
  province: 'Negros Occidental',
  postalCode: '6100',
);

/// A repository whose first read fails, so the store's retry can be seen.
final class _FailingOnce implements DeliveryAddressRepository {
  int reads = 0;

  @override
  Future<Result<DeliveryAddress?>> read() async {
    reads += 1;
    if (reads == 1) return const Failure(NetworkException());
    return const Success(home);
  }

  @override
  Future<Result<void>> save(DeliveryAddress address) async =>
      const Success<void>(null);
}

void main() {
  group('DeliveryAddress', () {
    test('reads on one line in courier order, skipping an empty purok', () {
      expect(
        home.oneLine,
        '12 Mabini St, Purok 3, San Isidro, Bacolod City, Negros Occidental, '
        '6100',
      );
      const noPurok = DeliveryAddress(
        fullName: 'A',
        email: 'a@b.co',
        mobile: '09171231234',
        street: 'S',
        barangay: 'B',
        city: 'C',
        province: 'P',
        postalCode: '1000',
      );
      expect(noPurok.oneLine, 'S, B, C, P, 1000');
      expect(home.mobileSpaced, '0917 123 1234');
    });

    test('validates the mobile, the postal code and the email', () {
      expect(DeliveryAddress.validateMobile(''), 'Mobile number is required.');
      expect(
        DeliveryAddress.validateMobile('1234'),
        'Enter an 11-digit mobile number starting with 09.',
      );
      expect(DeliveryAddress.validateMobile('09171231234'), isNull);
      expect(
        DeliveryAddress.validatePostalCode('61'),
        'Enter the 4-digit postal code.',
      );
      expect(DeliveryAddress.validatePostalCode('6100'), isNull);
      expect(DeliveryAddress.validateEmail(''), 'Email is required.');
      expect(DeliveryAddress.validateEmail('not-an-email'), isNotNull);
      expect(DeliveryAddress.validateEmail('ivy@example.com'), isNull);
    });
  });

  group('DeliveryAddressStore', () {
    test('starts empty for a new member and keeps a save at once', () async {
      final store = DeliveryAddressStore(FakeDeliveryAddressRepository());
      addTearDown(store.dispose);

      await store.load();
      expect(store.isLoaded, isTrue);
      expect(store.hasAddress, isFalse);

      final saved = store.save(home);
      expect(store.address, home);
      expect((await saved).isSuccess, isTrue);
    });

    test('opens on what is kept and clears on sign-out', () async {
      final store = DeliveryAddressStore(
        FakeDeliveryAddressRepository(initial: home),
      );
      addTearDown(store.dispose);
      var notified = 0;
      store.addListener(() => notified += 1);

      await store.load();
      expect(store.address, home);

      store.clear();
      expect(store.hasAddress, isFalse);
      expect(store.isLoaded, isFalse);
      expect(notified, 2);
    });

    test('a failed read is reported and may be asked again', () async {
      final repository = _FailingOnce();
      final store = DeliveryAddressStore(repository);
      addTearDown(store.dispose);

      await store.load();
      expect(store.error, isA<NetworkException>());
      expect(store.isLoaded, isFalse);

      await store.load();
      expect(store.error, isNull);
      expect(store.address, home);
      expect(repository.reads, 2);
    });
  });
}
