import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection.dart';
import '../../../core/theme/theme_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<ThemeCubit>(),
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: false,
      ),
      body: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return ListView(
            children: [
              const _SectionHeader('Appearance'),
              SwitchListTile(
                title: const Text('Dark Mode'),
                subtitle: const Text('Use dark theme'),
                value: themeMode == ThemeMode.dark,
                onChanged: (_) => context.read<ThemeCubit>().toggleTheme(),
              ),
              const Divider(),
              const _SectionHeader('Notifications'),
              ListTile(
                title: const Text('Default Snooze Duration'),
                subtitle: const Text('10 minutes'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              ListTile(
                title: const Text('Notification Sound'),
                subtitle: const Text('Default'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              const Divider(),
              const _SectionHeader('Data'),
              ListTile(
                title: const Text('Export Reminders'),
                trailing: const Icon(Icons.download_outlined),
                onTap: () {},
              ),
              ListTile(
                title: const Text('Clear All Data'),
                trailing: const Icon(Icons.delete_outline, color: Colors.red),
                onTap: () => _confirmClearData(context),
              ),
              const Divider(),
              const _SectionHeader('About'),
              const ListTile(
                title: Text('Version'),
                trailing: Text('1.0.0'),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: _BottomNav(selectedIndex: 3),
    );
  }

  void _confirmClearData(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text('This will delete all reminders and categories. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.primary,
        )),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int selectedIndex;
  const _BottomNav({required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) {
        switch (index) {
          case 0: Navigator.pushReplacementNamed(context, '/reminders'); break;
          case 1: Navigator.pushReplacementNamed(context, '/categories'); break;
          case 2: Navigator.pushReplacementNamed(context, '/analytics'); break;
          case 3: break;
        }
      },
      destinations: const [
        NavigationDestination(icon: Icon(Icons.notifications_outlined), label: 'Reminders'),
        NavigationDestination(icon: Icon(Icons.category_outlined), label: 'Categories'),
        NavigationDestination(icon: Icon(Icons.bar_chart_outlined), label: 'Analytics'),
        NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Settings'),
      ],
    );
  }
}