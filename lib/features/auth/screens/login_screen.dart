import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/routes/route_names.dart';
import '../../../shared/widgets/auth_glass_scaffold_widget.dart';
import '../providers/auth_provider.dart';
import '../widgets/login_form_widget.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthProvider authProvider = context.watch<AuthProvider>();
    if (authProvider.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          Navigator.of(context).pushReplacementNamed(RouteNames.shell);
        }
      });
    }

    return AuthGlassScaffold(
      title: AppStrings.appName,
      subtitle: 'Sign in to continue',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (authProvider.statusMessage != null)
            _AuthNoticeCard(
              message: authProvider.statusMessage!,
              icon: Icons.info_outline,
            ),
          if (authProvider.statusMessage != null)
            const SizedBox(height: 16),
          LoginForm(
            isLoading: authProvider.isLoading,
            onSubmit: (String email, String password) async {
              final bool ok = await context
                  .read<AuthProvider>()
                  .login(email: email, password: password);
              if (ok && context.mounted) {
                Navigator.of(context).pushReplacementNamed(RouteNames.shell);
              }
            },
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
              label: const Text('Continue with Google'),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(RouteNames.forgotPassword);
                },
                child: const Text('Forgot Password?'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(RouteNames.signup);
                },
                child: const Text('Create Account'),
              ),
            ],
          ),
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

class _AuthNoticeCard extends StatelessWidget {
  const _AuthNoticeCard({
    required this.message,
    required this.icon,
  });

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(26),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withAlpha(56)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icon, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
