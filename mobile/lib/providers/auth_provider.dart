import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../services/cache_service.dart';
import '../services/push_notification_service.dart';

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final String? error;
  final String? userRole;
  final String? tenantSlug;
  final String? fullName;
  final String? email;
  final String? phone;
  final String? instituteName;
  final String? primaryColor;
  final String? logoUrl;
  final String? avatarUrl;

  AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.error,
    this.userRole,
    this.tenantSlug,
    this.fullName,
    this.email,
    this.phone,
    this.instituteName,
    this.primaryColor,
    this.logoUrl,
    this.avatarUrl,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    String? error,
    String? userRole,
    String? tenantSlug,
    String? fullName,
    String? email,
    String? phone,
    String? instituteName,
    String? primaryColor,
    String? logoUrl,
    String? avatarUrl,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      error: error,
      userRole: userRole ?? this.userRole,
      tenantSlug: tenantSlug ?? this.tenantSlug,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      instituteName: instituteName ?? this.instituteName,
      primaryColor: primaryColor ?? this.primaryColor,
      logoUrl: logoUrl ?? this.logoUrl,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  late final ApiService _api;

  @override
  AuthState build() {
    _api = ref.watch(apiServiceProvider);
    return AuthState();
  }

  /// Reads whatever was cached from the last successful login/session
  /// restore, so the UI (and app theme) has something to show immediately
  /// while `restoreSession()` confirms the token is still valid.
  Future<void> hydrateFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) return;
    state = state.copyWith(
      userRole: prefs.getString('user_role'),
      tenantSlug: prefs.getString('tenant_slug'),
      fullName: prefs.getString('full_name'),
      email: prefs.getString('email'),
      phone: prefs.getString('phone'),
      instituteName: prefs.getString('institute_name'),
      primaryColor: prefs.getString('primary_color'),
      logoUrl: prefs.getString('logo_url'),
      avatarUrl: prefs.getString('avatar_url'),
    );
  }

  Future<bool> login(String phone, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _api.post('/auth/login', {'phone': phone, 'password': password});
      final accessToken = response['accessToken'];
      if (accessToken == null) {
        throw Exception('Token missing from response');
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', accessToken);
      if (response['refreshToken'] != null) {
        await prefs.setString('refresh_token', response['refreshToken']);
      }

      await _applyUserAndBranding(response['user'], response['branding']);

      // Sync FCM token with backend
      await PushNotificationService().sendTokenToBackend();

      state = state.copyWith(isLoading: false, isAuthenticated: true);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  /// Validates a previously-stored token against `GET /auth/me` (also
  /// refreshes cached role/branding). Used on app start so a user with a
  /// still-valid session skips the login screen entirely.
  Future<bool> restoreSession() async {
    try {
      final me = await _api.get('/auth/me');
      await _applyUserAndBranding(me['user'], me['branding']);
      
      // Sync FCM token with backend in case it changed while app was killed
      PushNotificationService().sendTokenToBackend();

      state = state.copyWith(isAuthenticated: true);
      return true;
    } catch (_) {
      await logout();
      return false;
    }
  }

  Future<void> _applyUserAndBranding(dynamic user, dynamic branding) async {
    final prefs = await SharedPreferences.getInstance();

    String? userRole;
    String? fullName;
    String? email;
    String? phone;
    String? avatarUrl;
    if (user is Map) {
      userRole = user['role']?.toString();
      fullName = user['fullName']?.toString();
      email = user['email']?.toString();
      phone = user['phone']?.toString();
      avatarUrl = user['avatarUrl']?.toString();
      if (userRole != null) await prefs.setString('user_role', userRole);
      if (fullName != null) await prefs.setString('full_name', fullName);
      if (email != null) await prefs.setString('email', email);
      if (phone != null) await prefs.setString('phone', phone);
      if (avatarUrl != null) await prefs.setString('avatar_url', avatarUrl);
    }

    String? tenantSlug;
    String? instituteName;
    String? primaryColor;
    String? logoUrl;
    if (branding is Map) {
      tenantSlug = branding['slug']?.toString();
      instituteName = branding['name']?.toString();
      primaryColor = branding['primaryColor']?.toString();
      logoUrl = branding['logoUrl']?.toString();
      if (tenantSlug != null) await prefs.setString('tenant_slug', tenantSlug);
      if (instituteName != null) await prefs.setString('institute_name', instituteName);
      if (primaryColor != null) await prefs.setString('primary_color', primaryColor);
      if (logoUrl != null) await prefs.setString('logo_url', logoUrl);
    }

    state = state.copyWith(
      userRole: userRole,
      fullName: fullName,
      email: email,
      phone: phone,
      avatarUrl: avatarUrl,
      tenantSlug: tenantSlug,
      instituteName: instituteName,
      primaryColor: primaryColor,
      logoUrl: logoUrl,
    );
  }

  /// Called after a successful branding save so the app theme/drawer update
  /// immediately, without needing another round-trip to the server.
  Future<void> updateLocalBranding({String? instituteName, String? primaryColor, String? logoUrl}) async {
    final prefs = await SharedPreferences.getInstance();
    if (instituteName != null) await prefs.setString('institute_name', instituteName);
    if (primaryColor != null) await prefs.setString('primary_color', primaryColor);
    if (logoUrl != null) await prefs.setString('logo_url', logoUrl);
    state = state.copyWith(
      instituteName: instituteName ?? state.instituteName,
      primaryColor: primaryColor ?? state.primaryColor,
      logoUrl: logoUrl ?? state.logoUrl,
    );
  }

  /// Uploads happen client-side (Cloudinary) first; this just tells the
  /// backend the resulting URL and updates local state so every screen
  /// watching [authProvider] reflects the new photo immediately.
  Future<void> updateAvatarUrl(String avatarUrl) async {
    final result = await _api.patch('/auth/avatar', {'avatarUrl': avatarUrl});
    final saved = (result['user'] as Map?)?['avatarUrl']?.toString() ?? avatarUrl;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('avatar_url', saved);
    state = state.copyWith(avatarUrl: saved);
  }

  Future<void> logout() async {
    // Unregister device token from backend before clearing the auth token
    await PushNotificationService().removeTokenFromBackend();

    // Clear SQLite cache so cached data from this account is
    // not visible if a different account logs in next.
    await CacheService.instance.clearAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('refresh_token');
    await prefs.remove('user_role');
    await prefs.remove('tenant_slug');
    await prefs.remove('full_name');
    await prefs.remove('email');
    await prefs.remove('phone');
    await prefs.remove('institute_name');
    await prefs.remove('primary_color');
    await prefs.remove('avatar_url');
    await prefs.remove('logo_url');
    state = AuthState();
  }
}
