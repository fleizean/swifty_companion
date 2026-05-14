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
/// Features glassmorphism container, staggered fade-in animations,
/// and smooth hover/press effects.
class SearchSuggestionsList extends StatefulWidget {
  final List<UserModel> suggestions;

  const SearchSuggestionsList({
    super.key,
    required this.suggestions,
  });

  @override
  State<SearchSuggestionsList> createState() => _SearchSuggestionsListState();
}

class _SearchSuggestionsListState extends State<SearchSuggestionsList>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
  }

  @override
  void didUpdateWidget(covariant SearchSuggestionsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.suggestions != widget.suggestions) {
      _animController.reset();
      _animController.forward();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOut,
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.03),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _animController,
          curve: Curves.easeOut,
        )),
        child: Container(
          decoration: BoxDecoration(
            // Glassmorphism-inspired dark container
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1A1F3D),
                Color(0xFF151930),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.secondary.withValues(alpha: 0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: AppColors.primaryRed.withValues(alpha: 0.04),
                blurRadius: 40,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Results header
                _ResultsHeader(count: widget.suggestions.length),
                // List
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.only(bottom: 8),
                    itemCount: widget.suggestions.length,
                    itemBuilder: (context, index) => _SuggestionTile(
                      user: widget.suggestions[index],
                      index: index,
                      total: widget.suggestions.length,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Results Header ──────────────────────────────────────────────────────────

class _ResultsHeader extends StatelessWidget {
  final int count;
  const _ResultsHeader({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.secondary.withValues(alpha: 0.08),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryRed,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '$count result${count != 1 ? 's' : ''} found',
            style: AppTypography.bodySm.copyWith(
              color: AppColors.muted.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Single Suggestion Tile ──────────────────────────────────────────────────

class _SuggestionTile extends StatefulWidget {
  final UserModel user;
  final int index;
  final int total;
  const _SuggestionTile({
    required this.user,
    required this.index,
    required this.total,
  });

  @override
  State<_SuggestionTile> createState() => _SuggestionTileState();
}

class _SuggestionTileState extends State<_SuggestionTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        context.read<SearchProvider>().addToRecent(widget.user.login);
        context.push('${AppRoutes.profile}/${widget.user.login}');
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _isPressed
              ? AppColors.primaryRed.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            // Avatar with ring
            _UserAvatar(imageUrl: widget.user.imageUrl),
            const SizedBox(width: 14),
            // Login + display name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.user.login,
                    style: AppTypography.bodyLg.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (widget.user.displayName != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      widget.user.displayName!,
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.muted.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Campus tag chip
            if (widget.user.campus != null) _TagChip(label: widget.user.campus!),
            const SizedBox(width: 8),
            // Arrow indicator
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppColors.muted.withValues(alpha: 0.3),
            ),
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
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryRed.withValues(alpha: 0.6),
            AppColors.secondary.withValues(alpha: 0.4),
          ],
        ),
      ),
      child: ClipOval(
        child: Container(
          width: 44,
          height: 44,
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
                    size: 22,
                  ),
                )
              : const Icon(
                  Icons.person,
                  color: AppColors.muted,
                  size: 22,
                ),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.secondaryContainer.withValues(alpha: 0.4),
            AppColors.secondaryContainer.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: 0.25),
        ),
      ),
      child: Text(
        label,
        style: AppTypography.labelCode.copyWith(
          color: AppColors.secondary,
          fontSize: 11,
        ),
      ),
    );
  }
}
