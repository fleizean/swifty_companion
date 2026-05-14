import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/user_repository.dart';

class SearchProvider extends ChangeNotifier {
  final UserRepository _userRepository;

  String _query = '';
  List<UserModel> _suggestions = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  AppException? _error;
  Timer? _debounce;

  // ── Recent searches cache ─────────────────────────────────────────────────
  final List<String> _recentSearches = [];
  static const int _maxRecentSearches = 10;

  // ── Memory cache for search results (rate limit optimization) ─────────────
  final Map<String, _CachedResult> _searchCache = {};
  static const Duration _cacheExpiry = Duration(minutes: 5);

  SearchProvider({required UserRepository userRepository})
      : _userRepository = userRepository;

  String get query => _query;
  List<UserModel> get suggestions => _suggestions;
  bool get isLoading => _isLoading;
  bool get hasSearched => _hasSearched;
  AppException? get error => _error;
  bool get hasQuery => _query.isNotEmpty;
  List<String> get recentSearches => List.unmodifiable(_recentSearches);

  void onQueryChanged(String value) {
    _query = value;
    _error = null;
    _debounce?.cancel();

    if (value.length < 3) {
      _suggestions = [];
      _hasSearched = false;
      notifyListeners();
      return;
    }

    _debounce = Timer(AppConstants.searchDebounce, () => _search(value));
    notifyListeners();
  }

  Future<void> _search(String query) async {
    // Check cache first (rate limit optimization)
    final cached = _searchCache[query.toLowerCase()];
    if (cached != null && !cached.isExpired) {
      _suggestions = cached.results;
      _hasSearched = true;
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();
    try {
      _suggestions = await _userRepository.searchUsers(query);
      _hasSearched = true;
      // Store in cache
      _searchCache[query.toLowerCase()] = _CachedResult(
        results: _suggestions,
        cachedAt: DateTime.now(),
      );
    } on AppException catch (e) {
      _error = e;
      _suggestions = [];
      _hasSearched = true;
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Add a login to recent searches when user taps a suggestion.
  void addToRecent(String login) {
    _recentSearches.remove(login); // remove duplicate
    _recentSearches.insert(0, login); // add to front
    if (_recentSearches.length > _maxRecentSearches) {
      _recentSearches.removeLast();
    }
    notifyListeners();
  }

  void removeFromRecent(String login) {
    _recentSearches.remove(login);
    notifyListeners();
  }

  void clearQuery() {
    _query = '';
    _suggestions = [];
    _error = null;
    _hasSearched = false;
    _debounce?.cancel();
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

/// In-memory cache entry for search results.
class _CachedResult {
  final List<UserModel> results;
  final DateTime cachedAt;

  _CachedResult({required this.results, required this.cachedAt});

  bool get isExpired =>
      DateTime.now().difference(cachedAt) > SearchProvider._cacheExpiry;
}
