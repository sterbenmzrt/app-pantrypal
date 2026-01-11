import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

/// Security utility class for password hashing and validation.
/// Uses SHA-256 with a random salt for secure password storage.
class SecurityUtils {
  static const int _saltLength = 32;
  static const String _separator = ':';

  /// Generates a cryptographically secure random salt.
  static String _generateSalt() {
    final random = Random.secure();
    final saltBytes = List<int>.generate(
      _saltLength,
      (_) => random.nextInt(256),
    );
    return base64Encode(saltBytes);
  }

  /// Hashes a password with SHA-256 and a random salt.
  /// Returns formatted string: "salt:hashedPassword"
  static String hashPassword(String password) {
    final salt = _generateSalt();
    final hash = _hashWithSalt(password, salt);
    return '$salt$_separator$hash';
  }

  /// Hashes a password with a given salt using SHA-256.
  static String _hashWithSalt(String password, String salt) {
    final saltedPassword = salt + password;
    final bytes = utf8.encode(saltedPassword);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Verifies a password against a stored hash.
  /// The storedHash should be in format: "salt:hashedPassword"
  static bool verifyPassword(String password, String storedHash) {
    try {
      final parts = storedHash.split(_separator);
      if (parts.length != 2) {
        return false;
      }
      final salt = parts[0];
      final hash = parts[1];
      final computedHash = _hashWithSalt(password, salt);
      return hash == computedHash;
    } catch (e) {
      return false;
    }
  }

  /// Validates password strength.
  /// Returns null if valid, or an error message if invalid.
  static String? validatePasswordStrength(String password) {
    if (password.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    return null;
  }

  /// Validates email format using regex.
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Sanitizes user input to prevent potential injection attacks.
  static String sanitizeInput(String input) {
    // Remove leading/trailing whitespace
    String sanitized = input.trim();
    // Remove any null characters
    sanitized = sanitized.replaceAll('\x00', '');
    return sanitized;
  }
}
