import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../router/app_router.dart';
import '../../../providers/search_provider.dart';

/// "Recent Searches" section with actual cached searches.
///
/// Displays recently tapped user logins as pill-style chips.
/// Tapping a chip navigates to that user's profile.
class RecentSearchesSection extends StatelessWidget {
  const RecentSearchesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final recentSearches = context.watch<SearchProvider>().recentSearches;

    if (recentSearches.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Searches',
          style: AppTypography.bodySm,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: recentSearches
              .map((login) => _RecentChip(
                    label: login,
                    onTap: () =>
                        context.push('${AppRoutes.profile}/$login'),
                    onRemove: () =>
                        context.read<SearchProvider>().removeFromRecent(login),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

// ── Recent Search Chip ──────────────────────────────────────────────────────

class _RecentChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _RecentChip({
    required this.label,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(left: 16, right: 8, top: 8, bottom: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF16213E),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: AppColors.secondary.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '@$label',
              style: AppTypography.labelCode.copyWith(
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onRemove,
              child: Icon(
                Icons.close,
                size: 14,
                color: AppColors.muted.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
