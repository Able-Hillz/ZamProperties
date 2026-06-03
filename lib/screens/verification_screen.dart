import 'package:flutter/material.dart';
import '../services/verification_service.dart';
import '../utils/constants.dart';

class VerificationScreen extends StatefulWidget {
  final String phoneNumber;
  
  const VerificationScreen({super.key, required this.phoneNumber});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _sendCode();
  }

  Future<void> _sendCode() async {
    setState(() => _isLoading = true);
    bool sent = await VerificationService.sendVerificationCode(widget.phoneNumber);
    setState(() {
      _isLoading = false;
    });
    
    if (sent) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification code sent! Check SMS (Demo: 123456)')),
      );
    }
  }

  Future<void> _verifyCode() async {
    if (_codeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter verification code')),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    bool verified = await VerificationService.verifyCode(
      widget.phoneNumber,
      _codeController.text,
    );
    setState(() => _isLoading = false);
    
    if (verified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Phone number verified!')),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid code. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Your Number'),
        backgroundColor: AppConstants.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.phone_android, size: 80, color: AppConstants.primaryColor),
            const SizedBox(height: 24),
            Text(
              'Verify ${widget.phoneNumber}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'We sent a 6-digit verification code to your phone',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 6,
              decoration: InputDecoration(
                labelText: 'Verification Code',
                hintText: '123456',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _verifyCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Verify'),
              ),
            ),
            TextButton(
              onPressed: _sendCode,
              child: const Text("Didn't receive code? Resend"),
            ),
          ],
        ),
      ),
    );
  }
}