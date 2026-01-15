import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/utils/rate_limiter.dart';
import '../../core/utils/secure_session_manager.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/settings_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  final SettingsRepository settingsRepository;
  final SecureSessionManager _sessionManager;

  AuthBloc({
    required this.authRepository,
    required this.settingsRepository,
    SecureSessionManager? sessionManager,
  }) : _sessionManager = sessionManager ?? SecureSessionManager(),
       super(const AuthState.unknown()) {
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
    debugPrint('AuthBloc: Checking auth status...');

    // First check for existing valid session
    try {
      final existingSession = await _sessionManager.getSession();
      debugPrint(
        'AuthBloc: Session check result: ${existingSession != null ? "found" : "not found"}',
      );

      if (existingSession != null) {
        // User has a valid session, authenticate them
        debugPrint(
          'AuthBloc: Restoring session for user: ${existingSession.email}',
        );
        emit(AuthState.authenticated(existingSession));
        return;
      }
    } catch (e) {
      debugPrint('AuthBloc: Error checking session: $e');
    }

    // Check if this is the first time the app is launched
    final isFirstLaunch = await settingsRepository.isFirstLaunch();
    debugPrint('AuthBloc: Is first launch: $isFirstLaunch');

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
    // Check rate limiting first
    if (authRateLimiter.isLockedOut(event.email)) {
      final remaining = authRateLimiter.getRemainingLockoutDuration(
        event.email,
      );
      final minutes = remaining?.inMinutes ?? 15;
      emit(
        AuthState.error(
          'Too many failed attempts. Please try again in $minutes minute${minutes == 1 ? '' : 's'}.',
        ),
      );
      return;
    }

    emit(const AuthState.loading());
    try {
      final user = await authRepository.login(event.email, event.password);
      if (user != null) {
        // Clear rate limiting on successful login
        authRateLimiter.clearAttempts(event.email);
        // Save session securely
        await _sessionManager.saveSession(user);
        // Mark first launch as completed when user logs in
        await settingsRepository.markFirstLaunchCompleted();
        emit(AuthState.authenticated(user));
      } else {
        // Record failed attempt
        authRateLimiter.recordAttempt(event.email);
        final remaining = authRateLimiter.getRemainingAttempts(event.email);

        if (remaining > 0) {
          emit(
            AuthState.error(
              'Invalid email or password. $remaining attempt${remaining == 1 ? '' : 's'} remaining.',
            ),
          );
        } else {
          emit(
            const AuthState.error(
              'Account temporarily locked. Please try again later.',
            ),
          );
        }
      }
    } catch (e) {
      // Record failed attempt for rate limiting
      authRateLimiter.recordAttempt(event.email);
      // Don't expose internal error details to users
      emit(const AuthState.error('Login failed. Please try again.'));
    }
  }

  Future<void> _onSignUpRequested(
    SignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    try {
      // Mark first launch as completed when user signs up
      await settingsRepository.markFirstLaunchCompleted();

      final user = await authRepository.signUp(
        event.name,
        event.email,
        event.password,
      );

      // Save session securely
      await _sessionManager.saveSession(user);
      emit(AuthState.authenticated(user));
    } catch (e) {
      // Check for specific error messages
      final errorMessage = e.toString();
      if (errorMessage.contains('Email already registered')) {
        emit(const AuthState.error('This email is already registered'));
      } else {
        emit(const AuthState.error('Sign up failed. Please try again.'));
      }
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    // Clear secure session
    await _sessionManager.clearSession();
    await authRepository.logout();
    emit(const AuthState.unauthenticated());
  }
}
