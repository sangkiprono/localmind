import 'package:go_router/go_router.dart';
import '../../presentation/reminders/pages/reminders_page.dart';
import '../../presentation/reminders/pages/reminder_form_page.dart';
import '../../presentation/categories/pages/categories_page.dart';
import '../../presentation/analytics/pages/analytics_page.dart';
import '../../presentation/settings/pages/settings_page.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/reminders',
    routes: [
      GoRoute(path: '/reminders', name: 'reminders', builder: (context, state) => const RemindersPage()),
      GoRoute(path: '/reminders/new', name: 'new-reminder', builder: (context, state) => const ReminderFormPage()),
      GoRoute(path: '/reminders/:id', name: 'edit-reminder', builder: (context, state) => ReminderFormPage(reminder: state.extra as dynamic)),
      GoRoute(path: '/categories', name: 'categories', builder: (context, state) => const CategoriesPage()),
      GoRoute(path: '/analytics', name: 'analytics', builder: (context, state) => const AnalyticsPage()),
      GoRoute(path: '/settings', name: 'settings', builder: (context, state) => const SettingsPage()),
    ],
  );
}