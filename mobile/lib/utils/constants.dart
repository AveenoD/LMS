import 'package:flutter/material.dart';

class Constants {
  static const String baseUrl = 'https://my-app-tau-umber-67.vercel.app/api';

  static const String privacyPolicyUrl =
      'https://www.campusweb.co.in/legals/privacy-policy';
  static const String termsAndConditionsUrl =
      'https://www.campusweb.co.in/legals/terms-conditions';

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
