enum ComplaintType {
  appIssue,
  agentConduct,
  propertyMisrepresentation,
  paymentIssue,
  other,
}

class Complaint {
  final String id;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final ComplaintType type;
  final String subject;
  final String description;
  final String? agentId;
  final String? agentName;
  final String? propertyId;
  final String? propertyTitle;
  final DateTime createdAt;
  final String status; // pending, reviewing, resolved, rejected
  final String? adminResponse;
  final DateTime? resolvedAt;

  Complaint({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.type,
    required this.subject,
    required this.description,
    this.agentId,
    this.agentName,
    this.propertyId,
    this.propertyTitle,
    required this.createdAt,
    this.status = 'pending',
    this.adminResponse,
    this.resolvedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'type': type.index,
      'subject': subject,
      'description': description,
      'agentId': agentId,
      'agentName': agentName,
      'propertyId': propertyId,
      'propertyTitle': propertyTitle,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
      'adminResponse': adminResponse,
      'resolvedAt': resolvedAt?.toIso8601String(),
    };
  }

  factory Complaint.fromMap(Map<String, dynamic> map) {
    return Complaint(
      id: map['id'],
      customerId: map['customerId'],
      customerName: map['customerName'],
      customerPhone: map['customerPhone'],
      type: ComplaintType.values[map['type']],
      subject: map['subject'],
      description: map['description'],
      agentId: map['agentId'],
      agentName: map['agentName'],
      propertyId: map['propertyId'],
      propertyTitle: map['propertyTitle'],
      createdAt: DateTime.parse(map['createdAt']),
      status: map['status'] ?? 'pending',
      adminResponse: map['adminResponse'],
      resolvedAt: map['resolvedAt'] != null ? DateTime.parse(map['resolvedAt']) : null,
    );
  }
}