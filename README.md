# Riverpod Action Listener

A standardized pattern for handling **one-off actions** (like API calls, Dialogs, Navigation) and their **side effects** in Riverpod.

## ❓ Why use this?

Handling "Actions" (e.g., Login, Saving Data, Deleting items) in Riverpod can be tricky.
*   "How do I show a Snackbar when an error occurs?"
*   "How do I navigate ONLY when the action succeeds?"
*   "How do I prevent the error state from persisting on the UI after I've handled it?"

`riverpod_action_listener` solves these problems by separating **Data (Read)** from **Actions (Write)** and providing a simple hook to handle side effects.

## ✨ Features

*   **🛡️ Standardized Result Types**: Explicitly distinguish between `Idle`, `Success`, and `Failure` using `ActionResult`.
*   **⚡ Automatic Error Handling**: Define a global error handler (e.g., Toast/Snackbar) **once**, and it applies to all actions automatically.
*   **🪝 Simple Hooks**: `useActionListener` reduces boilerplate. Just define what happens on `success`.
*   **🧩 Decoupled UI**: Your business logic remains pure Dart, independent of `BuildContext`.

---

## 🚀 Getting Started

### 1. Global Setup (main.dart)

Initialize the global configuration once in your `main` function. This allows you to define how errors should be displayed across your entire app.

```dart
void main() {
  // Define your global error UI behavior (e.g., using a Toast package or ScaffoldMessenger)
  ActionListenerConfig.initialize(
    onError: (context, error, stack) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $error'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    },
  );

  runApp(const ProviderScope(child: MyApp()));
}
```

---

## 📖 Usage Patterns

### Case 1: Action with Return Data (e.g., Login)

Use `ActionResult<T>` when your action needs to return data (e.g., a User object, an Auth Token).

#### 1. Define Notifier
```dart
// State type is ActionResult<String> (returns a token)
class LoginNotifier extends AsyncNotifier<ActionResult<String>> {
  @override
  ActionResult<String> build() => const ActionResult.idle();

  Future<void> login(String password) async {
    state = const AsyncValue.loading();
    try {
      // Perform API call...
      final token = await api.login(password);

      // Update state to success with data
      state = AsyncValue.data(ActionResult.success(token));
    } catch (e, stack) {
      // Just set the error. The UI Hook will handle it automatically!
      state = AsyncValue.error(e, stack);
    }
  }
}

final loginProvider = AsyncNotifierProvider<LoginNotifier, ActionResult<String>>(LoginNotifier.new);
```

#### 2. Listen in UI
```dart
class LoginScreen extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🪝 Listen for results
    useActionListener(
      ref,
      loginProvider,
      onSuccess: (token) {
        // Handle success (e.g., Navigate to Home)
        print('Login Success! Token: $token');
        context.go('/home');
      },
      // Error is handled automatically by GlobalConfig!
      // You can add 'onError' here if you need specific local handling.
    );

    return Scaffold(
      body: ElevatedButton(
        onPressed: () {
            // Trigger the action
            ref.read(loginProvider.notifier).login('password123');
        },
        child: const Text('Login'),
      ),
    );
  }
}
```

---

### Case 2: Pure Action (e.g., Delete, Logout)

Use `ActionVoidResult` when you only care if it succeeded or failed, without any return data.

#### 1. Define Notifier
```dart
class DeleteAccountNotifier extends AsyncNotifier<ActionVoidResult> {
  @override
  ActionVoidResult build() => const ActionVoidResult.idle();

  Future<void> delete() async {
    state = const AsyncValue.loading();
    try {
      await api.deleteAccount();
      // Set success (no data)
      state = const AsyncValue.data(ActionVoidResult.success());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
```

#### 2. Listen in UI
```dart
useVoidActionListener(
  ref,
  deleteAccountProvider,
  onSuccess: () {
    // Clean up and go to login
    context.go('/login');
  },
);
```

---

### Case 3: Multiple Actions in One Notifier

Use `MultiActionResult` when a single screen/notifier handles multiple related actions (e.g., "Resend Email" and "Verify Code").

#### 1. Define Actions
```dart
enum AuthAction { resendEmail, verifyCode }
```

#### 2. Define Notifier
```dart
class AuthNotifier extends AsyncNotifier<MultiActionResult<AuthAction, void>> {
  @override
  build() => const MultiActionResult.idle();

  Future<void> resend() async {
    state = const AsyncValue.loading();
    await api.resend();
    // Specify WHICH action succeeded
    state = const AsyncValue.data(MultiActionResult.success(AuthAction.resendEmail));
  }

  Future<void> verify() async {
    state = const AsyncValue.loading();
    await api.verify();
    state = const AsyncValue.data(MultiActionResult.success(AuthAction.verifyCode));
  }
}
```

#### 3. Listen in UI
```dart
useMultiActionListener(
  ref,
  authProvider,
  onSuccess: (action, data) {
    switch (action) {
      case AuthAction.resendEmail:
        showToast('Email resent!');
      case AuthAction.verifyCode:
        context.go('/home');
    }
  },
);
```

## ⚠️ Important Best Practices

1.  **Separate Read & Write**:
    *   Use `FutureProvider` / `StreamProvider` for **Reading** data (UI state).
    *   Use `AsyncNotifier<ActionResult>` for **Writing** data (User actions).
    *   Don't try to mix them.
2.  **AutoDispose**:
    *   Action providers should usually be `.autoDispose`. You typically don't want the "Success" state to persist if the user leaves the screen and comes back (unless you reset it manually).
