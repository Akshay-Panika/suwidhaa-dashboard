import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_urls.dart';
import '../model/module_banner_model.dart';

class ModuleBannerRepository {
  Future<List<ModuleBannerModel>> getBanners() async {
    try {
      final response = await ApiClient.dio.get(ApiUrls.moduleBannerList);
      final body = response.data;

      if (body is Map<String, dynamic> && body['success'] == true) {
        final rawList = body['data'] as List<dynamic>? ?? <dynamic>[];
        return rawList
            .where((item) => item is Map<String, dynamic>)
            .map((item) => ModuleBannerModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      throw Exception(
        (body is Map ? body['message']?.toString() : null) ??
            'Failed to load module banners',
      );
    } on DioException catch (e) {
      throw Exception(_extractDioError(e, 'Failed to fetch banners'));
    }
  }

  Future<ModuleBannerModel> getBannerDetail(int id) async {
    try {
      final response = await ApiClient.dio.get(ApiUrls.moduleBannerDetail(id));
      final body = response.data;

      if (body is Map<String, dynamic> &&
          body['success'] == true &&
          body['data'] is Map<String, dynamic>) {
        return ModuleBannerModel.fromJson(
          body['data'] as Map<String, dynamic>,
        );
      }

      throw Exception(
        (body is Map ? body['message']?.toString() : null) ??
            'Banner not found',
      );
    } on DioException catch (e) {
      throw Exception(_extractDioError(e, 'Failed to fetch banner detail'));
    }
  }

  Future<ModuleBannerModel> createBanner({
    required String name,
    String? youtubeVideoUrl,
    File? imageFile,
    Uint8List? imageBytes,
    String fileName = 'banner.png',
  }) async {
    try {
      final multipartFile = await _buildMultipartFile(
        imageFile: imageFile,
        imageBytes: imageBytes,
        fileName: fileName,
      );
      if (multipartFile == null) {
        throw Exception('Image file is required');
      }

      final Map<String, dynamic> fields = {
        'name': name.trim(),
        'image': multipartFile,
      };
      if (youtubeVideoUrl != null) {
        fields['youtube_video_url'] = youtubeVideoUrl.trim();
      }

      final formData = FormData.fromMap(fields);

      final response = await ApiClient.dio.post(
        ApiUrls.moduleBannerCreate,
        data: formData,
      );
      final body = response.data;

      if (response.statusCode == 201 ||
          (body is Map<String, dynamic> && body['success'] == true)) {
        if (body is Map<String, dynamic> &&
            body['data'] is Map<String, dynamic>) {
          return ModuleBannerModel.fromJson(
            body['data'] as Map<String, dynamic>,
          );
        }
        throw Exception('Created, but banner data missing in response');
      }

      throw Exception(_extractValidationOrMessage(body, 'Create failed'));
    } on DioException catch (e) {
      throw Exception(_extractDioError(e, 'Failed to create banner'));
    }
  }

  Future<ModuleBannerModel> updateBanner({
    required int id,
    required String name,
    String? youtubeVideoUrl,
    File? imageFile,
    Uint8List? imageBytes,
    String fileName = 'banner.png',
    bool usePatch = true,
  }) async {
    try {
      final multipartFile = await _buildMultipartFile(
        imageFile: imageFile,
        imageBytes: imageBytes,
        fileName: fileName,
      );

      final Map<String, dynamic> fields = {
        'name': name.trim(),
        'youtube_video_url': (youtubeVideoUrl ?? '').trim(),
      };
      if (multipartFile != null) {
        fields['image'] = multipartFile;
      }

      final formData = FormData.fromMap(fields);
      final endpoint = ApiUrls.moduleBannerDetail(id);

      final response = usePatch
          ? await ApiClient.dio.patch(endpoint, data: formData)
          : await ApiClient.dio.put(endpoint, data: formData);

      final body = response.data;
      if (response.statusCode == 200 ||
          (body is Map<String, dynamic> && body['success'] == true)) {
        if (body is Map<String, dynamic> &&
            body['data'] is Map<String, dynamic>) {
          return ModuleBannerModel.fromJson(
            body['data'] as Map<String, dynamic>,
          );
        }
        throw Exception('Updated, but banner data missing in response');
      }

      throw Exception(_extractValidationOrMessage(body, 'Update failed'));
    } on DioException catch (e) {
      throw Exception(_extractDioError(e, 'Failed to update banner'));
    }
  }

  Future<void> deleteBanner(int id) async {
    try {
      final response =
      await ApiClient.dio.delete(ApiUrls.moduleBannerDetail(id));
      final body = response.data;

      if (response.statusCode == 200 ||
          response.statusCode == 204 ||
          (body is Map<String, dynamic> && body['success'] == true)) {
        return;
      }

      throw Exception(
        (body is Map ? body['message']?.toString() : null) ?? 'Delete failed',
      );
    } on DioException catch (e) {
      throw Exception(_extractDioError(e, 'Failed to delete banner'));
    }
  }

  Future<MultipartFile?> _buildMultipartFile({
    File? imageFile,
    Uint8List? imageBytes,
    required String fileName,
  }) async {
    if (imageFile != null) {
      return MultipartFile.fromFile(imageFile.path, filename: fileName);
    }
    if (imageBytes != null && imageBytes.isNotEmpty) {
      return MultipartFile.fromBytes(imageBytes, filename: fileName);
    }
    return null;
  }

  String _extractDioError(DioException e, String fallback) {
    final data = e.response?.data;
    if (data != null) {
      return _extractValidationOrMessage(data, fallback);
    }
    return e.message ?? fallback;
  }

  String _extractValidationOrMessage(dynamic body, String fallback) {
    if (body is Map<String, dynamic>) {
      if (body['errors'] is Map) {
        final errors = body['errors'] as Map;
        final parts = <String>[];
        errors.forEach((k, v) => parts.add('$k: $v'));
        if (parts.isNotEmpty) return parts.join(' | ');
      }
      if (body['message'] != null) {
        return body['message'].toString();
      }
    }
    return fallback;
  }

  String cleanError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }
}