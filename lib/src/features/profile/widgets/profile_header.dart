import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/svg.dart';
import 'package:peer42/src/features/profile/widgets/profile_stats.dart';
import '../../../core/models/user_model.dart';
import '../../../core/models/coalition_model.dart';

class FuturisticProfileHeader extends StatelessWidget {
  final UserModel user;
  final CoalitionModel? coalition;
  final VoidCallback? onCoalitionTap;

  const FuturisticProfileHeader({
    super.key,
    required this.user,
    this.coalition,
    this.onCoalitionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildProfileImage(),
          const SizedBox(height: 24),
          _buildUserInfo(),
          const SizedBox(height: 16),
          _buildLevelProgress(),
          const SizedBox(height: 16),
          _buildStatsRow(),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    return Stack(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF00d4ff),
                Color(0xFF7209b7),
                Color(0xFFff006e),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00d4ff).withOpacity(0.4),
                blurRadius: 30,
                spreadRadius: 2,
              ),
            ],
          ),
          padding: const EdgeInsets.all(4),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: CachedNetworkImage(
              imageUrl: user.imageUrl ?? '',
              width: 112,
              height: 112,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.transparent,
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 60,
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.transparent,
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 60,
                ),
              ),
            ),
          ),
        ),
        if (coalition != null)
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: onCoalitionTap,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getCoalitionColor(),
                  border: Border.all(
                    color: Colors.white,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _getCoalitionColor().withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: _buildCoalitionImage(coalition!.imageUrl),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCoalitionImage(String imageUrl) {
  if (imageUrl.toLowerCase().endsWith('.svg')) {
    // Handle SVG
    return SvgPicture.network(
      imageUrl,
      fit: BoxFit.cover,
      placeholderBuilder: (context) => Container(
        color: Colors.transparent,
        child: const Icon(
          Icons.shield,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  } else {
    // Handle regular images  
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: Colors.transparent,
        child: const Icon(
          Icons.shield,
          color: Colors.white,
          size: 20,
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.transparent,
        child: const Icon(
          Icons.shield,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}


  Widget _buildUserInfo() {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF00d4ff), Color(0xFF7209b7)],
          ).createShader(bounds),
          child: Text(
            user.displayName,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '@${user.login}',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        if (coalition != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: _getCoalitionColor().withOpacity(0.2),
              border: Border.all(
                color: _getCoalitionColor(),
                width: 1,
              ),
            ),
            child: Text(
              coalition!.name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _getCoalitionColor(),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCoalitionBadge() {
    if (coalition == null) return SizedBox();
    
    return GestureDetector(
      onTap: onCoalitionTap,
      child: Container(
        // Your existing container styling
        child: Image.network(
          coalition!.imageUrl,
          // Your existing image styling
        ),
      ),
    );
  }

  Widget _buildLevelProgress() {
    final progress = user.levelProgress;
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Level ${user.level.floor()}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: Colors.white.withOpacity(0.1),
          ),
          child: Stack(
            children: [
              FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    gradient: LinearGradient(
                      colors: coalition != null
                          ? [
                              _getCoalitionColor(),
                              _getCoalitionColor().withOpacity(0.7),
                            ]
                          : const [
                              Color(0xFF00d4ff),
                              Color(0xFF7209b7),
                              Color(0xFFff006e),
                            ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: FuturisticStatCard(
            title: 'Wallet',
            value: '${user.wallet}₳',
            icon: Icons.account_balance_wallet,
            gradientColors: const [Color(0xFF00d4ff), Color(0xFF0099cc)],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FuturisticStatCard(
            title: 'Evaluation',
            value: '${user.correctionPoint}',
            icon: Icons.star,
            gradientColors: const [Color(0xFF7209b7), Color(0xFF5a0a8a)],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FuturisticStatCard(
            title: 'Level',
            value: user.level.toStringAsFixed(1),
            icon: Icons.trending_up,
            gradientColors: const [Color(0xFFff006e), Color(0xFFcc0055)],
          ),
        ),
      ],
    );
  }

  Color _getCoalitionColor() {
    if (coalition?.color != null) {
      return Color(int.parse('0xFF${coalition!.color.replaceAll('#', '')}'));
    }
    return const Color(0xFF00d4ff);
  }
}