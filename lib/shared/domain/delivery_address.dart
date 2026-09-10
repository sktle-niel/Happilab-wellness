import 'package:flutter/foundation.dart';

import '../../core/errors/app_exception.dart';
import '../../core/errors/result.dart';
import '../../core/security/input_validator.dart';

/// Where a member's orders are delivered, the way a courier needs it.
///
/// One per member: an order copies it when placed, so changing it later
/// changes only what comes next.
@immutable
class DeliveryAddress {
  const DeliveryAddress({
    required this.fullName,
    required this.email,
    required this.mobile,
    required this.street,
    required this.barangay,
    required this.city,
    required this.province,
    required this.postalCode,
    this.purok = '',
    this.landmark = '',
  });

  static final RegExp _mobile = RegExp(r'^09\d{9}$');
  static final RegExp _postalCode = RegExp(r'^\d{4}$');

  final String fullName;
  final String email;

  /// Eleven digits starting with 09, as the wallets keep theirs.
  final String mobile;

  /// House number, building and street — what a courier reads first.
  final String street;

  /// Optional: many barangays are split into puroks.
  final String purok;
  final String barangay;
  final String city;
  final String province;
  final String postalCode;

  /// Optional note that helps the courier find the door.
  final String landmark;

  /// The address on one line, in the order it is read.
  String get oneLine => [
    street,
    if (purok.isNotEmpty) purok,
    barangay,
    city,
    province,
    postalCode,
  ].join(', ');

  /// The mobile as a person reads it: 0917 123 4567.
  String get mobileSpaced =>
      '${mobile.substring(0, 4)} ${mobile.substring(4, 7)} ${mobile.substring(7)}';

  static String? validateMobile(String digits) {
    if (digits.isEmpty) return 'Mobile number is required.';
    if (!_mobile.hasMatch(digits)) {
      return 'Enter an 11-digit mobile number starting with 09.';
    }
    return null;
  }

  static String? validatePostalCode(String digits) {
    if (digits.isEmpty) return 'Postal code is required.';
    if (!_postalCode.hasMatch(digits)) return 'Enter the 4-digit postal code.';
    return null;
  }

  static String? validateEmail(String value) =>
      InputValidator.notEmpty(value, field: 'Email') ??
      InputValidator.email(value);

  @override
  bool operator ==(Object other) =>
      other is DeliveryAddress &&
      other.fullName == fullName &&
      other.email == email &&
      other.mobile == mobile &&
      other.street == street &&
      other.purok == purok &&
      other.barangay == barangay &&
      other.city == city &&
      other.province == province &&
      other.postalCode == postalCode &&
      other.landmark == landmark;

  @override
  int get hashCode => Object.hash(
    fullName,
    email,
    mobile,
    street,
    purok,
    barangay,
    city,
    province,
    postalCode,
    landmark,
  );
}

/// The member's delivery address, wherever it is kept.
abstract interface class DeliveryAddressRepository {
  /// The address, or null while the member has not set one.
  Future<Result<DeliveryAddress?>> read();

  /// Sets the address, or replaces the one kept.
  Future<Result<void>> save(DeliveryAddress address);
}

/// The member's delivery address, observable: every order form draws from
/// here, so an address set on the way to one order is what the next one
/// offers. Read once per session; a save lands here first and is written
/// through.
class DeliveryAddressStore extends ChangeNotifier {
  DeliveryAddressStore(this._repository);

  final DeliveryAddressRepository _repository;

  DeliveryAddress? _address;
  AppException? _error;
  Future<void>? _loading;

  DeliveryAddress? get address => _address;

  bool get hasAddress => _address != null;

  bool get isLoaded => _loading != null && _error == null;

  /// Why the last read failed, or null.
  AppException? get error => _error;

  /// Reads the address, once — later calls await the same read until it
  /// settles; a failed read may be asked again.
  Future<void> load() => _loading ??= _load();

  Future<void> _load() async {
    _error = null;
    final outcome = await _repository.read();
    outcome.fold((address) => _address = address, (error) => _error = error);
    if (_error != null) _loading = null;
    notifyListeners();
  }

  /// Keeps [address] here at once and writes it through. A refused write is
  /// reported so the form can say so, and the address stays for the session.
  Future<Result<void>> save(DeliveryAddress address) {
    _address = address;
    notifyListeners();
    return _repository.save(address);
  }

  void clear() {
    _loading = null;
    _error = null;
    if (_address == null) return;
    _address = null;
    notifyListeners();
  }
}
