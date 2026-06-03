import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/property.dart';
import '../services/mock_data_service.dart';
import '../services/chat_service.dart';
import '../widgets/property_card.dart';
import '../utils/constants.dart';
import 'add_property_screen.dart';
import 'agent_verification_screen.dart';
import 'chat_list_screen.dart';

class AgentDashboard extends StatefulWidget {
  final VoidCallback toggleTheme;
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
  List<Property> _myProperties = [];
  String? _agentPhone;
  String? _agentId;
  bool _isLoading = true;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadAgentData();
    _updateUnreadCount();
  }

  Future<void> _updateUnreadCount() async {
    if (_agentId != null) {
      setState(() {
        _unreadCount = ChatService.getAgentUnreadCount(_agentId!);
      });
    }
  }

  Future<void> _loadAgentData() async {
    setState(() => _isLoading = true);
    
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _agentId = prefs.getString('agentId');
      _agentPhone = prefs.getString('agentPhone');
      _myProperties = MockDataService.getAllProperties();
      _isLoading = false;
    });
    await _updateUnreadCount();
  }

  void _addProperty(Property newProperty) {
    setState(() {
      MockDataService.addProperty(newProperty);
      _myProperties = MockDataService.getAllProperties();
    });
  }

  void _updatePropertyStatus(Property property, PropertyStatus newStatus) {
    setState(() {
      MockDataService.updatePropertyStatus(property.id, newStatus);
      _myProperties = MockDataService.getAllProperties();
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<void> _goToVerification() async {
    if (_agentId == null) return;
    
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AgentVerificationScreen(
          agentId: _agentId!,
          agentPhone: _agentPhone ?? '',
        ),
      ),
    );
    
    if (result == true) {
      _loadAgentData();
    }
  }

  Future<void> _goToChats() async {
    if (_agentId == null) return;
    
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatListScreen(
          userId: _agentId!,
          userName: 'Agent',
          isAgent: true,
        ),
      ),
    );
    await _updateUnreadCount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isDarkMode ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        backgroundColor: AppConstants.primaryColor,
        elevation: 0,
        title: const Text('Agent Dashboard'),
        actions: [
          // Messages button with unread count
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.message),
                onPressed: _goToChats,
                tooltip: 'Messages',
              ),
              if (_unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 14,
                      minHeight: 14,
                    ),
                    child: Text(
                      '$_unreadCount',
                      style: const TextStyle(color: Colors.white, fontSize: 9),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          // Dark mode toggle
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.toggleTheme,
            tooltip: widget.isDarkMode ? 'Light Mode' : 'Dark Mode',
          ),
          // Verification button
          IconButton(
            icon: const Icon(Icons.verified_user),
            onPressed: _goToVerification,
            tooltip: 'Verify Business',
          ),
          // Logout button
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Stats cards
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Total Listings',
                          _myProperties.length.toString(),
                          Icons.home,
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Active',
                          _myProperties.where((p) => p.status == PropertyStatus.available).length.toString(),
                          Icons.check_circle,
                          Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Sold/Rented',
                          _myProperties.where((p) => p.status != PropertyStatus.available).length.toString(),
                          Icons.sell,
                          Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Listings header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'My Listings',
                        style: AppConstants.headline2,
                      ),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddPropertyScreen(),
                            ),
                          );
                          if (result != null && result is Property) {
                            _addProperty(result);
                          }
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add Property'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Properties list
                Expanded(
                  child: _myProperties.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.home_work, size: 80, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                'No properties yet',
                                style: AppConstants.headline2.copyWith(color: Colors.grey[600]),
                              ),
                              const SizedBox(height: 8),
                              const Text('Tap + to add your first property'),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _myProperties.length,
                          itemBuilder: (context, index) {
                            final property = _myProperties[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              child: Column(
                                children: [
                                  PropertyCard(
                                    property: property,
                                    onTap: () {
                                      showModalBottomSheet(
                                        context: context,
                                        builder: (context) {
                                          return Container(
                                            padding: const EdgeInsets.all(16),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Text(
                                                  'Update Status',
                                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                                ),
                                                const SizedBox(height: 16),
                                                ListTile(
                                                  leading: const Icon(Icons.check_circle, color: Colors.green),
                                                  title: const Text('Mark as Available'),
                                                  onTap: () {
                                                    _updatePropertyStatus(property, PropertyStatus.available);
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                                ListTile(
                                                  leading: const Icon(Icons.sell, color: Colors.red),
                                                  title: const Text('Mark as Sold'),
                                                  onTap: () {
                                                    _updatePropertyStatus(property, PropertyStatus.sold);
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                                ListTile(
                                                  leading: const Icon(Icons.home, color: Colors.orange),
                                                  title: const Text('Mark as Rented'),
                                                  onTap: () {
                                                    _updatePropertyStatus(property, PropertyStatus.rented);
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                                const Divider(),
                                                ListTile(
                                                  leading: const Icon(Icons.delete, color: Colors.red),
                                                  title: const Text('Delete Listing'),
                                                  onTap: () {
                                                    Navigator.pop(context);
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      const SnackBar(content: Text('Delete feature coming soon')),
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            title,
            style: AppConstants.caption,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}