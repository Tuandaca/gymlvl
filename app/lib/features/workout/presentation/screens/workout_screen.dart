import 'package:flutter/material.dart';

class WorkoutScreen extends StatelessWidget {
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D12),
      appBar: AppBar(
        title: const Text('LUYỆN TẬP', style: TextStyle(fontFamily: 'Orbitron', fontWeight: FontWeight.bold, letterSpacing: 2.0)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.fitness_center_rounded, size: 80, color: Colors.deepPurpleAccent),
            const SizedBox(height: 20),
            Text(
              'Danh sách bài tập và AI Coach...',
              style: TextStyle(
                color: Colors.deepPurpleAccent.withOpacity(0.8),
                fontSize: 16,
                letterSpacing: 1.2,
                shadows: [
                  Shadow(color: Colors.deepPurpleAccent.withOpacity(0.5), blurRadius: 10),
                ]
              ),
            ),
          ],
        ),
      ),
    );
  }
}
