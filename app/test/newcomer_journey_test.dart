import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/training_plan/newcomer_journey.dart';
import 'package:app/features/training_plan/newcomer_journey_models.dart';

void main() {
  group('NewcomerJourney', () {
    late NewcomerJourney machine;

    setUp(() {
      machine = NewcomerJourney();
    });

    test(
      'first entry: noHistory --profile complete, no history--> planAvailable',
      () {
        final result = machine.transition(
          current: const NoHistory(),
          event: JourneyEvent.profileComplete,
          context: const NewcomerJourneyContext(
            completedWorkoutCount: 0,
            planStarted: false,
          ),
        );
        expect(result.state, equals(const PlanAvailable()));
        expect(result.outcome, equals(JourneyOutcome.none));
      },
    );

    test('resume: planAvailable --plan opened--> planStarted', () {
      final result = machine.transition(
        current: const PlanAvailable(),
        event: JourneyEvent.planOpened,
        context: const NewcomerJourneyContext(
          completedWorkoutCount: 0,
          planStarted: false,
        ),
      );
      expect(result.state, equals(const PlanStarted()));
      expect(result.outcome, equals(JourneyOutcome.none));
    });

    test(
      'partial workout: planStarted --workout started--> workoutPartial',
      () {
        final result = machine.transition(
          current: const PlanStarted(),
          event: JourneyEvent.workoutStarted,
          context: const NewcomerJourneyContext(
            completedWorkoutCount: 0,
            planStarted: true,
          ),
        );
        expect(result.state, equals(const WorkoutPartial()));
        expect(result.outcome.workoutCreated, isTrue);
        expect(result.outcome.completionAwarded, isFalse);
        expect(result.outcome.progressionUnlocked, isFalse);
      },
    );

    test(
      'completion: workoutPartial --workout completed--> workoutComplete',
      () {
        final result = machine.transition(
          current: const WorkoutPartial(),
          event: JourneyEvent.workoutCompleted,
          context: const NewcomerJourneyContext(
            completedWorkoutCount: 1,
            planStarted: true,
          ),
        );
        expect(result.state, equals(const WorkoutComplete()));
        expect(result.outcome.completionAwarded, isTrue);
        expect(result.outcome.workoutCreated, isFalse);
      },
    );

    test('3rd workout completed: workoutComplete --> progressionAvailable', () {
      final result = machine.transition(
        current: const WorkoutComplete(),
        event: JourneyEvent.workoutCompleted,
        context: const NewcomerJourneyContext(
          completedWorkoutCount: 3,
          planStarted: true,
          lastCompletedDay: 3,
        ),
      );
      expect(result.state, equals(const ProgressionAvailable()));
      expect(result.outcome.progressionUnlocked, isTrue);
      expect(result.outcome.completionAwarded, isTrue);
    });

    test('returning user stays returningUser (terminal state)', () {
      final result = machine.transition(
        current: const ReturningUser(),
        event: JourneyEvent.workoutCompleted,
        context: const NewcomerJourneyContext(
          completedWorkoutCount: 5,
          planStarted: true,
        ),
      );
      expect(result.state, equals(const ReturningUser()));
      expect(result.outcome, equals(JourneyOutcome.none));
    });

    test('re-entering returningUser yields returningUser', () {
      final r1 = machine.transition(
        current: const ReturningUser(),
        event: JourneyEvent.profileComplete,
        context: const NewcomerJourneyContext(
          completedWorkoutCount: 1,
          planStarted: false,
        ),
      );
      expect(r1.state, equals(const ReturningUser()));
      final r2 = machine.transition(
        current: r1.state,
        event: JourneyEvent.planOpened,
        context: const NewcomerJourneyContext(
          completedWorkoutCount: 1,
          planStarted: false,
        ),
      );
      expect(r2.state, equals(const ReturningUser()));
      expect(r2.outcome, equals(JourneyOutcome.none));
    });

    test('retry before 3rd workout: no duplicate completion award', () {
      final result = machine.transition(
        current: const WorkoutComplete(),
        event: JourneyEvent.workoutCompleted,
        context: const NewcomerJourneyContext(
          completedWorkoutCount: 1,
          planStarted: true,
          lastCompletedDay: 1,
        ),
      );
      expect(result.state, equals(const WorkoutComplete()));
      expect(result.outcome, equals(JourneyOutcome.none));
    });

    test('invalid transition throws ArgumentError', () {
      expect(
        () => machine.transition(
          current: const NoHistory(),
          event: JourneyEvent.workoutCompleted,
          context: const NewcomerJourneyContext(
            completedWorkoutCount: 0,
            planStarted: false,
          ),
        ),
        throwsA(isArgumentError),
      );
    });

    test('deterministic: same input yields same result', () {
      const context = NewcomerJourneyContext(
        completedWorkoutCount: 0,
        planStarted: true,
      );
      final r1 = machine.transition(
        current: const PlanStarted(),
        event: JourneyEvent.workoutStarted,
        context: context,
      );
      final r2 = machine.transition(
        current: const PlanStarted(),
        event: JourneyEvent.workoutStarted,
        context: context,
      );
      expect(r2, equals(r1));
    });

    test('reconstruct: returning user from history', () {
      final state = NewcomerJourney.reconstruct(
        completedWorkoutCount: 3,
        planStarted: true,
        lastCompletedDay: 3,
      );
      expect(state, equals(const ReturningUser()));
    });

    test('reconstruct: fresh profile yields planAvailable', () {
      final state = NewcomerJourney.reconstruct(
        completedWorkoutCount: 0,
        planStarted: false,
        lastCompletedDay: null,
      );
      expect(state, equals(const PlanAvailable()));
    });

    test('reconstruct: 3 days completed yields progressionAvailable', () {
      final state = NewcomerJourney.reconstruct(
        completedWorkoutCount: 0,
        planStarted: true,
        lastCompletedDay: 3,
      );
      expect(state, equals(const ProgressionAvailable()));
    });

    test('helpers: terminal, in progress, completed workout', () {
      expect(NewcomerJourney.isTerminal(const ReturningUser()), isTrue);
      expect(NewcomerJourney.isTerminal(const WorkoutComplete()), isFalse);
      expect(
        NewcomerJourney.isWorkoutInProgress(const WorkoutPartial()),
        isTrue,
      );
      expect(NewcomerJourney.isWorkoutInProgress(const PlanStarted()), isTrue);
      expect(
        NewcomerJourney.isWorkoutInProgress(const PlanAvailable()),
        isFalse,
      );
      expect(
        NewcomerJourney.hasCompletedWorkout(const WorkoutComplete()),
        isTrue,
      );
      expect(
        NewcomerJourney.hasCompletedWorkout(const ProgressionAvailable()),
        isTrue,
      );
      expect(NewcomerJourney.hasCompletedWorkout(const PlanStarted()), isFalse);
    });
  });
}
