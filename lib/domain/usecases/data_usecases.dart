import '../repositories/reminder_repository.dart';
import '../repositories/category_repository.dart';
import '../entities/reminder.dart';
import '../entities/category.dart';

class ExportDataUseCase {
  final ReminderRepository _reminderRepo;
  final CategoryRepository _categoryRepo;

  ExportDataUseCase(this._reminderRepo, this._categoryRepo);

  Future<String> toCsv() async {
    final reminders = await _reminderRepo.getAllReminders();
    final categories = await _categoryRepo.getAllCategories();

    final categoryMap = {for (var c in categories) c.id: c.name};

    final buffer = StringBuffer();
    buffer.writeln('id,title,description,scheduledAt,priority,repeatType,category,isCompleted,isAllDay');

    for (final r in reminders) {
      final category = categoryMap[r.categoryId] ?? '';
      final desc = (r.description ?? '').replaceAll(',', ';');
      buffer.writeln('${r.id},'
          + '${r.title},'
          + '${desc},'
          + '${r.scheduledAt.toIso8601String()},'
          + '${r.priority.name},'
          + '${r.repeatType.name},'
          + '${category},'
          + '${r.isCompleted},'
          + '${r.isAllDay}');
    }
    return buffer.toString();
  }
}

class ClearAllDataUseCase {
  final ReminderRepository _reminderRepo;
  final CategoryRepository _categoryRepo;

  ClearAllDataUseCase(this._reminderRepo, this._categoryRepo);

  Future<void> execute() async {
    final reminders = await _reminderRepo.getAllReminders();
    for (final r in reminders) {
      await _reminderRepo.deleteReminder(r.id);
    }
    final categories = await _categoryRepo.getAllCategories();
    for (final c in categories) {
      await _categoryRepo.deleteCategory(c.id);
    }
  }
}