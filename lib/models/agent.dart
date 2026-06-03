class Agent {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final bool isVerified;
  final String? profileImageUrl;
  final String companyName;
  
  // TPIN & Verification Fields
  final String? tpin;
  final String? pacraNumber;
  final String? businessLicense;
  final String verificationLevel; // unverified, phoneVerified, businessVerified, premiumVerified
  final DateTime? createdAt;

  Agent({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    required this.isVerified,
    this.profileImageUrl,
    required this.companyName,
    this.tpin,
    this.pacraNumber,
    this.businessLicense,
    this.verificationLevel = 'unverified',
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'isVerified': isVerified,
      'profileImageUrl': profileImageUrl,
      'companyName': companyName,
      'tpin': tpin,
      'pacraNumber': pacraNumber,
      'businessLicense': businessLicense,
      'verificationLevel': verificationLevel,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory Agent.fromMap(Map<String, dynamic> map) {
    return Agent(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      email: map['email'],
      isVerified: map['isVerified'] ?? false,
      profileImageUrl: map['profileImageUrl'],
      companyName: map['companyName'],
      tpin: map['tpin'],
      pacraNumber: map['pacraNumber'],
      businessLicense: map['businessLicense'],
      verificationLevel: map['verificationLevel'] ?? 'unverified',
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
    );
  }
}