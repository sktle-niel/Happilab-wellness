import '../errors/app_exception.dart';

/// Reads a decoded JSON object one field at a time, refusing anything that
/// is not the shape the contract promised.
///
/// Every mismatch — a missing key, a string where a number was promised, a
/// list where an object was — is a [DataFormatException], never a crash:
/// what the server sends is untrusted, and a screen should show its error
/// view rather than fall over.
final class JsonReader {
  JsonReader._(this._fields);

  /// The object at the top of a response, or a failure to be one.
  factory JsonReader.of(Object? json) {
    if (json is Map<String, Object?>) return JsonReader._(json);
    if (json is Map) return JsonReader._(json.cast<String, Object?>());
    throw const DataFormatException();
  }

  final Map<String, Object?> _fields;

  /// Every element of the list at the top of a response, parsed.
  static List<T> listOf<T>(Object? json, T Function(JsonReader item) parse) {
    if (json is! List) throw const DataFormatException();
    return [for (final item in json) parse(JsonReader.of(item))];
  }

  String string(String key) => _require<String>(key);

  String? optionalString(String key) => _optional<String>(key);

  int integer(String key) {
    final value = _fields[key];
    if (value is int) return value;
    if (value is num && value == value.roundToDouble()) return value.toInt();
    throw const DataFormatException();
  }

  int? optionalInteger(String key) =>
      _fields[key] == null ? null : integer(key);

  bool boolean(String key) => _require<bool>(key);

  /// An ISO-8601 instant.
  DateTime dateTime(String key) {
    final parsed = DateTime.tryParse(string(key));
    if (parsed == null) throw const DataFormatException();
    return parsed;
  }

  DateTime? optionalDateTime(String key) =>
      _fields[key] == null ? null : dateTime(key);

  JsonReader object(String key) => JsonReader.of(_fields[key]);

  JsonReader? optionalObject(String key) =>
      _fields[key] == null ? null : object(key);

  List<T> list<T>(String key, T Function(JsonReader item) parse) =>
      listOf(_fields[key], parse);

  /// A closed set of names, matched to [values] by [name].
  T enumerated<T extends Enum>(String key, List<T> values) {
    final name = string(key);
    for (final value in values) {
      if (value.name == name) return value;
    }
    throw const DataFormatException();
  }

  T _require<T>(String key) {
    final value = _fields[key];
    if (value is T) return value;
    throw const DataFormatException();
  }

  T? _optional<T>(String key) {
    final value = _fields[key];
    if (value == null) return null;
    if (value is T) return value as T;
    throw const DataFormatException();
  }
}
