import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'admin_dashboard.dart';
import '../utils/constants.dart';

class UserTypeSelection extends StatelessWidget {
  const UserTypeSelection({super.key});

  Future<void> _setUserType(BuildContext context, String type, {bool isAgent = false}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userType', type);
    
    if (type == 'customer') {
      // Generate a simple customer ID if not exists
      String? customerId = prefs.getString('customerId');
      if (customerId == null) {
        customerId = 'cust_${DateTime.now().millisecondsSinceEpoch}';
        await prefs.setString('customerId', customerId);
        await prefs.setString('customerName', 'Customer $customerId');
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen(
          toggleTheme: _emptyToggle,
          isDarkMode: false,
        )),
      );
    } else if (type == 'agent' && isAgent) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  // Empty toggle function for initial navigation
  static void _emptyToggle() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppConstants.primaryColor,
              AppConstants.primaryColor.withValues(alpha: 0.7),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              
              // Logo
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 800),
                builder: (context, double value, child) {
                  return Transform.scale(
                    scale: value,
                    child: child,
                  );
                },
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.home_work,
                    size: 60,
                    color: AppConstants.primaryColor,
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // App Name
              Text(
                AppConstants.appName,
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Tagline
              Text(
                'Find your dream property in Zambia',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Customer Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 600),
                  builder: (context, double value, child) {
                    return Transform.translate(
                      offset: Offset(0, 50 * (1 - value)),
                      child: Opacity(
                        opacity: value,
                        child: child,
                      ),
                    );
                  },
                  child: ElevatedButton(
                    onPressed: () => _setUserType(context, 'customer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppConstants.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: const Size(double.infinity, 55),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.home, color: AppConstants.primaryColor),
                        SizedBox(width: 12),
                        Text(
                          'Continue as Customer',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Agent Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: OutlinedButton(
                  onPressed: () => _setUserType(context, 'agent', isAgent: true),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size(double.infinity, 55),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.storefront),
                      SizedBox(width: 12),
                      Text(
                        'Continue as Agent',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Admin Demo Button (Hidden in production)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AdminDashboard()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white38),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.admin_panel_settings, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Admin Access',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              
              const Spacer(),
              
              // Version info
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Version ${AppConstants.appVersion}',
                  style: GoogleFonts.poppins(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}