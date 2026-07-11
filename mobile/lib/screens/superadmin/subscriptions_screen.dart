import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/superadmin_providers.dart';

/// Super Admin's "Subscriptions" tab. `SubscriptionListItem`:
/// {tenantId, name, status, plan, amount, trialEndsAt, nextBillingDate}.
/// Toggling "Expiring soon" switches to `GET /subscriptions/expiring?days=`.
class SubscriptionsScreen extends ConsumerStatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  ConsumerState<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends ConsumerState<SubscriptionsScreen> {
  bool _expiringOnly = false;
  int _days = 3;

  @override
  Widget build(BuildContext context) {
    final listAsync = _expiringOnly
        ? ref.watch(expiringSubscriptionsProvider(_days))
        : ref.watch(subscriptionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscriptions'),
              ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Expiring soon only'),
                    value: _expiringOnly,
                    onChanged: (v) => setState(() => _expiringOnly = v),
                  ),
                ),
                if (_expiringOnly)
                  SizedBox(
                    width: 90,
                    child: TextFormField(
                      initialValue: _days.toString(),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Days', border: OutlineInputBorder()),
                      onFieldSubmitted: (v) => setState(() => _days = int.tryParse(v) ?? _days),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: listAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (subs) {
                if (subs.isEmpty) {
                  return const Center(child: Text('No subscriptions found.'));
                }
                return RefreshIndicator(
                  onRefresh: () async => _expiringOnly
                      ? ref.invalidate(expiringSubscriptionsProvider(_days))
                      : ref.invalidate(subscriptionsProvider),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: subs.length,
                    itemBuilder: (context, index) {
                      final sub = subs[index] as Map<String, dynamic>;
                      final trialEndsAt = sub['trialEndsAt']?.toString();
                      final nextBillingDate = sub['nextBillingDate']?.toString();
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(sub['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            [
                              if (sub['plan'] != null) 'Plan: ${sub['plan']}',
                              if (sub['amount'] != null) '₹${sub['amount']}',
                              if (trialEndsAt != null) 'Trial ends: ${trialEndsAt.split('T').first}',
                              if (nextBillingDate != null) 'Next bill: ${nextBillingDate.split('T').first}',
                            ].join('\n'),
                          ),
                          isThreeLine: true,
                          trailing: Text(
                            sub['status']?.toString() ?? '',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
