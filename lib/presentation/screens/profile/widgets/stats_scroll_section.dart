import 'package:flutter/material.dart';
import '../../../../data/models/user_model.dart';
import 'stat_card.dart';

/// Horizontal scrollable row of stat cards.
///
/// Shows: Wallet, Evals (correction points), Location, Blackhole.
class StatsScrollSection extends StatelessWidget {
  final UserModel user;

  const StatsScrollSection({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.5,
        children: [
          StatCard(
            icon: Icons.account_balance_wallet_outlined,
            value: user.wallet.toString(),
            label: 'Wallet',
          ),
          StatCard(
            icon: Icons.military_tech_outlined,
            value: user.correctionPoints.toString(),
            label: 'Evals',
          ),
          StatCard(
            icon: Icons.desktop_windows_outlined,
            value: user.location ?? 'Offline',
            label: 'Location',
          ),
          StatCard(
            icon: Icons.dark_mode_outlined,
            value: _formatBlackhole(),
            label: 'Blackhole',
          ),
        ],
      ),
    );
  }

  String _formatBlackhole() {
    if (user.blackholedAt == null) return '∞';
    try {
      final bh = DateTime.parse(user.blackholedAt!);
      final remaining = bh.difference(DateTime.now()).inDays;
      return remaining > 0 ? '${remaining}d' : 'Absorbed';
    } catch (_) {
      return 'N/A';
    }
  }
}
