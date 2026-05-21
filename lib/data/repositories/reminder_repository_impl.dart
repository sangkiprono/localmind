import 'package:drift/drift.dart' show Value;
import '../../domain/entities/reminder.dart' as entity;
import '../../domain/repositories/reminder_repository.dart';
import '../local/dao/reminders_dao.dart';
import '../local/database/app_database.dart';
import '../local/database/tables.dart';

class ReminderRepositoryImpl implements ReminderRepository {
  final RemindersDao _dao;
  ReminderRepositoryImpl(this._dao);

  @override
  Future<List<entity.Reminder>> getAllReminders() async {
    final rows = await _dao.getAllReminders();
    return rows.map<entity.Reminder>(_fromRow).toList();
  }

  @override
  Future<entity.Reminder?> getReminderById(String id) async {
    final row = await _dao.getReminderById(id);
    return row == null ? null : _fromRow(row);
  }

  @override
  Future<void> createReminder(entity.Reminder reminder) async {
    await _dao.insertReminder(_toCompanion(reminder));
  }

  @override
  Future<void> updateReminder(entity.Reminder reminder) async {
    await _dao.updateReminder(_toCompanion(reminder));
  }

  @override
  Future<void> deleteReminder(String id) async {
    await _dao.deleteReminder(id);
  }

  @override
  Future<List<entity.Reminder>> getRemindersByCategory(String categoryId) async {
    final rows = await _dao.getRemindersByCategory(categoryId);
    return rows.map<entity.Reminder>(_fromRow).toList();
  }

  @override
  Future<List<entity.Reminder>> getUpcomingReminders(DateTime from, DateTime to) async {
    final rows = await _dao.getPendingReminders();
    return rows.map<entity.Reminder>(_fromRow).where((r) =>
      r.scheduledAt.isAfter(from) && r.scheduledAt.isBefore(to)).toList();
  }

  entity.Reminder _fromRow(Reminder row) {
    return entity.Reminder(
      id: row.id,
      title: row.title,
      description: row.description,
      scheduledAt: row.scheduledAt,
      isAllDay: row.isAllDay,
      priority: entity.ReminderPriority.values[row.priority],
      repeatType: entity.RepeatType.values.firstWhere((e) => e.name == row.repeatType),
      categoryId: row.categoryId,
      isCompleted: row.isCompleted,
      isSnoozed: row.isSnoozed,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  RemindersCompanion _toCompanion(entity.Reminder r) {
    return RemindersCompanion(
      id: Value(r.id),
      title: Value(r.title),
      description: Value(r.description),
      scheduledAt: Value(r.scheduledAt),
      isAllDay: Value(r.isAllDay),
      priority: Value(r.priority.index),
      repeatType: Value(r.repeatType.name),
      categoryId: Value(r.categoryId),
      isCompleted: Value(r.isCompleted),
      isSnoozed: Value(r.isSnoozed),
      createdAt: Value(r.createdAt),
      updatedAt: Value(r.updatedAt),
    );
  }
}