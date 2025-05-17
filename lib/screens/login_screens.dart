import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../routes.dart';
import '../services/local_storage_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isDark = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    await LocalStorageService.setUsername(_usernameController.text.trim());
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tododo_theme', _isDark);

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
  }

  void _toggleTheme() {
    setState(() {
      _isDark = !_isDark;
    });
  }

  @override
  Widget build(BuildContext context) {
    final gradient = LinearGradient(
      colors: [Color(0xFF6D5FFD), Color(0xFF46A0FC)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Scaffold(
      backgroundColor:
          _isDark ? const Color(0xFF181A20) : const Color(0xFFF7F8FA),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Center(
                  child: Text(
                    'TODODO',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 36),
              Text(
                "Let's Get Started!",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: _isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Enter your username to continue",
                style: TextStyle(
                  color: _isDark ? Colors.white70 : Colors.grey[600],
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 28),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _usernameController,
                      style: TextStyle(
                        color: _isDark ? Colors.white : Colors.black,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Username',
                        prefixIcon: Icon(Icons.person, color: Colors.grey[500]),
                        filled: true,
                        fillColor:
                            _isDark
                                ? const Color(0xFF23243A)
                                : Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        hintStyle: TextStyle(
                          color: _isDark ? Colors.white54 : Colors.grey[500],
                        ),
                      ),
                      enabled: !_isLoading,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Username tidak boleh kosong';
                        }
                        if (value.trim().length < 3) {
                          return 'Minimal 3 karakter';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _isDark ? Color(0xFF6D5FFD) : Color(0xFF6D5FFD),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child:
                            _isLoading
                                ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                : const Text('Continue'),
                      ),
                    ),
                    const SizedBox(height: 18),
                    // Theme toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isDark ? Icons.dark_mode : Icons.light_mode,
                          color: _isDark ? Colors.white : Colors.deepPurple,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isDark ? 'Dark Mode' : 'Light Mode',
                          style: TextStyle(
                            color: _isDark ? Colors.white : Colors.deepPurple,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Switch(
                          value: _isDark,
                          onChanged: (val) => _toggleTheme(),
                          activeColor: Color(0xFF6D5FFD),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
