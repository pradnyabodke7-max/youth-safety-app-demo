// lib/services/sms_service.dart

import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'location_service.dart';

class SmsService {
  // Send SOS SMS to all emergency contacts
  static Future<void> sendSOSSms() async {
    try {
      // Get location
      String locationLink = await LocationService.getCurrentLocation();

      // SOS Message
      String message =
          'EMERGENCY! I need help! My current location is: $locationLink Please help me immediately!';

      // Get emergency contacts from storage
      final prefs = await SharedPreferences.getInstance();
      final String? contactsJson = prefs.getString('emergency_contacts');

      if (contactsJson == null) {
        return;
      }

      final List<dynamic> contacts = jsonDecode(contactsJson);

      if (contacts.isEmpty) {
        return;
      }

      // Send SMS to each contact
      for (var contact in contacts) {
        String phone = contact['phone'];

        // Create SMS link
        final Uri smsUri = Uri(
          scheme: 'sms',
          path: phone,
          queryParameters: {'body': message},
        );

        // Open SMS app
        if (await canLaunchUrl(smsUri)) {
          await launchUrl(smsUri);
        }
      }
    } catch (e) {
      print('Error sending SMS: $e');
    }
  }

  // Send custom message
  static Future<void> sendCustomSms({
    required String phone,
    required String message,
  }) async {
    try {
      final Uri smsUri = Uri(
        scheme: 'sms',
        path: phone,
        queryParameters: {'body': message},
      );

      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
      }
    } catch (e) {
      print('Error sending SMS: $e');
    }
  }
}