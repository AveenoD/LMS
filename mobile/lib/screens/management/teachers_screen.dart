import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/management_providers.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_button.dart';

import 'teacher_details_screen.dart';

class TeachersScreen extends ConsumerWidget {
  const TeachersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teachersAsync = ref.watch(teachersProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F2E27),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Teachers', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
            Text(
              'Manage and view all your teachers',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12, fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ),
      body: teachersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (teachers) {
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(teachersProvider),
            child: Column(
              children: [
                // Stats Header
                Card(
                  color: Colors.white,
                  margin: const EdgeInsets.all(16),
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Builder(builder: (_) {
                      final activeCount = teachers.where((t) { final m = t as Map<String, dynamic>; return m['status'] == 'active' || m['status'] == null; }).length;
                      final leaveCount = teachers.where((t) => (t as Map<String, dynamic>)['status'] == 'on_leave').length;
                      final inactiveCount = teachers.where((t) => (t as Map<String, dynamic>)['status'] == 'inactive').length;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatItem('Total', '${teachers.length}', Icons.people_outline, const Color(0xFF2E6656)),
                          _buildDivider(),
                          _buildStatItem('Active', '$activeCount', Icons.how_to_reg_outlined, Colors.blue),
                          _buildDivider(),
                          _buildStatItem('On Leave', '$leaveCount', Icons.beach_access, Colors.orange),
                          _buildDivider(),
                          _buildStatItem('Inactive', '$inactiveCount', Icons.person_off_outlined, Colors.grey),
                        ],
                      );
                    }),
                  ),
                ),
                
                // Search Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: Colors.grey.shade500, size: 20),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search by name or phone number...',
                              border: InputBorder.none,
                              hintStyle: TextStyle(fontSize: 13),
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                
                // Teacher List
                Expanded(
                  child: teachers.isEmpty
                      ? const Center(child: Text('No teachers found.'))
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: teachers.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final teacher = teachers[index] as Map<String, dynamic>;
                            return _buildTeacherCard(context, ref, teacher);
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (ctx) => const _AddTeacherBottomSheet(),
        ),
        backgroundColor: const Color(0xFF1F2E27),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Teacher', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1F2E27))),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.grey.shade200,
    );
  }

  Widget _buildTeacherCard(BuildContext context, WidgetRef ref, Map<String, dynamic> teacher) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TeacherDetailsScreen(teacher: teacher),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Card(
          margin: EdgeInsets.zero,
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.orange.shade50,
              child: const Icon(Icons.person_outline, color: Colors.orange, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    teacher['fullName'] ?? 'Unknown',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1F2E27)),
                  ),
                  const SizedBox(height: 2),
                  const Text('Teacher', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.phone_outlined, size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(teacher['phone']?.toString() ?? '', style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Builder(builder: (_) {
                    final status = teacher['status']?.toString() ?? 'active';
                    Color color;
                    Color bg;
                    String label;
                    if (status == 'on_leave') {
                      color = Colors.orange.shade700;
                      bg = Colors.orange.shade50;
                      label = 'On Leave';
                    } else if (status == 'inactive') {
                      color = Colors.grey.shade600;
                      bg = Colors.grey.shade100;
                      label = 'Inactive';
                    } else {
                      color = Colors.green.shade700;
                      bg = Colors.green.shade50;
                      label = 'Active';
                    }
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                          const SizedBox(width: 4),
                          Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                  padding: EdgeInsets.zero,
                  onSelected: (val) {
                    if (val == 'delete') _confirmDelete(context, ref, teacher);
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'delete', child: Text('Remove Teacher', style: TextStyle(color: Colors.red))),
                  ],
                ),
                const SizedBox(height: 24),
                const Icon(Icons.chevron_right, color: Colors.black87),
              ],
            ),
          ],
        ),
      ),
    ),
  ),
);
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, Map<String, dynamic> teacher) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove teacher?'),
        content: Text('${teacher['fullName'] ?? 'This teacher'} will be removed permanently.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await deleteTeacher(ref.read(apiServiceProvider), teacher['id'] as int);
      ref.invalidate(teachersProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Teacher removed')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e'), backgroundColor: Colors.red));
      }
    }
  }
}

class _AddTeacherBottomSheet extends ConsumerStatefulWidget {
  const _AddTeacherBottomSheet();

  @override
  ConsumerState<_AddTeacherBottomSheet> createState() => _AddTeacherBottomSheetState();
}

class _AddTeacherBottomSheetState extends ConsumerState<_AddTeacherBottomSheet> {
  final _fullName = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _email = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _fullName.dispose();
    _phone.dispose();
    _password.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_fullName.text.trim().isEmpty || _phone.text.trim().isEmpty || _password.text.isEmpty) {
      setState(() => _error = 'Full name, phone and password are required.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await createTeacher(
        ref.read(apiServiceProvider),
        fullName: _fullName.text.trim(),
        phone: _phone.text.trim(),
        password: _password.text,
        email: _email.text.trim(),
      );
      ref.invalidate(teachersProvider);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() {
        _saving = false;
        _error = '$e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Add New Teacher',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1F2E27)),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
            CustomTextField(
              label: 'Full Name',
              hint: 'e.g. Rahul Sharma',
              controller: _fullName,
              prefixIcon: Icons.person_outline,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Phone Number',
              hint: '10 digit mobile number',
              controller: _phone,
              prefixIcon: Icons.phone_outlined,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Password',
              hint: 'Min 6 characters',
              isPassword: true,
              controller: _password,
              prefixIcon: Icons.lock_outline,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Email Address (Optional)',
              hint: 'teacher@example.com',
              controller: _email,
              prefixIcon: Icons.email_outlined,
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13))),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 32),
            _saving
                ? const Center(child: CircularProgressIndicator())
                : SizedBox(
                    height: 52,
                    child: CustomButton(
                      text: 'Add Teacher',
                      onPressed: _submit,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
