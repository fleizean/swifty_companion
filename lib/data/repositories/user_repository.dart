import '../../core/constants/app_constants.dart';
import '../../core/errors/app_exception.dart';
import '../models/coalition_model.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import 'package:dio/dio.dart';

class UserRepository {
  final ApiService _apiService;

  UserRepository({required ApiService apiService}) : _apiService = apiService;

  Future<UserModel> getUser(String login) async {
    try {
      final response = await _apiService.dio.get('/users/$login');
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.error is AppException
          ? e.error as AppException
          : const ServerException();
    }
  }

  Future<List<CoalitionModel>> getCoalitions(int userId) async {
    try {
      await Future.delayed(AppConstants.requestDelay);
      final response = await _apiService.dio.get('/users/$userId/coalitions');
      return (response.data as List)
          .cast<Map<String, dynamic>>()
          .map(CoalitionModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw e.error is AppException
          ? e.error as AppException
          : const ServerException();
    }
  }

  Future<List<UserModel>> searchUsers(String query) async {
    try {
      final response = await _apiService.dio.get(
        '/users',
        queryParameters: {
          'search[login]': query,
          'per_page': AppConstants.searchPageSize,
        },
      );
      return (response.data as List)
          .cast<Map<String, dynamic>>()
          .map(UserModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw e.error is AppException
          ? e.error as AppException
          : const ServerException();
    }
  }
}
