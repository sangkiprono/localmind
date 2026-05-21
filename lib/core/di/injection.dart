import 'package:get_it/get_it.dart';
import '../../data/local/database/app_database.dart';
import '../../data/local/dao/reminders_dao.dart';
import '../../data/local/dao/categories_dao.dart';
import '../../data/repositories/reminder_repository_impl.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../domain/repositories/reminder_repository.dart';
import '../../domain/repositories/category_repository.dart';
import '../../presentation/reminders/bloc/reminder_bloc.dart';
import '../../presentation/categories/bloc/category_bloc.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  final db = await AppDatabase.create();
  getIt.registerSingleton<AppDatabase>(db);
  getIt.registerSingleton<RemindersDao>(db.remindersDao);
  getIt.registerSingleton<CategoriesDao>(db.categoriesDao);
  getIt.registerSingleton<ReminderRepository>(
    ReminderRepositoryImpl(getIt<RemindersDao>()),
  );
  getIt.registerSingleton<CategoryRepository>(
    CategoryRepositoryImpl(getIt<CategoriesDao>()),
  );
  getIt.registerFactory<ReminderBloc>(
    () => ReminderBloc(getIt<ReminderRepository>()),
  );
  getIt.registerFactory<CategoryBloc>(
    () => CategoryBloc(getIt<CategoryRepository>()),
  );
}