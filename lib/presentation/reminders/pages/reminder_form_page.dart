import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../core/di/injection.dart';
import '../../../domain/entities/reminder.dart';
import '../bloc/reminder_bloc.dart';
import '../bloc/reminder_event.dart';

class ReminderFormPage extends StatefulWidget {
  final dynamic reminder;
  const ReminderFormPage({super.key, this.reminder});

  @override
  State<ReminderFormPage> createState() => _ReminderFormPageState();
}

class _ReminderFormPageState extends State<ReminderFormPage> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  DateTime _scheduledAt = DateTime.now().add(const Duration(hours: 1));
  ReminderPriority _priority = ReminderPriority.medium;
  bool _isAllDay = false;
  late final ReminderBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = getIt<ReminderBloc>();
    if (widget.reminder != null) {
      final r = widget.reminder as Reminder;
      _titleController.text = r.title;
      _descController.text = r.description ?? '';
      _scheduledAt = r.scheduledAt;
      _priority = r.priority;
      _isAllDay = r.isAllDay;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _bloc.close();
    super.dispose();
  }

  void _save() {
    if (_titleController.text.trim().isEmpty) return;
    final now = DateTime.now();
    if (widget.reminder == null) {
      _bloc.add(CreateReminder(Reminder(
        id: const Uuid().v4(),
        title: _titleController.text.trim(),
        description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
        scheduledAt: _scheduledAt,
        isAllDay: _isAllDay,
        priority: _priority,
        createdAt: now,
        updatedAt: now,
      )));
    } else {
      final r = widget.reminder as Reminder;
      _bloc.add(UpdateReminder(Reminder(
        id: r.id,
        title: _titleController.text.trim(),
        description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
        scheduledAt: _scheduledAt,
        isAllDay: _isAllDay,
        priority: _priority,
        categoryId: r.categoryId,
        isCompleted: r.isCompleted,
        isSnoozed: r.isSnoozed,
        createdAt: r.createdAt,
        updatedAt: now,
      )));
    }
    context.pop();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _scheduledAt,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (date == null) return;
    if (!mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_scheduledAt),
    );
    if (time == null) return;
    setState(() {
      _scheduledAt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.reminder != null;
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        appBar: AppBar(
          title: Text(isEdit ? 'Edit Reminder' : 'New Reminder'),
          actions: [
            TextButton(
              onPressed: _save,
              child: const Text('Save'),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Date & Time'),
              subtitle: Text(_scheduledAt.toString().substring(0, 16)),
              trailing: const Icon(Icons.calendar_today_outlined),
              onTap: _pickDateTime,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('All Day'),
              value: _isAllDay,
              onChanged: (v) => setState(() => _isAllDay = v),
            ),
            const SizedBox(height: 8),
            const Text('Priority'),
            const SizedBox(height: 8),
            SegmentedButton<ReminderPriority>(
              segments: const [
                ButtonSegment(value: ReminderPriority.low, label: Text('Low')),
                ButtonSegment(value: ReminderPriority.medium, label: Text('Medium')),
                ButtonSegment(value: ReminderPriority.high, label: Text('High')),
              ],
              selected: {_priority},
              onSelectionChanged: (v) => setState(() => _priority = v.first),
            ),
          ],
        ),
      ),
    );
  }
}