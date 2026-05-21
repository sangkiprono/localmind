import 'package:equatable/equatable.dart';

enum ReminderPriority { low, medium, high }
enum RepeatType { none, daily, weekly, monthly, custom }

class Reminder extends Equatable {
  final String id;
  final String title;
  final String? description;
  final DateTime scheduledAt;
  final bool isAllDay;
  final ReminderPriority priority;
  final RepeatType repeatType;
  final String? categoryId;
  final bool isCompleted;
  final bool isSnoozed;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Reminder({
    required this.id,
    required this.title,
    this.description,
    required this.scheduledAt,
    this.isAllDay = false,
    this.priority = ReminderPriority.medium,
    this.repeatType = RepeatType.none,
    this.categoryId,
    this.isCompleted = false,
    this.isSnoozed = false,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, title, scheduledAt, isCompleted];
}