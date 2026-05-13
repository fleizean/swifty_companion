import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/common/bottom_nav_bar.dart';
import '../../widgets/common/network_error_view.dart';
import 'widgets/profile_header.dart';
import 'widgets/stats_scroll_section.dart';
import 'widgets/skills_section.dart';
import 'widgets/projects_section.dart';

/// Profile screen that displays full user profile data.
///
/// Layout (matching design):
/// - Top nav bar: back arrow + more options
/// - Scrollable body: avatar, login, campus, level badge
/// - Stats horizontal scroll
/// - Skills section with gradient bars
/// - Projects section with status badges
/// - Bottom navigation bar
class ProfileScreen extends StatefulWidget {
  final String login;

  const ProfileScreen({super.key, required this.login});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Load profile data after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().loadProfile(widget.login);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: Column(
        children: [
          // Top navigation
          const _ProfileTopNav(),
          // Content
          Expanded(child: _buildBody()),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) context.go('/search');
        },
      ),
    );
  }

  Widget _buildBody() {
    final provider = context.watch<ProfileProvider>();

    // Loading state
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryRed),
      );
    }

    // Error state
    if (provider.error != null) {
      return NetworkErrorView(
        title: 'Error',
        message: provider.error!.message,
        onRetry: () => provider.loadProfile(widget.login),
      );
    }

    // No user
    final user = provider.user;
    if (user == null) {
      return const Center(
        child: Text('User not found', style: TextStyle(color: AppColors.muted)),
      );
    }

    // Profile content
    final coalition = provider.coalition;

    return Stack(
      children: [
        // Background watermark of coalition logo
        if (coalition?.imageUrl != null)
          Positioned(
            top: 0,
            right: -80,
            child: Opacity(
              opacity: 0.05, // Very subtle watermark
              child: coalition!.imageUrl!.endsWith('.svg')
                  ? SvgPicture.network(
                      coalition.imageUrl!,
                      width: 400,
                      height: 400,
                      colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    )
                  : CachedNetworkImage(
                      imageUrl: coalition.imageUrl!,
                      width: 400,
                      height: 400,
                      color: Colors.white,
                    ),
            ),
          ),
        
        // Foreground content
        Positioned.fill(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          // Profile header (centered)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Center(
              child: ProfileHeader(
                user: user,
                coalition: provider.coalition,
              ),
            ),
          ),
          const SizedBox(height: 32),
          // Stats scroll (full width, handles its own padding)
          StatsScrollSection(user: user),
          const SizedBox(height: 32),
          // Skills
          if (user.skills.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SkillsSection(skills: user.skills),
            ),
          if (user.skills.isNotEmpty) const SizedBox(height: 32),
          // Projects
          if (user.projects.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ProjectsSection(user: user),
            ),
        ],
      ),
            ),
          ),
      ],
    );
  }
}

// ── Top Navigation Bar ──────────────────────────────────────────────────────

class _ProfileTopNav extends StatelessWidget {
  const _ProfileTopNav();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1A1A2E).withValues(alpha: 0.9),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Back button
              GestureDetector(
                onTap: () => context.pop(),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              // Right padding to balance the row since more options is removed
              const SizedBox(width: 24),
            ],
          ),
        ),
      ),
    );
  }
}
