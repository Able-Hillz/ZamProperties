import '../models/property.dart';
import '../models/agent.dart';
import 'hive_service.dart';

class MockDataService {
  static List<Property> _mockProperties = [];
  static List<Agent> _mockAgents = [];

  static Future<void> init() async {
    // Initialize Hive first
    await HiveService.init();
    
    // Try to load from Hive first
    final cachedProperties = HiveService.getAllProperties();
    
    if (cachedProperties.isNotEmpty) {
      _mockProperties = cachedProperties;
      print('✅ Loaded ${_mockProperties.length} properties from Hive cache');
    } else {
      // Initialize with mock data
      _initMockData();
      _initMockAgents();
      // Save to Hive
      await HiveService.saveProperties(_mockProperties);
      for (var agent in _mockAgents) {
        await HiveService.saveAgent(agent);
      }
      print('✅ Initialized with mock data and saved to Hive');
    }
  }

  static void _initMockData() {
    _mockProperties = [
      Property(
        id: '1',
        agentId: 'agent1',
        title: 'Modern 3-Bedroom House in Woodlands',
        description: 'Beautiful family home with spacious living area, modern kitchen, and fenced yard. Located close to Arcades Shopping Mall. Features include borehole, solar system, and servant quarters.',
        price: 3500,
        area: 'Woodlands',
        type: PropertyType.rent,
        status: PropertyStatus.available,
        imageUrls: [
          'https://images.unsplash.com/photo-1568605114967-8130f3a36994?w=800',
          'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=800',
          'https://images.unsplash.com/photo-1598928506311-c55ded91a20c?w=800',
        ],
        bedrooms: 3,
        bathrooms: 2,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        views: 42,
        locationAddress: 'Plot 123A, Woodlands Extension, near Arcades Mall',
        googleMapsLink: null,
      ),
      Property(
        id: '2',
        agentId: 'agent2',
        title: 'Commercial Land in Kabulonga',
        description: 'Prime commercial plot, 2000 sqm, perfect for office or retail development. Near East Park Mall.',
        price: 850000,
        area: 'Kabulonga',
        type: PropertyType.land,
        status: PropertyStatus.available,
        imageUrls: [
          'https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=800',
          'https://images.unsplash.com/photo-1444723121867-7a241cacace9?w=800',
        ],
        bedrooms: 0,
        bathrooms: 0,
        landSize: 2000,
        createdAt: DateTime.now().subtract(const Duration(days: 12)),
        views: 28,
        locationAddress: 'Corner of Kabulonga Road and Independence Avenue',
        googleMapsLink: null,
      ),
      Property(
        id: '3',
        agentId: 'agent1',
        title: 'Luxury 4-Bedroom House in Ibex Hill',
        description: 'Stunning luxury home with swimming pool, servant quarters, and landscaped garden.',
        price: 1200000,
        area: 'Ibex Hill',
        type: PropertyType.buy,
        status: PropertyStatus.available,
        imageUrls: [
          'https://images.unsplash.com/photo-1613490493576-7fde63acd811?w=800',
          'https://images.unsplash.com/photo-1580587771525-78b9dba3b914?w=800',
        ],
        bedrooms: 4,
        bathrooms: 3,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        views: 67,
        locationAddress: '15 Ibex Hill Road, Lusaka',
        googleMapsLink: null,
      ),
      Property(
        id: '4',
        agentId: 'agent2',
        title: '2-Bedroom Modern Apartment in Roma',
        description: 'Secure apartment complex with backup water system, prepaid electricity, and 24/7 CCTV.',
        price: 2200,
        area: 'Roma',
        type: PropertyType.rent,
        status: PropertyStatus.available,
        imageUrls: [
          'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=800',
          'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=800',
        ],
        bedrooms: 2,
        bathrooms: 1,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        views: 15,
        locationAddress: 'Roma Park Apartments, near Roma Shopping Mall',
        googleMapsLink: null,
      ),
    ];
  }

  static void _initMockAgents() {
    _mockAgents = [
      Agent(
        id: 'agent1',
        name: 'John Banda',
        phone: '+260977123456',
        email: 'john@zamproperty.com',
        isVerified: true,
        profileImageUrl: 'https://randomuser.me/api/portraits/men/32.jpg',
        companyName: 'Zamproperty Real Estate',
        tpin: '1234567890',
        verificationLevel: 'verified',
      ),
      Agent(
        id: 'agent2',
        name: 'Mary Phiri',
        phone: '+260966789012',
        email: 'mary@lusakahomes.com',
        isVerified: false,
        profileImageUrl: 'https://randomuser.me/api/portraits/women/68.jpg',
        companyName: 'Lusaka Homes Ltd',
        tpin: null,
        verificationLevel: 'unverified',
      ),
    ];
  }

  static List<Property> getAllProperties() {
    return _mockProperties;
  }

  static List<Property> getPropertiesByType(PropertyType type) {
    return _mockProperties.where((p) => p.type == type).toList();
  }

  static Property? getPropertyById(String id) {
    try {
      return _mockProperties.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  static Agent? getAgentById(String id) {
    try {
      return _mockAgents.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<Property> filterProperties({
    PropertyType? type,
    String? area,
    double? maxPrice,
  }) {
    return _mockProperties.where((p) {
      if (type != null && p.type != type) return false;
      if (area != null && p.area != area) return false;
      if (maxPrice != null && p.price > maxPrice) return false;
      return true;
    }).toList();
  }

  static Future<void> addProperty(Property property) async {
    _mockProperties.insert(0, property);
    await HiveService.addProperty(property);
    print('✅ Property added and saved to Hive: ${property.title}');
  }

  static Future<void> updatePropertyStatus(String propertyId, PropertyStatus newStatus) async {
    final index = _mockProperties.indexWhere((p) => p.id == propertyId);
    if (index != -1) {
      final updated = _mockProperties[index];
      _mockProperties[index] = Property(
        id: updated.id,
        agentId: updated.agentId,
        title: updated.title,
        description: updated.description,
        price: updated.price,
        area: updated.area,
        type: updated.type,
        status: newStatus,
        imageUrls: updated.imageUrls,
        bedrooms: updated.bedrooms,
        bathrooms: updated.bathrooms,
        landSize: updated.landSize,
        createdAt: updated.createdAt,
        views: updated.views,
        locationAddress: updated.locationAddress,
        googleMapsLink: updated.googleMapsLink,
      );
      await HiveService.updateProperty(_mockProperties[index]);
      print('✅ Property status updated: ${updated.title} -> ${newStatus.toString()}');
    }
  }
}