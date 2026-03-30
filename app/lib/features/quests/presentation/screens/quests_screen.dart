import 'package:flutter/material.dart';

class QuestsScreen extends StatelessWidget {
  const QuestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D12),
      appBar: AppBar(
        title: const Text('NHIỆM VỤ', style: TextStyle(fontFamily: 'Orbitron', fontWeight: FontWeight.bold, letterSpacing: 2.0)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.my_location_rounded, size: 80, color: Colors.orangeAccent),
            const SizedBox(height: 20),
            Text(
              'Quest hàng ngày, Quest chính tuyến...',
              style: TextStyle(
                color: Colors.orangeAccent.withOpacity(0.8),
                fontSize: 16,
                letterSpacing: 1.2,
                shadows: [
                  Shadow(color: Colors.orangeAccent.withOpacity(0.5), blurRadius: 10),
                ]
              ),
            ),
          ],
        ),
      ),
    );
  }
}
