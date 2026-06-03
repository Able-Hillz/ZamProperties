enum PropertyType { rent, buy, land }
enum PropertyStatus { available, sold, rented }

class Property {
  final String id;
  final String agentId;
  final String title;
  final String description;
  final double price;
  final String area;
  final PropertyType type;
  final PropertyStatus status;
  final List<String> imageUrls;
  final int bedrooms;
  final int bathrooms;
  final double? landSize;
  final DateTime createdAt;
  final int views;
  final String? locationAddress;
  final String? googleMapsLink;
  
  // NEW: Video walkthrough
  final String? videoUrl;
  final String? videoThumbnailUrl;
  
  // NEW: 360° photos
  final List<String> threeSixtyImageUrls;

  Property({
    required this.id,
    required this.agentId,
    required this.title,
    required this.description,
    required this.price,
    required this.area,
    required this.type,
    required this.status,
    required this.imageUrls,
    required this.bedrooms,
    required this.bathrooms,
    this.landSize,
    required this.createdAt,
    required this.views,
    this.locationAddress,
    this.googleMapsLink,
    this.videoUrl,
    this.videoThumbnailUrl,
    this.threeSixtyImageUrls = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'agentId': agentId,
      'title': title,
      'description': description,
      'price': price,
      'area': area,
      'type': type.index,
      'status': status.index,
      'imageUrls': imageUrls,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'landSize': landSize,
      'createdAt': createdAt.toIso8601String(),
      'views': views,
      'locationAddress': locationAddress,
      'googleMapsLink': googleMapsLink,
      'videoUrl': videoUrl,
      'videoThumbnailUrl': videoThumbnailUrl,
      'threeSixtyImageUrls': threeSixtyImageUrls,
    };
  }

  factory Property.fromMap(Map<String, dynamic> map) {
    return Property(
      id: map['id'],
      agentId: map['agentId'],
      title: map['title'],
      description: map['description'],
      price: map['price'],
      area: map['area'],
      type: PropertyType.values[map['type']],
      status: PropertyStatus.values[map['status']],
      imageUrls: List<String>.from(map['imageUrls']),
      bedrooms: map['bedrooms'],
      bathrooms: map['bathrooms'],
      landSize: map['landSize'],
      createdAt: DateTime.parse(map['createdAt']),
      views: map['views'],
      locationAddress: map['locationAddress'],
      googleMapsLink: map['googleMapsLink'],
      videoUrl: map['videoUrl'],
      videoThumbnailUrl: map['videoThumbnailUrl'],
      threeSixtyImageUrls: map['threeSixtyImageUrls'] != null 
          ? List<String>.from(map['threeSixtyImageUrls']) 
          : [],
    );
  }
}