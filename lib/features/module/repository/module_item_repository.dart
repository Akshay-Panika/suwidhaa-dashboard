import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_urls.dart';
import '../model/module_item_model.dart';

class ModuleItemRepository {
  final Dio _dio;

  ModuleItemRepository({Dio? dio}) : _dio = dio ?? ApiClient.dio;

  Future<List<ModuleItemModel>> fetchModules() async {
    final response = await _dio.get(ApiUrls.moduleList);
    final rawData = response.data;

    List<dynamic> list = const [];
    if (rawData is Map<String, dynamic> && rawData['data'] is List) {
      list = rawData['data'] as List<dynamic>;
    } else if (rawData is List) {
      list = rawData;
    }

    return list
        .whereType()
        .map((e) => ModuleItemModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<ModuleItemModel?> getModuleDetail(int id) async {
    final response = await _dio.get(ApiUrls.moduleDetail(id));
    final rawData = response.data;

    Map<String, dynamic>? itemMap;
    if (rawData is Map<String, dynamic>) {
      if (rawData['data'] is Map) {
        itemMap = Map<String, dynamic>.from(rawData['data'] as Map);
      } else {
        itemMap = rawData;
      }
    }

    if (itemMap == null) return null;
    return ModuleItemModel.fromJson(itemMap);
  }

  Future<ModuleItemModel?> createModule({
    required String name,
    File? imageFile,
    Uint8List? imageBytes,
    String fileName = 'module.png',
  }) async {
    final Map<String, dynamic> fields = {'name': name};

    if (imageBytes != null) {
      fields['image'] = MultipartFile.fromBytes(
        imageBytes,
        filename: fileName,
      );
    } else if (imageFile != null) {
      fields['image'] = await MultipartFile.fromFile(
        imageFile.path,
        filename: fileName,
      );
    }

    final formData = FormData.fromMap(fields);
    final response = await _dio.post(
      ApiUrls.moduleCreate,
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );

    return _parseModuleResponse(response.data);
  }

  Future<ModuleItemModel?> updateModule({
    required int id,
    required String name,
    File? imageFile,
    Uint8List? imageBytes,
    String fileName = 'module.png',
    bool usePatch = true,
  }) async {
    final Map<String, dynamic> fields = {'name': name};

    if (imageBytes != null) {
      fields['image'] = MultipartFile.fromBytes(
        imageBytes,
        filename: fileName,
      );
    } else if (imageFile != null) {
      fields['image'] = await MultipartFile.fromFile(
        imageFile.path,
        filename: fileName,
      );
    }

    final formData = FormData.fromMap(fields);
    final options = Options(contentType: 'multipart/form-data');

    final response = usePatch
        ? await _dio.patch(ApiUrls.moduleDetail(id), data: formData, options: options)
        : await _dio.put(ApiUrls.moduleDetail(id), data: formData, options: options);

    return _parseModuleResponse(response.data);
  }

  Future<bool> deleteModule(int id) async {
    final response = await _dio.delete(ApiUrls.moduleDetail(id));
    final rawData = response.data;
    if (rawData is Map<String, dynamic> && rawData['success'] == false) {
      return false;
    }
    return true;
  }

  ModuleItemModel? _parseModuleResponse(dynamic rawData) {
    if (rawData is Map<String, dynamic>) {
      if (rawData['data'] is Map) {
        return ModuleItemModel.fromJson(
          Map<String, dynamic>.from(rawData['data'] as Map),
        );
      }
      if (rawData['id'] != null) {
        return ModuleItemModel.fromJson(rawData);
      }
    }
    return null;
  }
}