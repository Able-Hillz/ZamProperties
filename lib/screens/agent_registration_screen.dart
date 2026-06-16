import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../services/hive_service.dart';
import '../models/agent.dart';
import 'agent_dashboard.dart';
import '../services/supabase_service.dart';

class AgentRegistrationScreen extends StatefulWidget {
  const AgentRegistrationScreen({super.key});

  @override
  State<AgentRegistrationScreen> createState() => _AgentRegistrationScreenState();
}

class _AgentRegistrationScreenState extends State<AgentRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _companyController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _licenseController = TextEditingController();  // Now REQUIRED
  final _whatsappController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _whatsappSameAsPhone = true;

  Future<void> _registerAndLogin() async {
  if (!_formKey.currentState!.validate()) return;
  
  setState(() => _isLoading = true);
  
  await Future.delayed(const Duration(milliseconds: 500));
  
  final prefs = await SharedPreferences.getInstance();
  final agentId = DateTime.now().millisecondsSinceEpoch.toString();
  
  // Check if phone already registered
  final existingPhone = prefs.getString('agentPhone');
  if (existingPhone == _phoneController.text) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('This phone number is already registered')),
    );
    setState(() => _isLoading = false);
    return;
  }
  
  // Determine WhatsApp number
  final whatsappNumber = _whatsappSameAsPhone 
      ? _phoneController.text 
      : _whatsappController.text;
  
  // Create Agent object
  final agent = Agent(
    id: agentId,
    name: _nameController.text,
    phone: _phoneController.text,
    whatsapp: whatsappNumber,
    email: _emailController.text.isNotEmpty ? _emailController.text : null,
    isVerified: false,
    profileImageUrl: null,
    companyName: _companyController.text.isNotEmpty ? _companyController.text : 'Independent Agent',
    tpin: null,
    licenseNumber: _licenseController.text,
    passwordHash: _passwordController.text,
    trustPoints: 75,
    verificationLevel: 'basicVerified',
    averageRating: 0.0,
    totalReviews: 0,
    createdAt: DateTime.now(),
  );
  
  // Save to Hive (local)
  await HiveService.saveAgent(agent);
  
  // Sync to Supabase (cloud) - FIXED: Added this!
  if (SupabaseService.isAvailable) {
    await SupabaseService.syncLocalToCloud();
  }
  
  // Save to SharedPreferences for quick access
  await prefs.setBool('isRegistered', true);
  await prefs.setString('userType', 'agent');
  await prefs.setString('agentId', agentId);
  await prefs.setString('agentName', _nameController.text);
  await prefs.setString('agentPhone', _phoneController.text);
  await prefs.setString('agentPassword', _passwordController.text);
  await prefs.setString('agentCompany', _companyController.text.isNotEmpty ? _companyController.text : 'Independent Agent');
  await prefs.setString('agentEmail', _emailController.text);
  await prefs.setBool('isLoggedIn', true);
  
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Registration successful! Welcome aboard!'),
        backgroundColor: Colors.green,
      ),
    );
    
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
  
  setState(() => _isLoading = false);
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agent Registration'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_add,
                  size: 50,
                  color: AppConstants.primaryColor,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Create Agent Account',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Join our platform and help people find their dream properties',
                style: TextStyle(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              // Full Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name *',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Enter full name' : null,
              ),
              const SizedBox(height: 16),
              
              // Phone Number
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number *',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                  helperText: 'Enter your active phone number',
                ),
                keyboardType: TextInputType.phone,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter phone number';
                  if (v.length < 10) return 'Enter valid phone number';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Company Name (Optional)
              TextFormField(
                controller: _companyController,
                decoration: const InputDecoration(
                  labelText: 'Company Name (Optional)',
                  prefixIcon: Icon(Icons.business),
                  border: OutlineInputBorder(),
                  helperText: 'Leave blank if you\'re an independent agent',
                ),
              ),
              const SizedBox(height: 16),
              
              // Email (Optional)
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email (Optional)',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              
              // Agent License Number (REQUIRED)
              TextFormField(
                controller: _licenseController,
                decoration: const InputDecoration(
                  labelText: 'Agent License Number *',
                  prefixIcon: Icon(Icons.badge),
                  border: OutlineInputBorder(),
                  helperText: 'Your TPIN or REAZ license number',
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'License number is required';
                  if (v.length < 5) return 'Enter valid license number';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // WhatsApp Number
              CheckboxListTile(
                value: _whatsappSameAsPhone,
                onChanged: (value) {
                  setState(() {
                    _whatsappSameAsPhone = value ?? true;
                  });
                },
                title: const Text('Use same number for WhatsApp'),
                subtitle: Text('Phone: ${_phoneController.text.isNotEmpty ? _phoneController.text : 'Enter phone number first'}'),
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: AppConstants.primaryColor,
              ),
              
              if (!_whatsappSameAsPhone)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TextFormField(
                    controller: _whatsappController,
                    decoration: const InputDecoration(
                      labelText: 'WhatsApp Number',
                      prefixIcon: Icon(Icons.chat),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                ),
              
              // Password
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password *',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  border: const OutlineInputBorder(),
                  helperText: 'Minimum 6 characters',
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter password';
                  if (v.length < 6) return 'Password must be at least 6 characters';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Confirm Password
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: 'Confirm Password *',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                  border: const OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v != _passwordController.text) return 'Passwords do not match';
                  return null;
                },
              ),
              const SizedBox(height: 32),
              
              // Register Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _registerAndLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Register & Continue',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account? ",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppConstants.primaryColor,
                    ),
                    child: const Text('Login Here'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Info Box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'License verification adds trust points to your profile! You can add TPIN later for even more trust.',
                        style: TextStyle(fontSize: 12, color: Colors.green.shade700),
                      ),
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
