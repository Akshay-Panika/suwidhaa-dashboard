import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/utils/app_color.dart';
import '../../../core/widget/flutter_toast.dart';
import '../binding/module_item_binding.dart';
import '../controller/module_item_controller.dart';
import '../model/module_item_model.dart';

class ModuleCard extends StatefulWidget {
  final VoidCallback? onBackToDashboard;

  const ModuleCard({super.key, this.onBackToDashboard});

  @override
  State<ModuleCard> createState() => _ModuleCardState();
}

class _ModuleCardState extends State<ModuleCard> {
  late final ModuleItemController _controller;
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _searchCtrl = TextEditingController();
  final TextEditingController _nameCtrl = TextEditingController();

  String _imageUrl = '';
  File? _pickedFile;
  Uint8List? _pickedBytes;
  String _pickedFileName = 'module.png';

  String _search = '';
  int? _selectedId;
  bool _isGridView = false;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<ModuleItemController>()) {
      ModuleItemBinding().dependencies();
    }
    _controller = Get.find<ModuleItemController>();
    _resetForm();
    _controller.fetchModules(showToastOnError: true);
  }

  void _resetForm() {
    setState(() {
      _selectedId = null;
      _nameCtrl.clear();
      _imageUrl = '';
      _pickedFile = null;
      _pickedBytes = null;
      _pickedFileName = 'module.png';
    });
  }

  Future<void> _selectModule(ModuleItemModel item) async {
    setState(() {
      _selectedId = item.id;
      _nameCtrl.text = item.name;
      _imageUrl = item.image;
      _pickedFile = null;
      _pickedBytes = null;
      _pickedFileName = 'module.png';
    });

    final detail = await _controller.getModuleDetail(item.id);
    if (detail != null && mounted && _selectedId == item.id) {
      setState(() {
        _nameCtrl.text = detail.name;
        _imageUrl = detail.image;
      });
    }
  }

  Future<void> _pickImage() async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file == null) return;

    _pickedFileName = file.name.isNotEmpty ? file.name : 'module.png';
    if (kIsWeb) {
      _pickedBytes = await file.readAsBytes();
      _pickedFile = null;
    } else {
      _pickedFile = File(file.path);
      _pickedBytes = null;
    }
    if (mounted) setState(() {});
  }

  Future<void> _saveModule() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      FlutterToast.error('Please enter a module name.');
      return;
    }

    final hasNewImage = _pickedBytes != null || _pickedFile != null;

    if (_selectedId == null) {
      if (!hasNewImage) {
        FlutterToast.error('Please choose a module image.');
        return;
      }

      final created = await _controller.createModule(
        name: name,
        imageFile: _pickedFile,
        imageBytes: _pickedBytes,
        fileName: _pickedFileName,
      );

      if (created != null && mounted) {
        _resetForm();
      }
    } else {
      final id = _selectedId!;
      final updated = await _controller.updateModule(
        id: id,
        name: name,
        imageFile: _pickedFile,
        imageBytes: _pickedBytes,
        fileName: _pickedFileName,
        usePatch: true,
      );

      if (updated != null && mounted) {
        _resetForm();
      }
    }
  }

  Future<void> _deleteModule() async {
    if (_selectedId == null) return;
    final id = _selectedId!;

    final deleted = await _controller.deleteModule(id);
    if (deleted && mounted) {
      _resetForm();
    }
  }

  void _handleBack() {
    if (widget.onBackToDashboard != null) {
      widget.onBackToDashboard!();
    } else {
      _resetForm();
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Widget _buildImagePickerBox() {
    Widget preview;
    if (_pickedBytes != null) {
      preview = Image.memory(_pickedBytes!, fit: BoxFit.cover);
    } else if (_pickedFile != null && !kIsWeb) {
      preview = Image.file(_pickedFile!, fit: BoxFit.cover);
    } else if (_imageUrl.isNotEmpty) {
      preview = Image.network(
        _imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Center(
          child: Icon(
            Icons.image_not_supported_rounded,
            color: AppColor.textSecondary,
          ),
        ),
      );
    } else {
      preview = const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate_rounded,
            color: AppColor.primary,
            size: 30,
          ),
          SizedBox(height: 6),
          Text(
            'Choose Module Image',
            style: TextStyle(fontSize: 12, color: AppColor.textSecondary),
          ),
        ],
      );
    }

    return InkWell(
      onTap: _controller.isSubmitting.value ? null : _pickImage,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 140,
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColor.bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColor.border),
        ),
        child: preview,
      ),
    );
  }

  Widget _buildModuleImage(String url, {double size = 40}) {
    if (url.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColor.lightPrimary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.layers_rounded,
          color: AppColor.primary,
          size: 20,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColor.lightPrimary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.image_not_supported_rounded,
            color: AppColor.primary,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildListItem(ModuleItemModel item) {
    final isSelected = _selectedId == item.id;

    return ListTile(
      selected: isSelected,
      selectedTileColor: AppColor.lightPrimary,
      tileColor: AppColor.bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isSelected ? AppColor.primary : AppColor.border,
        ),
      ),
      leading: _buildModuleImage(item.image),
      title: Text(
        item.name,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColor.deepPrimary,
        ),
      ),
      subtitle: Text(
        item.image.isNotEmpty ? item.image : 'No image URL',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 12,
          color: AppColor.textSecondary,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        size: 18,
        color: AppColor.textSecondary,
      ),
      onTap: () => _selectModule(item),
    );
  }

  Widget _buildGridItem(ModuleItemModel item) {
    final isSelected = _selectedId == item.id;

    return Material(
      color: isSelected ? AppColor.lightPrimary : AppColor.bg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _selectModule(item),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColor.primary : AppColor.border,
              width: isSelected ? 1.4 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildModuleImage(item.image, size: 44),
                  if (isSelected)
                    const Icon(
                      Icons.check_circle_rounded,
                      color: AppColor.primary,
                      size: 18,
                    ),
                ],
              ),
              const Spacer(),
              Text(
                item.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColor.deepPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.image.isNotEmpty ? item.image : 'No image URL',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColor.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final allModules = _controller.modules;
      final filtered = allModules.where((m) {
        if (_search.isEmpty) return true;
        return m.name.toLowerCase().contains(_search) ||
            m.image.toLowerCase().contains(_search) ||
            m.id.toString().contains(_search);
      }).toList();

      final isSubmitting = _controller.isSubmitting.value;

      return Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  tooltip: 'Back to Dashboard',
                  onPressed: _handleBack,
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18,
                    color: AppColor.deepPrimary,
                  ),
                ),
                const SizedBox(width: 6),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Modules',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColor.deepPrimary,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Manage all your Suwidhaa service modules in one place.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColor.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Refresh Modules',
                  onPressed: _controller.isLoading.value || isSubmitting
                      ? null
                      : () => _controller.fetchModules(showToastOnError: true),
                  icon: const Icon(
                    Icons.refresh_rounded,
                    color: AppColor.deepPrimary,
                  ),
                ),
                const SizedBox(width: 6),
                ElevatedButton.icon(
                  onPressed: isSubmitting ? null : _resetForm,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Add Module'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary,
                    foregroundColor: AppColor.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Card(
                elevation: 0,
                color: AppColor.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: AppColor.border),
                ),
                child: Row(
                  children: [
                    // Left: Search + List/Grid Toggle + Items
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _searchCtrl,
                                    onChanged: (v) {
                                      setState(
                                            () => _search = v.trim().toLowerCase(),
                                      );
                                    },
                                    decoration: InputDecoration(
                                      hintText: 'Search module...',
                                      prefixIcon: const Icon(
                                        Icons.search_rounded,
                                        color: AppColor.textSecondary,
                                      ),
                                      suffixIcon: _search.isNotEmpty
                                          ? IconButton(
                                        icon: const Icon(
                                          Icons.close_rounded,
                                          size: 18,
                                          color: AppColor.textSecondary,
                                        ),
                                        onPressed: () {
                                          _searchCtrl.clear();
                                          setState(() => _search = '');
                                        },
                                      )
                                          : null,
                                      filled: true,
                                      fillColor: AppColor.bg,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                          color: AppColor.border,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                          color: AppColor.border,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  decoration: BoxDecoration(
                                    color: AppColor.bg,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: AppColor.border),
                                  ),
                                  child: Row(
                                    children: [
                                      IconButton(
                                        tooltip: 'List View',
                                        onPressed: () => setState(
                                              () => _isGridView = false,
                                        ),
                                        icon: Icon(
                                          Icons.view_list_rounded,
                                          color: !_isGridView
                                              ? AppColor.primary
                                              : AppColor.textSecondary,
                                        ),
                                      ),
                                      IconButton(
                                        tooltip: 'Grid View',
                                        onPressed: () => setState(
                                              () => _isGridView = true,
                                        ),
                                        icon: Icon(
                                          Icons.grid_view_rounded,
                                          color: _isGridView
                                              ? AppColor.primary
                                              : AppColor.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Expanded(
                              child: _controller.isLoading.value &&
                                  allModules.isEmpty
                                  ? const Center(
                                child: CircularProgressIndicator(),
                              )
                                  : filtered.isEmpty
                                  ? const Center(
                                child: Text(
                                  'No modules found.',
                                  style: TextStyle(
                                    color: AppColor.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                              )
                                  : _isGridView
                                  ? GridView.builder(
                                itemCount: filtered.length,
                                gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 260,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  mainAxisExtent: 130,
                                ),
                                itemBuilder: (context, index) {
                                  return _buildGridItem(
                                    filtered[index],
                                  );
                                },
                              )
                                  : ListView.separated(
                                itemCount: filtered.length,
                                separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                                itemBuilder: (context, index) {
                                  return _buildListItem(
                                    filtered[index],
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const VerticalDivider(width: 1, color: AppColor.border),
                    // Right: Create / Edit Form
                    SizedBox(
                      width: 400,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _selectedId == null
                                      ? 'Add Module'
                                      : 'Edit Module #$_selectedId',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColor.deepPrimary,
                                  ),
                                ),
                                if (_selectedId != null ||
                                    _nameCtrl.text.isNotEmpty ||
                                    _pickedBytes != null ||
                                    _pickedFile != null)
                                  TextButton(
                                    onPressed: isSubmitting ? null : _resetForm,
                                    child: const Text('Clear'),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            _buildImagePickerBox(),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _nameCtrl,
                              decoration: InputDecoration(
                                labelText: 'Module Name',
                                filled: true,
                                fillColor: AppColor.bg,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: AppColor.border,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: isSubmitting ? null : _saveModule,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColor.primary,
                                foregroundColor: AppColor.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 13,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: isSubmitting
                                  ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColor.white,
                                ),
                              )
                                  : Text(
                                _selectedId == null
                                    ? 'Create Module'
                                    : 'Save Changes',
                              ),
                            ),
                            if (_selectedId != null) ...[
                              const SizedBox(height: 8),
                              OutlinedButton(
                                onPressed: isSubmitting ? null : _deleteModule,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColor.red,
                                  side: const BorderSide(color: AppColor.red),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text('Delete'),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}