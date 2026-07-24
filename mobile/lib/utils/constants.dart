import 'package:flutter/material.dart';

class Constants {
  // Use 10.0.2.2 for Android Emulator, 192.168.1.13 for physical device on LAN
  static const String baseUrl = 'http://192.168.1.13:4000/api/v1';

  static const String currencySymbol = '₹';

  /// Fallback brand color used before login / if an institute hasn't set one.
  static const Color defaultPrimaryColor = Color(0xFF1F2E27);

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
