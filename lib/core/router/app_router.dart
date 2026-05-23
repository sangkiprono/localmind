import 'package:go_router/go_router.dart';
import '../../presentation/reminders/pages/reminders_page.dart';
import '../../presentation/categories/pages/categories_page.dart';
import '../../presentation/analytics/pages/analytics_page.dart';
import '../../presentation/settings/pages/settings_page.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/reminders',
    routes: [
      GoRoute(
        path: '/reminders',
        builder: (context, state) => const RemindersPage(),
      ),
      GoRoute(
        path: '/categories',
        builder: (context, state) => const CategoriesPage(),
      ),
      GoRoute(
        path: '/analytics',
        builder: (context, state) => const AnalyticsPage(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
    ],
  );
}