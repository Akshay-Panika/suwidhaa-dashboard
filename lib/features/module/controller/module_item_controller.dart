import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../../core/widget/flutter_toast.dart';
import '../model/module_item_model.dart';
import '../repository/module_item_repository.dart';

class ModuleItemController extends GetxController {
  final ModuleItemRepository _repository;

  ModuleItemController({ModuleItemRepository? repository})
      : _repository = repository ?? ModuleItemRepository();

  final RxList<ModuleItemModel> modules = <ModuleItemModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchModules();
  }

  Future<void> fetchModules({bool showToastOnError = false}) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final list = await _repository.fetchModules();
      modules.assignAll(list);
    } on DioException catch (e) {
      final msg = _extractErrorMessage(e, 'Failed to load modules.');
      errorMessage.value = msg;
      if (showToastOnError) {
        FlutterToast.error(msg);
      }
    } catch (_) {
      const msg = 'Something went wrong while loading modules.';
      errorMessage.value = msg;
      if (showToastOnError) {
        FlutterToast.error(msg);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<ModuleItemModel?> getModuleDetail(int id) async {
    try {
      final detail = await _repository.getModuleDetail(id);
      if (detail == null) return null;

      final idx = modules.indexWhere((m) => m.id == id);
      if (idx != -1) {
        modules[idx] = detail;
        modules.refresh();
      }
      return detail;
    } on DioException catch (e) {
      final msg = _extractErrorMessage(e, 'Failed to load module detail.');
      FlutterToast.error(msg);
      return null;
    } catch (_) {
      FlutterToast.error('Failed to load module detail.');
      return null;
    }
  }

  Future<ModuleItemModel?> createModule({
    required String name,
    File? imageFile,
    Uint8List? imageBytes,
    String fileName = 'module.png',
  }) async {
    isSubmitting.value = true;
    try {
      final created = await _repository.createModule(
        name: name,
        imageFile: imageFile,
        imageBytes: imageBytes,
        fileName: fileName,
      );
      if (created != null) {
        modules.insert(0, created);
        modules.refresh();
      } else {
        await fetchModules();
      }
      FlutterToast.success('Module created.');
      return created;
    } on DioException catch (e) {
      final msg = _extractErrorMessage(e, 'Failed to create module.');
      FlutterToast.error(msg);
      return null;
    } catch (_) {
      FlutterToast.error('Something went wrong while creating module.');
      return null;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<ModuleItemModel?> updateModule({
    required int id,
    required String name,
    File? imageFile,
    Uint8List? imageBytes,
    String fileName = 'module.png',
    bool usePatch = true,
  }) async {
    isSubmitting.value = true;
    try {
      final updated = await _repository.updateModule(
        id: id,
        name: name,
        imageFile: imageFile,
        imageBytes: imageBytes,
        fileName: fileName,
        usePatch: usePatch,
      );
      if (updated != null) {
        final idx = modules.indexWhere((m) => m.id == id);
        if (idx != -1) {
          modules[idx] = updated;
          modules.refresh();
        }
      } else {
        await fetchModules();
      }
      FlutterToast.success('Module updated.');
      return updated;
    } on DioException catch (e) {
      final msg = _extractErrorMessage(e, 'Failed to update module.');
      FlutterToast.error(msg);
      return null;
    } catch (_) {
      FlutterToast.error('Something went wrong while updating module.');
      return null;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<bool> deleteModule(int id) async {
    isSubmitting.value = true;
    try {
      final deleted = await _repository.deleteModule(id);
      if (deleted) {
        modules.removeWhere((m) => m.id == id);
        modules.refresh();
        FlutterToast.success('Module deleted.');
      }
      return deleted;
    } on DioException catch (e) {
      final msg = _extractErrorMessage(e, 'Failed to delete module.');
      FlutterToast.error(msg);
      return false;
    } catch (_) {
      FlutterToast.error('Something went wrong while deleting module.');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  String _extractErrorMessage(DioException e, String fallback) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      if (data['message'] != null && data['message'].toString().isNotEmpty) {
        return data['message'].toString();
      }
      if (data['detail'] != null && data['detail'].toString().isNotEmpty) {
        return data['detail'].toString();
      }
    }
    return e.message ?? fallback;
  }
}