import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../ui/widgets/system_button.dart';

class WorkoutScreen extends StatelessWidget {
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D12),
      appBar: AppBar(
        title: const Text('LUYỆN TẬP',
            style: TextStyle(family: 'Orbitron', fontWeight: FontWeight.bold, letterSpacing: 2.0)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.fitness_center_rounded, size: 80, color: Colors.cyanAccent),
              const SizedBox(height: 20),
              const Text(
                'Sẵn sàng để thăng cấp?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontFamily: 'Orbitron',
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Chọn một bài tập chuẩn để bắt đầu buổi logging.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 40),
              SystemButton(
                text: 'Bắt đầu bài tập',
                onPressed: () {
                  context.push('/exercise-picker');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
