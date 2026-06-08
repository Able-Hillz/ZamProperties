import 'package:flutter/material.dart';
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
  
  final _whatsappController = TextEditingController();
  final _tpinController = TextEditingController();
  
  bool _isSubmitting = false;
  bool _sameAsPhone = false;
  bool _hasTPIN = false;
  int _trustPoints = 0;
  
  // TPIN benefits
  static const int _tpinTrustPoints = 50;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  Future<void> _loadExistingData() async {
    final agent = HiveService.getAgent(widget.agentId);
    if (agent != null) {
      setState(() {
        _whatsappController.text = agent.whatsapp ?? '';
        _tpinController.text = agent.tpin ?? '';
        _hasTPIN = agent.hasTPIN;
        _trustPoints = agent.trustPoints;
        
        // Check if WhatsApp is same as phone
        if (agent.whatsapp == widget.agentPhone) {
          _sameAsPhone = true;
        }
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
    
    // Determine WhatsApp number
    final whatsappNumber = _sameAsPhone ? widget.agentPhone : _whatsappController.text;
    
    // Calculate trust points
    int newTrustPoints = 50; // Base points for completing registration
    
    // Add points for TPIN
    final hasTPIN = _tpinController.text.isNotEmpty;
    if (hasTPIN) {
      newTrustPoints += _tpinTrustPoints;
    }
    
    // Add points for verified phone (if phone is valid length)
    if (widget.agentPhone.length >= 10) {
      newTrustPoints += 25;
    }
    
    // Add points for business email (if exists)
    if (existingAgent.email != null && existingAgent.email!.contains('@')) {
      newTrustPoints += 25;
    }
    
    // Determine verification level
    String verificationLevel;
    if (hasTPIN) {
      verificationLevel = 'premiumVerified';
    } else if (whatsappNumber.isNotEmpty && whatsappNumber == widget.agentPhone) {
      verificationLevel = 'phoneVerified';
    } else {
      verificationLevel = 'basicVerified';
    }
    
    final updatedAgent = Agent(
      id: existingAgent.id,
      name: existingAgent.name,
      phone: existingAgent.phone,
      whatsapp: whatsappNumber.isEmpty ? null : whatsappNumber,
      email: existingAgent.email,
      isVerified: hasTPIN || whatsappNumber.isNotEmpty,
      profileImageUrl: existingAgent.profileImageUrl,
      companyName: existingAgent.companyName,
      tpin: _tpinController.text.isNotEmpty ? _tpinController.text : null,
      trustPoints: newTrustPoints,
      verificationLevel: verificationLevel,
      createdAt: existingAgent.createdAt,
      averageRating: existingAgent.averageRating,
      totalReviews: existingAgent.totalReviews,
    );
    
    await HiveService.saveAgent(updatedAgent);
    
    // Show success message with TPIN bonus if applicable
    if (hasTPIN && !_hasTPIN) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('✓ TPIN Verified!'),
              Text(
                '+$_tpinTrustPoints trust points added',
                style: const TextStyle(fontSize: 12),
              ),
              const Text('Your profile will now appear more trustworthy'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification information saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
    
    setState(() => _isSubmitting = false);
    Navigator.pop(context, true);
  }

  String _getTrustLevelMessage() {
    if (_tpinController.text.isNotEmpty) {
      return '✓ TPIN verified! You get +$_tpinTrustPoints trust points';
    } else if (_sameAsPhone || _whatsappController.text.isNotEmpty) {
      return 'ℹ️ Add your TPIN to earn +$_tpinTrustPoints trust points';
    } else {
      return '⚠️ Add your WhatsApp number or TPIN to increase trust score';
    }
  }

  @override
  Widget build(BuildContext context) {
    final whatsappValue = _sameAsPhone ? widget.agentPhone : _whatsappController.text;
    final hasTPINValue = _tpinController.text.isNotEmpty;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agent Verification'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppConstants.primaryColor.withOpacity(0.1),
                      AppConstants.secondaryColor.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppConstants.primaryColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.verified_user, color: AppConstants.primaryColor, size: 40),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Build Trust with Customers',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Verified agents get trust badges, appear higher in search, and get more customer inquiries',
                            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Current Status Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _getStatusColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _getStatusColor()),
                ),
                child: Row(
                  children: [
                    Icon(_getStatusIcon(), color: _getStatusColor(), size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Current Trust Status',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            _getStatusText(),
                            style: TextStyle(color: _getStatusColor(), fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.star, size: 16, color: Colors.amber),
                              const SizedBox(width: 4),
                              Text(
                                '$_trustPoints Trust Points',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // WhatsApp Section (MAJOR FIELD 2)
              const Text(
                'WhatsApp Number',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Customers can reach you via WhatsApp for quick responses',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              
              CheckboxListTile(
                value: _sameAsPhone,
                onChanged: (bool? value) {
                  setState(() {
                    _sameAsPhone = value ?? false;
                    if (_sameAsPhone) {
                      _whatsappController.clear();
                    }
                  });
                },
                title: const Text('Use same number as phone number'),
                subtitle: Text('Phone: ${widget.agentPhone}'),
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: AppConstants.primaryColor,
              ),
              
              if (!_sameAsPhone)
                TextFormField(
                  controller: _whatsappController,
                  decoration: const InputDecoration(
                    labelText: 'WhatsApp Number',
                    hintText: '0977123456',
                    prefixIcon: Icon(Icons.chat),
                    border: OutlineInputBorder(),
                    helperText: 'Enter your WhatsApp number (optional)',
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (!_sameAsPhone && value != null && value.isNotEmpty) {
                      if (value.length < 10) {
                        return 'Please enter a valid phone number';
                      }
                    }
                    return null;
                  },
                ),
              const SizedBox(height: 24),
              
              // TPIN Section (MAJOR FIELD 3)
              const Text(
                'TPIN Number',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Taxpayer Identification Number - Adds trust points to your profile',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: hasTPINValue ? Colors.green : Colors.grey.shade300,
                    width: hasTPINValue ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextFormField(
                  controller: _tpinController,
                  decoration: InputDecoration(
                    labelText: 'TPIN Number',
                    hintText: '1234567890',
                    prefixIcon: const Icon(Icons.verified_user),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                    suffixIcon: hasTPINValue
                        ? Tooltip(
                            message: '+$_tpinTrustPoints trust points for TPIN',
                            child: Container(
                              margin: const EdgeInsets.all(8),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.verified, color: Colors.green, size: 16),
                                  SizedBox(width: 4),
                                  Text(
                                    '+50 pts',
                                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : null,
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
              ),
              
              if (hasTPINValue)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.stars, color: Colors.amber, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'TPIN verified! +$_tpinTrustPoints trust points added. Your profile will be prioritized.',
                            style: const TextStyle(color: Colors.green, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              
              // Trust Points Preview
              _buildTrustPointsPreview(whatsappValue, hasTPINValue),
              const SizedBox(height: 32),
              
              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitVerification,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Save Verification Info',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Info Box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Benefits of Verification',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    _buildBenefitItem(Icons.verified, 'Trust Badge on Profile'),
                    const SizedBox(height: 4),
                    _buildBenefitItem(Icons.trending_up, 'Higher Search Ranking'),
                    const SizedBox(height: 4),
                    _buildBenefitItem(Icons.people, 'More Customer Inquiries'),
                    const SizedBox(height: 4),
                    _buildBenefitItem(Icons.star, 'Increased Trust Points'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildTrustPointsPreview(String whatsappValue, bool hasTPIN) {
    int points = 50; // Base points
    
    if (hasTPIN) {
      points += _tpinTrustPoints;
    }
    
    if (whatsappValue.isNotEmpty) {
      points += 25;
    }
    
    if (widget.agentPhone.length >= 10) {
      points += 25;
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppConstants.primaryColor.withOpacity(0.1),
            AppConstants.secondaryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppConstants.primaryColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Trust Score Preview',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 28),
              const SizedBox(width: 8),
              Text(
                '$points',
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              Text(
                ' trust points',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _getTrustLevelMessage(),
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBenefitItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppConstants.primaryColor),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Color _getStatusColor() {
    if (_hasTPIN) {
      return Colors.green;
    } else if (_whatsappController.text.isNotEmpty || _sameAsPhone) {
      return Colors.orange;
    }
    return Colors.red;
  }

  IconData _getStatusIcon() {
    if (_hasTPIN) {
      return Icons.verified;
    } else if (_whatsappController.text.isNotEmpty || _sameAsPhone) {
      return Icons.phone_android;
    }
    return Icons.warning_amber;
  }

  String _getStatusText() {
    if (_hasTPIN) {
      return 'Premium Verified Agent';
    } else if (_whatsappController.text.isNotEmpty || _sameAsPhone) {
      return 'Phone Verified - Add TPIN for Premium Status';
    }
    return 'Unverified - Add WhatsApp or TPIN to get verified';
  }

  @override
  void dispose() {
    _whatsappController.dispose();
    _tpinController.dispose();
    super.dispose();
  }
}