import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/property.dart';
import '../utils/constants.dart';
import '../services/favorites_service.dart';

class PropertyCard extends StatefulWidget {
  final Property property;
  final VoidCallback onTap;

  const PropertyCard({
    super.key,
    required this.property,
    required this.onTap,
  });

  @override
  State<PropertyCard> createState() => _PropertyCardState();
}

class _PropertyCardState extends State<PropertyCard> {
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFavorite();
  }

  Future<void> _checkFavorite() async {
    bool favorite = await FavoritesService.isFavorite(widget.property.id);
    if (mounted) {
      setState(() {
        _isFavorite = favorite;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    await FavoritesService.toggleFavorite(widget.property.id);
    setState(() {
      _isFavorite = !_isFavorite;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isFavorite ? 'Added to favorites' : 'Removed from favorites'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  String _formatPrice() {
    final formatter = NumberFormat('#,##0');
    switch (widget.property.type) {
      case PropertyType.rent:
        return 'ZMW ${formatter.format(widget.property.price)}/month';
      case PropertyType.land:
        return 'ZMW ${formatter.format(widget.property.price)}';
      case PropertyType.car:
        return 'ZMW ${formatter.format(widget.property.price)}';
      case PropertyType.buy:
        return 'ZMW ${formatter.format(widget.property.price)}';
    }
  }

  String _getStatusText() {
    switch (widget.property.status) {
      case PropertyStatus.available:
        return 'AVAILABLE';
      case PropertyStatus.sold:
        return 'SOLD';
      case PropertyStatus.rented:
        return 'RENTED';
    }
  }

  Color _getStatusColor() {
    switch (widget.property.status) {
      case PropertyStatus.available:
        return Colors.green;
      case PropertyStatus.sold:
        return Colors.red;
      case PropertyStatus.rented:
        return Colors.orange;
    }
  }

  String _getTypeText() {
    switch (widget.property.type) {
      case PropertyType.rent:
        return 'FOR RENT';
      case PropertyType.buy:
        return 'FOR SALE';
      case PropertyType.land:
        return 'LAND';
      case PropertyType.car:
        return 'CAR';
    }
  }

  Color _getTypeColor() {
    switch (widget.property.type) {
      case PropertyType.rent:
        return Colors.blue;
      case PropertyType.buy:
        return Colors.purple;
      case PropertyType.land:
        return Colors.green;
      case PropertyType.car:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
      ),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppConstants.cardBorderRadius),
                  ),
                  child: widget.property.imageUrls.isNotEmpty
                      ? Image.network(
                          widget.property.imageUrls.first,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 200,
                              color: isDark ? Colors.grey[800] : Colors.grey[300],
                              child: const Icon(Icons.broken_image, size: 50),
                            );
                          },
                        )
                      : Container(
                          height: 200,
                          color: isDark ? Colors.grey[800] : Colors.grey[300],
                          child: Icon(
                            widget.property.type == PropertyType.car 
                                ? Icons.directions_car 
                                : Icons.home,
                            size: 50,
                            color: Colors.grey[600],
                          ),
                        ),
                ),
                
                // Promoted badge
                if (widget.property.isPromoted)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.amber, Colors.orange],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, color: Colors.white, size: 12),
                          SizedBox(width: 4),
                          Text('PROMOTED', style: TextStyle(color: Colors.white, fontSize: 10)),
                        ],
                      ),
                    ),
                  ),
                
                // Status badge
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getStatusText(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                
                // Type badge
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getTypeColor(),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.property.type == PropertyType.car 
                              ? Icons.directions_car 
                              : widget.property.type == PropertyType.land
                                  ? Icons.landscape
                                  : Icons.home,
                          color: Colors.white,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getTypeText(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Favorite button
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: _toggleFavorite,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: _isFavorite ? Colors.red : Colors.grey,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            // Content section
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    widget.property.title,
                    style: AppConstants.headline2.copyWith(fontSize: 18),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  
                  // Price
                  Text(
                    _formatPrice(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Car specific info (if car)
                  if (widget.property.type == PropertyType.car && widget.property.carMake != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.directions_car, size: 12, color: Colors.orange[800]),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.property.carMake} ${widget.property.carModel}',
                            style: TextStyle(fontSize: 12, color: Colors.orange[800]),
                          ),
                        ],
                      ),
                    ),
                  
                  const SizedBox(height: 8),
                  
                  // Location
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        widget.property.area,
                        style: AppConstants.bodyText.copyWith(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Features
                  if (widget.property.type != PropertyType.car && widget.property.type != PropertyType.land)
                    Row(
                      children: [
                        Icon(Icons.bed, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text('${widget.property.bedrooms}', style: AppConstants.caption),
                        const SizedBox(width: 16),
                        Icon(Icons.bathtub, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text('${widget.property.bathrooms}', style: AppConstants.caption),
                      ],
                    ),
                  
                  if (widget.property.type == PropertyType.land && widget.property.landSize != null)
                    Row(
                      children: [
                        Icon(Icons.landscape, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text('${widget.property.landSize!.toStringAsFixed(0)} sqm', style: AppConstants.caption),
                      ],
                    ),
                  
                  if (widget.property.type == PropertyType.car && widget.property.carYear != null)
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text('${widget.property.carYear}', style: AppConstants.caption),
                        const SizedBox(width: 16),
                        Icon(Icons.speed, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text('${widget.property.carMileage?.toStringAsFixed(0) ?? 'N/A'} km', style: AppConstants.caption),
                      ],
                    ),
                  
                  const SizedBox(height: 4),
                  
                  // Views
                  Row(
                    children: [
                      Icon(Icons.visibility, size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text('${widget.property.views} views', style: AppConstants.caption),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}