import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import 'agent_dashboard.dart';
import 'agent_registration_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  // Demo credentials (store registered agents too)
  final Map<String, String> _demoAgents = {
    '+260977123456': 'password123',
    '+260966789012': 'password123',
  };

  Future<void> _login() async {
    if (_phoneController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 1));

    // Check registered agents from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final registeredPhone = prefs.getString('agentPhone');
    final registeredPassword = prefs.getString('agentPassword');
    
    // Check demo OR registered agent
    bool isValid = false;
    
    if (_demoAgents.containsKey(_phoneController.text) &&
        _demoAgents[_phoneController.text] == _passwordController.text) {
      isValid = true;
    } else if (registeredPhone == _phoneController.text && 
               registeredPassword == _passwordController.text) {
      isValid = true;
    }
    
    if (isValid) {
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('agentPhone', _phoneController.text);
      await prefs.setString('userType', 'agent');
      
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AgentDashboard(
              toggleTheme: () {},
              isDarkMode: false,
            ),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid phone or password')),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(  // FIX: Wrap with ScrollView
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: AppConstants.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.storefront,
                  size: 50,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                AppConstants.appName,
                style: AppConstants.headline1.copyWith(
                  color: AppConstants.primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Agent Login',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 32),
              
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  hintText: '+260XXXXXXXXX',
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Login'),
                ),
              ),
              
              const SizedBox(height: 16),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AgentRegistrationScreen(),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppConstants.primaryColor,
                    ),
                    child: const Text(
                      'Register as Agent',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  children: [
                    Text(
                      'Demo Credentials:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text('Phone: +260977123456'),
                    Text('Password: password123'),
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
