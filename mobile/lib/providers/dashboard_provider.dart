import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

final dashboardProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  final authState = ref.watch(authProvider);

  try {
    // Determine endpoint based on user role
    String endpoint;
    String? userRole = authState.userRole;

    // If userRole is not yet loaded from provider, try to load from SharedPreferences
    if (userRole == null) {
      final prefs = await SharedPreferences.getInstance();
      userRole = prefs.getString('user_role');
    }

    // Select endpoint based on role
    if (userRole == 'super_admin') {
      endpoint = '/superadmin/analytics';
    } else if (userRole == 'coaching_admin') {
      endpoint = '/admin/dashboard';
    } else if (userRole == 'student') {
      endpoint = '/student/dashboard';
    } else if (userRole == 'teacher') {
      endpoint = '/teacher/schedule/today';
    } else {
      throw Exception('Unknown role: $userRole');
    }

    final response = await api.get(endpoint);
    return response as Map<String, dynamic>;
  } catch (e) {
    throw Exception('Failed to load dashboard data: $e');
  }
});
