import '../database/database_helper.dart';
import '../models/user_profile.dart';

class UserRepository {
  final DatabaseHelper _dbHelper;

  UserRepository({DatabaseHelper? helper})
    : _dbHelper = helper ?? DatabaseHelper();

  Future<UserProfile> getUserProfile() async {
    final profile = await _dbHelper.getUserProfile();
    return profile ?? UserProfile.empty;
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    await _dbHelper.saveUserProfile(profile);
  }
}
