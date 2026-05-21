import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../database/tables.dart';

part 'reminders_dao.g.dart';

@DriftAccessor(tables: [Reminders])
class RemindersDao extends DatabaseAccessor<AppDatabase>
    with _$RemindersDaoMixin {
  RemindersDao(super.db);

  Future<List<Reminder>> getAllReminders() => select(reminders).get();

  Future<Reminder?> getReminderById(String id) =>
      (select(reminders)..where((r) => r.id.equals(id))).getSingleOrNull();

  Future<List<Reminder>> getRemindersByCategory(String categoryId) =>
      (select(reminders)..where((r) => r.categoryId.equals(categoryId))).get();

  Future<List<Reminder>> getPendingReminders() =>
      (select(reminders)..where((r) => r.isCompleted.equals(false))).get();

  Future<int> insertReminder(RemindersCompanion reminder) =>
      into(reminders).insert(reminder);

  Future<bool> updateReminder(RemindersCompanion reminder) =>
      update(reminders).replace(reminder);

  Future<int> deleteReminder(String id) =>
      (delete(reminders)..where((r) => r.id.equals(id))).go();

  Future<int> markComplete(String id) =>
      (update(reminders)..where((r) => r.id.equals(id)))
          .write(const RemindersCompanion(isCompleted: Value(true)));

  Future<int> snoozeReminder(String id, DateTime newTime) =>
      (update(reminders)..where((r) => r.id.equals(id))).write(
        RemindersCompanion(
          isSnoozed: const Value(true),
          scheduledAt: Value(newTime),
          updatedAt: Value(DateTime.now()),
        ),
      );
}