import 'package:shared_preferences/shared_preferences.dart';

class VerificationService {
  static const String _verifiedKey = 'verified_agents';
  
  // Simulate SMS verification (will integrate with real SMS API later)
  static Future<bool> sendVerificationCode(String phoneNumber) async {
    // In production, integrate with Africa's Talking, Twilio, or MTN API
    print('Sending verification code to $phoneNumber');
    print('Demo code: 123456');
    
    // For demo, always return true
    return true;
  }
  
  // Verify code
  static Future<bool> verifyCode(String phoneNumber, String code) async {
    // For demo, any 6-digit code works
    if (code.length == 6 && int.tryParse(code) != null) {
      await markAgentAsVerified(phoneNumber);
      return true;
    }
    return false;
  }
  
  // Mark agent as verified
  static Future<void> markAgentAsVerified(String phoneNumber) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> verified = prefs.getStringList(_verifiedKey) ?? [];
    if (!verified.contains(phoneNumber)) {
      verified.add(phoneNumber);
      await prefs.setStringList(_verifiedKey, verified);
    }
  }
  
  // Check if agent is verified
  static Future<bool> isAgentVerified(String phoneNumber) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> verified = prefs.getStringList(_verifiedKey) ?? [];
    return verified.contains(phoneNumber);
  }
  
  // Submit documents for verification (TIN, business license)
  static Future<void> submitDocuments(String agentId, List<String> documentUrls) async {
    // In production, store in Firestore
    print('Submitting documents for agent $agentId');
  }
}