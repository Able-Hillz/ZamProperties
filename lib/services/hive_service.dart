import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/property.dart';
import '../models/agent.dart';

class HiveService {
  static late Box _propertiesBox;
  static late Box _agentsBox;
  static late Box _settingsBox;
  static bool _isInitialized = false;

  static Future<void> init() async {
    if (_isInitialized) return;
    
    if (kIsWeb) {
      // Web: Use default directory (works automatically)
      Hive.init('');
      print('✅ Hive initialized for Web');
    } else {
      // Mobile/Desktop: Use app documents directory
      final appDocumentDir = await getApplicationDocumentsDirectory();
      Hive.init(appDocumentDir.path);
      print('✅ Hive initialized for Mobile at ${appDocumentDir.path}');
    }
    
    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(PropertyAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(AgentAdapter());
    }
    
    // Open boxes
    _propertiesBox = await Hive.openBox('properties');
    _agentsBox = await Hive.openBox('agents');
    _settingsBox = await Hive.openBox('settings');
    
    _isInitialized = true;
    print('✅ Hive boxes opened: ${_propertiesBox.length} properties, ${_agentsBox.length} agents');
  }

  // ============ PROPERTIES ============
  
  static Future<void> saveProperties(List<Property> properties) async {
    if (!_isInitialized) await init();
    
    await _propertiesBox.clear();
    for (var property in properties) {
      await _propertiesBox.put(property.id, property);
    }
    
    await _settingsBox.put('lastSync', DateTime.now().toIso8601String());
    print('✅ Saved ${properties.length} properties to Hive');
  }
  
  static List<Property> getAllProperties() {
    if (!_isInitialized) return [];
    return _propertiesBox.values.cast<Property>().toList();
  }
  
  static Property? getProperty(String id) {
    if (!_isInitialized) return null;
    return _propertiesBox.get(id);
  }
  
  static Future<void> addProperty(Property property) async {
    if (!_isInitialized) await init();
    await _propertiesBox.put(property.id, property);
  }
  
  static Future<void> updateProperty(Property property) async {
    if (!_isInitialized) await init();
    await _propertiesBox.put(property.id, property);
  }
  
  static Future<void> deleteProperty(String id) async {
    if (!_isInitialized) await init();
    await _propertiesBox.delete(id);
  }
  
  // ============ AGENTS ============
  
  static Future<void> saveAgent(Agent agent) async {
    if (!_isInitialized) await init();
    await _agentsBox.put(agent.id, agent);
  }
  
  static Agent? getAgent(String id) {
    if (!_isInitialized) return null;
    return _agentsBox.get(id);
  }
  
  static Agent? getAgentByPhone(String phone) {
    if (!_isInitialized) return null;
    final agents = _agentsBox.values.cast<Agent>();
    try {
      return agents.firstWhere((agent) => agent.phone == phone);
    } catch (e) {
      return null;
    }
  }
  
  static List<Agent> getAllAgents() {
    if (!_isInitialized) return [];
    return _agentsBox.values.cast<Agent>().toList();
  }
  
  // ============ SETTINGS ============
  
  static String? getLastSyncTime() {
    if (!_isInitialized) return null;
    return _settingsBox.get('lastSync');
  }
  
  static Future<void> clearAllData() async {
    if (!_isInitialized) await init();
    await _propertiesBox.clear();
    await _agentsBox.clear();
    await _settingsBox.clear();
    print('✅ All Hive data cleared');
  }
}

// ============ HIVE ADAPTERS ============

class PropertyAdapter extends TypeAdapter<Property> {
  @override
  final int typeId = 0;

  @override
  Property read(BinaryReader reader) {
    return Property(
      id: reader.readString(),
      agentId: reader.readString(),
      title: reader.readString(),
      description: reader.readString(),
      price: reader.readDouble(),
      area: reader.readString(),
      type: PropertyType.values[reader.readInt()],
      status: PropertyStatus.values[reader.readInt()],
      imageUrls: reader.readStringList(),
      bedrooms: reader.readInt(),
      bathrooms: reader.readInt(),
      landSize: reader.readDouble(),
      createdAt: DateTime.parse(reader.readString()),
      views: reader.readInt(),
      locationAddress: reader.readString(),
      googleMapsLink: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, Property obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.agentId);
    writer.writeString(obj.title);
    writer.writeString(obj.description);
    writer.writeDouble(obj.price);
    writer.writeString(obj.area);
    writer.writeInt(obj.type.index);
    writer.writeInt(obj.status.index);
    writer.writeStringList(obj.imageUrls);
    writer.writeInt(obj.bedrooms);
    writer.writeInt(obj.bathrooms);
    writer.writeDouble(obj.landSize ?? 0);
    writer.writeString(obj.createdAt.toIso8601String());
    writer.writeInt(obj.views);
    writer.writeString(obj.locationAddress ?? '');
    writer.writeString(obj.googleMapsLink ?? '');
  }
}

class AgentAdapter extends TypeAdapter<Agent> {
  @override
  final int typeId = 1;

  @override
  Agent read(BinaryReader reader) {
    return Agent(
      id: reader.readString(),
      name: reader.readString(),
      phone: reader.readString(),
      email: reader.readString(),
      isVerified: reader.readBool(),
      profileImageUrl: reader.readString(),
      companyName: reader.readString(),
      tpin: reader.readString(),
      pacraNumber: reader.readString(),
      businessLicense: reader.readString(),
      verificationLevel: reader.readString(),
      createdAt: DateTime.parse(reader.readString()),
    );
  }

  @override
  void write(BinaryWriter writer, Agent obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.writeString(obj.phone);
    writer.writeString(obj.email ?? '');
    writer.writeBool(obj.isVerified);
    writer.writeString(obj.profileImageUrl ?? '');
    writer.writeString(obj.companyName);
    writer.writeString(obj.tpin ?? '');
    writer.writeString(obj.pacraNumber ?? '');
    writer.writeString(obj.businessLicense ?? '');
    writer.writeString(obj.verificationLevel);
    writer.writeString(obj.createdAt?.toIso8601String() ?? DateTime.now().toIso8601String());
  }
}