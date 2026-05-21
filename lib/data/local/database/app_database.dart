import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';
import '../database/tables.dart';
import '../dao/reminders_dao.dart';
import '../dao/categories_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Reminders, Categories], daos: [RemindersDao, CategoriesDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase._internal(super.e);

  static Future<AppDatabase> create() async {
    final db = await WasmDatabase.open(
      databaseName: 'localmind_db',
      sqlite3Uri: Uri.parse('/sql-wasm.wasm'),
      driftWorkerUri: Uri.parse('/drift_worker.dart.js'),
    );
    return AppDatabase._internal(db.resolvedExecutor);
  }

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _insertDefaultCategories();
        },
      );

  Future<void> _insertDefaultCategories() async {
    final defaults = [
      CategoriesCompanion.insert(id: 'cat_personal', name: 'Personal', colorValue: 0xFF1A73E8, createdAt: DateTime.now()),
      CategoriesCompanion.insert(id: 'cat_work', name: 'Work', colorValue: 0xFF0F9D58, createdAt: DateTime.now()),
      CategoriesCompanion.insert(id: 'cat_health', name: 'Health', colorValue: 0xFFDB4437, createdAt: DateTime.now()),
    ];
    for (final cat in defaults) {
      await into(categories).insert(cat);
    }
  }
}