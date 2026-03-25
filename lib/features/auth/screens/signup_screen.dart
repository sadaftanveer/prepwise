import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/routes/route_names.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/auth_glass_scaffold_widget.dart';
import '../providers/auth_provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  double get _passwordStrength {
    final String password = _passwordController.text;
    int score = 0;
    if (password.length >= 8) {
      score++;
    }
    if (RegExp(r'[A-Z]').hasMatch(password)) {
      score++;
    }
    if (RegExp(r'[a-z]').hasMatch(password)) {
      score++;
    }
    if (RegExp(r'\d').hasMatch(password)) {
      score++;
    }
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(password)) {
      score++;
    }
    return score / 5;
  }

  String get _passwordStrengthLabel {
    final double strength = _passwordStrength;
    if (strength >= 0.8) {
      return 'Strong password';
    }
    if (strength >= 0.6) {
      return 'Good password';
    }
    if (strength >= 0.4) {
      return 'Fair password';
    }
    return 'Use a stronger password';
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final bool ok = await context.read<AuthProvider>().signup(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

    if (!mounted) {
      return;
    }

    if (ok) {
      Navigator.of(context).pushReplacementNamed(RouteNames.shell);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthProvider authProvider = context.watch<AuthProvider>();

    return AuthGlassScaffold(
      title: 'Create Account',
      subtitle: 'Join PrepWise to track your interview prep',
      child: AutofillGroup(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const <String>[AutofillHints.email],
                autocorrect: false,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: Validators.email,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                textInputAction: TextInputAction.next,
                autofillHints: const <String>[AutofillHints.newPassword],
                autocorrect: false,
                enableSuggestions: false,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    ),
                  ),
                ),
                obscureText: _obscurePassword,
                validator: Validators.password,
              ),
              const SizedBox(height: 10),
              _PasswordStrengthMeter(
                strength: _passwordStrength,
                label: _passwordStrengthLabel,
              ),
              const SizedBox(height: 6),
              Text(
                'Use 8+ characters with upper/lowercase letters, a number, and a symbol.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                    ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirmPasswordController,
                textInputAction: TextInputAction.done,
                autofillHints: const <String>[AutofillHints.newPassword],
                autocorrect: false,
                enableSuggestions: false,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                  ),
                ),
                obscureText: _obscureConfirmPassword,
                onFieldSubmitted: (_) => _submit(),
                validator: (String? value) {
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return Validators.password(value);
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: authProvider.isLoading ? null : _submit,
                  child: Text(
                    authProvider.isLoading ? 'Creating Account...' : 'Sign Up',
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const _AuthSeparator(label: 'or continue with'),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: authProvider.isLoading
                      ? null
                      : () async {
                          final bool ok =
                              await context.read<AuthProvider>().loginWithGoogle();
                          if (ok && context.mounted) {
                            Navigator.of(context)
                                .pushReplacementNamed(RouteNames.shell);
                          }
                        },
                  icon: const Icon(Icons.g_mobiledata),
                  label: const Text('Sign up with Google'),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Already have an account? Sign in'),
              ),
              if (authProvider.statusMessage != null) ...<Widget>[
                const SizedBox(height: 8),
                _StatusText(
                  message: authProvider.statusMessage!,
                  color: Colors.white,
                ),
              ],
              if (authProvider.error != null) ...<Widget>[
                const SizedBox(height: 8),
                _StatusText(
                  message: authProvider.error!,
                  color: Theme.of(context).colorScheme.error,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PasswordStrengthMeter extends StatelessWidget {
  const _PasswordStrengthMeter({
    required this.strength,
    required this.label,
  });

  final double strength;
  final String label;

  @override
  Widget build(BuildContext context) {
    Color color = Colors.redAccent;
    if (strength >= 0.8) {
      color = Colors.lightGreenAccent;
    } else if (strength >= 0.6) {
      color = Colors.greenAccent;
    } else if (strength >= 0.4) {
      color = Colors.amberAccent;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: strength == 0 ? 0.08 : strength,
            minHeight: 6,
            backgroundColor: Colors.white.withAlpha(36),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

class _AuthSeparator extends StatelessWidget {
  const _AuthSeparator({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                ),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}

class _StatusText extends StatelessWidget {
  const _StatusText({
    required this.message,
    required this.color,
  });

  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: color),
      textAlign: TextAlign.center,
    );
  }
}
