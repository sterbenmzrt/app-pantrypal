import '../database/database_helper.dart';
import '../models/user_profile.dart';

class AuthRepository {
  final DatabaseHelper _dbHelper;

  AuthRepository({DatabaseHelper? helper})
    : _dbHelper = helper ?? DatabaseHelper();

  Future<UserProfile?> login(String email, String password) async {
    return _dbHelper.authenticateUser(email, password);
  }

  Future<UserProfile> signUp(String name, String email, String password) async {
    final newUser = UserProfile(name: name, email: email, password: password);
    return await _dbHelper.registerUser(newUser);
  }

  Future<void> logout() async {
    // Clear session if any
  }
}
