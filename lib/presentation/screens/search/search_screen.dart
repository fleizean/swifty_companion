import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../router/app_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/search_provider.dart';
import '../../widgets/common/bottom_nav_bar.dart';
import 'widgets/search_app_bar.dart';
import 'widgets/search_input.dart';
import 'widgets/search_suggestions_list.dart';
import 'widgets/recent_searches_section.dart';
import 'widgets/search_empty_state.dart';
import 'widgets/search_not_found.dart';

/// Main search screen composing all search sub-widgets.
///
/// Layout (matching design):
/// - Fixed top app bar with logo + "Peer42" + logout icon
/// - Search input (pill-shaped)
/// - Recent Searches chips (when no active query)
/// - Search suggestions list (when typing)
/// - Empty state illustration (no results)
/// - Bottom navigation bar (Explore + Profile)
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      body: const Column(
        children: [
          SearchAppBar(),
          Expanded(child: _SearchBody()),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 0,
        onTap: (index) => _onNavTap(context, index),
      ),
    );
  }

  void _onNavTap(BuildContext context, int index) {
    if (index == 1) {
      // Profile tab → navigate to own profile
      final login = context.read<AuthProvider>().userLogin;
      if (login != null) {
        context.push('${AppRoutes.profile}/$login');
      }
    }
  }
}

// ── Search Body (input + content area) ──────────────────────────────────────

class _SearchBody extends StatelessWidget {
  const _SearchBody();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SearchProvider>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          // Search input
          const SearchInput(),
          const SizedBox(height: 24),
          // Content area
          Expanded(child: _buildContent(provider)),
        ],
      ),
    );
  }

  Widget _buildContent(SearchProvider provider) {
    // Show suggestions when we have them
    if (provider.suggestions.isNotEmpty) {
      return SearchSuggestionsList(suggestions: provider.suggestions);
    }

    // Show loading
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryRed),
      );
    }

    // Show error
    if (provider.error != null) {
      return Center(
        child: Text(
          provider.error!.message,
          style: const TextStyle(color: AppColors.error),
          textAlign: TextAlign.center,
        ),
      );
    }

    // Search was performed but returned no results
    if (provider.hasSearched && provider.suggestions.isEmpty) {
      return SearchNotFound(query: provider.query);
    }

    // Default: recent searches + empty state
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RecentSearchesSection(),
        Expanded(child: SearchEmptyState()),
      ],
    );
  }
}
