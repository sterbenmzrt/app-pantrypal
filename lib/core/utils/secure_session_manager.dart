import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/user_profile.dart';
import '../../data/database/database_helper.dart';

/// Secure session manager for handling user authentication sessions.
/// Uses SQLite database as primary storage (most reliable on mobile),
/// with flutter_secure_storage and SharedPreferences as fallbacks.
class SecureSessionManager {
  static const String _sessionKey = 'user_session';
  static const String _sessionExpiryKey = 'session_expiry';
  static const Duration _sessionDuration = Duration(days: 30);

  final FlutterSecureStorage _storage;
  final DatabaseHelper _dbHelper;

  SecureSessionManager({
    FlutterSecureStorage? storage,
    DatabaseHelper? dbHelper,
  }) : _storage =
           storage ??
           const FlutterSecureStorage(
             aOptions: AndroidOptions(
               encryptedSharedPreferences: true,
               resetOnError: true,
             ),
             iOptions: IOSOptions(
               accessibility: KeychainAccessibility.first_unlock_this_device,
             ),
           ),
       _dbHelper = dbHelper ?? DatabaseHelper();

  /// Saves the user session. Uses multiple storage methods for redundancy.
  Future<void> saveSession(UserProfile user) async {
    debugPrint('SecureSessionManager: Saving session for ${user.email}');

    // Primary: Save to database (most reliable on mobile)
    try {
      await _dbHelper.saveActiveSession(user);
      debugPrint('SecureSessionManager: Session saved to database');
    } catch (e) {
      debugPrint('SecureSessionManager: Database session save failed: $e');
    }

    // Backup 1: Secure storage
    try {
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
      debugPrint('SecureSessionManager: Session saved to secure storage');
    } catch (e) {
      debugPrint('SecureSessionManager: Secure storage failed: $e');
    }

    // Backup 2: SharedPreferences
    try {
      final sessionData = {
        'id': user.id,
        'name': user.name,
        'email': user.email,
        'profileImage': user.profileImage,
      };
      final expiry = DateTime.now().add(_sessionDuration);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_sessionKey, jsonEncode(sessionData));
      await prefs.setString(_sessionExpiryKey, expiry.toIso8601String());
      debugPrint('SecureSessionManager: Session saved to SharedPreferences');
    } catch (e) {
      debugPrint('SecureSessionManager: SharedPreferences failed: $e');
    }
  }

  /// Retrieves the stored session if valid.
  /// Tries database first, then secure storage, then SharedPreferences.
  Future<UserProfile?> getSession() async {
    debugPrint('SecureSessionManager: Getting session...');

    // Try database first (most reliable)
    try {
      final dbSession = await _dbHelper.getActiveSession();
      if (dbSession != null) {
        debugPrint('SecureSessionManager: Session found in database');
        return dbSession;
      }
    } catch (e) {
      debugPrint('SecureSessionManager: Database session read failed: $e');
    }

    // Try secure storage
    try {
      final sessionJson = await _storage.read(key: _sessionKey);
      final expiryString = await _storage.read(key: _sessionExpiryKey);

      if (sessionJson != null && expiryString != null) {
        final expiry = DateTime.parse(expiryString);
        if (DateTime.now().isBefore(expiry)) {
          final sessionData = jsonDecode(sessionJson) as Map<String, dynamic>;
          final profile = _createUserProfile(sessionData);
          debugPrint('SecureSessionManager: Session found in secure storage');
          // Migrate to database
          await _dbHelper.saveActiveSession(profile);
          return profile;
        }
      }
    } catch (e) {
      debugPrint('SecureSessionManager: Secure storage read failed: $e');
    }

    // Try SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionJson = prefs.getString(_sessionKey);
      final expiryString = prefs.getString(_sessionExpiryKey);

      if (sessionJson != null && expiryString != null) {
        final expiry = DateTime.parse(expiryString);
        if (DateTime.now().isBefore(expiry)) {
          final sessionData = jsonDecode(sessionJson) as Map<String, dynamic>;
          final profile = _createUserProfile(sessionData);
          debugPrint(
            'SecureSessionManager: Session found in SharedPreferences',
          );
          // Migrate to database
          await _dbHelper.saveActiveSession(profile);
          return profile;
        }
      }
    } catch (e) {
      debugPrint('SecureSessionManager: SharedPreferences read failed: $e');
    }

    debugPrint('SecureSessionManager: No valid session found');
    return null;
  }

  UserProfile _createUserProfile(Map<String, dynamic> sessionData) {
    return UserProfile(
      id: sessionData['id'] as int?,
      name: sessionData['name'] as String,
      email: sessionData['email'] as String,
      profileImage: sessionData['profileImage'] as String?,
    );
  }

  /// Clears all stored sessions (logout).
  Future<void> clearSession() async {
    debugPrint('SecureSessionManager: Clearing all sessions...');

    // Clear database
    try {
      await _dbHelper.clearActiveSession();
    } catch (e) {
      debugPrint('SecureSessionManager: Database clear failed: $e');
    }

    // Clear secure storage
    try {
      await _storage.delete(key: _sessionKey);
      await _storage.delete(key: _sessionExpiryKey);
    } catch (e) {
      debugPrint('SecureSessionManager: Secure storage clear failed: $e');
    }

    // Clear SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_sessionKey);
      await prefs.remove(_sessionExpiryKey);
    } catch (e) {
      debugPrint('SecureSessionManager: SharedPreferences clear failed: $e');
    }

    debugPrint('SecureSessionManager: All sessions cleared');
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
      debugPrint('SecureSessionManager: Session refreshed');
    }
  }
}
