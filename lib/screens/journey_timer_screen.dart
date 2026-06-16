// lib/screens/journey_timer_screen.dart

import 'package:flutter/material.dart';
import 'dart:async';

class JourneyTimerScreen extends StatefulWidget {
  const JourneyTimerScreen({super.key});

  @override
  State<JourneyTimerScreen> createState() => _JourneyTimerScreenState();
}

class _JourneyTimerScreenState extends State<JourneyTimerScreen> {
  // Timer variables
  int _selectedMinutes = 15;
  int _remainingSeconds = 0;
  bool _isRunning = false;
  Timer? _timer;

  // Start the timer
  void _startTimer() {
    setState(() {
      _remainingSeconds = _selectedMinutes * 60;
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          // Timer finished - trigger SOS
          _timer?.cancel();
          _isRunning = false;
          _triggerSOS();
        }
      });
    });
  }

  // Stop the timer
  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _remainingSeconds = 0;
    });

    // Show safe message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Journey completed safely!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Trigger SOS when timer runs out
  void _triggerSOS() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text(
          '🚨 SOS TRIGGERED!',
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Your journey timer has expired!\nSOS message is being sent to your emergency contacts!',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text(
              'I AM SAFE',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // Format seconds to MM:SS
  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      // Top Bar
      appBar: AppBar(
        backgroundColor: const Color(0xFFE53935),
        title: const Text(
          'Journey Timer',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Info Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info, color: Colors.blue),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Set a timer for your journey. If you don\'t stop it in time, SOS will be sent automatically!',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Timer Display
            Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isRunning
                    ? const Color(0xFFE53935)
                    : Colors.grey[300],
                boxShadow: [
                  BoxShadow(
                    color: _isRunning
                        ? Colors.red.withOpacity(0.4)
                        : Colors.grey.withOpacity(0.3),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  _isRunning
                      ? _formatTime(_remainingSeconds)
                      : '${_selectedMinutes.toString().padLeft(2, '0')}:00',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Select Minutes
            if (!_isRunning) ...[
              const Text(
                'Select Journey Duration',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              // Minute Selector Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [5, 10, 15, 30, 60].map((minutes) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedMinutes = minutes;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _selectedMinutes == minutes
                            ? const Color(0xFFE53935)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFE53935),
                        ),
                      ),
                      child: Text(
                        '${minutes}m',
                        style: TextStyle(
                          color: _selectedMinutes == minutes
                              ? Colors.white
                              : const Color(0xFFE53935),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 40),

              // Start Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _startTimer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE53935),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Start Journey',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],

            // Stop Button (shown when timer is running)
            if (_isRunning) ...[
              const Text(
                'Journey in progress...',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _stopTimer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'I Reached Safely ✅',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}