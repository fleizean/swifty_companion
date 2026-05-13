import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../data/models/user_model.dart';
import '../../../../router/app_router.dart';
import '../../../providers/search_provider.dart';

/// Dropdown-style list of search suggestions.
///
/// Each item shows: avatar, login, full name, and an optional tag chip.
class SearchSuggestionsList extends StatelessWidget {
  final List<UserModel> suggestions;

  const SearchSuggestionsList({
    super.key,
    required this.suggestions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F3460),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 12,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: ListView.separated(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: suggestions.length,
          separatorBuilder: (_, _) => Divider(
            height: 1,
            color: Colors.white.withValues(alpha: 0.05),
          ),
          itemBuilder: (context, index) => _SuggestionTile(
            user: suggestions[index],
          ),
        ),
      ),
    );
  }
}

// ── Single Suggestion Tile ──────────────────────────────────────────────────

class _SuggestionTile extends StatelessWidget {
  final UserModel user;
  const _SuggestionTile({required this.user});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.read<SearchProvider>().addToRecent(user.login);
        context.push('${AppRoutes.profile}/${user.login}');
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Avatar
            _UserAvatar(imageUrl: user.imageUrl),
            const SizedBox(width: 12),
            // Login + display name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.login,
                    style: AppTypography.bodyLg.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (user.displayName != null)
                    Text(
                      user.displayName!,
                      style: AppTypography.bodySm,
                    ),
                ],
              ),
            ),
            // Campus tag chip
            if (user.campus != null) _TagChip(label: user.campus!),
          ],
        ),
      ),
    );
  }
}

// ── User Avatar ─────────────────────────────────────────────────────────────

class _UserAvatar extends StatelessWidget {
  final String? imageUrl;
  const _UserAvatar({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Container(
        width: 40,
        height: 40,
        color: AppColors.surfaceContainerHighest,
        child: imageUrl != null
            ? CachedNetworkImage(
                imageUrl: imageUrl!,
                fit: BoxFit.cover,
                placeholder: (_, _) => const Center(
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: AppColors.primaryRed,
                    ),
                  ),
                ),
                errorWidget: (_, _, _) => const Icon(
                  Icons.person,
                  color: AppColors.muted,
                  size: 20,
                ),
              )
            : const Icon(
                Icons.person,
                color: AppColors.muted,
                size: 20,
              ),
      ),
    );
  }
}

// ── Tag Chip ────────────────────────────────────────────────────────────────

class _TagChip extends StatelessWidget {
  final String label;
  const _TagChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        label,
        style: AppTypography.labelCode.copyWith(
          color: AppColors.secondary,
        ),
      ),
    );
  }
}
