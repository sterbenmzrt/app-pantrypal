import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/user_repository.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository repository;

  UserBloc({required this.repository}) : super(const UserState()) {
    on<LoadUserProfile>(_onLoadUserProfile);
    on<UpdateUserProfile>(_onUpdateUserProfile);
    on<ClearUserProfile>(_onClearUserProfile);
    on<SetUserProfile>(_onSetUserProfile);
  }

  Future<void> _onLoadUserProfile(
    LoadUserProfile event,
    Emitter<UserState> emit,
  ) async {
    emit(state.copyWith(status: UserStatus.loading));
    try {
      final profile = await repository.getUserProfile();
      emit(state.copyWith(status: UserStatus.loaded, profile: profile));
    } catch (e) {
      emit(
        state.copyWith(status: UserStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onUpdateUserProfile(
    UpdateUserProfile event,
    Emitter<UserState> emit,
  ) async {
    emit(state.copyWith(status: UserStatus.loading));
    try {
      await repository.saveUserProfile(event.profile);
      emit(state.copyWith(status: UserStatus.loaded, profile: event.profile));
    } catch (e) {
      emit(
        state.copyWith(status: UserStatus.error, errorMessage: e.toString()),
      );
    }
  }

  void _onClearUserProfile(ClearUserProfile event, Emitter<UserState> emit) {
    emit(const UserState()); // Reset to initial state
  }

  void _onSetUserProfile(SetUserProfile event, Emitter<UserState> emit) {
    emit(state.copyWith(status: UserStatus.loaded, profile: event.profile));
  }
}
