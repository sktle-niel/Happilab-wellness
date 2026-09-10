import 'package:flutter/widgets.dart';

import '../../../core/security/input_validator.dart';
import '../../../shared/domain/delivery_address.dart';

/// The fields of the address form, in the order the screen lays them out.
enum AddressField {
  fullName('Full name'),
  mobile('Mobile number'),
  email('Email'),
  province('Province'),
  city('City / Municipality'),
  barangay('Barangay'),
  postalCode('Postal code'),
  street('Street, building, house no.'),
  purok('Purok'),
  landmark('Landmark / delivery note');

  const AddressField(this.label);

  final String label;

  /// Purok and landmark help the courier but are not required.
  bool get isRequired => this != purok && this != landmark;
}

/// Form state for the delivery address: one controller per field, one error
/// per field, and the rules — which live here and in [DeliveryAddress], so
/// the screen only renders them.
///
/// Opens on what is saved when anything is, so one form sets and edits; a
/// new form starts with the member's own name and email filled in.
class DeliveryAddressForm extends ChangeNotifier {
  DeliveryAddressForm({
    DeliveryAddress? existing,
    String memberName = '',
    String memberEmail = '',
  }) : isNew = existing == null,
       _controllers = {
         for (final field in AddressField.values)
           field: TextEditingController(
             text: existing == null
                 ? _prefill(field, memberName, memberEmail)
                 : _valueOf(existing, field),
           ),
       };

  /// True when there is no address saved yet.
  final bool isNew;

  final Map<AddressField, TextEditingController> _controllers;
  final Map<AddressField, String?> _errors = {};

  TextEditingController controllerOf(AddressField field) =>
      _controllers[field]!;

  String? errorOf(AddressField field) => _errors[field];

  /// Clears a field's error as soon as the member starts fixing it, and only
  /// then — notifying on every keystroke would rebuild the form for nothing.
  void onChanged(AddressField field) {
    if (_errors[field] == null) return;
    _errors[field] = null;
    notifyListeners();
  }

  /// The address the form describes, once it is complete — or null, with
  /// the errors set for the screen to show.
  DeliveryAddress? submit() {
    final values = {
      for (final field in AddressField.values)
        field: InputValidator.sanitize(_controllers[field]!.text),
    };
    // Spaces and dashes are how people type a number, not part of it.
    final mobile = _digits(values[AddressField.mobile]!);
    final postalCode = _digits(values[AddressField.postalCode]!);

    for (final field in AddressField.values) {
      _errors[field] = switch (field) {
        AddressField.mobile => DeliveryAddress.validateMobile(mobile),
        AddressField.postalCode => DeliveryAddress.validatePostalCode(
          postalCode,
        ),
        AddressField.email => DeliveryAddress.validateEmail(values[field]!),
        _ when field.isRequired => InputValidator.notEmpty(
          values[field],
          field: field.label,
        ),
        _ => null,
      };
    }
    notifyListeners();

    if (_errors.values.any((error) => error != null)) return null;
    return DeliveryAddress(
      fullName: values[AddressField.fullName]!,
      email: values[AddressField.email]!.toLowerCase(),
      mobile: mobile,
      street: values[AddressField.street]!,
      purok: values[AddressField.purok]!,
      barangay: values[AddressField.barangay]!,
      city: values[AddressField.city]!,
      province: values[AddressField.province]!,
      postalCode: postalCode,
      landmark: values[AddressField.landmark]!,
    );
  }

  static String _digits(String value) => value.replaceAll(RegExp(r'\D'), '');

  static String _prefill(AddressField field, String name, String email) =>
      switch (field) {
        AddressField.fullName => name,
        AddressField.email => email,
        _ => '',
      };

  static String _valueOf(DeliveryAddress address, AddressField field) =>
      switch (field) {
        AddressField.fullName => address.fullName,
        AddressField.mobile => address.mobile,
        AddressField.email => address.email,
        AddressField.province => address.province,
        AddressField.city => address.city,
        AddressField.barangay => address.barangay,
        AddressField.postalCode => address.postalCode,
        AddressField.street => address.street,
        AddressField.purok => address.purok,
        AddressField.landmark => address.landmark,
      };

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}
