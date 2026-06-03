import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/hive_service.dart';
import '../models/agent.dart';
import '../utils/constants.dart';

class AgentVerificationScreen extends StatefulWidget {
  final String agentId;
  final String agentPhone;

  const AgentVerificationScreen({
    super.key,
    required this.agentId,
    required this.agentPhone,
  });

  @override
  State<AgentVerificationScreen> createState() => _AgentVerificationScreenState();
}

class _AgentVerificationScreenState extends State<AgentVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _tpinController = TextEditingController();
  final _pacraController = TextEditingController();
  final _businessLicenseController = TextEditingController();
  
  File? _businessLicenseImage;
  final ImagePicker _picker = ImagePicker();
  
  bool _isSubmitting = false;
  String _verificationLevel = 'unverified';

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  Future<void> _loadExistingData() async {
    final agent = HiveService.getAgent(widget.agentId);
    if (agent != null) {
      setState(() {
        _tpinController.text = agent.tpin ?? '';
        _pacraController.text = agent.pacraNumber ?? '';
        _businessLicenseController.text = agent.businessLicense ?? '';
        _verificationLevel = agent.verificationLevel;
      });
    }
  }

  Future<void> _pickDocument() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _businessLicenseImage = File(image.path);
      });
    }
  }

  Future<void> _submitVerification() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSubmitting = true);
    
    final existingAgent = HiveService.getAgent(widget.agentId);
    if (existingAgent == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agent not found')),
      );
      setState(() => _isSubmitting = false);
      return;
    }
    
    final updatedAgent = Agent(
      id: existingAgent.id,
      name: existingAgent.name,
      phone: existingAgent.phone,
      email: existingAgent.email,
      isVerified: _tpinController.text.isNotEmpty && _pacraController.text.isNotEmpty,
      profileImageUrl: existingAgent.profileImageUrl,
      companyName: existingAgent.companyName,
      tpin: _tpinController.text.isNotEmpty ? _tpinController.text : null,
      pacraNumber: _pacraController.text.isNotEmpty ? _pacraController.text : null,
      businessLicense: _businessLicenseController.text.isNotEmpty ? _businessLicenseController.text : null,
      verificationLevel: _determineVerificationLevel(),
      createdAt: existingAgent.createdAt,
    );
    
    await HiveService.saveAgent(updatedAgent);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Verification information saved!')),
    );
    
    setState(() => _isSubmitting = false);
    Navigator.pop(context, true);
  }

  String _determineVerificationLevel() {
    if (_tpinController.text.isNotEmpty && _pacraController.text.isNotEmpty) {
      return 'businessVerified';
    } else if (_tpinController.text.isNotEmpty) {
      return 'phoneVerified';
    }
    return 'unverified';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Verification'),
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
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.verified_user, color: Colors.blue[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Why get verified?',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Verified agents get a trust badge and appear higher in search results',
                            style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _getStatusColor().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _getStatusColor()),
                ),
                child: Row(
                  children: [
                    Icon(_getStatusIcon(), color: _getStatusColor()),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Current Status',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            _getStatusText(),
                            style: TextStyle(color: _getStatusColor()),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              const Text(
                'TPIN Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _tpinController,
                decoration: const InputDecoration(
                  labelText: 'TPIN Number',
                  hintText: 'e.g., 1234567890',
                  prefixIcon: Icon(Icons.numbers),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _pacraController,
                decoration: const InputDecoration(
                  labelText: 'PACRA Registration Number',
                  hintText: 'e.g., 2024/123456',
                  prefixIcon: Icon(Icons.business),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _businessLicenseController,
                decoration: const InputDecoration(
                  labelText: 'Business License Number (Optional)',
                  hintText: 'e.g., LCC/2024/123',
                  prefixIcon: Icon(Icons.assignment),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              
              const Text(
                'Upload Documents (Optional)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              GestureDetector(
                onTap: _pickDocument,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _businessLicenseImage != null ? Icons.check_circle : Icons.upload_file,
                        color: _businessLicenseImage != null ? Colors.green : Colors.grey,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _businessLicenseImage != null ? 'Document uploaded' : 'Business License / Certificate',
                          style: TextStyle(
                            color: _businessLicenseImage != null ? Colors.green : Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitVerification,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Save Verification Info', style: TextStyle(fontSize: 16)),
                ),
              ),
              
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    const Text(
                      'What happens next?',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your information will be reviewed by our team. '
                      'Once verified, you\'ll receive a verified badge on your profile '
                      'and your listings will be prioritized.',
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (_verificationLevel) {
      case 'businessVerified':
        return Colors.green;
      case 'phoneVerified':
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

  IconData _getStatusIcon() {
    switch (_verificationLevel) {
      case 'businessVerified':
        return Icons.verified;
      case 'phoneVerified':
        return Icons.phone;  // Changed to simple phone icon
      default:
        return Icons.warning;
    }
  }

  String _getStatusText() {
    switch (_verificationLevel) {
      case 'businessVerified':
        return 'Fully Verified Business';
      case 'phoneVerified':
        return 'Phone Verified (TPIN Pending)';
      default:
        return 'Unverified - Complete TPIN to get verified';
    }
  }

  @override
  void dispose() {
    _tpinController.dispose();
    _pacraController.dispose();
    _businessLicenseController.dispose();
    super.dispose();
  }
}