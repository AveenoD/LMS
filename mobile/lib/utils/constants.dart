import 'package:flutter/material.dart';

class Constants {
  // Use 192.168.1.9 for physical device connected on local network
  static const String baseUrl = 'http://192.168.1.9:4000/api/v1';

  static const String currencySymbol = '₹';

  /// Fallback brand color used before login / if an institute hasn't set one.
  static const Color defaultPrimaryColor = Colors.deepPurple;

  /// Parses a `#RRGGBB` hex string (as returned by the branding API) into a
  /// [Color]. Falls back to [defaultPrimaryColor] for null/malformed input.
  static Color colorFromHex(String? hex) {
    if (hex == null) return defaultPrimaryColor;
    var value = hex.trim();
    if (value.startsWith('#')) value = value.substring(1);
    if (value.length != 6) return defaultPrimaryColor;
    final parsed = int.tryParse('FF$value', radix: 16);
    if (parsed == null) return defaultPrimaryColor;
    return Color(parsed);
  }
}
