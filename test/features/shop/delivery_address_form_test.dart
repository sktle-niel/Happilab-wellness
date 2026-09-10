import 'package:flutter_test/flutter_test.dart';
import 'package:happilab/features/shop/presentation/delivery_address_form.dart';
import 'package:happilab/shared/domain/delivery_address.dart';

void main() {
  const saved = DeliveryAddress(
    fullName: 'Ivy Santos',
    email: 'ivy@example.com',
    mobile: '09171231234',
    street: '12 Mabini St',
    purok: 'Purok 3',
    barangay: 'San Isidro',
    city: 'Bacolod City',
    province: 'Negros Occidental',
    postalCode: '6100',
    landmark: 'Blue gate',
  );

  DeliveryAddressForm build({DeliveryAddress? existing, String name = ''}) {
    final form = DeliveryAddressForm(existing: existing, memberName: name);
    addTearDown(form.dispose);
    return form;
  }

  void type(DeliveryAddressForm form, AddressField field, String text) =>
      form.controllerOf(field).text = text;

  group('DeliveryAddressForm', () {
    test("a new form starts with the member's name and nothing else", () {
      final form = build(name: 'Ivy Santos');

      expect(form.isNew, isTrue);
      expect(form.controllerOf(AddressField.fullName).text, 'Ivy Santos');
      expect(form.controllerOf(AddressField.email).text, isEmpty);
      expect(form.controllerOf(AddressField.city).text, isEmpty);
    });

    test('opens on what is saved', () {
      final form = build(existing: saved, name: 'Someone Else');

      expect(form.isNew, isFalse);
      expect(form.controllerOf(AddressField.fullName).text, 'Ivy Santos');
      expect(form.controllerOf(AddressField.purok).text, 'Purok 3');
      expect(form.controllerOf(AddressField.landmark).text, 'Blue gate');
      expect(form.controllerOf(AddressField.postalCode).text, '6100');
    });

    test('refuses an empty form field by field, optional ones aside', () {
      final form = build();

      expect(form.submit(), isNull);
      expect(form.errorOf(AddressField.fullName), 'Full name is required.');
      expect(form.errorOf(AddressField.mobile), 'Mobile number is required.');
      expect(form.errorOf(AddressField.email), 'Email is required.');
      expect(form.errorOf(AddressField.province), 'Province is required.');
      expect(
        form.errorOf(AddressField.city),
        'City / Municipality is required.',
      );
      expect(form.errorOf(AddressField.barangay), 'Barangay is required.');
      expect(form.errorOf(AddressField.postalCode), 'Postal code is required.');
      expect(
        form.errorOf(AddressField.street),
        'Street, building, house no. is required.',
      );
      expect(form.errorOf(AddressField.purok), isNull);
      expect(form.errorOf(AddressField.landmark), isNull);
    });

    test("clears a field's error once the member types, and only then", () {
      final form = build();
      var notified = 0;
      form.addListener(() => notified += 1);
      form.submit();
      expect(notified, 1);

      form.onChanged(AddressField.city);
      expect(form.errorOf(AddressField.city), isNull);
      expect(notified, 2);

      form.onChanged(AddressField.city);
      expect(notified, 2);
    });

    test('tidies the address it hands back', () {
      final form = build();
      type(form, AddressField.fullName, '  Ivy Santos ');
      type(form, AddressField.mobile, '0917-123 1234');
      type(form, AddressField.email, 'Ivy@Example.com');
      type(form, AddressField.province, 'Negros Occidental');
      type(form, AddressField.city, 'Bacolod City');
      type(form, AddressField.barangay, 'San Isidro');
      type(form, AddressField.postalCode, '61 00');
      type(form, AddressField.street, '12 Mabini St');

      expect(
        form.submit(),
        const DeliveryAddress(
          fullName: 'Ivy Santos',
          email: 'ivy@example.com',
          mobile: '09171231234',
          street: '12 Mabini St',
          barangay: 'San Isidro',
          city: 'Bacolod City',
          province: 'Negros Occidental',
          postalCode: '6100',
        ),
      );
    });

    test('refuses a mobile and a postal code of the wrong shape', () {
      final form = build(existing: saved);
      type(form, AddressField.mobile, '1234');
      type(form, AddressField.postalCode, '61');

      expect(form.submit(), isNull);
      expect(
        form.errorOf(AddressField.mobile),
        'Enter an 11-digit mobile number starting with 09.',
      );
      expect(
        form.errorOf(AddressField.postalCode),
        'Enter the 4-digit postal code.',
      );
    });
  });
}
