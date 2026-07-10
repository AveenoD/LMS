import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/theme/app_spacing.dart';
import '../../widgets/cards.dart';
import '../../widgets/misc_components.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/fab.dart';

class TeachersListScreen extends StatelessWidget {
  const TeachersListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: const GreenAppBar(title: "Teachers"),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: 8,
        itemBuilder: (context, index) {
          return ListItemRow(
            initials: "T${index + 1}",
            title: "Teacher Name ${index + 1}",
            subtitle: "+91 987654321${index}",
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.redInk),
              onPressed: () {},
            ),
          );
        },
      ),
      floatingActionButton: GoldFAB(
        onPressed: () {},
      ),
    );
  }
}

