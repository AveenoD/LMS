import 'package:flutter/material.dart';

class Constants {
  // Use 10.0.2.2 for Android Emulator, 192.168.1.14 for physical device on LAN
  static const String baseUrl = 'http://192.168.1.9:4000/api/v1';

  static const String currencySymbol = '₹';

  /// The "Web application" OAuth client ID from Google Cloud Console —
  /// used as google_sign_in's serverClientId so the backend can exchange
  /// the resulting server auth code for a refresh token. Must match
  /// GOOGLE_OAUTH_CLIENT_ID in the backend's .env.
  static const String googleOAuthWebClientId =
      '616148352281-69ektourfds5q3mi1u9042bbpkfgg148.apps.googleusercontent.com';

  /// The app's single fixed theme color — every institute uses the same UI color.
  static const Color defaultPrimaryColor = Color(0xFF1F2E27);
}
