import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/reminder_repository.dart';
import '../../../domain/entities/reminder.dart';
import 'reminder_event.dart';
import 'reminder_state.dart';

class ReminderBloc extends Bloc<ReminderEvent, ReminderState> {
  final ReminderRepository _repository;

  ReminderBloc(this._repository) : super(const ReminderInitial()) {
    on<LoadReminders>(_onLoad);
    on<CreateReminder>(_onCreate);
    on<UpdateReminder>(_onUpdate);
    on<DeleteReminder>(_onDelete);
    on<CompleteReminder>(_onComplete);
    on<FilterByCategory>(_onFilter);
  }

  Future<void> _onLoad(LoadReminders event, Emitter<ReminderState> emit) async {
    emit(const ReminderLoading());
    try {
      final reminders = await _repository.getAllReminders();
      emit(ReminderLoaded(reminders: reminders, filtered: reminders));
    } catch (e) {
      emit(ReminderError(e.toString()));
    }
  }

  Future<void> _onCreate(CreateReminder event, Emitter<ReminderState> emit) async {
    try {
      await _repository.createReminder(event.reminder);
      add(const LoadReminders());
    } catch (e) {
      emit(ReminderError(e.toString()));
    }
  }

  Future<void> _onUpdate(UpdateReminder event, Emitter<ReminderState> emit) async {
    try {
      await _repository.updateReminder(event.reminder);
      add(const LoadReminders());
    } catch (e) {
      emit(ReminderError(e.toString()));
    }
  }

  Future<void> _onDelete(DeleteReminder event, Emitter<ReminderState> emit) async {
    try {
      await _repository.deleteReminder(event.id);
      add(const LoadReminders());
    } catch (e) {
      emit(ReminderError(e.toString()));
    }
  }

  Future<void> _onComplete(CompleteReminder event, Emitter<ReminderState> emit) async {
    final current = state;
    if (current is ReminderLoaded) {
      final reminder = current.reminders.firstWhere((r) => r.id == event.id);
      final updated = Reminder(
        id: reminder.id,
        title: reminder.title,
        description: reminder.description,
        scheduledAt: reminder.scheduledAt,
        isAllDay: reminder.isAllDay,
        priority: reminder.priority,
        repeatType: reminder.repeatType,
        categoryId: reminder.categoryId,
        isCompleted: true,
        isSnoozed: reminder.isSnoozed,
        createdAt: reminder.createdAt,
        updatedAt: DateTime.now(),
      );
      await _repository.updateReminder(updated);
      add(const LoadReminders());
    }
  }

  Future<void> _onFilter(FilterByCategory event, Emitter<ReminderState> emit) async {
    final current = state;
    if (current is ReminderLoaded) {
      final filtered = event.categoryId == null
          ? current.reminders
          : current.reminders.where((r) => r.categoryId == event.categoryId).toList();
      emit(ReminderLoaded(
        reminders: current.reminders,
        filtered: filtered,
        activeCategoryId: event.categoryId,
      ));
    }
  }
}