import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D12),
      appBar: AppBar(
        title: const Text('HỒ SƠ NHÂN VẬT', style: TextStyle(fontFamily: 'Orbitron', fontWeight: FontWeight.bold, letterSpacing: 2.0)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shield_outlined, size: 80, color: Colors.tealAccent),
            const SizedBox(height: 20),
            Text(
              'Danh hiệu, Badges, Level Progress...',
              style: TextStyle(
                color: Colors.tealAccent.withOpacity(0.8),
                fontSize: 16,
                letterSpacing: 1.2,
                shadows: [
                  Shadow(color: Colors.tealAccent.withOpacity(0.5), blurRadius: 10),
                ]
              ),
            ),
          ],
        ),
      ),
    );
  }
}
