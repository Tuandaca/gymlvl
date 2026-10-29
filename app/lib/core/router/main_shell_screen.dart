import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../localization/localization_engine.dart';
import '../theme/candy_colors.dart';
import '../../ui/candy/candy_navigation_item.dart';
import '../../features/workout/presentation/providers/exercise_providers.dart';
import 'persistent_active_workout_banner.dart';

class MainShellScreen extends ConsumerStatefulWidget {
  const MainShellScreen({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends ConsumerState<MainShellScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(activeWorkoutControllerProvider.notifier)
          .checkForActiveWorkout();
    });
  }

  void _select(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeWorkout = ref.watch(activeWorkoutControllerProvider);
    final hasActiveWorkout = activeWorkout.hasActiveWorkout;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 960) {
          return Scaffold(
            backgroundColor: CandyColors.canvas,
            body: Row(
              children: [
                _buildNeubrutalistRail(context, hasActiveWorkout),
                const VerticalDivider(
                  width: 2.0,
                  thickness: 2.0,
                  color: CandyColors.ink,
                ),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(child: widget.navigationShell),
                      const PersistentActiveWorkoutBanner(),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          backgroundColor: CandyColors.canvas,
          body: widget.navigationShell,
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const PersistentActiveWorkoutBanner(),
              _buildNeubrutalistBottomBar(context, hasActiveWorkout),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNeubrutalistBottomBar(
    BuildContext context,
    bool hasActiveWorkout,
  ) {
    return Container(
      decoration: const BoxDecoration(
        color: CandyColors.card,
        border: Border(
          top: BorderSide(
            color: CandyColors.ink,
            width: CandyColors.borderWidth,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              CandyNavigationItem(
                icon: widget.navigationShell.currentIndex == 0
                    ? Icons.dashboard_rounded
                    : Icons.dashboard_outlined,
                label: 'dashboard_tab'.tr(ref),
                isSelected: widget.navigationShell.currentIndex == 0,
                activeColor: CandyColors.canaryYellow,
                onTap: () => _select(0),
              ),
              CandyNavigationItem(
                icon: widget.navigationShell.currentIndex == 1
                    ? Icons.fitness_center_rounded
                    : Icons.fitness_center_outlined,
                label: 'training_tab'.tr(ref),
                isSelected: widget.navigationShell.currentIndex == 1,
                activeColor: CandyColors.mintGreen,
                badgeText: hasActiveWorkout ? '!' : null,
                onTap: () => _select(1),
              ),
              CandyNavigationItem(
                icon: widget.navigationShell.currentIndex == 2
                    ? Icons.military_tech_rounded
                    : Icons.military_tech_outlined,
                label: 'quests_tab'.tr(ref),
                isSelected: widget.navigationShell.currentIndex == 2,
                activeColor: CandyColors.softLilac,
                onTap: () => _select(2),
              ),
              CandyNavigationItem(
                icon: widget.navigationShell.currentIndex == 3
                    ? Icons.person_rounded
                    : Icons.person_outline_rounded,
                label: 'profile_tab'.tr(ref),
                isSelected: widget.navigationShell.currentIndex == 3,
                activeColor: CandyColors.hotPink,
                onTap: () => _select(3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNeubrutalistRail(BuildContext context, bool hasActiveWorkout) {
    return Container(
      width: 240,
      decoration: const BoxDecoration(
        color: CandyColors.card,
        border: Border(
          right: BorderSide(
            color: CandyColors.ink,
            width: CandyColors.borderWidth,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 24.0,
                horizontal: 16.0,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: CandyColors.canaryYellow,
                      borderRadius: BorderRadius.circular(12.0),
                      border: CandyColors.standardBorder(width: 2.0),
                      boxShadow: CandyColors.shadowSmall(),
                    ),
                    child: const Icon(
                      Icons.bolt_rounded,
                      color: CandyColors.ink,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'GYMLVL',
                        style: TextStyle(
                          fontFamily: CandyFonts.display,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: CandyColors.ink,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 2, thickness: 2, color: CandyColors.ink),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                children: [
                  _buildRailItem(
                    index: 0,
                    icon: Icons.dashboard_rounded,
                    label: 'dashboard_tab'.tr(ref),
                    activeColor: CandyColors.canaryYellow,
                  ),
                  const SizedBox(height: 8),
                  _buildRailItem(
                    index: 1,
                    icon: Icons.fitness_center_rounded,
                    label: 'training_tab'.tr(ref),
                    activeColor: CandyColors.mintGreen,
                    badgeText: hasActiveWorkout ? '!' : null,
                  ),
                  const SizedBox(height: 8),
                  _buildRailItem(
                    index: 2,
                    icon: Icons.military_tech_rounded,
                    label: 'quests_tab'.tr(ref),
                    activeColor: CandyColors.softLilac,
                  ),
                  const SizedBox(height: 8),
                  _buildRailItem(
                    index: 3,
                    icon: Icons.person_rounded,
                    label: 'profile_tab'.tr(ref),
                    activeColor: CandyColors.hotPink,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRailItem({
    required int index,
    required IconData icon,
    required String label,
    required Color activeColor,
    String? badgeText,
  }) {
    final isSelected = widget.navigationShell.currentIndex == index;

    return GestureDetector(
      onTap: () => _select(index),
      child: AnimatedContainer(
        duration: CandyTimings.press,
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(14.0),
          border: isSelected
              ? CandyColors.standardBorder(width: 2.0)
              : Border.all(color: Colors.transparent, width: 2.0),
          boxShadow: isSelected ? CandyColors.shadowSmall() : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected ? CandyColors.ink : CandyColors.charcoal,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: CandyFonts.body,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? CandyColors.ink : CandyColors.charcoal,
                ),
              ),
            ),
            if (badgeText != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: CandyColors.hotPink,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: CandyColors.ink, width: 1.0),
                ),
                child: Text(
                  badgeText,
                  style: const TextStyle(
                    fontFamily: CandyFonts.mono,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
