import 'package:flutter/material.dart';

class Agent {
  final String id;
  final String name;
  final String phone;
  final String? whatsapp;
  final String? email;
  final bool isVerified;
  final String? profileImageUrl;
  final String companyName;
  
  // TPIN / License Number
  final String? tpin;
  final String? licenseNumber;  // NEW: Agent license number
  final String? passwordHash;    // NEW: Hashed password
  
  final int trustPoints;
  final String verificationLevel;
  final double averageRating;
  final int totalReviews;
  final DateTime? createdAt;

  Agent({
    required this.id,
    required this.name,
    required this.phone,
    this.whatsapp,
    this.email,
    required this.isVerified,
    this.profileImageUrl,
    required this.companyName,
    this.tpin,
    this.licenseNumber,
    this.passwordHash,
    this.trustPoints = 50,
    this.verificationLevel = 'basicVerified',
    this.averageRating = 0.0,
    this.totalReviews = 0,
    this.createdAt,
  });

  String get displayWhatsApp => whatsapp ?? phone;
  bool get hasTPIN => tpin != null && tpin!.isNotEmpty;
  bool get hasLicense => licenseNumber != null && licenseNumber!.isNotEmpty;
  
  String get trustLevel {
    if (trustPoints >= 150) return 'Premium Trusted Agent';
    if (trustPoints >= 100) return 'Trusted Agent';
    if (trustPoints >= 75) return 'Verified Agent';
    if (trustPoints >= 50) return 'New Agent';
    return 'Basic Agent';
  }
  
  Color get trustColor {
    if (trustPoints >= 150) return const Color(0xFFFFD700);
    if (trustPoints >= 100) return Colors.green;
    if (trustPoints >= 75) return Colors.blue;
    if (trustPoints >= 50) return Colors.orange;
    return Colors.grey;
  }
  
  IconData get trustIcon {
    if (trustPoints >= 100) return Icons.verified;
    if (trustPoints >= 50) return Icons.star_half;
    return Icons.star_outline;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'whatsapp': whatsapp,
      'email': email,
      'isVerified': isVerified,
      'profileImageUrl': profileImageUrl,
      'companyName': companyName,
      'tpin': tpin,
      'licenseNumber': licenseNumber,
      'passwordHash': passwordHash,
      'trustPoints': trustPoints,
      'verificationLevel': verificationLevel,
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory Agent.fromMap(Map<String, dynamic> map) {
    return Agent(
      id: map['id'] as String,
      name: map['name'] as String,
      phone: map['phone'] as String,
      whatsapp: map['whatsapp'] as String?,
      email: map['email'] as String?,
      isVerified: map['isVerified'] ?? false,
      profileImageUrl: map['profileImageUrl'] as String?,
      companyName: map['companyName'] as String,
      tpin: map['tpin'] as String?,
      licenseNumber: map['licenseNumber'] as String?,
      passwordHash: map['passwordHash'] as String?,
      trustPoints: map['trustPoints'] as int? ?? 50,
      verificationLevel: map['verificationLevel'] as String? ?? 'basicVerified',
      averageRating: (map['averageRating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: map['totalReviews'] as int? ?? 0,
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt'] as String) : null,
    );
  }
}
