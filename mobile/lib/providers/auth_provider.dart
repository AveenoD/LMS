import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final String? error;
  final String? userRole;
  final String? tenantSlug;

  AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.error,
    this.userRole,
    this.tenantSlug,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    String? error,
    String? userRole,
    String? tenantSlug,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      error: error ?? this.error,
      userRole: userRole ?? this.userRole,
      tenantSlug: tenantSlug ?? this.tenantSlug,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  late final ApiService _api;

  @override
  AuthState build() {
    _api = ref.watch(apiServiceProvider);
    // Restore auth state from SharedPreferences synchronously where possible
    _restoreAuthState();
    return AuthState();
  }

  void _restoreAuthState() {
    // Try to restore state synchronously using SharedPreferences
    // Note: This is a fire-and-forget operation to update state after app restart
    SharedPreferences.getInstance().then((prefs) {
      final token = prefs.getString('auth_token');
      if (token != null) {
        final userRole = prefs.getString('user_role');
        final tenantSlug = prefs.getString('tenant_slug');
        state = state.copyWith(
          isAuthenticated: true,
          userRole: userRole,
          tenantSlug: tenantSlug,
        );
      }
    });
  }

  Future<bool> login(String phone, String password, {String? slug}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final Map<String, dynamic> body = {'phone': phone, 'password': password};
      if (slug != null && slug.isNotEmpty) {
        body['slug'] = slug;
      }

      final response = await _api.post('/auth/login', body);

      final accessToken =
          response['accessToken'] ??
          response['token'] ??
          response['access_token'];
      if (accessToken != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', accessToken);
        // Also store refresh token if provided
        if (response['refreshToken'] != null) {
          await prefs.setString('refresh_token', response['refreshToken']);
        }

        // Extract user role and tenant slug from response
        String? userRole;
        String? tenantSlug;
        if (response['user'] != null) {
          userRole = response['user']['role'];
          if (userRole != null) {
            await prefs.setString('user_role', userRole);
          }
        }
        if (response['branding'] != null) {
          tenantSlug = response['branding']['slug'];
          if (tenantSlug != null) {
            await prefs.setString('tenant_slug', tenantSlug);
          }
        }

        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          userRole: userRole,
          tenantSlug: tenantSlug,
        );
        return true;
      } else {
        throw Exception("Token missing from response");
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    state = state.copyWith(isAuthenticated: false);
  }
}
