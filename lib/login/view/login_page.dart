import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:august_chat/repositories/auth_repository.dart';
import 'package:august_chat/register/register.dart';
import 'package:august_chat/login/login.dart';

/// Login page with email/password form.
///
/// Provides navigation to registration page for new users.
class LoginPage extends StatefulWidget {
  /// Creates a [LoginPage].
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    context.read<LoginBloc>().add(LoginSubmitEvent(
      _email.text,
      _password.text,      
    ));
  }

  void _goRegister() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (ctx) => RegisterBloc(authRepo: ctx.read<AuthRepository>()),
          child: const RegisterPage(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: BlocBuilder<LoginBloc, LoginState>(
          builder: (context, state) {
            final loading = state.status == LoginStatus.submitting;
    
            return Column(
              children: [
                TextField(
                  controller: _email,
                  decoration: const InputDecoration(labelText: 'Email'),
                  enabled: !loading,
                ),
                TextField(
                  controller: _password,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  enabled: !loading,
                  onSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 16),
                if (state.status == LoginStatus.failure && state.errorMessage != null)
                  Text(state.errorMessage!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: loading ? null : _submit,
                    child: loading
                        ? const SizedBox(
                            height: 18, width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Login'),
                  ),
                ),
                TextButton(
                  onPressed: loading ? null : _goRegister,
                  child: const Text('Create account'),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}
