import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import 'agent_verification_screen.dart';

class AgentProfileScreen extends StatefulWidget {
  const AgentProfileScreen({super.key});

  @override
  State<AgentProfileScreen> createState() => _AgentProfileScreenState();
}

class _AgentProfileScreenState extends State<AgentProfileScreen> {
  String _agentName = '';
  String _agentPhone = '';
  String _agentEmail = '';
  String _agentCompany = '';
  int _trustPoints = 0;
  bool _hasTPIN = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _agentName = prefs.getString('agentName') ?? '';
      _agentPhone = prefs.getString('agentPhone') ?? '';
      _agentEmail = prefs.getString('agentEmail') ?? '';
      _agentCompany = prefs.getString('agentCompany') ?? '';
      _trustPoints = prefs.getInt('agentTrustPoints') ?? 50;
      _hasTPIN = prefs.getBool('agentHasTPIN') ?? false;
      _isLoading = false;
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/user-type', (route) => false);
    }
  }

  String _getTrustLevel() {
    if (_trustPoints >= 150) return 'Premium Trusted Agent';
    if (_trustPoints >= 100) return 'Trusted Agent';
    if (_trustPoints >= 75) return 'Verified Agent';
    if (_trustPoints >= 50) return 'New Agent';
    return 'Basic Agent';
  }

  Color _getTrustColor() {
    if (_trustPoints >= 150) return const Color(0xFFFFD700);
    if (_trustPoints >= 100) return Colors.green;
    if (_trustPoints >= 75) return Colors.blue;
    if (_trustPoints >= 50) return Colors.orange;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigate to edit profile
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppConstants.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: AppConstants.primaryColor,
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _agentName,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getTrustColor().withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, color: _getTrustColor(), size: 16),
                        const SizedBox(width: 4),
                        Text(
                          _getTrustLevel(),
                          style: TextStyle(color: _getTrustColor(), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Trust Points Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Trust Score',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 32),
                        const SizedBox(width: 8),
                        Text(
                          '$_trustPoints',
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        Text('points', style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: _trustPoints / 150,
                      backgroundColor: Colors.grey[200],
                      color: _getTrustColor(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Contact Information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Contact Information',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.phone, color: AppConstants.primaryColor),
                      title: const Text('Phone Number'),
                      subtitle: Text(_agentPhone),
                    ),
                    ListTile(
                      leading: const Icon(Icons.email, color: AppConstants.primaryColor),
                      title: const Text('Email'),
                      subtitle: Text(_agentEmail),
                    ),
                    ListTile(
                      leading: const Icon(Icons.business, color: AppConstants.primaryColor),
                      title: const Text('Company'),
                      subtitle: Text(_agentCompany),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Verification Status
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Verification Status',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Divider(),
                    ListTile(
                      leading: Icon(
                        _hasTPIN ? Icons.verified : Icons.warning,
                        color: _hasTPIN ? Colors.green : Colors.orange,
                      ),
                      title: const Text('TPIN Verification'),
                      subtitle: Text(_hasTPIN ? 'Verified' : 'Not verified'),
                      trailing: !_hasTPIN
                          ? TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AgentVerificationScreen(
                                      agentId: '',
                                      agentPhone: _agentPhone,
                                    ),
                                  ),
                                ).then((_) => _loadProfile());
                              },
                              child: const Text('Verify Now'),
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
