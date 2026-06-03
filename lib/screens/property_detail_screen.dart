import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/property.dart';
import '../models/agent.dart';
import '../services/mock_data_service.dart';
import '../services/whatsapp_service.dart';
import '../services/chat_service.dart';
import '../services/customer_service.dart';
import '../utils/constants.dart';
import '../widgets/video_player_widget.dart';
import '../widgets/three_sixty_viewer.dart';
import 'chat_screen.dart';

class PropertyDetailScreen extends StatefulWidget {
  final Property property;

  const PropertyDetailScreen({
    super.key,
    required this.property,
  });

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  late Property _property;
  Agent? _agent;
  int _currentImageIndex = 0;
  bool _isChatStarting = false;

  @override
  void initState() {
    super.initState();
    _property = widget.property;
    _agent = MockDataService.getAgentById(_property.agentId);
  }

  Future<void> _openMaps() async {
    if (_property.googleMapsLink != null && _property.googleMapsLink!.isNotEmpty) {
      final Uri url = Uri.parse(_property.googleMapsLink!);
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
        return;
      }
    }
    
    if (_property.locationAddress != null && _property.locationAddress!.isNotEmpty) {
      final query = Uri.encodeComponent(_property.locationAddress!);
      final searchUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
      if (await canLaunchUrl(searchUrl)) {
        await launchUrl(searchUrl);
      }
    }
  }

  Future<void> _startChat() async {
    setState(() => _isChatStarting = true);
    
    final customerId = await CustomerService.getCustomerId();
    final customerName = await CustomerService.getCustomerName();
    final customerPhone = await CustomerService.getCustomerPhone();
    
    String chatId = '${_property.id}_${_agent?.id}_$customerId';
    
    var existingChat = ChatService.getChat(chatId);
    if (existingChat == null) {
      chatId = await ChatService.createChat(
        propertyId: _property.id,
        customerId: customerId,
        customerName: customerName,
        customerPhone: customerPhone,
      );
    } else {
      chatId = existingChat.id;
    }
    
    setState(() => _isChatStarting = false);
    
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            chatId: chatId,
            currentUserId: customerId,
            currentUserName: customerName,
            otherUserName: _agent?.name ?? 'Agent',
            propertyTitle: _property.title,
            isAgent: false,
            agentId: _agent?.id,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.grey[850] : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: isDark ? Colors.white : Colors.black87),
            onPressed: _shareProperty,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image carousel
            if (_property.imageUrls.isNotEmpty)
              Column(
                children: [
                  SizedBox(
                    height: 300,
                    child: PageView.builder(
                      onPageChanged: (int index) {
                        setState(() {
                          _currentImageIndex = index;
                        });
                      },
                      itemCount: _property.imageUrls.length,
                      itemBuilder: (context, index) {
                        return Image.network(
                          _property.imageUrls[index],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: const Icon(Icons.broken_image, size: 80),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _property.imageUrls.asMap().entries.map((entry) {
                      return Container(
                        width: 8.0,
                        height: 8.0,
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentImageIndex == entry.key
                              ? AppConstants.primaryColor
                              : Colors.grey,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            
            // Video Walkthrough
            if (_property.videoUrl != null && _property.videoUrl!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.videocam, color: AppConstants.primaryColor),
                        SizedBox(width: 8),
                        Text(
                          'Video Walkthrough',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: VideoPlayerWidget(
                        videoUrl: _property.videoUrl!,
                        thumbnailUrl: _property.videoThumbnailUrl,
                      ),
                    ),
                  ],
                ),
              ),
            
            // 360° Photo Tour
            if (_property.threeSixtyImageUrls.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.threesixty, color: AppConstants.primaryColor),
                        const SizedBox(width: 8),
                        const Text(
                          '360° Virtual Tour',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ThreeSixtyViewer(
                      imageUrls: _property.threeSixtyImageUrls,
                    ),
                  ],
                ),
              ),
            
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    _property.title,
                    style: AppConstants.headline1,
                  ),
                  const SizedBox(height: 8),
                  
                  // Price
                  Text(
                    _formatPrice(),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _getStatusColor()),
                    ),
                    child: Text(
                      _getStatusText(),
                      style: TextStyle(
                        color: _getStatusColor(),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Key details
                  const Text(
                    'Key Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 2.5,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: [
                      _buildDetailCard(Icons.location_on, 'Area', _property.area),
                      if (_property.type != PropertyType.land) ...[
                        _buildDetailCard(Icons.bed, 'Bedrooms', '${_property.bedrooms}'),
                        _buildDetailCard(Icons.bathtub, 'Bathrooms', '${_property.bathrooms}'),
                      ],
                      if (_property.landSize != null)
                        _buildDetailCard(Icons.landscape, 'Land Size', '${_property.landSize} sqm'),
                      _buildDetailCard(Icons.visibility, 'Views', '${_property.views}'),
                      _buildDetailCard(Icons.calendar_today, 'Posted', _getTimeAgo()),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Description
                  const Text(
                    'Description',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _property.description,
                    style: AppConstants.bodyText.copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  
                  // Location Section
                  if (_property.locationAddress != null && _property.locationAddress!.isNotEmpty)
                    _buildLocationSection(),
                  
                  // Agent info
                  if (_agent != null) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'Agent Information',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: AppConstants.primaryColor,
                              child: Text(
                                _agent!.name[0],
                                style: const TextStyle(fontSize: 24, color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        _agent!.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (_agent!.isVerified) ...[
                                        const SizedBox(width: 8),
                                        const Icon(Icons.verified, color: Colors.blue, size: 16),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _agent!.companyName,
                                    style: AppConstants.caption,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.phone, size: 14, color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      Text(_agent!.phone, style: AppConstants.caption),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _property.status == PropertyStatus.available
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[850] : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    // WhatsApp Button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _contactAgent,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF25D366),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.chat, color: Colors.white),
                        label: const Text('WhatsApp'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // In-App Chat Button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isChatStarting ? null : _startChat,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: _isChatStarting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.message, color: Colors.white),
                        label: Text(_isChatStarting ? 'Starting...' : 'Message'),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildLocationSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Location',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: _openMaps,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppConstants.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.location_on,
                      color: AppConstants.primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _property.locationAddress!,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tap to view on map',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: isDark ? Colors.grey[500] : Colors.grey[400],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailCard(IconData icon, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppConstants.primaryColor),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppConstants.caption),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  String _formatPrice() {
    final formatter = NumberFormat('#,##0');
    if (_property.type == PropertyType.rent) {
      return 'ZMW ${formatter.format(_property.price)}/month';
    } else if (_property.type == PropertyType.land) {
      return 'ZMW ${formatter.format(_property.price)}';
    } else {
      return 'ZMW ${formatter.format(_property.price)}';
    }
  }

  String _getStatusText() {
    switch (_property.status) {
      case PropertyStatus.available:
        return 'Available';
      case PropertyStatus.sold:
        return 'Sold';
      case PropertyStatus.rented:
        return 'Rented';
    }
  }

  Color _getStatusColor() {
    switch (_property.status) {
      case PropertyStatus.available:
        return Colors.green;
      case PropertyStatus.sold:
        return Colors.red;
      case PropertyStatus.rented:
        return Colors.orange;
    }
  }

  String _getTimeAgo() {
    final difference = DateTime.now().difference(_property.createdAt);
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} years ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  void _contactAgent() async {
    if (_agent != null) {
      await WhatsAppService.contactAgent(_agent!.phone, _property.title);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agent information not available')),
      );
    }
  }

  void _shareProperty() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share feature coming soon')),
    );
  }
}