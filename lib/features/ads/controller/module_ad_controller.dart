import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/widget/flutter_toast.dart';
import '../model/module_ad_model.dart';
import '../repository/module_ad_repository.dart';

enum ModuleAdMode { create, edit, view }

class ModuleAdController extends GetxController {
  // ── REPOSITORY (direct instance, no constructor) ──
  final ModuleAdRepository _repository = ModuleAdRepository();

  // ── STATE ─────────────────────────────────────
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxList<ModuleAdModel> ads = <ModuleAdModel>[].obs;

  final RxString search = ''.obs;
  final Rx<ModuleAdMode> mode = ModuleAdMode.create.obs;
  final Rx<ModuleAdModel?> selected = Rx<ModuleAdModel?>(null);

  // ── FORM STATE ────────────────────────────────
  final RxString name = ''.obs;
  final Rx<Uint8List?> pickedImageBytes = Rx<Uint8List?>(null);
  final RxString pickedImageName = ''.obs;
  final RxString youtubeVideoUrl = ''.obs;
  final RxBool imageError = false.obs;

  final ImagePicker _picker = ImagePicker();

  // ── DERIVED ───────────────────────────────────
  List<ModuleAdModel> get filtered {
    final q = search.value.trim().toLowerCase();
    if (q.isEmpty) return ads;
    return ads.where((a) {
      return a.name.toLowerCase().contains(q) ||
          a.image.toLowerCase().contains(q) ||
          (a.youtubeVideoUrl ?? '').toLowerCase().contains(q);
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    loadAds();
  }

  // ═════════════════════════════════════════════
  //  LIST
  // ═════════════════════════════════════════════
  Future<void> loadAds() async {
    try {
      isLoading.value = true;
      final list = await _repository.getAds();
      ads.assignAll(list);
    } on DioException catch (e) {
      FlutterToast.error(_extractError(e));
    } catch (e) {
      FlutterToast.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  // ═════════════════════════════════════════════
  //  PICK IMAGE
  // ═════════════════════════════════════════════
  Future<void> pickImage() async {
    try {
      final XFile? file =
      await _picker.pickImage(source: ImageSource.gallery);
      if (file == null) return;

      final bytes = await file.readAsBytes();
      pickedImageBytes.value = bytes;
      pickedImageName.value = file.name.isNotEmpty ? file.name : 'ad.png';
      imageError.value = false;
    } catch (e) {
      FlutterToast.error('Failed to pick image: $e');
    }
  }

  void clearPickedImage() {
    pickedImageBytes.value = null;
    pickedImageName.value = '';
  }

  // ═════════════════════════════════════════════
  //  MODE SWITCH
  // ═════════════════════════════════════════════
  void startCreate() {
    mode.value = ModuleAdMode.create;
    selected.value = null;
    name.value = '';
    youtubeVideoUrl.value = '';
    imageError.value = false;
    clearPickedImage();
  }

  void startEdit(ModuleAdModel ad) {
    mode.value = ModuleAdMode.edit;
    selected.value = ad;
    name.value = ad.name;
    youtubeVideoUrl.value = ad.youtubeVideoUrl ?? '';
    imageError.value = false;
    clearPickedImage();
  }

  void startView(ModuleAdModel ad) {
    mode.value = ModuleAdMode.view;
    selected.value = ad;
    name.value = ad.name;
    youtubeVideoUrl.value = ad.youtubeVideoUrl ?? '';
  }

  // ═════════════════════════════════════════════
  //  SAVE (create / update)
  // ═════════════════════════════════════════════
  Future<void> save() async {
    if (isSubmitting.value) return;

    final isEdit = mode.value == ModuleAdMode.edit;
    final trimmedName = name.value.trim();

    if (trimmedName.isEmpty) {
      FlutterToast.warning('Please enter an ad name');
      return;
    }

    if (!isEdit && pickedImageBytes.value == null) {
      imageError.value = true;
      FlutterToast.warning('Please select an ad image');
      return;
    }

    if (isEdit &&
        pickedImageBytes.value == null &&
        trimmedName == (selected.value?.name ?? '') &&
        youtubeVideoUrl.value.trim() ==
            (selected.value?.youtubeVideoUrl ?? '')) {
      FlutterToast.warning('No changes to update');
      return;
    }

    try {
      isSubmitting.value = true;

      if (isEdit && selected.value != null) {
        await _repository.updateAd(
          id: selected.value!.id,
          name: trimmedName,
          imageBytes: pickedImageBytes.value,
          imageName:
          pickedImageName.value.isEmpty ? null : pickedImageName.value,
          youtubeVideoUrl: youtubeVideoUrl.value.trim(),
        );
        FlutterToast.success('Ad updated successfully');
      } else {
        await _repository.createAd(
          name: trimmedName,
          imageBytes: pickedImageBytes.value!,
          imageName: pickedImageName.value,
          youtubeVideoUrl: youtubeVideoUrl.value.trim().isEmpty
              ? null
              : youtubeVideoUrl.value.trim(),
        );
        FlutterToast.success('Ad created successfully');
      }

      await loadAds();
      startCreate();
    } on DioException catch (e) {
      FlutterToast.error(_extractError(e));
    } catch (e) {
      FlutterToast.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      isSubmitting.value = false;
    }
  }

  // ═════════════════════════════════════════════
  //  DELETE
  // ═════════════════════════════════════════════
  Future<void> delete(ModuleAdModel ad) async {
    try {
      isSubmitting.value = true;
      await _repository.deleteAd(ad.id);
      if (selected.value?.id == ad.id) startCreate();
      await loadAds();
      FlutterToast.success('Ad deleted successfully');
    } on DioException catch (e) {
      FlutterToast.error(_extractError(e));
    } catch (e) {
      FlutterToast.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      isSubmitting.value = false;
    }
  }

  // ═════════════════════════════════════════════
  //  ERROR PARSER
  // ═════════════════════════════════════════════
  String _extractError(DioException e) {
    final data = e.response?.data;

    if (data is Map) {
      final errors = data['errors'];
      if (errors is Map && errors.isNotEmpty) {
        final first = errors.values.first;
        if (first is List && first.isNotEmpty) return first.first.toString();
        return first.toString();
      }
      if (data['message'] != null) return data['message'].toString();
    }
    return e.message ?? 'Something went wrong';
  }
}