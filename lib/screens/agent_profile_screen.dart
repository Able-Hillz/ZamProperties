import 'package:flutter/material.dart';
import '../services/hive_service.dart';
import '../models/agent.dart';
import '../utils/constants.dart';

class AgentProfileScreen extends StatefulWidget {
  final String agentId;

  const AgentProfileScreen({super.key, required this.agentId});

  @override
  State<AgentProfileScreen> createState() => _AgentProfileScreenState();
}

class _AgentProfileScreenState extends State<AgentProfileScreen> {
  Agent? _agent;
  bool _isLoading = true;
  int _totalListings = 0;
  int _totalViews = 0;
  int _totalInquiries = 0;

  @override
  void initState() {
    super.initState();
    _loadAgent();
    _loadAgentStats();
  }

  Future<void> _loadAgent() async {
    final agent = HiveService.getAgent(widget.agentId);
    setState(() {
      _agent = agent;
      _isLoading = false;
    });
  }

  Future<void> _loadAgentStats() async {
    // TODO: Fetch actual stats from database
    setState(() {
      _totalListings = 5;
      _totalViews = 128;
      _totalInquiries = 12;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_agent == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: Text('Agent not found')),
      );
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Edit profile coming soon')),
              );
            },
            tooltip: 'Edit Profile',
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
                color: _agent!.trustColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppConstants.primaryColor,
                    child: Text(
                      _agent!.name.isNotEmpty ? _agent!.name[0].toUpperCase() : 'A',
                      style: const TextStyle(fontSize: 40, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _agent!.name,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: _agent!.trustColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_agent!.trustIcon, size: 16, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          _agent!.trustLevel,
                          style: const TextStyle(color: Colors.white, fontSize: 12),
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
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Trust Score',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.star, color: Colors.amber),
                        const SizedBox(width: 8),
                        Text(
                          '${_agent!.trustPoints}',
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          ' points',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    LinearProgressIndicator(
                      value: (_agent!.trustPoints / 150).clamp(0.0, 1.0),
                      backgroundColor: Colors.grey[300],
                      color: _agent!.trustColor,
                      borderRadius: BorderRadius.circular(4),
                      minHeight: 8,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Next level at 100 points',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Contact Information
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Contact Information',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoTile(Icons.phone, 'Phone', _agent!.phone),
                    const Divider(),
                    _buildInfoTile(Icons.chat, 'WhatsApp', _agent!.displayWhatsApp),
                    if (_agent!.email != null && _agent!.email!.isNotEmpty) ...[
                      const Divider(),
                      _buildInfoTile(Icons.email, 'Email', _agent!.email!),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Business Information
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Business Information',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoTile(Icons.business, 'Company', _agent!.companyName),
                    const Divider(),
                    _buildInfoTile(Icons.badge, 'License Number', _agent!.licenseNumber ?? 'Not provided'),
                    if (_agent!.tpin != null && _agent!.tpin!.isNotEmpty) ...[
                      const Divider(),
                      _buildInfoTile(Icons.verified_user, 'TPIN', _agent!.tpin!),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Activity Stats
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Activity Stats',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            Icons.home,
                            'Listings',
                            _totalListings.toString(),
                            Colors.blue,
                          ),
                        ),
                        Expanded(
                          child: _buildStatCard(
                            Icons.visibility,
                            'Views',
                            _totalViews.toString(),
                            Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            Icons.star,
                            'Rating',
                            _agent!.averageRating.toStringAsFixed(1),
                            Colors.amber,
                          ),
                        ),
                        Expanded(
                          child: _buildStatCard(
                            Icons.reviews,
                            'Reviews',
                            _agent!.totalReviews.toString(),
                            Colors.purple,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            Icons.message,
                            'Inquiries',
                            _totalInquiries.toString(),
                            Colors.orange,
                          ),
                        ),
                        const Expanded(child: SizedBox()),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppConstants.primaryColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  }
}
