import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/zambia_areas.dart';
import '../models/property.dart';
import '../services/mock_data_service.dart';
import '../widgets/property_card.dart';
import 'property_detail_screen.dart';
import 'favorites_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const HomeScreen({
    super.key,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Property> _properties = [];
  List<Property> _filteredProperties = [];
  bool _isLoading = true;
  
  // Filters
  PropertyType? _selectedType;
  String? _selectedArea;
  double? _maxPrice;
  
  // Available price ranges for Zambia market
  final Map<String, double> _priceRanges = {
    'Any Price': 0,
    'Under ZMW 2,000': 2000,
    'ZMW 2,000 - 5,000': 5000,
    'ZMW 5,000 - 10,000': 10000,
    'ZMW 10,000 - 20,000': 20000,
    'ZMW 20,000+': 100000,
  };

  @override
  void initState() {
    super.initState();
    _loadProperties();
  }

  void _loadProperties() {
    setState(() {
      _properties = MockDataService.getAllProperties();
      _filteredProperties = _properties;
      _isLoading = false;
    });
  }

  void _applyFilters() {
    setState(() {
      _filteredProperties = MockDataService.filterProperties(
        type: _selectedType,
        area: _selectedArea,
        maxPrice: _maxPrice,
      );
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedType = null;
      _selectedArea = null;
      _maxPrice = null;
      _filteredProperties = _properties;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isDarkMode ? Colors.grey[900] : Colors.grey[50],
      body: Column(
        children: [
          // Custom AppBar
          Container(
            decoration: const BoxDecoration(
              color: AppConstants.primaryColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.home_work, color: AppConstants.secondaryColor),
                        const SizedBox(width: 8),
                        const Text(
                          AppConstants.appName,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        const Spacer(),
                        // Dark Mode Toggle
                        IconButton(
                          icon: Icon(
                            widget.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                            color: Colors.white,
                          ),
                          onPressed: widget.toggleTheme,
                          tooltip: widget.isDarkMode ? 'Light Mode' : 'Dark Mode',
                        ),
                        // Favorites
                        IconButton(
                          icon: const Icon(Icons.favorite_border, color: Colors.white),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const FavoritesScreen()),
                            );
                          },
                          tooltip: 'Favorites',
                        ),
                        // Settings
                        IconButton(
                          icon: const Icon(Icons.settings, color: Colors.white),
                          onPressed: () {
                            Navigator.pushNamed(context, '/settings');
                          },
                          tooltip: 'Settings',
                        ),
                      ],
                    ),
                  ),
                  // Quick filter chips
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('All', _selectedType == null, () {
                            setState(() => _selectedType = null);
                            _applyFilters();
                          }),
                          const SizedBox(width: 8),
                          _buildFilterChip('For Rent', _selectedType == PropertyType.rent, () {
                            setState(() => _selectedType = PropertyType.rent);
                            _applyFilters();
                          }),
                          const SizedBox(width: 8),
                          _buildFilterChip('For Sale', _selectedType == PropertyType.buy, () {
                            setState(() => _selectedType = PropertyType.buy);
                            _applyFilters();
                          }),
                          const SizedBox(width: 8),
                          _buildFilterChip('Land', _selectedType == PropertyType.land, () {
                            setState(() => _selectedType = PropertyType.land);
                            _applyFilters();
                          }),
                          const SizedBox(width: 8),
                          _buildFilterChip('Filter', false, _showFilterSheet),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Results count
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_filteredProperties.length} properties found',
                  style: AppConstants.caption.copyWith(fontSize: 14),
                ),
                if (_selectedArea != null || _selectedType != null || _maxPrice != null)
                  TextButton(
                    onPressed: _clearFilters,
                    child: const Text('Clear All'),
                  ),
              ],
            ),
          ),
          
          // Property list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredProperties.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredProperties.length,
                        itemBuilder: (context, index) {
                          final property = _filteredProperties[index];
                          return PropertyCard(
                            property: property,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PropertyDetailScreen(
                                    property: property,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: Colors.white,
      selectedColor: AppConstants.primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppConstants.primaryColor,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? AppConstants.primaryColor : Colors.grey[300]!,
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filter Properties',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  
                  // Area filter
                  const Text('Area', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedArea,
                        hint: const Text('Select Area'),
                        isExpanded: true,
                        items: [
                          const DropdownMenuItem(value: null, child: Text('All Areas')),
                          ...ZambiaAreas.getAllAreas().map((area) {
                            return DropdownMenuItem(value: area, child: Text(area));
                          }),
                        ],
                        onChanged: (value) {
                          setStateModal(() {
                            _selectedArea = value;
                          });
                        },
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Price range filter
                  const Text('Price Range (ZMW)', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _priceRanges.entries
                            .firstWhere((entry) => entry.value == (_maxPrice ?? 0))
                            .key,
                        isExpanded: true,
                        items: _priceRanges.keys.map((range) {
                          return DropdownMenuItem(value: range, child: Text(range));
                        }).toList(),
                        onChanged: (value) {
                          setStateModal(() {
                            _maxPrice = _priceRanges[value!];
                          });
                        },
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _clearFilters();
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Reset'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _applyFilters();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppConstants.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Apply Filters'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No properties found',
            style: AppConstants.headline2.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try adjusting your filters',
            style: AppConstants.caption,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _clearFilters,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
            ),
            child: const Text('Clear Filters'),
          ),
        ],
      ),
    );
  }
}