import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class AgentDashboard extends StatefulWidget {
  final Function toggleTheme;
  final bool isDarkMode;

  const AgentDashboard({
    super.key,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  @override
  State<AgentDashboard> createState() => _AgentDashboardState();
}

class _AgentDashboardState extends State<AgentDashboard> {
  int _selectedIndex = 0;
  
  // Agent data from SharedPreferences
  String _agentName = '';
  String _agentPhone = '';
  String _agentCompany = '';
  String _agentEmail = '';

  @override
  void initState() {
    super.initState();
    _loadAgentData();
  }

  Future<void> _loadAgentData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _agentName = prefs.getString('agentName') ?? 'Agent Name';
      _agentPhone = prefs.getString('agentPhone') ?? '+260XXXXXXXXX';
      _agentCompany = prefs.getString('agentCompany') ?? 'Your Company';
      _agentEmail = prefs.getString('agentEmail') ?? 'agent@example.com';
    });
  }

  final List<Widget> _tabs = [];

  @override
  Widget build(BuildContext context) {
    _tabs.clear();
    _tabs.addAll([
      const PropertiesTab(),
      const ClientsTab(),
      const AppointmentsTab(),
      const MessagesTab(),
      ProfileTab(
        agentName: _agentName,
        agentPhone: _agentPhone,
        agentCompany: _agentCompany,
        agentEmail: _agentEmail,
        toggleTheme: widget.toggleTheme,
        isDarkMode: widget.isDarkMode,
      ),
    ]);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agent Dashboard'),
        backgroundColor: AppConstants.primaryColor,
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => widget.toggleTheme(),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(),
          ),
        ],
      ),
      body: _tabs[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.house), label: 'Properties'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Clients'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Appointments'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/user-type');
    }
  }
}

class PropertiesTab extends StatelessWidget {
  const PropertiesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.house, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('Your Properties', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('List of your properties will appear here'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: AppConstants.primaryColor),
            child: const Text('Add New Property'),
          ),
        ],
      ),
    );
  }
}

class ClientsTab extends StatelessWidget {
  const ClientsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text('Your Clients', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('List of your clients will appear here'),
        ],
      ),
    );
  }
}

class AppointmentsTab extends StatelessWidget {
  const AppointmentsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text('Appointments', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('Your scheduled appointments will appear here'),
        ],
      ),
    );
  }
}

class MessagesTab extends StatelessWidget {
  const MessagesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.message, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text('Messages', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('Your messages will appear here'),
        ],
      ),
    );
  }
}

class ProfileTab extends StatelessWidget {
  final String agentName;
  final String agentPhone;
  final String agentCompany;
  final String agentEmail;
  final Function toggleTheme;
  final bool isDarkMode;

  const ProfileTab({
    super.key,
    required this.agentName,
    required this.agentPhone,
    required this.agentCompany,
    required this.agentEmail,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Profile Avatar
          CircleAvatar(
            radius: 50,
            backgroundColor: AppConstants.primaryColor,
            child: Text(
              agentName.isNotEmpty ? agentName[0].toUpperCase() : 'A',
              style: const TextStyle(fontSize: 40, color: Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          // Agent Name
          Text(
            agentName,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          // Agent Role
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Real Estate Agent',
              style: TextStyle(color: AppConstants.primaryColor),
            ),
          ),
          const SizedBox(height: 32),
          // Profile Details Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildProfileRow(Icons.business, 'Company', agentCompany),
                  const Divider(),
                  _buildProfileRow(Icons.phone, 'Phone', agentPhone),
                  const Divider(),
                  _buildProfileRow(Icons.email, 'Email', agentEmail),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Edit Profile Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // Navigate to edit profile
              },
              icon: const Icon(Icons.edit),
              label: const Text('Edit Profile'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppConstants.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: AppConstants.primaryColor),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Theme Toggle Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => toggleTheme(),
              icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
              label: Text(isDarkMode ? 'Light Mode' : 'Dark Mode'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[200],
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 24, color: AppConstants.primaryColor),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
