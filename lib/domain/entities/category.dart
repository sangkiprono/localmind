import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final String id;
  final String name;
  final int colorValue;
  final DateTime createdAt;

  const Category({
    required this.id,
    required this.name,
    required this.colorValue,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, name];
}