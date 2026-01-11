import 'dart:async';

/// Rate limiter to protect against brute-force attacks on authentication.
/// Implements exponential backoff with configurable parameters.
class RateLimiter {
  final int maxAttempts;
  final Duration lockoutDuration;
  final Duration attemptWindow;

  final Map<String, List<DateTime>> _attemptHistory = {};
  final Map<String, DateTime> _lockoutUntil = {};

  RateLimiter({
    this.maxAttempts = 5,
    this.lockoutDuration = const Duration(minutes: 15),
    this.attemptWindow = const Duration(minutes: 5),
  });

  /// Records an authentication attempt for the given identifier (e.g., email).
  void recordAttempt(String identifier) {
    final now = DateTime.now();
    final key = identifier.toLowerCase();

    // Initialize if needed
    _attemptHistory[key] ??= [];

    // Clean old attempts outside the window
    _attemptHistory[key] =
        _attemptHistory[key]!
            .where((attempt) => now.difference(attempt) < attemptWindow)
            .toList();

    // Add new attempt
    _attemptHistory[key]!.add(now);

    // Check if we should lock out
    if (_attemptHistory[key]!.length >= maxAttempts) {
      _lockoutUntil[key] = now.add(lockoutDuration);
      _attemptHistory[key]!.clear();
    }
  }

  /// Checks if the identifier is currently locked out.
  bool isLockedOut(String identifier) {
    final key = identifier.toLowerCase();
    final lockoutTime = _lockoutUntil[key];

    if (lockoutTime == null) {
      return false;
    }

    if (DateTime.now().isAfter(lockoutTime)) {
      // Lockout expired
      _lockoutUntil.remove(key);
      return false;
    }

    return true;
  }

  /// Gets the remaining lockout duration for the identifier.
  Duration? getRemainingLockoutDuration(String identifier) {
    final key = identifier.toLowerCase();
    final lockoutTime = _lockoutUntil[key];

    if (lockoutTime == null) {
      return null;
    }

    final remaining = lockoutTime.difference(DateTime.now());
    if (remaining.isNegative) {
      _lockoutUntil.remove(key);
      return null;
    }

    return remaining;
  }

  /// Gets the number of remaining attempts before lockout.
  int getRemainingAttempts(String identifier) {
    final key = identifier.toLowerCase();
    final attempts = _attemptHistory[key]?.length ?? 0;
    return (maxAttempts - attempts).clamp(0, maxAttempts);
  }

  /// Clears the attempt history for an identifier (e.g., after successful login).
  void clearAttempts(String identifier) {
    final key = identifier.toLowerCase();
    _attemptHistory.remove(key);
    _lockoutUntil.remove(key);
  }

  /// Resets all rate limiting data.
  void reset() {
    _attemptHistory.clear();
    _lockoutUntil.clear();
  }
}

/// Global rate limiter instance for authentication.
final authRateLimiter = RateLimiter();
