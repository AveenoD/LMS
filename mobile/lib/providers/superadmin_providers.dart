import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

// Helper function to check if user can access superadmin features
Future<bool> _canAccessSuperAdmin() async {
  final prefs = await SharedPreferences.getInstance();
  final userRole = prefs.getString('user_role');
  return userRole == 'super_admin';
}

// ─────────────────────────── Providers ───────────────────────────

final superAdminAnalyticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final canAccess = await _canAccessSuperAdmin();
  if (!canAccess) return {};
  final api = ref.watch(apiServiceProvider);
  final response = await api.get('/superadmin/analytics');
  return response as Map<String, dynamic>;
});

final tenantsProvider = FutureProvider<List<dynamic>>((ref) async {
  final canAccess = await _canAccessSuperAdmin();
  if (!canAccess) return [];
  final api = ref.watch(apiServiceProvider);
  final response = await api.get('/superadmin/tenants');
  return response as List<dynamic>;
});

final plansCatalogProvider = FutureProvider<List<dynamic>>((ref) async {
  final canAccess = await _canAccessSuperAdmin();
  if (!canAccess) return [];
  final api = ref.watch(apiServiceProvider);
  final response = await api.get('/superadmin/plans');
  return response as List<dynamic>;
});

final leadsProvider = FutureProvider<List<dynamic>>((ref) async {
  final canAccess = await _canAccessSuperAdmin();
  if (!canAccess) return [];
  final api = ref.watch(apiServiceProvider);
  final response = await api.get('/superadmin/leads');
  return response as List<dynamic>;
});

final subscriptionsProvider = FutureProvider<List<dynamic>>((ref) async {
  final canAccess = await _canAccessSuperAdmin();
  if (!canAccess) return [];
  final api = ref.watch(apiServiceProvider);
  final response = await api.get('/superadmin/subscriptions');
  return response as List<dynamic>;
});

// ─────────────────────────── Write actions ───────────────────────────

Future<Map<String, dynamic>> registerTenant(ApiService api, {
  required String name,
  required String slug,
  String? city,
  String? phone,
  String? primaryColor,
  required String adminName,
  required String adminPhone,
  required String adminPassword,
  required String billingCycle,
  required int planCatalogId,
}) async {
  final body = <String, dynamic>{
    'name': name,
    'slug': slug,
    if (city != null && city.isNotEmpty) 'city': city,
    if (phone != null && phone.isNotEmpty) 'phone': phone,
    if (primaryColor != null && primaryColor.isNotEmpty) 'primaryColor': primaryColor,
    'adminName': adminName,
    'adminPhone': adminPhone,
    'adminPassword': adminPassword,
    'billingCycle': billingCycle,
    'planCatalogId': planCatalogId,
  };
  return await api.post('/superadmin/tenants', body) as Map<String, dynamic>;
}

Future<void> suspendTenant(ApiService api, int id, bool isActive) async {
  await api.patch('/superadmin/tenants/$id/suspend', {'isActive': isActive});
}

Future<void> updateLeadStatus(ApiService api, int id, String status) async {
  await api.patch('/superadmin/leads/$id/status', {'status': status});
}
