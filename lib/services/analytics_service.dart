import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class AnalyticsService {
  // Get agent stats
  static Future<Map<String, dynamic>> getAgentStats(String agentId) async {
    if (!SupabaseService.isAvailable) {
      return {
        'totalListings': 0,
        'totalViews': 0,
        'avgViewsPerListing': 0,
      };
    }
    
    try {
      final response = await SupabaseService.supabase
          .from('properties')
          .select()
          .eq('agent_id', agentId);
      
      final List<dynamic> properties = response as List<dynamic>;
      
      // Calculate total views
      int totalViews = 0;
      for (var property in properties) {
        totalViews += property['views'] as int? ?? 0;
      }
      
      return {
        'totalListings': properties.length,
        'totalViews': totalViews,
        'avgViewsPerListing': properties.isEmpty ? 0 : totalViews / properties.length,
      };
    } catch (e) {
      print('Analytics error: $e');
      return {
        'totalListings': 0,
        'totalViews': 0,
        'avgViewsPerListing': 0,
      };
    }
  }
  
  // Get views over time
  static Future<Map<String, int>> getViewsOverTime(String propertyId) async {
    if (!SupabaseService.isAvailable) {
      return {};
    }
    
    try {
      final response = await SupabaseService.supabase
          .from('property_analytics')
          .select()
          .eq('property_id', propertyId)
          .order('date', ascending: true);
      
      final Map<String, int> viewsByDate = {};
      for (var record in response as List<dynamic>) {
        viewsByDate[record['date']] = record['views'] as int? ?? 0;
      }
      
      return viewsByDate;
    } catch (e) {
      print('Error getting views over time: $e');
      return {};
    }
  }
  
  // Get popular properties - FIXED VERSION
  static Future<List<Map<String, dynamic>>> getPopularProperties({
    int limit = 10,
    String? city,
    String? propertyType,
  }) async {
    if (!SupabaseService.isAvailable) {
      return [];
    }
    
    try {
      // Build query with filters
      var query = SupabaseService.supabase
          .from('properties')
          .select('id, title, views, city, type, price, image_urls');
      
      // Apply optional filters
      if (city != null && city.isNotEmpty) {
        query = query.eq('city', city);
      }
      
      if (propertyType != null && propertyType.isNotEmpty) {
        query = query.eq('type', propertyType);
      }
      
      // Apply ordering and limit
      final response = await query
          .order('views', ascending: false)
          .limit(limit);
      
      return response as List<Map<String, dynamic>>;
    } catch (e) {
      print('Error getting popular properties: $e');
      return [];
    }
  }
  
  // Track property view
  static Future<void> trackPropertyView(String propertyId, String? userId) async {
    if (!SupabaseService.isAvailable) return;
    
    try {
      // Increment views count on property
      await SupabaseService.supabase.rpc(
        'increment_property_views',
        params: {
          'property_id': propertyId,
        },
      );
      
      // Record individual view for analytics
      await SupabaseService.supabase
          .from('property_views')
          .insert({
            'property_id': propertyId,
            'user_id': userId,
            'viewed_at': DateTime.now().toIso8601String(),
          });
          
    } catch (e) {
      print('Error tracking property view: $e');
    }
  }
  
  // Get agent performance metrics
  static Future<Map<String, dynamic>> getAgentPerformance(String agentId) async {
    if (!SupabaseService.isAvailable) {
      return {
        'totalListings': 0,
        'totalViews': 0,
        'totalInquiries': 0,
        'conversionRate': 0.0,
        'averageRating': 0.0,
      };
    }
    
    try {
      // Get agent's properties
      final properties = await SupabaseService.supabase
          .from('properties')
          .select()
          .eq('agent_id', agentId);
      
      final propertyList = properties as List<dynamic>;
      
      // Calculate total views
      int totalViews = 0;
      for (var property in propertyList) {
        totalViews += property['views'] as int? ?? 0;
      }
      
      // Get total inquiries for agent's properties
      final propertyIds = propertyList.map((p) => p['id'] as String).toList();
      
      int totalInquiries = 0;
      if (propertyIds.isNotEmpty) {
        final inquiries = await SupabaseService.supabase
            .from('inquiries')
            .select()
            .inFilter('property_id', propertyIds);
        
        totalInquiries = (inquiries as List<dynamic>).length;
      }
      
      // Get agent rating
      double averageRating = 0.0;
      final ratings = await SupabaseService.supabase
          .from('agent_ratings')
          .select('rating')
          .eq('agent_id', agentId);
      
      final ratingList = ratings as List<dynamic>;
      if (ratingList.isNotEmpty) {
        int totalRating = 0;
        for (var rating in ratingList) {
          totalRating += rating['rating'] as int? ?? 0;
        }
        averageRating = totalRating / ratingList.length;
      }
      
      // Calculate conversion rate (inquiries / views * 100)
      final conversionRate = totalViews > 0 
          ? (totalInquiries / totalViews) * 100 
          : 0.0;
      
      return {
        'totalListings': propertyList.length,
        'totalViews': totalViews,
        'totalInquiries': totalInquiries,
        'conversionRate': conversionRate,
        'averageRating': averageRating,
        'avgViewsPerListing': propertyList.isEmpty ? 0 : totalViews / propertyList.length,
      };
      
    } catch (e) {
      print('Error getting agent performance: $e');
      return {};
    }
  }
}