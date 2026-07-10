import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_shadows.dart';
import '../../widgets/misc_components.dart';
import '../../widgets/app_bar.dart';

class PaymentReceiptScreen extends StatelessWidget {
  final String paymentId;

  const PaymentReceiptScreen({Key? key, required this.paymentId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: GreenAppBar(
        title: "Payment Receipt",
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [AppShadows.elevatedShadow],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.school, color: AppColors.inkGreen),
                    const SizedBox(width: 12),
                    Text("Excel Academy", style: AppText.displaySm.copyWith(color: AppColors.inkGreen, fontSize: 18)),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Divider(color: AppColors.divider, height: 1),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: AppColors.chalkTeal10,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle_outline, color: AppColors.chalkTeal, size: 48),
                ),
                const SizedBox(height: 12),
                Text("Payment Successful", style: AppText.displaySm.copyWith(color: AppColors.chalkTeal, fontSize: 22)),
                const SizedBox(height: 24),
                const CalcRow(label: "Receipt No", value: "REC-2024-001"),
                const CalcRow(label: "Student", value: "Rahul Sharma"),
                const CalcRow(label: "Date", value: "12 Aug 2024, 10:30 AM"),
                const CalcRow(label: "Method", value: "UPI"),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Divider(color: AppColors.divider, height: 1),
                ),
                const CalcRow(
                  label: "Amount Paid",
                  value: "₹5,000",
                  isBold: true,
                  color: AppColors.inkGreen,
                  fontSize: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

