import 'package:equatable/equatable.dart';
import '../../../domain/entities/reminder.dart';

abstract class ReminderEvent extends Equatable {
  const ReminderEvent();
  @override
  List<Object?> get props => [];
}

class LoadReminders extends ReminderEvent {
  const LoadReminders();
}

class CreateReminder extends ReminderEvent {
  final Reminder reminder;
  const CreateReminder(this.reminder);
  @override
  List<Object?> get props => [reminder];
}

class UpdateReminder extends ReminderEvent {
  final Reminder reminder;
  const UpdateReminder(this.reminder);
  @override
  List<Object?> get props => [reminder];
}

class DeleteReminder extends ReminderEvent {
  final String id;
  const DeleteReminder(this.id);
  @override
  List<Object?> get props => [id];
}

class CompleteReminder extends ReminderEvent {
  final String id;
  const CompleteReminder(this.id);
  @override
  List<Object?> get props => [id];
}

class FilterByCategory extends ReminderEvent {
  final String? categoryId;
  const FilterByCategory(this.categoryId);
  @override
  List<Object?> get props => [categoryId];
}

class SearchReminders extends ReminderEvent {
  final String query;
  const SearchReminders(this.query);
  @override
  List<Object?> get props => [query];
}