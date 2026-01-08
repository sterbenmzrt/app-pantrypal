/// Helper class for formatting numbers consistently across platforms.
class NumberHelpers {
  /// Formats a quantity value to display without decimals if it's a whole number.
  /// Examples:
  /// - 1.0 → "1"
  /// - 2.5 → "2.5"
  /// - 10.0 → "10"
  static String formatQuantity(double quantity) {
    // Check if the quantity is a whole number
    if (quantity == quantity.roundToDouble()) {
      return quantity.toInt().toString();
    }
    return quantity.toString();
  }
}
