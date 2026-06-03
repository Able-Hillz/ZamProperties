import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  static const String _key = 'favorites';
  
  // Save favorite property IDs
  static Future<void> toggleFavorite(String propertyId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList(_key) ?? [];
    
    if (favorites.contains(propertyId)) {
      favorites.remove(propertyId);
    } else {
      favorites.add(propertyId);
    }
    
    await prefs.setStringList(_key, favorites);
  }
  
  // Check if property is favorited
  static Future<bool> isFavorite(String propertyId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList(_key) ?? [];
    return favorites.contains(propertyId);
  }
  
  // Get all favorite IDs
  static Future<List<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }
  
  // Clear all favorites
  static Future<void> clearFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
  
  // Get favorite count
  static Future<int> getFavoritesCount() async {
    final favorites = await getFavorites();
    return favorites.length;
  }
}