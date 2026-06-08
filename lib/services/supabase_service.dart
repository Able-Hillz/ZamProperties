import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/property.dart';
import '../models/agent.dart';
import 'hive_service.dart';

class SupabaseService {
  static final supabase = Supabase.instance.client;
  static bool _isInitialized = false;

  static Future<void> init() async {
    await Supabase.initialize(
      url: 'YOUR_SUPABASE_URL',  // ← Replace with your URL
      anonKey: 'YOUR_ANON_KEY',   // ← Replace with your anon key
    );
    _isInitialized = true;
    print('✅ Supabase initialized');
  }

  static bool get isAvailable => _isInitialized;

  // Upload multiple images
  // Upload multiple images
static Future<List<String>> uploadImages(List<File> images, String propertyId) async {
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


  // Upload single image
  // Upload single image to Supabase Storage - FIXED
static Future<String?> uploadImage(File imageFile, String fileName) async {
  if (!_isInitialized) return null;
  
  try {
    // Read file bytes
    final bytes = await imageFile.readAsBytes();
    
    // Upload to storage bucket
    await supabase.storage
        .from('property-images')
        .uploadBinary(fileName, bytes);
    
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
      
      return publicUrl;
    } catch (e) {
      print('❌ Video upload failed: $e');
      return null;
    }
  }

  // Sync local to cloud
  static Future<void> syncLocalToCloud() async {
    if (!_isInitialized) return;
    
    print('🔄 Syncing local data to Supabase...');
    
    try {
      final localProperties = HiveService.getAllProperties();
      for (var property in localProperties) {
        await supabase.from('properties').upsert(property.toMap());
      }
      
      final localAgents = HiveService.getAllAgents();
      for (var agent in localAgents) {
        await supabase.from('agents').upsert(agent.toMap());
      }
      
      print('✅ Synced ${localProperties.length} properties, ${localAgents.length} agents');
    } catch (e) {
      print('❌ Sync failed: $e');
    }
  }


// Simple real-time listener - FIXED
//static void listenToChanges() {
  //if (!_isInitialized) return;
  //print('🎧 Real-time listener enabled for properties');
  
  // Listen to all changes on properties table
  //supabase
      //.from('properties')
      //.stream(primaryKey: ['id'])
      ///.listen((List<Map<String, dynamic>> data) {
    //print('🔄 Real-time update received: ${data.length} properties');
    //pullFromCloud();
  //});
//}


  // Pull from cloud to Hive
 // Pull from cloud to Hive - FIXED
static Future<void> pullFromCloud() async {
  if (!_isInitialized) return;
  
  print('🔄 Pulling data from Supabase...');
  
  try {
    // Pull properties - handle null response
    final propertiesResponse = await supabase.from('properties').select();
    final cloudProperties = (propertiesResponse as List?) ?? [];
    
    if (cloudProperties.isNotEmpty) {
      final properties = cloudProperties.map((json) => Property.fromMap(json)).toList();
      await HiveService.saveProperties(properties);
      print('✅ Pulled ${properties.length} properties');
    } else {
      print('ℹ️ No properties found in cloud');
    }
    
    // Pull agents - handle null response
    final agentsResponse = await supabase.from('agents').select();
    final cloudAgents = (agentsResponse as List?) ?? [];
    
    if (cloudAgents.isNotEmpty) {
      for (var json in cloudAgents) {
        final agent = Agent.fromMap(json);
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
}