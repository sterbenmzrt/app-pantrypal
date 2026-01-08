import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/settings_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  final SettingsRepository settingsRepository;

  AuthBloc({required this.authRepository, required this.settingsRepository})
    : super(const AuthState.unknown()) {
    on<LoginRequested>(_onLoginRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<CheckAuthStatus>(_onCheckAuthStatus);

    // Delay auth check to allow splash screen to display
    Future.delayed(const Duration(seconds: 2), () {
      add(CheckAuthStatus());
    });
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    // Check if this is the first time the app is launched
    final isFirstLaunch = await settingsRepository.isFirstLaunch();

    if (isFirstLaunch) {
      // First time user - show welcome screen
      emit(const AuthState.firstLaunch());
    } else {
      // Returning user - go to login
      emit(const AuthState.unauthenticated());
    }
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    print('AuthBloc: Login requested for ${event.email}');
    emit(const AuthState.loading());
    try {
      final user = await authRepository.login(event.email, event.password);
      if (user != null) {
        // Mark first launch as completed when user logs in
        await settingsRepository.markFirstLaunchCompleted();
        print('AuthBloc: Login successful for ${user.email}');
        emit(AuthState.authenticated(user));
      } else {
        print('AuthBloc: Login failed - user not found or invalid password');
        emit(const AuthState.error('Invalid email or password'));
      }
    } catch (e) {
      print('AuthBloc: Login error: $e');
      emit(AuthState.error(e.toString()));
    }
  }

  Future<void> _onSignUpRequested(
    SignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    print('AuthBloc: SignUp requested for ${event.email}');
    emit(const AuthState.loading());
    try {
      // Mark first launch as completed when user signs up
      await settingsRepository.markFirstLaunchCompleted();

      final user = await authRepository.signUp(
        event.name,
        event.email,
        event.password,
      );
      print('AuthBloc: SignUp successful for ${user.email}');
      emit(AuthState.authenticated(user));
    } catch (e) {
      print('AuthBloc: SignUp error: $e');
      emit(AuthState.error(e.toString()));
    }
  }

  void _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) {
    print('AuthBloc: Logout requested');
    authRepository.logout();
    print('AuthBloc: Emitting unauthenticated state');
    emit(const AuthState.unauthenticated());
  }
}
