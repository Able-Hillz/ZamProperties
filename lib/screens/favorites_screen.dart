import 'package:flutter/material.dart';
import '../services/mock_data_service.dart';
import '../services/favorites_service.dart';
import '../models/property.dart';
import '../widgets/property_card.dart';
import '../utils/constants.dart';
import 'property_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Property> _favoriteProperties = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);
    
    final favoriteIds = await FavoritesService.getFavorites();
    final allProperties = MockDataService.getAllProperties();
    final favorites = allProperties.where((p) => favoriteIds.contains(p.id)).toList();
    
    setState(() {
      _favoriteProperties = favorites;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: AppConstants.primaryColor,
        elevation: 0,
        title: const Text(
          'My Favorites',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favoriteProperties.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite_border, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No favorites yet',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap the heart icon on any property to save it',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _favoriteProperties.length,
                  itemBuilder: (context, index) {
                    return PropertyCard(
                      property: _favoriteProperties[index],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PropertyDetailScreen(
                              property: _favoriteProperties[index],
                            ),
                          ),
                        ).then((_) => _loadFavorites());
                      },
                    );
                  },
                ),
    );
  }
}