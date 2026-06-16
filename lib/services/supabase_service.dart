import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../models/property.dart';
import '../models/agent.dart';
import 'hive_service.dart';

class SupabaseService {
  static final supabase = Supabase.instance.client;
  static bool _isInitialized = false;

  static Future<void> init() async {
    await Supabase.initialize(
    
      url: 'https://jqekjnzbwqhhvffcvuzn.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpxZWtqbnpid3FoaHZmZmN2dXpuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODA2NDMxOTIsImV4cCI6MjA5NjIxOTE5Mn0.ghDIMBC0S0Ry0za0RgOgPQnJwpDPul9iw6LZ3Xltfzc', // Replace with your actual anon key
    
    );


    _isInitialized = true;
    print('✅ Supabase initialized');
  }

  static bool get isAvailable => _isInitialized;

  // ============ IMAGE UPLOADS (Web + Mobile Compatible) ============

  // Upload multiple images (accepts both File and XFile)
  static Future<List<String>> uploadImages(List<dynamic> images, String propertyId) async {
    List<String> uploadedUrls = [];
    
    for (int i = 0; i < images.length; i++) {
      final fileName = 'properties/$propertyId/image_$i.jpg';
      final url = await uploadImage(images[i], fileName);
      if (url != null) {
        uploadedUrls.add(url);
      }
    }
    
    return uploadedUrls;
  }

  // Upload single image - Works on Web + Mobile
  static Future<String?> uploadImage(dynamic imageFile, String fileName) async {
    if (!_isInitialized) return null;
    
    try {
      // Handle different image source types
      if (imageFile is XFile) {
        // Web: XFile from image_picker
        await supabase.storage
            .from('property-images')
            .upload(fileName, imageFile as File);
      } else if (imageFile is File) {
        // Mobile/Desktop: File object
        await supabase.storage
            .from('property-images')
            .upload(fileName, imageFile);
      } else if (imageFile != null && imageFile.path != null) {
        // Fallback: try as file path
        final file = File(imageFile.path);
        await supabase.storage
            .from('property-images')
            .upload(fileName, file);
      } else {
        print('❌ Unsupported image type: ${imageFile.runtimeType}');
        return null;
      }
      
      // Get public URL
      final publicUrl = supabase.storage
          .from('property-images')
          .getPublicUrl(fileName);
      
      print('✅ Image uploaded: $publicUrl');
      return publicUrl;
    } catch (e) {
      print('❌ Image upload failed: $e');
      return null;
    }
  }

  // Upload video
  static Future<String?> uploadVideo(File videoFile, String propertyId) async {
    if (!_isInitialized) return null;
    
    try {
      final fileName = 'properties/$propertyId/video.mp4';
      
      await supabase.storage
          .from('property-videos')
          .upload(fileName, videoFile);
      
      final publicUrl = supabase.storage
          .from('property-videos')
          .getPublicUrl(fileName);
      
      print('✅ Video uploaded: $publicUrl');
      return publicUrl;
    } catch (e) {
      print('❌ Video upload failed: $e');
      return null;
    }
  }

  // ============ SYNC LOCAL TO CLOUD ============

  // Sync local Hive data to Supabase (camelCase → snake_case)
  static Future<void> syncLocalToCloud() async {
    if (!_isInitialized) return;
    
    print('🔄 Syncing local data to Supabase...');
    
    try {
      // Sync Properties
      final localProperties = HiveService.getAllProperties();
      for (var property in localProperties) {
        final snakeCaseProperty = {
          'id': property.id,
          'agent_id': property.agentId,
          'title': property.title,
          'description': property.description,
          'price': property.price,
          'area': property.area,
          'type': property.type.index,
          'status': property.status.index,
          'image_urls': property.imageUrls,
          'bedrooms': property.bedrooms,
          'bathrooms': property.bathrooms,
          'land_size': property.landSize,
          'created_at': property.createdAt.toIso8601String(),
          'views': property.views,
          'location_address': property.locationAddress,
          'google_maps_link': property.googleMapsLink,
          'video_url': property.videoUrl,
          'video_thumbnail_url': property.videoThumbnailUrl,
          'three_sixty_image_urls': property.threeSixtyImageUrls,
          'is_promoted': property.isPromoted,
          'promotion_expiry': property.promotionExpiry?.toIso8601String(),
          'car_make': property.carMake,
          'car_model': property.carModel,
          'car_year': property.carYear,
          'car_fuel_type': property.carFuelType,
          'car_transmission': property.carTransmission,
          'car_mileage': property.carMileage,
          'car_color': property.carColor,
          'car_condition': property.carCondition,
        };
        await supabase.from('properties').upsert(snakeCaseProperty);
      }
      
      // Sync Agents
      final localAgents = HiveService.getAllAgents();
      for (var agent in localAgents) {
        final snakeCaseAgent = {
          'id': agent.id,
          'name': agent.name,
          'phone': agent.phone,
          'whatsapp': agent.whatsapp,
          'email': agent.email,
          'is_verified': agent.isVerified,
          'profile_image_url': agent.profileImageUrl,
          'company_name': agent.companyName,
          'tpin': agent.tpin,
          'license_number': agent.licenseNumber,
          'password_hash': agent.passwordHash,
          'trust_points': agent.trustPoints,
          'verification_level': agent.verificationLevel,
          'average_rating': agent.averageRating,
          'total_reviews': agent.totalReviews,
          'created_at': agent.createdAt?.toIso8601String(),
        };
        await supabase.from('agents').upsert(snakeCaseAgent);
      }
      
      print('✅ Synced ${localProperties.length} properties, ${localAgents.length} agents');
    } catch (e) {
      print('❌ Sync failed: $e');
    }
  }

  // ============ PULL FROM CLOUD TO LOCAL ============

  // Pull data from Supabase to Hive (snake_case → camelCase)
  static Future<void> pullFromCloud() async {
    if (!_isInitialized) return;
    
    print('🔄 Pulling data from Supabase...');
    
    try {
      // Pull Properties
      final propertiesResponse = await supabase.from('properties').select();
      final cloudProperties = (propertiesResponse as List?) ?? [];
      
      if (cloudProperties.isNotEmpty) {
        final properties = cloudProperties.map((json) => Property(
          id: json['id'] ?? '',
          agentId: json['agent_id'] ?? '',
          title: json['title'] ?? '',
          description: json['description'] ?? '',
          price: (json['price'] as num?)?.toDouble() ?? 0.0,
          area: json['area'] ?? '',
          type: PropertyType.values[json['type'] ?? 0],
          status: PropertyStatus.values[json['status'] ?? 0],
          imageUrls: List<String>.from(json['image_urls'] ?? []),
          bedrooms: json['bedrooms'] ?? 0,
          bathrooms: json['bathrooms'] ?? 0,
          landSize: json['land_size'] != null ? (json['land_size'] as num).toDouble() : null,
          createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
          views: json['views'] ?? 0,
          locationAddress: json['location_address'],
          googleMapsLink: json['google_maps_link'],
          videoUrl: json['video_url'],
          videoThumbnailUrl: json['video_thumbnail_url'],
          threeSixtyImageUrls: List<String>.from(json['three_sixty_image_urls'] ?? []),
          isPromoted: json['is_promoted'] ?? false,
          promotionExpiry: json['promotion_expiry'] != null ? DateTime.parse(json['promotion_expiry']) : null,
          carMake: json['car_make'],
          carModel: json['car_model'],
          carYear: json['car_year'],
          carFuelType: json['car_fuel_type'],
          carTransmission: json['car_transmission'],
          carMileage: json['car_mileage'],
          carColor: json['car_color'],
          carCondition: json['car_condition'],
        )).toList();
        
        await HiveService.saveProperties(properties);
        print('✅ Pulled ${properties.length} properties');
      } else {
        print('ℹ️ No properties found in cloud');
      }
      
      // Pull Agents
      final agentsResponse = await supabase.from('agents').select();
      final cloudAgents = (agentsResponse as List?) ?? [];
      
      if (cloudAgents.isNotEmpty) {
        for (var json in cloudAgents) {
          final agent = Agent(
            id: json['id'] ?? '',
            name: json['name'] ?? '',
            phone: json['phone'] ?? '',
            whatsapp: json['whatsapp'],
            email: json['email'],
            isVerified: json['is_verified'] ?? false,
            profileImageUrl: json['profile_image_url'],
            companyName: json['company_name'] ?? '',
            tpin: json['tpin'],
            licenseNumber: json['license_number'],
            passwordHash: json['password_hash'],
            trustPoints: json['trust_points'] ?? 50,
            verificationLevel: json['verification_level'] ?? 'basicVerified',
            averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
            totalReviews: json['total_reviews'] ?? 0,
            createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
          );
          await HiveService.saveAgent(agent);
        }
        print('✅ Pulled ${cloudAgents.length} agents');
      } else {
        print('ℹ️ No agents found in cloud');
      }
      
    } catch (e) {
      print('❌ Pull failed: $e');
    }
  }

  // ============ SINGLE ITEM SYNC ============

  // Upload a single property to cloud
  static Future<void> uploadProperty(Property property) async {
    if (!_isInitialized) return;
    
    try {
      final snakeCaseProperty = {
        'id': property.id,
        'agent_id': property.agentId,
        'title': property.title,
        'description': property.description,
        'price': property.price,
        'area': property.area,
        'type': property.type.index,
        'status': property.status.index,
        'image_urls': property.imageUrls,
        'bedrooms': property.bedrooms,
        'bathrooms': property.bathrooms,
        'land_size': property.landSize,
        'created_at': property.createdAt.toIso8601String(),
        'views': property.views,
        'location_address': property.locationAddress,
        'google_maps_link': property.googleMapsLink,
        'video_url': property.videoUrl,
        'video_thumbnail_url': property.videoThumbnailUrl,
        'three_sixty_image_urls': property.threeSixtyImageUrls,
        'is_promoted': property.isPromoted,
        'car_make': property.carMake,
        'car_model': property.carModel,
        'car_year': property.carYear,
        'car_fuel_type': property.carFuelType,
        'car_transmission': property.carTransmission,
        'car_mileage': property.carMileage,
        'car_color': property.carColor,
        'car_condition': property.carCondition,
      };
      await supabase.from('properties').upsert(snakeCaseProperty);
      print('✅ Property uploaded: ${property.title}');
    } catch (e) {
      print('❌ Upload failed: $e');
    }
  }

  // Upload a single agent to cloud
  static Future<void> uploadAgent(Agent agent) async {
    if (!_isInitialized) return;
    
    try {
      final snakeCaseAgent = {
        'id': agent.id,
        'name': agent.name,
        'phone': agent.phone,
        'whatsapp': agent.whatsapp,
        'email': agent.email,
        'is_verified': agent.isVerified,
        'profile_image_url': agent.profileImageUrl,
        'company_name': agent.companyName,
        'tpin': agent.tpin,
        'license_number': agent.licenseNumber,
        'password_hash': agent.passwordHash,
        'trust_points': agent.trustPoints,
        'verification_level': agent.verificationLevel,
        'average_rating': agent.averageRating,
        'total_reviews': agent.totalReviews,
        'created_at': agent.createdAt?.toIso8601String(),
      };
      await supabase.from('agents').upsert(snakeCaseAgent);
      print('✅ Agent uploaded: ${agent.name}');
    } catch (e) {
      print('❌ Agent upload failed: $e');
    }
  }

  // ============ DELETE ============

  // Delete property from cloud
  static Future<void> deleteProperty(String propertyId) async {
    if (!_isInitialized) return;
    
    try {
      await supabase.from('properties').delete().eq('id', propertyId);
      print('✅ Property deleted: $propertyId');
    } catch (e) {
      print('❌ Delete failed: $e');
    }
  }

  // ============ UTILITY ============

  // Check if Supabase is reachable
  static Future<bool> checkConnection() async {
    if (!_isInitialized) return false;
    
    try {
      await supabase.from('properties').select().limit(1);
      return true;
    } catch (e) {
      return false;
    }
  }
}

