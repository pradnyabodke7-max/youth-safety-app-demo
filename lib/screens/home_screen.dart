// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:youth_safety_app/services/location_service.dart';
import 'package:youth_safety_app/services/call_service.dart';
import 'package:youth_safety_app/services/alarm_service.dart';
import 'package:youth_safety_app/providers/auth_provider.dart';
import 'package:youth_safety_app/providers/sos_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _locationText = 'Getting location...';
  bool _isAlarmPlaying = false;

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    String location = await LocationService.getLocationText();
    setState(() {
      _locationText = location;
    });
  }

  Future<void> _triggerSOS() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final sosProvider = Provider.of<SosProvider>(context, listen: false);
    final uid = authProvider.currentUser?.uid;

    if (uid == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('SOS Activated! Sending help...'),
        backgroundColor: Colors.red,
      ),
    );

    final success = await sosProvider.triggerSOS(uid);

    if (!mounted) return;
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(sosProvider.errorMessage ?? 'Failed to send SOS'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFFE53935),
        title: const Text(
          'Youth Safety',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Status Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 30),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'You are Safe',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Tap SOS if you need help',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Location Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.2),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: Color(0xFFE53935),
                    size: 30,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Current Location',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          _locationText,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _getLocation,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // SOS Button
            GestureDetector(
              onTap: _triggerSOS,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: const Color(0xFFE53935),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withValues(alpha: 0.4),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.sos,
                      color: Colors.white,
                      size: 80,
                    ),
                    Text(
                      'HELP ME',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Feature Buttons Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                // Panic Alarm Button
                _featureButton(
                  icon: _isAlarmPlaying ? Icons.volume_off : Icons.volume_up,
                  label: _isAlarmPlaying ? 'Stop Alarm' : 'Panic Alarm',
                  color: Colors.orange,
                  onTap: () async {
                    if (_isAlarmPlaying) {
                      await AlarmService.stopAlarm();
                      setState(() {
                        _isAlarmPlaying = false;
                      });
                    } else {
                      await AlarmService.playAlarm();
                      setState(() {
                        _isAlarmPlaying = true;
                      });
                    }
                  },
                ),

                // Emergency Contacts Button
                _featureButton(
                  icon: Icons.contacts,
                  label: 'Emergency\nContacts',
                  color: Colors.blue,
                  onTap: () {
                    Navigator.pushNamed(context, '/contacts');
                  },
                ),

                // Journey Timer Button
                _featureButton(
                  icon: Icons.timer,
                  label: 'Journey Timer',
                  color: Colors.purple,
                  onTap: () {
                    Navigator.pushNamed(context, '/journey');
                  },
                ),

                // Call 112 Button
                _featureButton(
                  icon: Icons.call,
                  label: 'Call 112',
                  color: Colors.green,
                  onTap: () async {
                    await CallService.callEmergency();
                  },
                ),

                // SOS History Button
                _featureButton(
                  icon: Icons.history,
                  label: 'SOS History',
                  color: Colors.redAccent,
                  onTap: () {
                    Navigator.pushNamed(context, '/sos-history');
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _featureButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.2),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 40),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}