import 'package:get_it/get_it.dart';
import '../../data/local/database/app_database.dart';
import '../../data/local/dao/reminders_dao.dart';
import '../../data/local/dao/categories_dao.dart';
import '../../data/repositories/reminder_repository_impl.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../domain/repositories/reminder_repository.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/usecases/data_usecases.dart';
import '../../presentation/reminders/bloc/reminder_bloc.dart';
import '../../presentation/categories/bloc/category_bloc.dart';
import '../../services/notifications/notification_service.dart';
import '../../core/theme/theme_cubit.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  final db = AppDatabase();
  getIt.registerSingleton<AppDatabase>(db);
  getIt.registerSingleton<RemindersDao>(db.remindersDao);
  getIt.registerSingleton<CategoriesDao>(db.categoriesDao);
  getIt.registerSingleton<ReminderRepository>(
    ReminderRepositoryImpl(getIt<RemindersDao>()),
  );
  getIt.registerSingleton<CategoryRepository>(
    CategoryRepositoryImpl(getIt<CategoriesDao>()),
  );
  getIt.registerSingleton<ExportDataUseCase>(
    ExportDataUseCase(getIt<ReminderRepository>(), getIt<CategoryRepository>()),
  );
  getIt.registerSingleton<ClearAllDataUseCase>(
    ClearAllDataUseCase(getIt<ReminderRepository>(), getIt<CategoryRepository>()),
  );
  final notificationService = NotificationService();
  await notificationService.init();
  getIt.registerSingleton<NotificationService>(notificationService);
  getIt.registerFactory<ReminderBloc>(
    () => ReminderBloc(getIt<ReminderRepository>(), getIt<NotificationService>()),
  );
  getIt.registerFactory<CategoryBloc>(
    () => CategoryBloc(getIt<CategoryRepository>()),
  );
  final themeCubit = ThemeCubit();
  await themeCubit.loadTheme();
  getIt.registerSingleton<ThemeCubit>(themeCubit);
}