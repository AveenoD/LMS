import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/superadmin_providers.dart';
import '../../theme/app_colors.dart';
import '../../services/api_service.dart';

class TenantDetailsScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> tenant;
  const TenantDetailsScreen({super.key, required this.tenant});

  @override
  ConsumerState<TenantDetailsScreen> createState() => _TenantDetailsScreenState();
}

class _TenantDetailsScreenState extends ConsumerState<TenantDetailsScreen> {
  late bool _isActive;
  String _selectedTab = 'Overview';

  @override
  void initState() {
    super.initState();
    _isActive = widget.tenant['isActive'] == true;
  }

  Future<void> _toggleActive(bool value) async {
    final oldVal = _isActive;
    setState(() => _isActive = value);
    try {
      await setTenantActive(ref.read(apiServiceProvider), widget.tenant['id'] as int, value);
      ref.invalidate(tenantsProvider);
    } catch (e) {
      if (mounted) {
        setState(() => _isActive = oldVal);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e'), backgroundColor: Colors.red));
      }
    }
  }

  String _monthStr(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day} ${_monthStr(date.month)} ${date.year}';
  }

  Widget _buildStat(IconData icon, String count, String label) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: Colors.grey.shade700),
              const SizedBox(width: 6),
              Text(count, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildActionBtn(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Icon(icon, color: const Color(0xFF1F2E27), size: 20),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 30,
      width: 1,
      color: Colors.grey.shade300,
    );
  }

  Widget _buildRightRowText(String label, String value, Color valueColor, {double fontSize = 11}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: valueColor, fontWeight: FontWeight.bold, fontSize: fontSize),
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tenant = widget.tenant;
    final int id = tenant['id'];
    final String name = tenant['name'] ?? 'Unknown';
    final String? city = tenant['city']?.toString();
    final String studentCount = tenant['studentCount']?.toString() ?? '0';
    final String teacherCount = tenant['teacherCount']?.toString() ?? '0';
    final String batchCount = tenant['batchCount']?.toString() ?? '0';
    final String status = tenant['status']?.toString() ?? 'unknown';

    final String? trialEndsAtStr = tenant['trialEndsAt'];
    final String? createdAtStr = tenant['createdAt'];
    
    DateTime? trialEndsAt = trialEndsAtStr != null ? DateTime.tryParse(trialEndsAtStr) : null;
    DateTime? createdAt = createdAtStr != null ? DateTime.tryParse(createdAtStr) : null;
    
    String statusText = status.toUpperCase();
    Color statusColor = Colors.grey;
    Color statusBgColor = Colors.grey.withValues(alpha: 0.1);

    if (status == 'trial') {
      statusText = 'TRIAL';
      statusColor = Colors.orange;
      statusBgColor = Colors.orange.withValues(alpha: 0.1);
    } else if (status == 'active') {
      statusText = 'PREMIUM';
      statusColor = Colors.green;
      statusBgColor = Colors.green.withValues(alpha: 0.1);
    } else {
      statusText = status == 'past_due' ? 'EXPIRED' : status.toUpperCase();
      statusColor = Colors.red;
      statusBgColor = Colors.red.withValues(alpha: 0.1);
    }

    final subDetailAsync = ref.watch(tenantSubscriptionProvider(id));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('Tenant Details', style: TextStyle(color: AppColors.textPrimary)),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header Card (Left & Right)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2)),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: const Color(0xFFE8F0ED),
                    child: const Icon(Icons.business, color: Color(0xFF1F2E27), size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1F2E27)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text('Status', style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                            const SizedBox(width: 4),
                            SizedBox(
                              height: 20,
                              child: Transform.scale(
                                scale: 0.6,
                                child: CupertinoSwitch(
                                  value: _isActive,
                                  activeColor: const Color(0xFF1F2E27),
                                  onChanged: _toggleActive,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 12, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '${city != null && city.isNotEmpty ? '$city, ' : ''}Maharashtra',
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_outlined, size: 12, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'Joined on ${_formatDate(createdAt)}',
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Stats Row
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2)),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStat(Icons.school, studentCount, 'Students'),
                  _buildVerticalDivider(),
                  _buildStat(Icons.person, teacherCount, 'Teachers'),
                  _buildVerticalDivider(),
                  _buildStat(Icons.menu_book, batchCount, 'Batches'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2)),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionBtn(Icons.edit_outlined, 'Edit Institute'),
                  _buildActionBtn(Icons.workspace_premium_outlined, 'Manage Plan'),
                  _buildActionBtn(Icons.chat_bubble_outline, 'Send Message'),
                  _buildActionBtn(Icons.receipt_long_outlined, 'View Invoice'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Tabs Row
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = 'Overview'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _selectedTab == 'Overview' ? const Color(0xFF1F2E27) : Colors.transparent,
                            width: 2,
                          )
                        )
                      ),
                      child: Center(
                        child: Text(
                          'Overview',
                          style: TextStyle(
                            fontWeight: _selectedTab == 'Overview' ? FontWeight.bold : FontWeight.w500,
                            color: _selectedTab == 'Overview' ? const Color(0xFF1F2E27) : Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = 'Payments'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _selectedTab == 'Payments' ? const Color(0xFF1F2E27) : Colors.transparent,
                            width: 2,
                          )
                        )
                      ),
                      child: Center(
                        child: Text(
                          'Payments',
                          style: TextStyle(
                            fontWeight: _selectedTab == 'Payments' ? FontWeight.bold : FontWeight.w500,
                            color: _selectedTab == 'Payments' ? const Color(0xFF1F2E27) : Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Tab Content
            if (_selectedTab == 'Overview') ...[
              const Text('Subscription Overview', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              subDetailAsync.when(
                loading: () => const Center(child: Padding(padding: EdgeInsets.all(24.0), child: CircularProgressIndicator())),
                error: (err, stack) => Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: Text('Error loading subscription details: $err', style: const TextStyle(color: Colors.red)),
                ),
                data: (detail) {
                  final String planName = detail['planName']?.toString() ?? 'N/A';
                  final String billingCycle = detail['billingCycle']?.toString() ?? 'N/A';
                  final String subStatus = detail['status']?.toString() ?? 'unknown';
                  
                  final String? trialEndsStr = detail['trialEndsAt'];
                  final String? nextBillStr = detail['nextBillingDate'];
                  
                  DateTime? subTrialEndsAt = trialEndsStr != null ? DateTime.tryParse(trialEndsStr) : trialEndsAt;
                  DateTime? nextBillingDate = nextBillStr != null ? DateTime.tryParse(nextBillStr) : null;

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _buildDetailRow('Current Plan', planName),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusBgColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(statusText, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow('Billing Cycle', billingCycle.toUpperCase()),
                        const SizedBox(height: 12),
                        _buildDetailRow('Status', subStatus.toUpperCase()),
                        const SizedBox(height: 12),
                        _buildDetailRow('Trial Ends On', _formatDate(subTrialEndsAt)),
                        const SizedBox(height: 12),
                        _buildDetailRow('Next Billing Date', _formatDate(nextBillingDate)),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: () {
                              // Can call Manage Plan dialog here if implemented
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF1F2E27),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            icon: const Icon(Icons.star_border, size: 18),
                            label: const Text('Manage Plan'),
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
            ] else if (_selectedTab == 'Payments') ...[
              Container(
                padding: const EdgeInsets.all(32),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(Icons.payment, size: 48, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    Text('No Payment History', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary)),
      ],
    );
  }
}
