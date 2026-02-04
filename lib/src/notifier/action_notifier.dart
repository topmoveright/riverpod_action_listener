// ignore: implementation_imports
import 'package:riverpod/src/internals.dart' show KeepAliveLink;
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Base class for ActionNotifiers.
///
/// Extends [AsyncNotifier] and automatically calls `ref.keepAlive()` when
/// [state] is set to [AsyncValue.loading] to prevent disposal during
/// asynchronous operations.
///
/// The keep-alive link is automatically closed when the operation completes
/// (either success or error).
///
/// Usage:
/// ```dart
/// class MyActionNotifier extends ActionNotifier<ActionVoidResult> {
///   @override
///   FutureOr<ActionVoidResult> build() => const ActionVoidResult.idle();
///
///   Future<void> doSomething() async {
///     state = const AsyncValue.loading();
///     // ... async work ...
///     state = const AsyncValue.data(ActionVoidResult.success());
///   }
/// }
///
/// // Provider declaration (works with both autoDispose and normal providers)
/// final myActionProvider = AsyncNotifierProvider.autoDispose<...>(...);
/// ```
abstract class ActionNotifier<T> extends AsyncNotifier<T> {
  KeepAliveLink? _keepAliveLink;

  @override
  set state(AsyncValue<T> value) {
    // Start keepAlive when entering loading state
    if (value.isLoading && _keepAliveLink == null) {
      _keepAliveLink = ref.keepAlive();
    }
    // Close keepAlive when leaving loading state (data or error)
    else if (!value.isLoading && _keepAliveLink != null) {
      _keepAliveLink!.close();
      _keepAliveLink = null;
    }
    super.state = value;
  }
}
