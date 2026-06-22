// lib/services/shake_service.dart

import 'package:shake/shake.dart';

class ShakeService {
  static ShakeDetector? _detector;

  // Start listening for shake
  static void startListening({required Function onShake}) {
    _detector = ShakeDetector.autoStart(
      onPhoneShake: () {
        onShake();
      },
      shakeThresholdGravity: 2.7,
      shakeSlopTimeMS: 500,
      shakeCountResetTime: 3000,
      minimumShakeCount: 2,
    );
  }

  // Stop listening for shake
  static void stopListening() {
    _detector?.stopListening();
    _detector = null;
  }
}