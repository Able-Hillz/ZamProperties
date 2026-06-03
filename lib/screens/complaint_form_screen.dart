import 'package:flutter/material.dart';
import '../models/complaint.dart';
import '../services/complaint_service.dart';
import '../utils/constants.dart';

class ComplaintFormScreen extends StatefulWidget {
  final String customerId;
  final String customerName;
  final String customerPhone;

  const ComplaintFormScreen({
    super.key,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
  });

  @override
  State<ComplaintFormScreen> createState() => _ComplaintFormScreenState();
}

class _ComplaintFormScreenState extends State<ComplaintFormScreen> {
  final _formKey = GlobalKey<FormState>();
  ComplaintType _selectedType = ComplaintType.appIssue;
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isSubmitting = false;

  final Map<ComplaintType, String> _typeLabels = {
    ComplaintType.appIssue: 'App Issue',
    ComplaintType.agentConduct: 'Agent Conduct',
    ComplaintType.propertyMisrepresentation: 'Property Misrepresentation',
    ComplaintType.paymentIssue: 'Payment Issue',
    ComplaintType.other: 'Other',
  };

  Future<void> _submitComplaint() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final complaint = Complaint(
      id: 'comp_${DateTime.now().millisecondsSinceEpoch}',
      customerId: widget.customerId,
      customerName: widget.customerName,
      customerPhone: widget.customerPhone,
      type: _selectedType,
      subject: _subjectController.text.trim(),
      description: _descriptionController.text.trim(),
      createdAt: DateTime.now(),
    );

    await ComplaintService.submitComplaint(complaint);

    setState(() => _isSubmitting = false);
    
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Complaint submitted successfully! We\'ll review it shortly.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Complaint'),
        backgroundColor: AppConstants.primaryColor,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your feedback helps us improve. All complaints are reviewed within 24-48 hours.',
                        style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              const Text(
                'Issue Type *',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<ComplaintType>(
                initialValue: _selectedType,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: ComplaintType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_typeLabels[type]!),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(
                  labelText: 'Subject *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a subject';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  hintText: 'Please provide detailed information about your issue...',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitComplaint,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Submit Complaint'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}