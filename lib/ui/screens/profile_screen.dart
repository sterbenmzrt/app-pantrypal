import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
          _buildSectionContainer(context, [
            _buildListTile(context, 'Personal Information', Icons.person),
          ]),

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
            onPressed: () {},
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
      onTap: () {
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
}
