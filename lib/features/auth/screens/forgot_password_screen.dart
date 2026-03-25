import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/validators.dart';
import '../../../shared/widgets/auth_glass_scaffold_widget.dart';
import '../providers/auth_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final bool ok = await context.read<AuthProvider>().sendPasswordResetEmail(
          email: _emailController.text.trim(),
        );

    if (!mounted) {
      return;
    }
    if (ok) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthProvider authProvider = context.watch<AuthProvider>();

    return AuthGlassScaffold(
      title: 'Reset Password',
      subtitle: 'We will email you reset instructions',
      child: AutofillGroup(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                autofillHints: const <String>[AutofillHints.email],
                autocorrect: false,
                decoration: const InputDecoration(labelText: 'Email'),
                onFieldSubmitted: (_) => _sendResetLink(),
                validator: Validators.email,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: authProvider.isLoading ? null : _sendResetLink,
                  child: Text(
                    authProvider.isLoading ? 'Sending...' : 'Send Reset Email',
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Back to Sign In'),
              ),
              if (authProvider.statusMessage != null) ...<Widget>[
                const SizedBox(height: 8),
                Text(
                  authProvider.statusMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.primary),
                  textAlign: TextAlign.center,
                ),
              ],
              if (authProvider.error != null) ...<Widget>[
                const SizedBox(height: 8),
                Text(
                  authProvider.error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
