import 'package:flutter/foundation.dart';
import '../../core/errors/app_exception.dart';
import '../../data/models/coalition_model.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/user_repository.dart';

class ProfileProvider extends ChangeNotifier {
  final UserRepository _userRepository;

  UserModel? _user;
  CoalitionModel? _coalition;
  bool _isLoading = false;
  AppException? _error;

  ProfileProvider({required UserRepository userRepository})
      : _userRepository = userRepository;

  UserModel? get user => _user;
  CoalitionModel? get coalition => _coalition;
  bool get isLoading => _isLoading;
  AppException? get error => _error;

  Future<void> loadProfile(String login) async {
    _isLoading = true;
    _error = null;
    _user = null;
    _coalition = null;
    notifyListeners();

    try {
      _user = await _userRepository.getUser(login);
      final coalitions = await _userRepository.getCoalitions(_user!.id);
      _coalition = coalitions.firstOrNull;
    } on AppException catch (e) {
      _error = e;
    }

    _isLoading = false;
    notifyListeners();
  }

  void reset() {
    _user = null;
    _coalition = null;
    _error = null;
    _isLoading = false;
  }
}
