import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'routes.dart'; // Pastikan file routes.dart sudah ada dan benar
import 'screens/login_screens.dart';
import 'screens/dashboard_screen.dart';
import 'screens/tasks_screen.dart';
import 'screens/events_screen.dart';
import 'screens/settings_screens.dart';
import 'screens/dashboard_screen.dart' show CustomBottomNavBar;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('tododo_theme') ?? false;
  final themeNotifier = ValueNotifier<ThemeMode>(
    isDark ? ThemeMode.dark : ThemeMode.light,
  );
  runApp(TododoApp(themeNotifier: themeNotifier));
}

class TododoApp extends StatelessWidget {
  final ValueNotifier<ThemeMode> themeNotifier;
  const TododoApp({super.key, required this.themeNotifier});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'Tododo',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
            brightness: Brightness.light,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
            brightness: Brightness.dark,
          ),
          themeMode: mode,
          initialRoute: '/',
          onGenerateRoute:
              (settings) =>
                  AppRoutes.generateRouteWithTheme(settings, themeNotifier),
        );
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('tododo_username');
    await Future.delayed(const Duration(milliseconds: 800));
    if (username == null || username.isEmpty) {
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      Navigator.pushReplacementNamed(context, '/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Contoh login sederhana
    final TextEditingController controller = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('tododo_username', controller.text);
                // Setelah login, arahkan ke dashboard
                // ignore: use_build_context_synchronously
                Navigator.pushReplacementNamed(context, '/dashboard');
              },
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: const Center(child: Text('Welcome to Tododo!')),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({Key? key}) : super(key: key);

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  final GlobalKey<TasksScreenState> _taskKey = GlobalKey<TasksScreenState>();
  final GlobalKey<DashboardScreenState> _dashboardKey =
      GlobalKey<DashboardScreenState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const BouncingScrollPhysics(),
        onPageChanged: (i) => setState(() => _currentIndex = i),
        children: [
          DashboardScreen(key: _dashboardKey),
          TasksScreen(key: _taskKey),
          const EventsScreen(),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTabSelected: (index) {
          setState(() => _currentIndex = index);
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
          );
        },
        onFabPressed: () {
          if (_currentIndex == 0) {
            // Dashboard: show add dialog (task/event/note)
            // Akan dipanggil dari DashboardScreen
          } else if (_currentIndex == 1) {
            // Task: langsung add task
            _taskKey.currentState?.addTaskFromNav();
          } else if (_currentIndex == 2) {
            // Event: langsung add event
            // Implementasi sesuai kebutuhan
          }
        },
      ),
    );
  }
}
