import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:riverpod_action_listener/src/config/action_listener_config.dart';
import 'package:riverpod_action_listener/src/result/action_result.dart';
import 'package:riverpod_action_listener/src/result/multi_action_result.dart';

/// Listens to an [AsyncNotifier] returning [ActionResult<T>] and handles side effects.
///
/// [provider]: The AsyncNotifierProvider to listen to.
/// [onSuccess]: Callback invoked when the action succeeds.
/// [onError]: Optional callback invoked when the action fails.
///            If provided, this is called IN ADDITION to the global handler.
///            To suppress global handling, see [skipGlobalError].
void useActionListener<T>(
  WidgetRef ref,
  ProviderBase<AsyncValue<ActionResult<T>>> provider, {
  required void Function(T data) onSuccess,
  void Function(Object error, StackTrace stack)? onError,
  bool skipGlobalError = false,
}) {
  final context = useContext();
  // Using ref.listen manually inside useEffect or just ref.listen directly?
  // Inside HookWidget build method, we can use ref.listen directly.
  // But wait, standard riverpod ref.listen SHOULD NOT be called inside build if it's not a hook.
  // BUT this IS a hook function (starts with use).
  // However, ref.listen returns a void and sets up a listener that lives as long as the widget.
  // In `hooks_riverpod`, `ref` is accessible.
  // actually `ref.listen` is safe to call in build of ConsumerWidget.
  // Inside a hook, we accept `ref`.

  ref.listen<AsyncValue<ActionResult<T>>>(provider, (prev, next) {
    next.whenOrNull(
      error: (error, stack) {
        if (!skipGlobalError) {
          ActionListenerConfig.instance.onError?.call(context, error, stack);
        }
        onError?.call(error, stack);
      },
      data: (result) {
        if (result is ActionSuccess<T>) {
          onSuccess(result.data);
        }
      },
    );
  });
}

/// Listens to an [AsyncNotifier] returning [ActionVoidResult].
///
/// See [useActionListener] for parameter details.
void useVoidActionListener(
  WidgetRef ref,
  ProviderBase<AsyncValue<ActionVoidResult>> provider, {
  required VoidCallback onSuccess,
  void Function(Object error, StackTrace stack)? onError,
  bool skipGlobalError = false,
}) {
  final context = useContext();

  ref.listen<AsyncValue<ActionVoidResult>>(provider, (prev, next) {
    next.whenOrNull(
      error: (error, stack) {
        if (!skipGlobalError) {
          ActionListenerConfig.instance.onError?.call(context, error, stack);
        }
        onError?.call(error, stack);
      },
      data: (result) {
        if (result is ActionVoidSuccess) {
          onSuccess();
        }
      },
    );
  });
}

/// Listens to an [AsyncNotifier] returning [MultiActionResult<A, T>].
///
/// [onSuccess] callback receives both the [action] identifier and optional [data].
void useMultiActionListener<A extends Enum, T>(
  WidgetRef ref,
  ProviderBase<AsyncValue<MultiActionResult<A, T>>> provider, {
  required void Function(A action, T? data) onSuccess,
  void Function(Object error, StackTrace stack)? onError,
  bool skipGlobalError = false,
}) {
  final context = useContext();

  ref.listen<AsyncValue<MultiActionResult<A, T>>>(provider, (prev, next) {
    next.whenOrNull(
      error: (error, stack) {
        if (!skipGlobalError) {
          ActionListenerConfig.instance.onError?.call(context, error, stack);
        }
        onError?.call(error, stack);
      },
      data: (result) {
        if (result is MultiActionSuccess<A, T>) {
          onSuccess(result.action, result.data);
        }
      },
    );
  });
}
