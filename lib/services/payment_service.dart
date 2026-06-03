import 'package:shared_preferences/shared_preferences.dart';

class PaymentService {
  // Promoted listing prices (ZMW)
  static const Map<String, double> promotionPrices = {
    '3 Days': 10.0,
    '7 Days': 20.0,
    '30 Days': 50.0,
  };
  
  // Store promoted listings
  static Future<void> promoteListing(String propertyId, int days) async {
    final prefs = await SharedPreferences.getInstance();
    DateTime expiryDate = DateTime.now().add(Duration(days: days));
    await prefs.setString('promoted_$propertyId', expiryDate.toIso8601String());
  }
  
  // Check if listing is promoted
  static Future<bool> isPromoted(String propertyId) async {
    final prefs = await SharedPreferences.getInstance();
    String? expiryStr = prefs.getString('promoted_$propertyId');
    if (expiryStr == null) return false;
    
    DateTime expiry = DateTime.parse(expiryStr);
    return DateTime.now().isBefore(expiry);
  }
  
  // Get promoted listings (sorted first)
  static Future<List<String>> getPromotedListings(List<String> allIds) async {
    List<String> promoted = [];
    List<String> normal = [];
    
    for (String id in allIds) {
      if (await isPromoted(id)) {
        promoted.add(id);
      } else {
        normal.add(id);
      }
    }
    
    return [...promoted, ...normal];
  }
  
  // Simulate mobile money payment (MTN MoMo / Airtel Money)
  static Future<bool> processMobileMoneyPayment({
    required String phoneNumber,
    required double amount,
    required String provider, // 'mtn' or 'airtel'
    required String propertyId,
  }) async {
    // In production, integrate with actual MoMo API
    print('Processing $provider payment of ZMW $amount from $phoneNumber');
    
    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));
    
    // For demo, always succeed
    bool success = true;
    
    if (success) {
      // Promote for 7 days by default
      await promoteListing(propertyId, 7);
    }
    
    return success;
  }
  
  // Generate payment reference
  static String generateReference() {
    return 'ZAM${DateTime.now().millisecondsSinceEpoch}';
  }
}