import 'package:flutter/material.dart';
import 'screens/login_screens.dart';
import 'screens/dashboard_screen.dart';
import 'screens/notes_screen.dart';
import 'screens/tasks_screen.dart';
import 'screens/events_screen.dart';
import 'screens/tracker_screen.dart';
import 'screens/settings_screens.dart';
import 'screens/splash_screen.dart';
import 'screens/task_form_screen.dart';
import 'models/task_model.dart';

class AppRoutes {
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String notes = '/notes';
  static const String tasks = '/tasks';
  static const String events = '/events';
  static const String tracker = '/tracker';
  static const String settings = '/settings';
  static const String taskAdd = '/task-add';
  static const String taskEdit = '/task-edit';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case AppRoutes.dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      case AppRoutes.notes:
        return MaterialPageRoute(builder: (_) => const NotesScreen());
      case AppRoutes.tasks:
        return MaterialPageRoute(builder: (_) => const TasksScreen());
      case AppRoutes.events:
        return MaterialPageRoute(builder: (_) => const EventsScreen());
      case AppRoutes.tracker:
        return MaterialPageRoute(builder: (_) => const TrackerScreen());
      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case AppRoutes.taskAdd:
        return MaterialPageRoute(builder: (_) => const TaskFormScreen());
      case AppRoutes.taskEdit:
        final task = settings.arguments as TaskModel;
        return MaterialPageRoute(builder: (_) => TaskFormScreen(task: task));
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      default:
        return MaterialPageRoute(
          builder:
              (_) => const Scaffold(body: Center(child: Text('404 Not Found'))),
        );
    }
  }

  static Route<dynamic> generateRouteWithTheme(
    RouteSettings settings,
    ValueNotifier<ThemeMode> themeNotifier,
  ) {
    switch (settings.name) {
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case AppRoutes.dashboard:
        return MaterialPageRoute(
          builder: (_) => DashboardScreen(themeNotifier: themeNotifier),
        );
      case AppRoutes.notes:
        return MaterialPageRoute(builder: (_) => const NotesScreen());
      case AppRoutes.tasks:
        return MaterialPageRoute(builder: (_) => const TasksScreen());
      case AppRoutes.events:
        return MaterialPageRoute(builder: (_) => const EventsScreen());
      case AppRoutes.tracker:
        return MaterialPageRoute(builder: (_) => const TrackerScreen());
      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case AppRoutes.taskAdd:
        return MaterialPageRoute(builder: (_) => const TaskFormScreen());
      case AppRoutes.taskEdit:
        final task = settings.arguments as TaskModel;
        return MaterialPageRoute(builder: (_) => TaskFormScreen(task: task));
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      default:
        return MaterialPageRoute(
          builder:
              (_) => const Scaffold(body: Center(child: Text('404 Not Found'))),
        );
    }
  }
}
