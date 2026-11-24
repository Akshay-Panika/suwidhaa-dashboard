import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_urls.dart';
import '../model/module_ad_model.dart';

class ModuleAdRepository {
  final Dio _dio = ApiClient.dio;

  // ── GET LIST ──────────────────────────────────
  Future<List<ModuleAdModel>> getAds() async {
    final res = await _dio.get(ApiUrls.moduleAdsList);
    final data = res.data;

    if (data is Map && data['success'] == true) {
      final list = (data['data'] ?? []) as List;
      return list
          .map((e) => ModuleAdModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception(
      (data is Map ? data['message'] : null) ?? 'Failed to load ads',
    );
  }

  // ── GET DETAIL ────────────────────────────────
  Future<ModuleAdModel> getAd(int id) async {
    final res = await _dio.get(ApiUrls.moduleAdsDetail(id));
    return ModuleAdModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  // ── CREATE ────────────────────────────────────
  Future<ModuleAdModel> createAd({
    required String name,
    required Uint8List imageBytes,
    required String imageName,
    String? youtubeVideoUrl,
  }) async {
    final formData = FormData.fromMap({
      'name': name.trim(),
      'image': MultipartFile.fromBytes(
        imageBytes,
        filename: imageName,
      ),
      if (youtubeVideoUrl != null && youtubeVideoUrl.trim().isNotEmpty)
        'youtube_video_url': youtubeVideoUrl.trim(),
    });

    final res = await _dio.post(ApiUrls.moduleAdsCreate, data: formData);
    return ModuleAdModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  // ── UPDATE (PATCH) ────────────────────────────
  Future<ModuleAdModel> updateAd({
    required int id,
    String? name,
    Uint8List? imageBytes,
    String? imageName,
    String? youtubeVideoUrl,
  }) async {
    final map = <String, dynamic>{};

    if (name != null) {
      map['name'] = name.trim();
    }
    if (imageBytes != null && (imageName ?? '').isNotEmpty) {
      map['image'] = MultipartFile.fromBytes(
        imageBytes,
        filename: imageName,
      );
    }
    if (youtubeVideoUrl != null) {
      map['youtube_video_url'] = youtubeVideoUrl.trim();
    }
    if (map.isEmpty) throw Exception('Nothing to update');

    final res = await _dio.patch(
      ApiUrls.moduleAdsDetail(id),
      data: FormData.fromMap(map),
    );
    return ModuleAdModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  // ── DELETE ────────────────────────────────────
  Future<void> deleteAd(int id) async {
    final res = await _dio.delete(ApiUrls.moduleAdsDetail(id));
    if (res.data is Map && res.data['success'] == true) return;
    throw Exception(
      (res.data is Map ? res.data['message'] : null) ?? 'Failed to delete ad',
    );
  }
}