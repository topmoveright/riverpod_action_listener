/// Represents the result state of multiple actions within a single Notifier.
///
/// [A] is the Enum type identifying the action.
/// [T] is the optional data type returned by the action.
sealed class MultiActionResult<A extends Enum, T> {
  const MultiActionResult._();

  /// Initial state.
  const factory MultiActionResult.idle() = MultiActionIdle<A, T>;

  /// One of the actions completed successfully.
  const factory MultiActionResult.success(A action, {T? data}) =
      MultiActionSuccess<A, T>;

  /// Returns true if the state is success.
  bool get isSuccess => this is MultiActionSuccess<A, T>;

  /// Returns the action identifier if success, otherwise null.
  A? get actionOrNull => switch (this) {
        MultiActionSuccess<A, T>(:final action) => action,
        _ => null,
      };

  /// Returns the data if success, otherwise null.
  T? get dataOrNull => switch (this) {
        MultiActionSuccess<A, T>(:final data) => data,
        _ => null,
      };
}

/// Initial state (Idle).
class MultiActionIdle<A extends Enum, T> extends MultiActionResult<A, T> {
  const MultiActionIdle() : super._();

  @override
  String toString() => 'MultiActionIdle<$A, $T>()';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is MultiActionIdle<A, T>);

  @override
  int get hashCode => Object.hash(runtimeType, A, T);
}

/// Success state.
class MultiActionSuccess<A extends Enum, T> extends MultiActionResult<A, T> {
  const MultiActionSuccess(this.action, {this.data}) : super._();

  final A action;
  final T? data;

  @override
  String toString() =>
      'MultiActionSuccess<$A, $T>(action: $action, data: $data)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MultiActionSuccess<A, T> &&
          action == other.action &&
          data == other.data);

  @override
  int get hashCode => Object.hash(runtimeType, action, data);
}
