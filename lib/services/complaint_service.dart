import 'package:hive/hive.dart';
import '../models/complaint.dart';

class ComplaintService {
  static late Box _complaintsBox;
  static bool _isInitialized = false;

  static Future<void> init() async {
    if (_isInitialized) return;
    
    _complaintsBox = await Hive.openBox('complaints');
    _isInitialized = true;
    print('✅ ComplaintService initialized');
  }

  // Submit a complaint
  static Future<void> submitComplaint(Complaint complaint) async {
    await _complaintsBox.put(complaint.id, complaint.toMap());
    print('✅ Complaint submitted: ${complaint.subject}');
  }

  // Get all complaints (admin)
  static List<Complaint> getAllComplaints() {
    return _complaintsBox.values
        .map((map) => Complaint.fromMap(map as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Get complaints by customer
  static List<Complaint> getCustomerComplaints(String customerId) {
    return _complaintsBox.values
        .map((map) => Complaint.fromMap(map as Map<String, dynamic>))
        .where((c) => c.customerId == customerId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Get pending complaints (admin)
  static List<Complaint> getPendingComplaints() {
    return _complaintsBox.values
        .map((map) => Complaint.fromMap(map as Map<String, dynamic>))
        .where((c) => c.status == 'pending' || c.status == 'reviewing')
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Update complaint status (admin)
  static Future<void> updateComplaintStatus({
    required String complaintId,
    required String status,
    String? adminResponse,
  }) async {
    final map = _complaintsBox.get(complaintId);
    if (map != null) {
      final complaint = Complaint.fromMap(map as Map<String, dynamic>);
      final updatedComplaint = Complaint(
        id: complaint.id,
        customerId: complaint.customerId,
        customerName: complaint.customerName,
        customerPhone: complaint.customerPhone,
        type: complaint.type,
        subject: complaint.subject,
        description: complaint.description,
        agentId: complaint.agentId,
        agentName: complaint.agentName,
        propertyId: complaint.propertyId,
        propertyTitle: complaint.propertyTitle,
        createdAt: complaint.createdAt,
        status: status,
        adminResponse: adminResponse ?? complaint.adminResponse,
        resolvedAt: status == 'resolved' ? DateTime.now() : complaint.resolvedAt,
      );
      await _complaintsBox.put(complaintId, updatedComplaint.toMap());
    }
  }
}