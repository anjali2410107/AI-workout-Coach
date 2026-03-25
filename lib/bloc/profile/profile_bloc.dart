import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/user_profile.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(const ProfileState()) {
    on<ProfileLoaded>(_onLoaded);
    on<ProfileSaved>(_onSaved);
    on<ProfileSetupStepChanged>(_onStepChanged);
    on<ProfileSetupNameChanged>((e, emit) => emit(state.copyWith(setupName: e.name)));
    on<ProfileSetupAgeChanged>((e, emit) => emit(state.copyWith(setupAge: e.age)));
    on<ProfileSetupWeightChanged>((e, emit) => emit(state.copyWith(setupWeight: e.weight)));
    on<ProfileSetupHeightChanged>((e, emit) => emit(state.copyWith(setupHeight: e.height)));
    on<ProfileSetupGoalToggled>(_onGoalToggled);
    on<ProfileSetupLevelChanged>((e, emit) => emit(state.copyWith(setupLevel: e.level)));
  }

  void _onLoaded(ProfileLoaded event, Emitter<ProfileState> emit) {
    emit(state.copyWith(status: ProfileStatus.loading));
    try {
      final profile = UserProfileService.getProfile();
      emit(state.copyWith(status: ProfileStatus.loaded, profile: profile));
    } catch (e) {
      emit(state.copyWith(status: ProfileStatus.error, error: e.toString()));
    }
  }

  Future<void> _onSaved(ProfileSaved event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(status: ProfileStatus.saving));
    try {
      final profile = UserProfile(
        name: event.name,
        age: event.age,
        weight: event.weight,
        height: event.height,
        fitnessGoal: event.fitnessGoals.join(', '),
        fitnessLevel: event.fitnessLevel,
      );
      await UserProfileService.saveProfile(profile);
      await UserProfileService.setOnboarded();
      emit(state.copyWith(status: ProfileStatus.saved, profile: profile));
    } catch (e) {
      emit(state.copyWith(status: ProfileStatus.error, error: e.toString()));
    }
  }

  void _onStepChanged(ProfileSetupStepChanged event, Emitter<ProfileState> emit) {
    emit(state.copyWith(setupStep: event.step));
  }

  void _onGoalToggled(ProfileSetupGoalToggled event, Emitter<ProfileState> emit) {
    final goals = List<String>.from(state.setupGoals);
    if (goals.contains(event.goal)) {
      if (goals.length > 1) goals.remove(event.goal);
    } else {
      goals.add(event.goal);
    }
    emit(state.copyWith(setupGoals: goals));
  }
}