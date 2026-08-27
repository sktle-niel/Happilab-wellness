import 'app_exception.dart';

/// Outcome of an operation that is allowed to fail.
///
/// Returning a [Result] instead of throwing keeps failure handling visible in
/// the signature: callers cannot forget the sad path, and features stop being
/// wrapped in defensive try/catch.
sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;

  T? get valueOrNull => switch (this) {
    Success<T>(:final value) => value,
    Failure<T>() => null,
  };

  AppException? get errorOrNull => switch (this) {
    Success<T>() => null,
    Failure<T>(:final error) => error,
  };

  /// Collapses both branches into one value — the safe way to render a result.
  R fold<R>(
    R Function(T value) onSuccess,
    R Function(AppException error) onFailure,
  ) => switch (this) {
    Success<T>(:final value) => onSuccess(value),
    Failure<T>(:final error) => onFailure(error),
  };

  Result<R> map<R>(R Function(T value) transform) => switch (this) {
    Success<T>(:final value) => Success<R>(transform(value)),
    Failure<T>(:final error) => Failure<R>(error),
  };
}

final class Success<T> extends Result<T> {
  const Success(this.value);

  final T value;
}

final class Failure<T> extends Result<T> {
  const Failure(this.error);

  final AppException error;
}
