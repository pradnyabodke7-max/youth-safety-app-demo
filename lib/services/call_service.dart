// lib/services/call_service.dart

import 'package:url_launcher/url_launcher.dart';

class CallService {
  // Call emergency number 112
  static Future<void> callEmergency() async {
    try {
      final Uri callUri = Uri(
        scheme: 'tel',
        path: '112',
      );

      if (await canLaunchUrl(callUri)) {
        await launchUrl(callUri);
      }
    } catch (e) {
      print('Error making call: $e');
    }
  }

  // Call any number
  static Future<void> callNumber(String phone) async {
    try {
      final Uri callUri = Uri(
        scheme: 'tel',
        path: phone,
      );

      if (await canLaunchUrl(callUri)) {
        await launchUrl(callUri);
      }
    } catch (e) {
      print('Error making call: $e');
    }
  }
}