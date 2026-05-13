import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../data/models/user_model.dart';
import '../../../../data/models/coalition_model.dart';

/// Profile header section: avatar with gradient border ring,
/// login name, campus + coalition, and gradient level badge.
class ProfileHeader extends StatelessWidget {
  final UserModel user;
  final CoalitionModel? coalition;

  const ProfileHeader({
    super.key,
    required this.user,
    this.coalition,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Avatar with gradient border
        _GradientAvatar(imageUrl: user.imageUrl),
        const SizedBox(height: 24),
        // Login name
        Text(
          user.login,
          style: AppTypography.headlineLg.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 4),
        // Campus + coalition
        Text(
          _buildSubtitle(),
          style: AppTypography.bodyLg.copyWith(
            color: const Color(0xFF8E97FD),
          ),
        ),
        const SizedBox(height: 16),
        // Level badge
        _LevelBadge(level: user.level),
      ],
    );
  }

  String _buildSubtitle() {
    final parts = <String>[];
    if (user.campus != null) parts.add('42 ${user.campus!}');
    if (coalition != null) parts.add(coalition!.name);
    return parts.join(' • ');
  }
}

// ── Gradient Avatar ─────────────────────────────────────────────────────────

class _GradientAvatar extends StatelessWidget {
  final String? imageUrl;
  const _GradientAvatar({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 132,
      height: 132,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Gradient ring
          Container(
            width: 132,
            height: 132,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  AppColors.primaryRed,
                  AppColors.secondary,
                ],
              ),
            ),
          ),
          // Inner dark ring (gap)
          Container(
            width: 126,
            height: 126,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF1A1A2E),
            ),
          ),
          // Actual avatar
          ClipOval(
            child: SizedBox(
              width: 120,
              height: 120,
              child: imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => Container(
                        color: AppColors.surfaceContainerHighest,
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primaryRed,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                      errorWidget: (_, _, _) => Container(
                        color: AppColors.surfaceContainerHighest,
                        child: const Icon(
                          Icons.person,
                          size: 48,
                          color: AppColors.muted,
                        ),
                      ),
                    )
                  : Container(
                      color: AppColors.surfaceContainerHighest,
                      child: const Icon(
                        Icons.person,
                        size: 48,
                        color: AppColors.muted,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Level Badge ─────────────────────────────────────────────────────────────

class _LevelBadge extends StatelessWidget {
  final double level;
  const _LevelBadge({required this.level});

  @override
  Widget build(BuildContext context) {
    // 42 network level cap is roughly around 21 for students.
    final progress = (level / 21).clamp(0.0, 1.0);

    return SizedBox(
      width: 240,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Level ${level.toStringAsFixed(2)}',
                style: AppTypography.labelCode.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: AppTypography.labelCode.copyWith(
                  color: AppColors.primaryRed,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 12,
            decoration: BoxDecoration(
              color: const Color(0xFF16213E).withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Stack(
              children: [
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryRed.withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
