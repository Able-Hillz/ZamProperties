import 'package:shared_preferences/shared_preferences.dart';

class CustomerService {
  static const String _customerIdKey = 'customerId';
  static const String _customerNameKey = 'customerName';
  static const String _customerPhoneKey = 'customerPhone';
  
  static Future<String> getCustomerId() async {
    final prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString(_customerIdKey);
    if (id == null) {
      id = 'cust_${DateTime.now().millisecondsSinceEpoch}';
      await prefs.setString(_customerIdKey, id);
    }
    return id;
  }
  
  static Future<String> getCustomerName() async {
    final prefs = await SharedPreferences.getInstance();
    String? name = prefs.getString(_customerNameKey);
    if (name == null) {
      name = 'Customer';
      await prefs.setString(_customerNameKey, name);
    }
    return name;
  }
  
  static Future<String> getCustomerPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_customerPhoneKey) ?? '';
  }
  
  static Future<void> setCustomerInfo({required String name, String? phone}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_customerNameKey, name);
    if (phone != null) {
      await prefs.setString(_customerPhoneKey, phone);
    }
  }
}