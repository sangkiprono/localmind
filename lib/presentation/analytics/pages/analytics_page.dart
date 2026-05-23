import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection.dart';
import '../../reminders/bloc/reminder_bloc.dart';
import '../../reminders/bloc/reminder_event.dart';
import '../../reminders/bloc/reminder_state.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ReminderBloc>()..add(const LoadReminders()),
      child: const _AnalyticsView(),
    );
  }
}

class _AnalyticsView extends StatelessWidget {
  const _AnalyticsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        centerTitle: false,
      ),
      body: BlocBuilder<ReminderBloc, ReminderState>(
        builder: (context, state) {
          if (state is ReminderLoading) return const Center(child: CircularProgressIndicator());
          if (state is ReminderLoaded) {
            final total = state.reminders.length;
            final completed = state.reminders.where((r) => r.isCompleted).length;
            final pending = total - completed;
            final overdue = state.reminders.where((r) => !r.isCompleted && r.scheduledAt.isBefore(DateTime.now())).length;
            final rate = total == 0 ? 0.0 : completed / total;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _StatCard(label: 'Total Reminders', value: total.toString()),
                const SizedBox(height: 12),
                _StatCard(label: 'Completed', value: completed.toString(), color: Colors.green),
                const SizedBox(height: 12),
                _StatCard(label: 'Pending', value: pending.toString(), color: Colors.orange),
                const SizedBox(height: 12),
                _StatCard(label: 'Overdue', value: overdue.toString(), color: Colors.red),
                const SizedBox(height: 12),
                _StatCard(label: 'Completion Rate', value: '${(rate * 100).toStringAsFixed(1)}%', color: Colors.blue),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
      bottomNavigationBar: _BottomNav(selectedIndex: 2),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  const _StatCard({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: theme.textTheme.bodyLarge),
            Text(value, style: theme.textTheme.headlineSmall?.copyWith(
              color: color ?? theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            )),
          ],
        ),
      ),
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
          case 2: break;
          case 3: Navigator.pushReplacementNamed(context, '/settings'); break;
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