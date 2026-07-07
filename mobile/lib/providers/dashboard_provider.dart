import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';

final dashboardProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  try {
    final response = await api.get('/admin/dashboard');
    return response as Map<String, dynamic>;
  } catch (e) {
    throw Exception('Failed to load dashboard data: $e');
  }
});
