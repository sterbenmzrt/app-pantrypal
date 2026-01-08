import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/auth/auth_bloc.dart';
import '../../logic/auth/auth_event.dart';
import '../../logic/settings/settings_bloc.dart';
import '../../logic/settings/settings_event.dart';
import '../../logic/settings/settings_state.dart';
import '../../logic/user/user_bloc.dart';
import '../../logic/user/user_state.dart';
import '../../logic/user/user_event.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Header
          BlocBuilder<UserBloc, UserState>(
            builder: (context, state) {
              final user = state.profile;
              return Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image:
                            user.profileImage != null &&
                                    user.profileImage!.isNotEmpty
                                ? NetworkImage(user.profileImage!)
                                : const NetworkImage(
                                  'https://lh3.googleusercontent.com/aida-public/AB6AXuDcXm9c_-O7N4H5C0XltaEsuYkAeSowAeqOdRcp_rqlIFARGzXwadNA4AJAUdMmprS8n7GZQirvIcX7XtLGBq5_QoXsm3M3eem7_FNBWrQOj6tzy-PPvmR2ZFA-aHYRiZ30Ev1qjCnkueyItslEHyUVR5o2Gu3XhKhKMbo9srNkJEPgLICecuwI9120513mE1gv6QqlewdX4MlCT6JkSW6Gsd0Ioh_QG98zKaeLeCRwtwSrhfI5ai5xzPlCtmDoQ5ZzI_jeNgJqGw',
                                ),
                        fit: BoxFit.cover,
                      ),
                      color: Colors.grey[300],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.name.isEmpty ? 'Set Your Name' : user.name,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    user.email.isEmpty ? 'Set Your Email' : user.email,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () => _showEditProfileDialog(context, user),
                    child: const Text('Edit Profile'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      side: BorderSide(color: theme.primaryColor),
                      foregroundColor: theme.primaryColor,
                      backgroundColor: theme.primaryColor.withOpacity(0.1),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 32),

          _buildSectionTitle(context, 'Account'),
          BlocBuilder<UserBloc, UserState>(
            builder: (context, userState) {
              return _buildSectionContainer(context, [
                _buildListTile(
                  context,
                  'Personal Information',
                  Icons.person,
                  onTap:
                      () => _showPersonalInfoPopup(context, userState.profile),
                ),
              ]);
            },
          ),

          _buildSectionTitle(context, 'App Settings'),
          _buildSectionContainer(context, [
            _buildListTile(
              context,
              'Theme',
              Icons.contrast,
              trailing: BlocBuilder<SettingsBloc, SettingsState>(
                builder: (context, state) {
                  return Text(
                    state.themeMode.name[0].toUpperCase() +
                        state.themeMode.name.substring(1),
                  );
                },
              ),
            ),
          ]),

          const SizedBox(height: 32),
          TextButton(
            onPressed: () => _showLogoutConfirmation(context),
            child: const Text(
              'Log Out',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 16, left: 4),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildSectionContainer(BuildContext context, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1)),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildListTile(
    BuildContext context,
    String title,
    IconData icon, {
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Theme.of(context).primaryColor),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailing != null) ...[trailing, const SizedBox(width: 8)],
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
      onTap:
          onTap ??
          () {
            if (title == 'Theme') {
              _showThemeSelector(context);
            }
          },
    );
  }

  void _showThemeSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Select Theme',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                _buildThemeOption(context, 'System', ThemeMode.system),
                _buildThemeOption(context, 'Light', ThemeMode.light),
                _buildThemeOption(context, 'Dark', ThemeMode.dark),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildThemeOption(BuildContext context, String title, ThemeMode mode) {
    final currentMode = context.read<SettingsBloc>().state.themeMode;
    return ListTile(
      title: Text(title),
      trailing:
          currentMode == mode
              ? const Icon(Icons.check, color: Colors.green)
              : null,
      onTap: () {
        context.read<SettingsBloc>().add(ChangeTheme(mode));
        Navigator.pop(context);
      },
    );
  }

  void _showEditProfileDialog(BuildContext context, dynamic user) {
    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final newName = nameController.text.trim();
                final newEmail = emailController.text.trim();

                final updatedUser = user.copyWith(
                  name: newName,
                  email: newEmail,
                );

                context.read<UserBloc>().add(UpdateUserProfile(updatedUser));
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showPersonalInfoPopup(BuildContext context, dynamic user) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.person, color: theme.primaryColor),
              ),
              const SizedBox(width: 12),
              const Text('Personal Information'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Profile Image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image:
                        user.profileImage != null &&
                                user.profileImage!.isNotEmpty
                            ? NetworkImage(user.profileImage!)
                            : const NetworkImage(
                              'https://lh3.googleusercontent.com/aida-public/AB6AXuDcXm9c_-O7N4H5C0XltaEsuYkAeSowAeqOdRcp_rqlIFARGzXwadNA4AJAUdMmprS8n7GZQirvIcX7XtLGBq5_QoXsm3M3eem7_FNBWrQOj6tzy-PPvmR2ZFA-aHYRiZ30Ev1qjCnkueyItslEHyUVR5o2Gu3XhKhKMbo9srNkJEPgLICecuwI9120513mE1gv6QqlewdX4MlCT6JkSW6Gsd0Ioh_QG98zKaeLeCRwtwSrhfI5ai5xzPlCtmDoQ5ZzI_jeNgJqGw',
                            ),
                    fit: BoxFit.cover,
                  ),
                  color: Colors.grey[300],
                ),
              ),
              const SizedBox(height: 24),
              // Info Items
              _buildInfoRow(
                context,
                'Full Name',
                user.name.isEmpty ? 'Not set' : user.name,
                Icons.badge,
              ),
              const Divider(height: 1),
              _buildInfoRow(
                context,
                'Email',
                user.email.isEmpty ? 'Not set' : user.email,
                Icons.email,
              ),
              const Divider(height: 1),
              _buildInfoRow(
                context,
                'User ID',
                user.id?.toString() ?? 'N/A',
                Icons.fingerprint,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showEditProfileDialog(context, user);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Edit'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: theme.primaryColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    // Capture the AuthBloc reference before showing the dialog
    final authBloc = context.read<AuthBloc>();
    print('Profile: AuthBloc captured: $authBloc');

    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Log Out'),
            content: const Text('Are you sure you want to log out?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  print(
                    'Profile: Logout button pressed, dispatching LogoutRequested',
                  );
                  authBloc.add(LogoutRequested());
                  Navigator.pop(dialogContext);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Log Out'),
              ),
            ],
          ),
    );
  }
}
