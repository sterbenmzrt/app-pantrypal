import 'package:equatable/equatable.dart';
import '../../data/models/user_profile.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();
  @override
  List<Object?> get props => [];
}

class LoadUserProfile extends UserEvent {}

class UpdateUserProfile extends UserEvent {
  final UserProfile profile;
  const UpdateUserProfile(this.profile);
  @override
  List<Object?> get props => [profile];
}

/// Clear user profile data (used on logout)
class ClearUserProfile extends UserEvent {}

/// Set user profile directly (used after login/signup)
class SetUserProfile extends UserEvent {
  final UserProfile profile;
  const SetUserProfile(this.profile);
  @override
  List<Object?> get props => [profile];
}
