import 'package:flutter/widgets.dart';

/// Callback function for handling errors globally.
/// [context] is provided from the hook's build context.
/// [error] is the error object from AsyncValue.
/// [stackTrace] is the stack trace from AsyncValue.
typedef ActionListenerErrorCallback = void Function(
  BuildContext context,
  Object error,
  StackTrace stackTrace,
);

/// Global configuration for Action Listener Pattern.
///
/// Use [initialize] in your main function to set up global error handling.
class ActionListenerConfig {
  static ActionListenerConfig? _instance;

  /// Returns the singleton instance.
  /// Throws if [initialize] has not been called.
  static ActionListenerConfig get instance {
    _instance ??= ActionListenerConfig._();
    return _instance!;
  }

  final ActionListenerErrorCallback? onError;

  ActionListenerConfig._({this.onError});

  /// Initialize the global configuration.
  ///
  /// [onError]: A callback that will be invoked when an action fails.
  /// This is where you should trigger your global UI feedback (e.g. SnackBar, Dialog).
  static void initialize({
    ActionListenerErrorCallback? onError,
  }) {
    _instance = ActionListenerConfig._(onError: onError);
  }
}
