import 'package:equatable/equatable.dart';
import '../../../domain/entities/reminder.dart';

abstract class ReminderState extends Equatable {
  const ReminderState();
  @override
  List<Object?> get props => [];
}

class ReminderInitial extends ReminderState {
  const ReminderInitial();
}

class ReminderLoading extends ReminderState {
  const ReminderLoading();
}

class ReminderLoaded extends ReminderState {
  final List<Reminder> reminders;
  final List<Reminder> filtered;
  final String? activeCategoryId;
  const ReminderLoaded({
    required this.reminders,
    required this.filtered,
    this.activeCategoryId,
  });
  @override
  List<Object?> get props => [reminders, filtered, activeCategoryId];
}

class ReminderError extends ReminderState {
  final String message;
  const ReminderError(this.message);
  @override
  List<Object?> get props => [message];
}