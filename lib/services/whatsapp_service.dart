import 'package:url_launcher/url_launcher.dart';

class WhatsAppService {
  static Future<void> contactAgent(String agentPhone, String propertyTitle) async {
    // Format phone number (ensure it has country code)
    String formattedPhone = agentPhone;
    if (!formattedPhone.startsWith('+260')) {
      if (formattedPhone.startsWith('0')) {
        formattedPhone = '+260${formattedPhone.substring(1)}';
      } else {
        formattedPhone = '+260$formattedPhone';
      }
    }
    
    // Remove any spaces or dashes
    formattedPhone = formattedPhone.replaceAll(RegExp(r'[\s-]'), '');
    
    final message = "Hello, I'm interested in: $propertyTitle (from Zambia Real Estate App). Is this still available?";
    final encodedMessage = Uri.encodeComponent(message);
    final whatsappUrl = "https://wa.me/$formattedPhone?text=$encodedMessage";
    
    try {
      final Uri url = Uri.parse(whatsappUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        throw 'Could not launch WhatsApp';
      }
    } catch (e) {
      print('Error launching WhatsApp: $e');
      // Fallback: show dialog with phone number
    }
  }
}