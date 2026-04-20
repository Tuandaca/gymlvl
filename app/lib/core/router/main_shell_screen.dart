import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/localization/localization_engine.dart';

class MainShellScreen extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const MainShellScreen({super.key, required this.navigationShell});

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: AppTheme.cyanNeon.withOpacity(0.3),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.cyanNeon.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: BottomNavigationBar(
            currentIndex: navigationShell.currentIndex,
            onTap: _onTap,
            backgroundColor: AppTheme.panelBackground,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppTheme.cyanNeon,
            unselectedItemColor: Colors.white54,
            selectedLabelStyle: const TextStyle(
              fontFamily: 'Orbitron',
              fontWeight: FontWeight.bold,
              fontSize: 10,
              letterSpacing: 1,
              shadows: [
                Shadow(color: AppTheme.cyanNeon, blurRadius: 8),
              ],
            ),
            unselectedLabelStyle: const TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 9,
              letterSpacing: 1,
            ),
            items: _buildNavItems(ref),
          ),
        ),
      ),
    );
  }

  List<BottomNavigationBarItem> _buildNavItems(WidgetRef ref) {
    return [
      _buildItem(Icons.dashboard_rounded, 'dashboard_tab'.tr(ref), 0),
      _buildItem(Icons.fitness_center_rounded, 'training_tab'.tr(ref), 1),
      _buildItem(Icons.my_location_rounded, 'quests_tab'.tr(ref), 2),
      _buildItem(Icons.shield_rounded, 'profile_tab'.tr(ref), 3),
    ];
  }

  BottomNavigationBarItem _buildItem(IconData icon, String label, int index) {
    final isSelected = index == navigationShell.currentIndex;
    return BottomNavigationBarItem(
      icon: Container(
        margin: const EdgeInsets.only(bottom: 4, top: 4),
        child: Icon(
          icon,
          size: 24,
          shadows: isSelected
              ? [const Shadow(color: AppTheme.cyanNeon, blurRadius: 12)]
              : null,
        ),
      ),
      label: '[${label.toUpperCase()}]',
    );
  }
}
