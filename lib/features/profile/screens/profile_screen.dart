import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/routes/route_names.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../shared/providers/app_navigation_provider.dart';
import '../../../core/constants/app_enums.dart';
import '../providers/profile_provider.dart';
import '../widgets/profile_header_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().load();
    });
  }

  Future<void> _pickProfileImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? picked =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null || !context.mounted) {
      return;
    }
    await context.read<ProfileProvider>().updateProfileImage(File(picked.path));
  }

  Future<void> _handleLogout(BuildContext context) async {
    await context.read<AuthProvider>().logout();
    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        RouteNames.login,
        (Route<dynamic> route) => false,
      );
    }
  }

  Future<void> _handleDeleteAccount(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: const Text(
            'This will permanently remove your account. Continue?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    if (!context.mounted) {
      return;
    }

    final bool ok = await context.read<AuthProvider>().deleteAccount();
    if (ok && context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        RouteNames.login,
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ProfileProvider profile = context.watch<ProfileProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            Stack(
              alignment: Alignment.bottomRight,
              children: <Widget>[
                CircleAvatar(
                  radius: 44,
                  backgroundColor: Colors.white,
                  backgroundImage:
                      profile.photoUrl != null ? NetworkImage(profile.photoUrl!) : null,
                  child: profile.photoUrl == null
                      ? const Icon(Icons.person, size: 44)
                      : null,
                ),
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: InkWell(
                    onTap: profile.isLoading ? null : () => _pickProfileImage(context),
                    child: const CircleAvatar(
                      radius: 16,
                      child: Icon(Icons.camera_alt, size: 16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ProfileHeader(name: profile.displayName, role: profile.role),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.email),
                title: Text(profile.email),
              ),
            ),
            if (profile.error != null) ...<Widget>[
              const SizedBox(height: 8),
              Text(
                profile.error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  context.read<AppNavigationProvider>().setTab(AppTab.resources);
                },
                child: const Text('Saved Resources'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _handleLogout(context),
                child: const Text('Sign Out'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _handleDeleteAccount(context),
                child: const Text('Delete Account'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
