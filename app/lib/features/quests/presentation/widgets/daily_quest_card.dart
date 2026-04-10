import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../ui/widgets/system_panel.dart';
import '../../domain/quest_instance.dart';

class DailyQuestCard extends StatelessWidget {
  final QuestInstance quest;

  const DailyQuestCard({super.key, required this.quest});

  @override
  Widget build(BuildContext context) {
    final isCompleted = quest.status == 'completed';

    return SystemPanel(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'DAILY MISSION',
                    style: TextStyle(
                      color: AppTheme.textDim,
                      fontSize: 10,
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        isCompleted ? 'MISSION SECURED' : 'ACTIVE ROUTINE',
                        style: TextStyle(
                          color: isCompleted ? Colors.greenAccent : AppTheme.cyanNeon,
                          fontSize: 18,
                          fontFamily: 'Orbitron',
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      if (isCompleted) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.check_circle, color: Colors.greenAccent, size: 20),
                      ],
                    ],
                  ),
                ],
              ),
              if (!isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.cyanNeon.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.cyanNeon.withOpacity(0.5)),
                  ),
                  child: const Text(
                    '350 XP',
                    style: TextStyle(color: AppTheme.cyanNeon, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white10),
          const SizedBox(height: 16),
          
          // Danh sách bài tập
          ...quest.config.map((ex) => _buildExerciseRow(ex, isCompleted)).toList(),
          
          const SizedBox(height: 20),
          if (!isCompleted)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Bắt đầu workout dựa trên Quest này
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.cyanNeon,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('DEPLOY NOW', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildExerciseRow(PrescribedExercise ex, bool isCompleted) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.fitness_center_rounded, 
              color: isCompleted ? Colors.greenAccent.withOpacity(0.5) : AppTheme.textDim, 
              size: 20
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ex.exerciseName,
                  style: TextStyle(
                    color: isCompleted ? AppTheme.textDim : AppTheme.textMain,
                    fontWeight: FontWeight.bold,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                Text(
                  '${ex.sets} Sets × ${ex.reps} Reps',
                  style: const TextStyle(color: AppTheme.textDim, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            '${ex.weightKg}kg',
            style: TextStyle(
              color: isCompleted ? AppTheme.textDim : AppTheme.purpleNeon,
              fontWeight: FontWeight.bold,
              fontFamily: 'Orbitron',
            ),
          ),
        ],
      ),
    );
  }
}
