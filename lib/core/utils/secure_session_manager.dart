import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../data/models/user_profile.dart';

/// Secure session manager for handling user authentication sessions.
/// Uses flutter_secure_storage for encrypted storage of session data.
class SecureSessionManager {
  static const String _sessionKey = 'user_session';
  static const String _sessionExpiryKey = 'session_expiry';
  static const Duration _sessionDuration = Duration(days: 7);

  final FlutterSecureStorage _storage;

  SecureSessionManager({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(encryptedSharedPreferences: true),
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.first_unlock_this_device,
            ),
          );

  /// Saves the user session securely after successful login.
  Future<void> saveSession(UserProfile user) async {
    final sessionData = {
      'id': user.id,
      'name': user.name,
      'email': user.email,
      'profileImage': user.profileImage,
    };

    final expiry = DateTime.now().add(_sessionDuration);

    await _storage.write(key: _sessionKey, value: jsonEncode(sessionData));

    await _storage.write(
      key: _sessionExpiryKey,
      value: expiry.toIso8601String(),
    );
  }

  /// Retrieves the stored session if valid.
  /// Returns null if no session exists or if session has expired.
  Future<UserProfile?> getSession() async {
    try {
      final sessionJson = await _storage.read(key: _sessionKey);
      final expiryString = await _storage.read(key: _sessionExpiryKey);

      if (sessionJson == null || expiryString == null) {
        return null;
      }

      final expiry = DateTime.parse(expiryString);
      if (DateTime.now().isAfter(expiry)) {
        // Session expired, clear it
        await clearSession();
        return null;
      }

      final sessionData = jsonDecode(sessionJson) as Map<String, dynamic>;
      return UserProfile(
        id: sessionData['id'] as int?,
        name: sessionData['name'] as String,
        email: sessionData['email'] as String,
        profileImage: sessionData['profileImage'] as String?,
      );
    } catch (e) {
      // If any error occurs, clear the session and return null
      await clearSession();
      return null;
    }
  }

  /// Clears the stored session (logout).
  Future<void> clearSession() async {
    await _storage.delete(key: _sessionKey);
    await _storage.delete(key: _sessionExpiryKey);
  }

  /// Checks if a valid session exists.
  Future<bool> hasValidSession() async {
    final session = await getSession();
    return session != null;
  }

  /// Refreshes the session expiry time.
  Future<void> refreshSession() async {
    final session = await getSession();
    if (session != null) {
      await saveSession(session);
    }
  }
}
