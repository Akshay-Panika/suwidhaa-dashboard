import 'dart:io';
import 'dart:typed_data';
import 'package:get/get.dart';
import '../../../core/widget/flutter_toast.dart';
import '../model/module_banner_model.dart';
import '../repository/module_banner_repository.dart';

class ModuleBannerController extends GetxController {
  final ModuleBannerRepository _repository;

  ModuleBannerController({ModuleBannerRepository? repository})
      : _repository = repository ?? ModuleBannerRepository();

  final RxList<ModuleBannerModel> banners = <ModuleBannerModel>[].obs;
  final Rx<ModuleBannerModel?> selectedBanner = Rx<ModuleBannerModel?>(null);

  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBanners();
  }

  Future<void> fetchBanners({bool showToastOnError = false}) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final list = await _repository.getBanners();
      banners.assignAll(list);
    } catch (e) {
      errorMessage.value = _repository.cleanError(e);
      if (showToastOnError) {
        FlutterToast.error(errorMessage.value);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<ModuleBannerModel?> getBannerDetail(
      int id, {
        bool setAsSelected = true,
      }) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final detail = await _repository.getBannerDetail(id);
      if (setAsSelected) {
        selectedBanner.value = detail;
      }
      return detail;
    } catch (e) {
      final msg = _repository.cleanError(e);
      errorMessage.value = msg;
      FlutterToast.error(msg);
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createBanner({
    required String name,
    String? youtubeVideoUrl,
    File? imageFile,
    Uint8List? imageBytes,
    String fileName = 'banner.png',
  }) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      FlutterToast.warning('Please enter a banner name');
      return false;
    }
    if (imageFile == null && (imageBytes == null || imageBytes.isEmpty)) {
      FlutterToast.warning('Please select an image');
      return false;
    }

    isSubmitting.value = true;
    try {
      await _repository.createBanner(
        name: trimmedName,
        youtubeVideoUrl: youtubeVideoUrl,
        imageFile: imageFile,
        imageBytes: imageBytes,
        fileName: fileName,
      );
      FlutterToast.success('Module banner created successfully');
      await fetchBanners();
      return true;
    } catch (e) {
      FlutterToast.error(_repository.cleanError(e));
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<bool> updateBanner({
    required int id,
    required String name,
    String? youtubeVideoUrl,
    File? imageFile,
    Uint8List? imageBytes,
    String fileName = 'banner.png',
    bool usePatch = true,
  }) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      FlutterToast.warning('Please enter a banner name');
      return false;
    }

    final hasImage =
        imageFile != null || (imageBytes != null && imageBytes.isNotEmpty);
    if (!usePatch && !hasImage) {
      FlutterToast.warning('Please select an image for full update (PUT)');
      return false;
    }

    isSubmitting.value = true;
    try {
      final updated = await _repository.updateBanner(
        id: id,
        name: trimmedName,
        youtubeVideoUrl: youtubeVideoUrl,
        imageFile: imageFile,
        imageBytes: imageBytes,
        fileName: fileName,
        usePatch: usePatch,
      );
      selectedBanner.value = updated;
      FlutterToast.success('Module banner updated successfully');
      await fetchBanners();
      return true;
    } catch (e) {
      FlutterToast.error(_repository.cleanError(e));
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<bool> deleteBanner(int id) async {
    isSubmitting.value = true;
    try {
      await _repository.deleteBanner(id);
      banners.removeWhere((item) => item.id == id);
      if (selectedBanner.value?.id == id) {
        selectedBanner.value = null;
      }
      FlutterToast.success('Module banner deleted successfully');
      return true;
    } catch (e) {
      FlutterToast.error(_repository.cleanError(e));
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }
}