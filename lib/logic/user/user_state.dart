import 'package:equatable/equatable.dart';
import '../../data/models/user_profile.dart';

enum UserStatus { initial, loading, loaded, error }

class UserState extends Equatable {
  final UserStatus status;
  final UserProfile profile;
  final String? errorMessage;

  const UserState({
    this.status = UserStatus.initial,
    this.profile = UserProfile.empty,
    this.errorMessage,
  });

  UserState copyWith({
    UserStatus? status,
    UserProfile? profile,
    String? errorMessage,
  }) {
    return UserState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, profile, errorMessage];
}
