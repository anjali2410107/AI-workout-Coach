import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/groq_service.dart';

part 'workout_plan_event.dart';
part 'workout_plan_state.dart';

class WorkoutPlanBloc extends Bloc<WorkoutPlanEvent, WorkoutPlanState> {
  final GroqService _groq;

  WorkoutPlanBloc({GroqService? groqService})
      : _groq = groqService ?? GroqService(),
        super(const WorkoutPlanState()) {
    on<WorkoutPlanFitnessLevelChanged>(
            (e, emit) => emit(state.copyWith(fitnessLevel: e.level)));
    on<WorkoutPlanGoalChanged>(
            (e, emit) => emit(state.copyWith(goal: e.goal)));
    on<WorkoutPlanDaysChanged>(
            (e, emit) => emit(state.copyWith(daysPerWeek: e.days)));
    on<WorkoutPlanFocusAreaToggled>(_onAreaToggled);
    on<WorkoutPlanGenerateRequested>(_onGenerateRequested);
  }

  void _onAreaToggled(WorkoutPlanFocusAreaToggled event, Emitter<WorkoutPlanState> emit) {
    final areas = List<String>.from(state.focusAreas);
    if (areas.contains(event.area)) {
      if (areas.length > 1) areas.remove(event.area);
    } else {
      areas.add(event.area);
    }
    emit(state.copyWith(focusAreas: areas));
  }

  Future<void> _onGenerateRequested(
      WorkoutPlanGenerateRequested event, Emitter<WorkoutPlanState> emit) async {
    emit(state.copyWith(status: WorkoutPlanStatus.loading));
    try {
      final plan = await _groq.generateWorkoutPlan(
        fitnessLevel: state.fitnessLevel,
        goal: state.goal,
        daysPerWeek: state.daysPerWeek,
        focusAreas: state.focusAreas,
      );
      emit(state.copyWith(status: WorkoutPlanStatus.loaded, plan: plan));
    } catch (e) {
      emit(state.copyWith(
          status: WorkoutPlanStatus.error, error: e.toString()));
    }
  }
}