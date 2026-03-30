import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D12), // Dark futuristic background
      appBar: AppBar(
        title: const Text('TỔNG QUAN', style: TextStyle(fontFamily: 'Orbitron', fontWeight: FontWeight.bold, letterSpacing: 2.0)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.dashboard_customize_rounded, size: 80, color: Colors.cyanAccent),
            const SizedBox(height: 20),
            Text(
              'Dashboard đang được xây dựng...',
              style: TextStyle(
                color: Colors.cyanAccent.withOpacity(0.8),
                fontSize: 16,
                letterSpacing: 1.2,
                shadows: [
                  Shadow(color: Colors.cyanAccent.withOpacity(0.5), blurRadius: 10),
                ]
              ),
            ),
          ],
        ),
      ),
    );
  }
}
