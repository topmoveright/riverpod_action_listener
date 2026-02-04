/// Represents the result state of a single action that returns data.
///
/// Use [AsyncNotifier] with `AsyncValue<ActionResult<T>>` to handle
/// core action states: Idle, Success (with data), and Failure (handled by AsyncValue.error).
sealed class ActionResult<T> {
  const ActionResult._();

  /// Initial state. Action has not started yet.
  const factory ActionResult.idle() = ActionIdle<T>;

  /// Action completed successfully with data.
  const factory ActionResult.success(T data) = ActionSuccess<T>;
}

/// Initial state (Idle).
class ActionIdle<T> extends ActionResult<T> {
  const ActionIdle() : super._();

  @override
  String toString() => 'ActionIdle<$T>()';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is ActionIdle<T>);

  @override
  int get hashCode => runtimeType.hashCode;
}

/// Success state with data.
class ActionSuccess<T> extends ActionResult<T> {
  const ActionSuccess(this.data) : super._();

  final T data;

  @override
  String toString() => 'ActionSuccess<$T>(data: $data)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActionSuccess<T> && data == other.data);

  @override
  int get hashCode => Object.hash(runtimeType, data);
}

// -----------------------------------------------------------------------------

/// Represents the result state of a single action with no return data.
sealed class ActionVoidResult {
  const ActionVoidResult._();

  /// Initial state.
  const factory ActionVoidResult.idle() = ActionVoidIdle;

  /// Action completed successfully.
  const factory ActionVoidResult.success() = ActionVoidSuccess;
}

/// Initial state (Idle).
class ActionVoidIdle extends ActionVoidResult {
  const ActionVoidIdle() : super._();

  @override
  String toString() => 'ActionVoidIdle()';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is ActionVoidIdle);

  @override
  int get hashCode => runtimeType.hashCode;
}

/// Success state.
class ActionVoidSuccess extends ActionVoidResult {
  const ActionVoidSuccess() : super._();

  @override
  String toString() => 'ActionVoidSuccess()';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is ActionVoidSuccess);

  @override
  int get hashCode => runtimeType.hashCode;
}
