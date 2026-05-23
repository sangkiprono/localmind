import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di/injection.dart';
import '../bloc/reminder_bloc.dart';
import '../bloc/reminder_event.dart';
import '../bloc/reminder_state.dart';
import '../widgets/reminder_list_item.dart';
import '../widgets/empty_reminders.dart';

class RemindersPage extends StatelessWidget {
  const RemindersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ReminderBloc>()..add(const LoadReminders()),
      child: const _RemindersView(),
    );
  }
}

class _RemindersView extends StatefulWidget {
  const _RemindersView();

  @override
  State<_RemindersView> createState() => _RemindersViewState();
}

class _RemindersViewState extends State<_RemindersView> {
  final _searchController = TextEditingController();
  bool _showSearch = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _showSearch
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search reminders...',
                  border: InputBorder.none,
                ),
                onChanged: (q) => context.read<ReminderBloc>().add(SearchReminders(q)),
              )
            : const Text('LocalMind'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(_showSearch ? Icons.close : Icons.search),
            onPressed: () {
              setState(() => _showSearch = !_showSearch);
              if (!_showSearch) {
                _searchController.clear();
                context.read<ReminderBloc>().add(const SearchReminders(''));
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () => _showFilterSheet(context),
          ),
        ],
      ),
      body: BlocBuilder<ReminderBloc, ReminderState>(
        builder: (context, state) {
          if (state is ReminderLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ReminderError) {
            return Center(child: Text(state.message));
          }
          if (state is ReminderLoaded) {
            if (state.filtered.isEmpty) {
              return const EmptyReminders();
            }
            return ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: state.filtered.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final reminder = state.filtered[index];
                return ReminderListItem(
                  reminder: reminder,
                  onComplete: () => context.read<ReminderBloc>().add(CompleteReminder(reminder.id)),
                  onDelete: () => context.read<ReminderBloc>().add(DeleteReminder(reminder.id)),
                  onTap: () => context.push('/reminders/' + reminder.id, extra: reminder),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/reminders/new'),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(icon: Icon(Icons.notifications_outlined), label: 'Reminders'),
          NavigationDestination(icon: Icon(Icons.category_outlined), label: 'Categories'),
          NavigationDestination(icon: Icon(Icons.bar_chart_outlined), label: 'Analytics'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Settings'),
        ],
        selectedIndex: 0,
        onDestinationSelected: (index) {
          switch (index) {
            case 0: context.go('/reminders'); break;
            case 1: context.go('/categories'); break;
            case 2: context.go('/analytics'); break;
            case 3: context.go('/settings'); break;
          }
        },
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<ReminderBloc>(),
        child: const _FilterSheet(),
      ),
    );
  }
}

class _FilterSheet extends StatelessWidget {
  const _FilterSheet();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Filter by Priority', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              FilterChip(label: const Text('All'), selected: true, onSelected: (_) => Navigator.pop(context)),
              FilterChip(label: const Text('High'), selected: false, onSelected: (_) => Navigator.pop(context)),
              FilterChip(label: const Text('Medium'), selected: false, onSelected: (_) => Navigator.pop(context)),
              FilterChip(label: const Text('Low'), selected: false, onSelected: (_) => Navigator.pop(context)),
            ],
          ),
          const SizedBox(height: 16),
          Text('Filter by Status', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              FilterChip(label: const Text('All'), selected: true, onSelected: (_) => Navigator.pop(context)),
              FilterChip(label: const Text('Pending'), selected: false, onSelected: (_) => Navigator.pop(context)),
              FilterChip(label: const Text('Completed'), selected: false, onSelected: (_) => Navigator.pop(context)),
              FilterChip(label: const Text('Overdue'), selected: false, onSelected: (_) => Navigator.pop(context)),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}