import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../providers/search_provider.dart';

/// Pill-shaped search input field with icon prefix.
///
/// Uses the design system's Level-1 background (#16213E),
/// focus border becomes lavender (secondary color).
class SearchInput extends StatefulWidget {
  const SearchInput({super.key});

  @override
  State<SearchInput> createState() => _SearchInputState();
}

class _SearchInputState extends State<SearchInput> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    // Initialize controller with current query if any
    _controller = TextEditingController(
      text: context.read<SearchProvider>().query,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<SearchProvider>();

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(999),
      ),
      child: TextField(
        controller: _controller,
        onChanged: provider.onQueryChanged,
        style: AppTypography.bodyLg,
        decoration: InputDecoration(
          hintText: 'Search users...',
          hintStyle: AppTypography.bodyLg.copyWith(color: AppColors.muted),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 16, right: 8),
            child: Icon(
              Icons.search,
              color: AppColors.primaryRed,
              size: 22,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 40,
            minHeight: 40,
          ),
          suffixIcon: context.watch<SearchProvider>().hasQuery
              ? IconButton(
                  icon: const Icon(Icons.close, color: AppColors.muted, size: 20),
                  onPressed: () {
                    _controller.clear();
                    provider.clearQuery();
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(999),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(999),
            borderSide: const BorderSide(
              color: AppColors.secondary,
              width: 1,
            ),
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}
