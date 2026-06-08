import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/user_type_selection.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/agent_dashboard.dart';
import 'screens/settings_screen.dart';
import 'screens/agent_verification_screen.dart';  // CHANGED: Use existing file
import 'utils/constants.dart';
import 'services/mock_data_service.dart';
import 'services/sync_service.dart';
import 'services/theme_service.dart';
import 'services/chat_service.dart';
import 'services/rating_service.dart';
import 'services/complaint_service.dart';
import 'services/supabase_service.dart';
import 'services/notification_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'screens/agent_registration_screen.dart'; // Add import
import 'screens/agent_profile_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
// Initialize Notifications (skip on web)
  if (!kIsWeb) {
    try {
      await NotificationService.init();
    } catch (e) {
      print('⚠️ Notifications not available: $e');
    }
  }

  // Initialize all services
  await MockDataService.init();
  await ChatService.init();
  await RatingService.init();
  await ComplaintService.init();
  SyncService.startMonitoring();
  
  // Initialize Supabase (optional - app works without it)
  try {
    await SupabaseService.init();
    await SupabaseService.pullFromCloud();
    // SupabaseService.listenToChanges(); // Temporarily disabled
    print('✅ Supabase connected');
  } catch (e) {
    print('⚠️ Supabase not available: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final isDark = await ThemeService.isDarkMode();
    setState(() {
      _isDarkMode = isDark;
    });
  }

  void toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
      ThemeService.setDarkMode(_isDarkMode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.green,
        fontFamily: GoogleFonts.poppins().fontFamily,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: false,
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
        ),
        cardColor: Colors.white,
        dialogBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: AppConstants.secondaryColor,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.green,
        fontFamily: GoogleFonts.poppins().fontFamily,
        scaffoldBackgroundColor: Colors.grey[900],
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: false,
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
        ),
        cardColor: Colors.grey[850],
        dialogBackgroundColor: Colors.grey[850],
        colorScheme: ColorScheme.fromSwatch(
          brightness: Brightness.dark,
        ).copyWith(
          secondary: AppConstants.secondaryColor,
        ),
      ),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      initialRoute: '/',
      routes: {

        // In routes:
        '/agent-profile': (context) => const AgentProfileScreen(),
        '/agent-registration': (context) => const AgentRegistrationScreen(),
        '/': (context) => SplashScreen(toggleTheme: toggleTheme),
        '/user-type': (context) => UserTypeSelection(),
        '/home': (context) => HomeScreen(toggleTheme: toggleTheme, isDarkMode: _isDarkMode),
        '/login': (context) => LoginScreen(),
        '/agent-dashboard': (context) => AgentDashboard(toggleTheme: toggleTheme, isDarkMode: _isDarkMode),
        '/settings': (context) => SettingsScreen(),
        '/agent-verification': (context) => const AgentVerificationScreen(  // ADDED with correct name
          agentId: '',
          agentPhone: '',
        ),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  final VoidCallback toggleTheme;

  const SplashScreen({super.key, required this.toggleTheme});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    
    _animationController.forward();
    _checkUserType();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkUserType() async {
    await Future.delayed(const Duration(seconds: 2));
    final prefs = await SharedPreferences.getInstance();
    final userType = prefs.getString('userType');
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    
    if (mounted) {
      if (userType == 'agent' && isLoggedIn) {
        Navigator.pushReplacementNamed(context, '/agent-dashboard');
      } else if (userType == 'customer') {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacementNamed(context, '/user-type');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppConstants.primaryColor,
              AppConstants.primaryColor.withOpacity(0.8),
              isDark ? Colors.grey[900]! : Colors.white,
            ],
            stops: const [0.0, 0.3, 0.8],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.home_work,
                      size: 70,
                      color: AppConstants.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    AppConstants.appName,
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Find your dream property in Zambia',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 48),
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
