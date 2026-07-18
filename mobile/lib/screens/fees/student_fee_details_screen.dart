import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_colors.dart';
import '../../providers/management_providers.dart' as mgmt;
import '../../services/api_service.dart';
import '../../widgets/record_payment_bottom_sheet.dart';
import '../../widgets/fee_overview_card.dart';
import '../../widgets/installment_row.dart';
import '../../widgets/payment_history_row.dart';

class StudentFeeDetailsScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> student;

  const StudentFeeDetailsScreen({super.key, required this.student});

  @override
  ConsumerState<StudentFeeDetailsScreen> createState() =>
      _StudentFeeDetailsScreenState();
}

class _StudentFeeDetailsScreenState
    extends ConsumerState<StudentFeeDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.student;
    final studentId = s['id'] as int;

    // Fetch detailed data from backend
    final detailsAsync = ref.watch(mgmt.studentDetailsProvider(studentId));
    final details = detailsAsync.value;
    final isLoading = detailsAsync.isLoading;
    final hasError = detailsAsync.hasError;

    final fullName = s['fullName']?.toString() ?? 'Unknown Student';
    
    // We can extract basic student info from details if available
    final studentInfo = details?['student'] as Map<String, dynamic>?;
    final rollNo = studentInfo?['roll_no']?.toString() ?? 'N/A';
    final grade = studentInfo?['grade']?.toString() ?? 'N/A';
    
    // Fallback for initials
    final parts = fullName.trim().split(' ');
    final initials = parts.length > 1
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : (fullName.isNotEmpty ? fullName[0].toUpperCase() : '?');

    final tabBar = TabBar(
      controller: _tabController,
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white70,
      indicatorColor: const Color(0xFFA87D26),
      indicatorWeight: 3,
      tabs: const [
        Tab(text: 'Overview'),
        Tab(text: 'Payments'),
        Tab(text: 'Installments'),
        Tab(text: 'Receipts'),
      ],
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: SliverAppBar(
                expandedHeight: 180,
                backgroundColor: const Color(0xFF1F2E27), // Dark green background
                pinned: true,
                iconTheme: const IconThemeData(color: Colors.white),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.pin,
                  background: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 50, left: 24, right: 24),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: const Color(0xFFE8F0EA),
                            child: Text(
                              initials,
                              style: const TextStyle(
                                color: Color(0xFF1F2E27),
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      fullName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF2E6656),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'Active',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Class $grade • Roll No. $rollNo',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(tabBar.preferredSize.height),
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.black12,
                          width: 1.0,
                        ),
                      ),
                    ),
                    child: tabBar,
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildOverviewTab(s, details, isLoading, hasError),
            _buildPaymentsTab(details, isLoading, hasError),
            _buildInstallmentsTab(details, isLoading, hasError),
            _buildReceiptsTab(details, isLoading, hasError),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FilledButton.icon(
            onPressed: () => showRecordPaymentBottomSheet(context, ref, prefillStudentId: studentId),
            icon: const Icon(Icons.add),
            label: const Text('Receive Payment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFA87D26),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewTab(Map<String, dynamic> s, Map<String, dynamic>? details, bool isLoading, bool hasError) {
    return Builder(
      builder: (BuildContext context) {
        return CustomScrollView(
          slivers: [
            SliverOverlapInjector(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            ),
            SliverToBoxAdapter(
              child: _buildFeesContent(s, details, isLoading, hasError),
            ),
          ],
        );
      }
    );
  }
  
  Widget _buildPaymentsTab(Map<String, dynamic>? details, bool isLoading, bool hasError) {
    return Builder(
      builder: (BuildContext context) {
        return CustomScrollView(
          slivers: [
            SliverOverlapInjector(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Payments will appear here.'),
              ),
            ),
          ],
        );
      }
    );
  }

  Widget _buildInstallmentsTab(Map<String, dynamic>? details, bool isLoading, bool hasError) {
    return Builder(
      builder: (BuildContext context) {
        return CustomScrollView(
          slivers: [
            SliverOverlapInjector(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Installments will appear here.'),
              ),
            ),
          ],
        );
      }
    );
  }

  Widget _buildReceiptsTab(Map<String, dynamic>? details, bool isLoading, bool hasError) {
    return Builder(
      builder: (BuildContext context) {
        return CustomScrollView(
          slivers: [
            SliverOverlapInjector(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Receipts will appear here.'),
              ),
            ),
          ],
        );
      }
    );
  }

  Widget _buildFeesContent(Map<String, dynamic> s, Map<String, dynamic>? details, bool isLoading, bool hasError) {
    if (isLoading) return const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()));
    if (hasError) return const Center(child: Padding(padding: EdgeInsets.all(40), child: Text('Failed to load details', style: TextStyle(color: Colors.red))));

    final feesData = details?['fees'] as Map<String, dynamic>?;
    final overview = feesData?['overview'] as Map<String, dynamic>?;
    final installments = feesData?['installments'] as List<dynamic>? ?? [];
    final history = feesData?['history'] as List<dynamic>? ?? [];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (overview != null)
            FeeOverviewCard(
              total: overview['total'] ?? 0,
              paid: overview['paid'] ?? 0,
              pending: overview['pending'] ?? 0,
              lastPaymentDate: overview['lastPayment']?['date']?.toString(),
              lastPaymentAmount: overview['lastPayment']?['amount'],
              nextDueDate: overview['nextDue']?.toString(),
            ),
          const SizedBox(height: 20),
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => showRecordPaymentBottomSheet(context, ref, prefillStudentId: s['id'] as int),
                  icon: const Icon(Icons.receipt_long, size: 18),
                  label: const Text('Receive Payment', style: TextStyle(fontSize: 12)),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFA87D26),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _sendWhatsAppReminder(s),
                  icon: const Icon(Icons.chat_outlined, color: Colors.green, size: 18),
                  label: const Text('Send Reminder', style: TextStyle(fontSize: 12, color: Colors.green)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.green),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {}, // placeholder
                  icon: const Icon(Icons.print_outlined, color: Colors.grey, size: 18),
                  label: const Text('Print Receipt', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.grey),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Installment Schedule', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              TextButton(onPressed: () => _tabController.animateTo(2), child: const Text('View All', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold))),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              children: [
                if (installments.isEmpty)
                  const Padding(padding: EdgeInsets.all(20), child: Text('No installments found.'))
                else
                  ...installments.take(3).toList().asMap().entries.map((e) => InstallmentRow(
                    index: e.key + 1,
                    title: e.value['title']?.toString() ?? '',
                    amount: e.value['amount'] ?? 0,
                    status: e.value['status']?.toString() ?? 'Upcoming',
                    dueDate: e.value['dueDate']?.toString(),
                  )),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Payment History', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              TextButton(onPressed: () => _tabController.animateTo(1), child: const Text('View All', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold))),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              children: [
                if (history.isEmpty)
                  const Padding(padding: EdgeInsets.all(20), child: Text('No payment history found.'))
                else
                  ...history.take(3).map((h) => PaymentHistoryRow(
                    date: h['date']?.toString() ?? '',
                    amount: h['amount']?.toString() ?? '0',
                    method: h['method']?.toString() ?? 'Cash',
                    receiptNo: h['receiptNo']?.toString() ?? '',
                  )),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Fee Structure section
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFFE8F0EA), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.account_balance_wallet, color: Color(0xFF2E6656)),
              ),
              title: const Text('Fee Structure', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Total ${installments.length} Components'),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Total Amount', style: TextStyle(fontSize: 10, color: Colors.grey)),
                  Text('₹${overview?['total'] ?? 0}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E6656))),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          // Notes section
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFFF9E6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFFD54F).withValues(alpha: 0.5)),
            ),
            child: ListTile(
              leading: const Icon(Icons.sticky_note_2, color: Color(0xFFA87D26)),
              title: const Text('Notes', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Parent requested to pay next installment by next week.', style: TextStyle(fontSize: 12)),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Future<void> _sendWhatsAppReminder(Map<String, dynamic> s) async {
    try {
      final studentId = s['id'] as int?;
      if (studentId == null) return;
      final result =
          await mgmt.sendFeeReminder(ref.read(apiServiceProvider), studentId);
      final waUrl = result['waUrl']?.toString() ?? '';
      
      if (waUrl.isNotEmpty) {
        final uri = Uri.parse(waUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Could not launch WhatsApp. Copying link instead.')),
            );
            Clipboard.setData(ClipboardData(text: waUrl));
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }
}
