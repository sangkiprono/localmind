import 'package:flutter/material.dart';
import '../../../domain/entities/reminder.dart';

class ReminderListItem extends StatelessWidget {
  final Reminder reminder;
  final VoidCallback onComplete;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const ReminderListItem({
    super.key,
    required this.reminder,
    required this.onComplete,
    required this.onDelete,
    required this.onTap,
  });

  Color _priorityColor(BuildContext context) {
    switch (reminder.priority) {
      case ReminderPriority.high:
        return Colors.red.shade400;
      case ReminderPriority.medium:
        return Colors.orange.shade400;
      case ReminderPriority.low:
        return Colors.green.shade400;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dismissible(
      key: Key(reminder.id),
      background: Container(
        color: Colors.green.shade600,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: const Icon(Icons.check, color: Colors.white),
      ),
      secondaryBackground: Container(
        color: Colors.red.shade600,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          onComplete();
        } else {
          onDelete();
        }
      },
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 4,
          height: 40,
          decoration: BoxDecoration(
            color: _priorityColor(context),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        title: Text(
          reminder.title,
          style: theme.textTheme.bodyLarge?.copyWith(
            decoration: reminder.isCompleted ? TextDecoration.lineThrough : null,
            color: reminder.isCompleted ? theme.colorScheme.outline : null,
          ),
        ),
        subtitle: Text(
          _formatDate(reminder.scheduledAt),
          style: theme.textTheme.bodySmall?.copyWith(
            color: _isOverdue(reminder) ? Colors.red : theme.colorScheme.outline,
          ),
        ),
        trailing: Checkbox(
          value: reminder.isCompleted,
          onChanged: (_) => onComplete(),
          shape: const CircleBorder(),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(dt.year, dt.month, dt.day);
    if (date == today) return 'Today ' + _time(dt);
    if (date == today.add(const Duration(days: 1))) return 'Tomorrow ' + _time(dt);
    return '${dt.day}/' + '${dt.month}/' + '${dt.year} ' + _time(dt);
  }

  String _time(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  bool _isOverdue(Reminder r) =>
      !r.isCompleted && r.scheduledAt.isBefore(DateTime.now());
}