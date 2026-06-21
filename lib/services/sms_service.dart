// lib/services/sms_service.dart

import 'package:url_launcher/url_launcher.dart';
import 'package:youth_safety_app/models/contact_model.dart';

class SmsService {
  /// Sends the SOS message to each given contact via the device's SMS app.
  /// Contacts and location are now passed in (Firestore-backed) instead of
  /// being read from local SharedPreferences.
  static Future<void> sendSOSSms({
    required List<ContactModel> contacts,
    required String locationLink,
  }) async {
    if (contacts.isEmpty) {
      return;
    }

    final String message =
        'EMERGENCY! I need help! My current location is: $locationLink Please help me immediately!';

    for (final contact in contacts) {
      final Uri smsUri = Uri(
        scheme: 'sms',
        path: contact.phone,
        queryParameters: {'body': message},
      );

      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
      }
    }
  }

  // Send custom message
  static Future<void> sendCustomSms({
    required String phone,
    required String message,
  }) async {
    final Uri smsUri = Uri(
      scheme: 'sms',
      path: phone,
      queryParameters: {'body': message},
    );

    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    }
  }
}