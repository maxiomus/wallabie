import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../register.dart';

/// Registration page for creating new user accounts.
///
/// Collects display name, email, and password for account creation.
class RegisterPage extends StatefulWidget {
  /// Creates a [RegisterPage].
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _displayName = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _displayName.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    context.read<RegisterBloc>().add(RegisterSubmitEvent(
      _email.text,
      _password.text,
      _displayName.text,            
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RegisterBloc, RegisterState>(
      listenWhen: (p, c) => p.status != c.status,
      listener: (context, state) {
        if (state.status == RegisterStatus.success) {
          Navigator.of(context).pop();          
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Register')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: BlocBuilder<RegisterBloc, RegisterState>(
            builder: (context, state) {
              final loading = state.status == RegisterStatus.submitting;

              return Column(
                children: [
                  TextField(
                    controller: _displayName,
                    decoration: const InputDecoration(labelText: 'Display name'),
                    textInputAction: TextInputAction.next,
                    enabled: !loading,
                  ),
                  TextField(
                    controller: _email,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    enabled: !loading,
                  ),
                  TextField(
                    controller: _password,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    enabled: !loading,
                    onSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: 16),
                  if (state.status == RegisterStatus.failure &&
                      state.errorMessage != null)
                    Text(state.errorMessage!,
                        style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: loading ? null : _submit,
                      child: loading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Create account'),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
