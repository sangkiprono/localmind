import 'package:drift/drift.dart' show Value;
import '../../domain/entities/category.dart' as entity;
import '../../domain/repositories/category_repository.dart';
import '../local/dao/categories_dao.dart';
import '../local/database/app_database.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoriesDao _dao;
  CategoryRepositoryImpl(this._dao);

  @override
  Future<List<entity.Category>> getAllCategories() async {
    final rows = await _dao.getAllCategories();
    return rows.map((r) => entity.Category(
      id: r.id,
      name: r.name,
      colorValue: r.colorValue,
      createdAt: r.createdAt,
    )).toList();
  }

  @override
  Future<void> createCategory(entity.Category category) async {
    await _dao.insertCategory(CategoriesCompanion(
      id: Value(category.id),
      name: Value(category.name),
      colorValue: Value(category.colorValue),
      createdAt: Value(category.createdAt),
    ));
  }

  @override
  Future<void> updateCategory(entity.Category category) async {
    await _dao.updateCategory(CategoriesCompanion(
      id: Value(category.id),
      name: Value(category.name),
      colorValue: Value(category.colorValue),
      createdAt: Value(category.createdAt),
    ));
  }

  @override
  Future<void> deleteCategory(String id) async {
    await _dao.deleteCategory(id);
  }
}