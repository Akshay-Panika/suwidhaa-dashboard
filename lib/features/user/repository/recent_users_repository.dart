import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_urls.dart';
import '../model/recent_user_model.dart';

class RecentUsersRepository {
  final Dio _dio;

  RecentUsersRepository({Dio? dio}) : _dio = dio ?? ApiClient.dio;

  Future<List<RecentUserModel>> fetchRecentUsers() async {
    final response = await _dio.get(ApiUrls.profileList);
    final body = response.data;

    if (body is Map<String, dynamic>) {
      if (body['success'] == false) {
        throw Exception(body['message']?.toString() ?? 'Failed to load users');
      }

      final rawList = body['data'];
      if (rawList is List) {
        final List<RecentUserModel> result = [];
        for (final item in rawList) {
          if (item is Map<String, dynamic>) {
            result.add(RecentUserModel.fromJson(item));
          }
        }
        return result;
      }
    }

    return [];
  }
}