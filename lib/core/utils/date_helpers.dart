import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'package:intl/intl.dart';

class DateHelpers {
  static Color getStatusColor(DateTime expiryDate) {
    final now = DateTime.now();
    // Reset time to midnight for comparison
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);

    final days = expiry.difference(today).inDays;

    if (days < 0) return Colors.grey; // Expired
    if (days < 3) return AppTheme.statusCritical; // 0, 1, 2
    if (days < 6) return AppTheme.statusWarning; // 3, 4, 5
    return AppTheme.statusSafe;
  }

  static String getExpiryText(DateTime expiryDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);

    final days = expiry.difference(today).inDays;

    if (days < 0) return "Expired ${days.abs()} days ago";
    if (days == 0) return "Expires Today";
    if (days == 1) return "Expires Tomorrow";
    return "Expires in $days days";
  }

  static String formatDate(DateTime date) {
    return DateFormat.yMMMd().format(date);
  }
}
