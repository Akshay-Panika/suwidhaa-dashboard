import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_urls.dart';
import '../../../core/widget/flutter_toast.dart';
import '../model/recent_user_model.dart';

class RecentUsersController extends GetxController {
  final Dio _dio = ApiClient.dio;

  final RxList<RecentUserModel> users = <RecentUserModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchRecentUsers();
  }

  Future<void> fetchRecentUsers({bool showErrorToast = true}) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _dio.get(ApiUrls.profileList);
      final body = response.data;

      if (body is Map<String, dynamic>) {
        if (body['success'] == false) {
          throw Exception(body['message']?.toString() ?? 'Failed to load users');
        }

        final rawList = body['data'];
        if (rawList is List) {
          final List<RecentUserModel> parsed = [];
          for (final item in rawList) {
            if (item is Map<String, dynamic>) {
              parsed.add(RecentUserModel.fromJson(item));
            }
          }
          users.assignAll(parsed);
          return;
        }
      }

      users.clear();
    } on DioException catch (e) {
      final msg = _extractDioError(e);
      errorMessage.value = msg;
      if (showErrorToast) {
        FlutterToast.error(msg);
      }
    } catch (e) {
      const msg = 'Unable to load recent users';
      errorMessage.value = msg;
      if (showErrorToast) {
        FlutterToast.error(msg);
      }
    } finally {
      isLoading.value = false;
    }
  }

  String _extractDioError(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic> && data['message'] != null) {
      return data['message'].toString();
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Request timed out. Please try again.';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'No internet connection.';
    }
    return e.message ?? 'Network error occurred';
  }
}