import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_action_listener/riverpod_action_listener.dart';

// 1. Initialize Global Config
void main() {
  ActionListenerConfig.initialize(
    onError: (context, error, stack) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Global Error Handler: $error'),
          backgroundColor: Colors.red,
        ),
      );
    },
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: const LoginScreen());
  }
}

// 2. Define Action Notifier
class LoginNotifier extends ActionNotifier<ActionResult<String>> {
  @override
  ActionResult<String> build() => const ActionResult.idle();

  Future<void> login(String userId) async {
    state = const AsyncValue.loading();

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    if (userId == 'error') {
      state = AsyncValue.error('Invalid Credentials', StackTrace.current);
    } else {
      state = AsyncValue.data(ActionResult.success('Token_$userId'));
    }
  }
}

final loginProvider =
    AsyncNotifierProvider<LoginNotifier, ActionResult<String>>(
      LoginNotifier.new,
    );

// 3. UI Implementation
class LoginScreen extends HookConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usernameController = useTextEditingController(text: 'user123');
    final statusText = useState<String>('Idle');

    // 4. Use Hook
    useActionListener(
      ref,
      loginProvider,
      onSuccess: (token) {
        statusText.value = 'Login Success! Token: $token';
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login Success! Navigating...'),
            backgroundColor: Colors.green,
          ),
        );
      },
      onError: (error, stack) {
        // Global handler is called automatically.
        // This is for additional local handling.
        statusText.value = 'Login Failed: $error';
      },
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Action Listener Example')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: 'Username (type "error" to fail)',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(loginProvider.notifier).login(usernameController.text);
              },
              child: const Text('Login'),
            ),
            const SizedBox(height: 32),
            Text('Status: ${statusText.value}'),
          ],
        ),
      ),
    );
  }
}
