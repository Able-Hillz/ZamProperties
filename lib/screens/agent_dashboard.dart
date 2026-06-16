import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/property.dart';
import '../services/mock_data_service.dart';
import '../services/chat_service.dart';
import '../services/hive_service.dart';
import '../services/supabase_service.dart';
import '../models/agent.dart';
import '../widgets/property_card.dart';
import '../utils/constants.dart';
import 'add_property_screen.dart';
import 'agent_verification_screen.dart';
import 'chat_list_screen.dart';
import 'agent_profile_screen.dart';

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

class _AgentDashboardState extends State<AgentDashboard> with SingleTickerProviderStateMixin {
  List<Property> _myProperties = [];
  String? _agentPhone;
  String? _agentId;
  String? _agentName;
  bool _isLoading = true;
  int _unreadCount = 0;
  Agent? _agent;
  
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAgentData();
  }

  Future<void> _loadAgentData() async {
    setState(() => _isLoading = true);
    
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _agentId = prefs.getString('agentId');
      _agentPhone = prefs.getString('agentPhone');
      _agentName = prefs.getString('agentName') ?? 'Agent';
      _myProperties = MockDataService.getAllProperties();
      _isLoading = false;
    });
    
    await _loadAgentFromHive();
    await _updateUnreadCount();
  }

  Future<void> _loadAgentFromHive() async {
    if (_agentId != null) {
      final agent = HiveService.getAgent(_agentId!);
      setState(() => _agent = agent);
    }
  }

  Future<void> _updateUnreadCount() async {
    if (_agentId != null) {
      setState(() => _unreadCount = ChatService.getAgentUnreadCount(_agentId!));
    }
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

  // ============ EDIT/DELETE METHODS ============

  /// Edit an existing property
  Future<void> _editProperty(Property property) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPropertyScreen(propertyToEdit: property),
      ),
    );
    if (result == true) _loadAgentData();
  }

  /// Delete a property with confirmation dialog
  Future<void> _deleteProperty(Property property) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Property?'),
        content: Text('Are you sure you want to delete "${property.title}"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      setState(() => _isLoading = true);
      await MockDataService.deleteProperty(property.id);
      if (SupabaseService.isAvailable) await SupabaseService.deleteProperty(property.id);
      setState(() {
        _myProperties = MockDataService.getAllProperties();
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Property deleted')),
      );
    }
  }

  /// Show property actions bottom sheet (Edit, Update Status, Delete)
  void _showPropertyActions(Property property) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Property Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            // Edit Listing
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blue),
              title: const Text('Edit Listing'),
              onTap: () {
                Navigator.pop(context);
                _editProperty(property);
              },
            ),
            // Update Status
            ListTile(
              leading: const Icon(Icons.track_changes, color: Colors.orange),
              title: const Text('Update Status'),
              onTap: () {
                Navigator.pop(context);
                _showStatusOptions(property);
              },
            ),
            const Divider(),
            // Delete Listing
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Listing', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _deleteProperty(property);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Show status update options
  void _showStatusOptions(Property property) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Update Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
          ],
        ),
      ),
    );
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) Navigator.pushReplacementNamed(context, '/login');
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
    if (result == true) _loadAgentData();
  }

  Future<void> _goToChats() async {
    if (_agentId == null) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatListScreen(
          userId: _agentId!,
          userName: _agentName ?? 'Agent',
          isAgent: true,
        ),
      ),
    );
    await _updateUnreadCount();
  }

  Future<void> _goToProfile() async {
    if (_agentId == null) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AgentProfileScreen(agentId: _agentId!),
      ),
    );
    await _loadAgentFromHive();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    
    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        backgroundColor: AppConstants.primaryColor,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.storefront, size: 20, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Dashboard', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                if (_agent != null) Text(_agent!.trustLevel, style: TextStyle(fontSize: 10, color: _agent!.trustColor)),
              ],
            ),
          ],
        ),
        actions: [
          if (_agent != null)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: _agent!.trustColor.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
              child: Row(
                children: [
                  Icon(Icons.star, size: 14, color: _agent!.trustColor),
                  const SizedBox(width: 4),
                  Text('${_agent!.trustPoints}', style: TextStyle(fontSize: 12, color: _agent!.trustColor)),
                ],
              ),
            ),
          // Messages Button
          Stack(
            children: [
              IconButton(icon: const Icon(Icons.message), onPressed: _goToChats),
              if (_unreadCount > 0)
                Positioned(
                  right: 8, top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                    child: Text('$_unreadCount', style: const TextStyle(color: Colors.white, fontSize: 9), textAlign: TextAlign.center),
                  ),
                ),
            ],
          ),
          IconButton(icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode), onPressed: widget.toggleTheme),
          IconButton(icon: const Icon(Icons.verified_user), onPressed: _goToVerification),
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.list), text: 'Listings'),
            Tab(icon: Icon(Icons.person), text: 'Profile'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [_buildOverviewTab(), _buildListingsTab(), _buildProfileTab()],
            ),
    );
  }

  Widget _buildOverviewTab() {
    final activeCount = _myProperties.where((p) => p.status == PropertyStatus.available).length;
    final soldRentedCount = _myProperties.length - activeCount;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppConstants.primaryColor, AppConstants.secondaryColor]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Welcome back, $_agentName!', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 8),
                Text('You have ${_myProperties.length} total listings', style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildStatCard('Total Listings', _myProperties.length.toString(), Icons.home, Colors.blue)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard('Active', activeCount.toString(), Icons.check_circle, Colors.green)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildStatCard('Sold/Rented', soldRentedCount.toString(), Icons.sell, Colors.orange)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard('Trust Points', _agent?.trustPoints.toString() ?? '0', Icons.star, Colors.amber)),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildActionCard('Add Property', Icons.add_home, Colors.green, () async {
                final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddPropertyScreen()));
                if (result != null && result is Property) _addProperty(result);
              })),
              const SizedBox(width: 12),
              Expanded(child: _buildActionCard('Messages', Icons.message, Colors.blue, _goToChats)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildActionCard('My Profile', Icons.person, Colors.purple, _goToProfile)),
              const SizedBox(width: 12),
              Expanded(child: _buildActionCard('Verify', Icons.verified_user, Colors.orange, _goToVerification)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildListingsTab() {
    final allListings = List<Property>.from(_myProperties)..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: () async {
              final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddPropertyScreen()));
              if (result != null && result is Property) _addProperty(result);
            },
            icon: const Icon(Icons.add),
            label: const Text('Add New Property'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${allListings.length} Total Listings', style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('${allListings.where((p) => p.status == PropertyStatus.available).length} Active', style: TextStyle(color: Colors.green[600])),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: allListings.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.home_work, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text('No properties yet', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                      const SizedBox(height: 8),
                      const Text('Tap + to add your first property'),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: allListings.length,
                  itemBuilder: (context, index) {
                    final property = allListings[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: PropertyCard(
                        property: property,
                        onTap: () => _showPropertyActions(property),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildProfileTab() {
    if (_agent == null) return const Center(child: Text('Loading profile...'));
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: _agent!.trustColor.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 45,
                  backgroundColor: AppConstants.primaryColor,
                  child: Text(_agent!.name.isNotEmpty ? _agent!.name[0].toUpperCase() : 'A', style: const TextStyle(fontSize: 36, color: Colors.white)),
                ),
                const SizedBox(height: 12),
                Text(_agent!.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: _agent!.trustColor, borderRadius: BorderRadius.circular(20)),
                  child: Text(_agent!.trustLevel, style: const TextStyle(color: Colors.white, fontSize: 12)),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _goToProfile,
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text('View Full Profile'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppConstants.primaryColor,
                    elevation: 0,
                    side: BorderSide(color: AppConstants.primaryColor),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildQuickInfoTile(Icons.phone, 'Phone', _agent!.phone),
                  const Divider(),
                  _buildQuickInfoTile(Icons.chat, 'WhatsApp', _agent!.displayWhatsApp),
                  const Divider(),
                  _buildQuickInfoTile(Icons.badge, 'License', _agent!.licenseNumber ?? 'Not provided'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickInfoTile(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppConstants.primaryColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600]), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: widget.isDarkMode ? Colors.grey[800] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 1))],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
