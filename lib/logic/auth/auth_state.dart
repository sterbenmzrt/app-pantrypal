import 'package:equatable/equatable.dart';
import '../../data/models/user_profile.dart';

enum AuthStatus { unknown, authenticated, unauthenticated, loading, error }

class AuthState extends Equatable {
  final AuthStatus status;
  final UserProfile user;
  final String? errorMessage;

  const AuthState._({
    this.status = AuthStatus.unknown,
    this.user = UserProfile.empty,
    this.errorMessage,
  });

  const AuthState.unknown() : this._();

  const AuthState.authenticated(UserProfile user)
    : this._(status: AuthStatus.authenticated, user: user);

  const AuthState.unauthenticated()
    : this._(status: AuthStatus.unauthenticated);

  const AuthState.loading() : this._(status: AuthStatus.loading);

  const AuthState.error(String message)
    : this._(status: AuthStatus.error, errorMessage: message);

  @override
  List<Object?> get props => [status, user, errorMessage];
}
