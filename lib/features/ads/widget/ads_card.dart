import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../../../core/utils/app_color.dart';
import '../controller/module_ad_controller.dart';
import '../model/module_ad_model.dart';

class AdsCard extends StatefulWidget {
  final VoidCallback? onBackToDashboard;

  const AdsCard({super.key, this.onBackToDashboard});

  @override
  State<AdsCard> createState() => _AdsCardState();
}

class _AdsCardState extends State<AdsCard> {
  late final ModuleAdController _controller;
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _searchCtrl = TextEditingController();
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _urlCtrl = TextEditingController();

  YoutubePlayerController? _inlineVideoController;
  String? _playingVideoId;

  String _imageUrl = '';
  File? _pickedFile;
  Uint8List? _pickedBytes;
  String _pickedFileName = 'ad.png';

  String _search = '';
  int? _selectedId;
  bool _isGridView = false;

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<ModuleAdController>()
        ? Get.find<ModuleAdController>()
        : Get.put(ModuleAdController(), permanent: true);

    _urlCtrl.addListener(() {
      if (!mounted) return;
      final currentId = _extractYoutubeId(_urlCtrl.text);
      if (_playingVideoId != null && _playingVideoId != currentId) {
        _stopInlineVideo();
      } else {
        setState(() {});
      }
    });

    _startNewAdForm();
    _controller.loadAds();
  }

  String? _extractYoutubeId(String rawUrl) {
    final trimmed = rawUrl.trim();
    if (trimmed.isEmpty) return null;

    final directId = YoutubePlayerController.convertUrlToId(trimmed);
    if (directId != null && directId.isNotEmpty) {
      return directId;
    }

    final uri = Uri.tryParse(trimmed);
    if (uri == null) return null;

    final segments = uri.pathSegments;
    for (final marker in ['shorts', 'live', 'embed']) {
      final idx = segments.indexOf(marker);
      if (idx != -1 && idx + 1 < segments.length) {
        final candidate = segments[idx + 1].trim();
        if (candidate.isNotEmpty) return candidate;
      }
    }

    return null;
  }

  Future<void> _stopInlineVideo() async {
    final oldController = _inlineVideoController;
    _inlineVideoController = null;
    _playingVideoId = null;
    if (mounted) setState(() {});
    await oldController?.close();
  }

  Future<void> _playInlineVideo(String rawUrl) async {
    final videoId = _extractYoutubeId(rawUrl);
    if (videoId == null) {
      Fluttertoast.showToast(
        msg: 'Invalid YouTube video URL.',
        backgroundColor: AppColor.red,
        textColor: AppColor.white,
      );
      return;
    }

    await _stopInlineVideo();

    final controller = YoutubePlayerController.fromVideoId(
      videoId: videoId,
      autoPlay: true,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        strictRelatedVideos: true,
      ),
    );

    if (!mounted) {
      await controller.close();
      return;
    }

    setState(() {
      _inlineVideoController = controller;
      _playingVideoId = videoId;
    });
  }

  Future<void> _selectAd(ModuleAdModel item) async {
    await _stopInlineVideo();
    _controller.startEdit(item);
    setState(() {
      _selectedId = item.id;
      _titleCtrl.text = item.name;
      _urlCtrl.text = item.youtubeVideoUrl ?? '';
      _imageUrl = item.image;
      _pickedFile = null;
      _pickedBytes = null;
      _pickedFileName = 'ad.png';
    });
  }

  Future<void> _startNewAdForm() async {
    await _stopInlineVideo();
    _controller.startCreate();
    setState(() {
      _selectedId = null;
      _titleCtrl.clear();
      _urlCtrl.clear();
      _imageUrl = '';
      _pickedFile = null;
      _pickedBytes = null;
      _pickedFileName = 'ad.png';
    });
  }

  Future<void> _pickImage() async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file != null) {
      await _stopInlineVideo();
      final fileName = file.name.isNotEmpty ? file.name : 'ad.png';
      final bytes = await file.readAsBytes();

      _pickedFileName = fileName;
      _pickedBytes = bytes;
      _pickedFile = kIsWeb ? null : File(file.path);

      _controller.pickedImageName.value = fileName;
      _controller.pickedImageBytes.value = bytes;
      _controller.imageError.value = false;

      if (mounted) setState(() {});
    }
  }

  Future<void> _saveAd() async {
    final title = _titleCtrl.text.trim();
    final youtubeUrl = _urlCtrl.text.trim();

    if (title.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Please enter an ad title.',
        backgroundColor: AppColor.red,
        textColor: AppColor.white,
      );
      return;
    }

    await _stopInlineVideo();
    _controller.name.value = title;
    _controller.youtubeVideoUrl.value = youtubeUrl;
    _controller.pickedImageName.value =
    _pickedFileName.isNotEmpty ? _pickedFileName : 'ad.png';

    if (_pickedBytes != null) {
      _controller.pickedImageBytes.value = _pickedBytes;
    }

    await _controller.save();
    if (_controller.mode.value == ModuleAdMode.create &&
        _controller.selected.value == null) {
      await _startNewAdForm();
    }
  }

  void _handleBack() {
    if (widget.onBackToDashboard != null) {
      widget.onBackToDashboard!();
    } else {
      _startNewAdForm();
    }
  }


  Future<void> _deleteAd() async {
    final current = _controller.selected.value;
    if (current == null) return;
    await _stopInlineVideo();
    await _controller.delete(current);
    if (_controller.selected.value == null) {
      await _startNewAdForm();
    }
  }

  @override
  void dispose() {
    _inlineVideoController?.close();
    _searchCtrl.dispose();
    _titleCtrl.dispose();
    _urlCtrl.dispose();
    super.dispose();
  }

  Widget _buildAdThumb(String imageUrl, {double size = 40}) {
    if (imageUrl.isEmpty) {
      return Icon(
        Icons.image_rounded,
        color: AppColor.primary,
        size: size * 0.6,
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        imageUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(
          Icons.image_rounded,
          color: AppColor.primary,
        ),
      ),
    );
  }

  Widget _buildListItem(ModuleAdModel item) {
    final isSelected = _selectedId == item.id;
    final hasVideo = _extractYoutubeId(item.youtubeVideoUrl ?? '') != null;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isSelected ? AppColor.lightPrimary : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColor.primary : AppColor.border,
          width: isSelected ? 1.4 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => _selectAd(item),
          child: Row(
            children: [
              _buildAdThumb(item.image, size: 50),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColor.deepPrimary,
                      ),
                    ),
                    if (item.youtubeVideoUrl != null &&
                        item.youtubeVideoUrl!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        item.youtubeVideoUrl!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColor.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (hasVideo) ...[
                const SizedBox(width: 8),
                const Icon(
                  Icons.play_circle_fill_rounded,
                  color: AppColor.primary,
                  size: 22,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridItem(ModuleAdModel item) {
    final isSelected = _selectedId == item.id;
    final hasVideo = _extractYoutubeId(item.youtubeVideoUrl ?? '') != null;

    return Material(
      color: isSelected ? AppColor.lightPrimary : AppColor.bg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _selectAd(item),
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
                  _buildAdThumb(item.image, size: 36),
                  if (hasVideo)
                    const Icon(
                      Icons.play_circle_fill_rounded,
                      color: AppColor.primary,
                      size: 20,
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
                item.youtubeVideoUrl ?? 'No YouTube URL',
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

  Widget _buildImageOrVideoBox() {
    if (_inlineVideoController != null && _playingVideoId != null) {
      return Container(
        height: 150,
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColor.border),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            YoutubePlayer(
              controller: _inlineVideoController!,
              aspectRatio: 16 / 9,
            ),
            Positioned(
              top: 6,
              right: 6,
              child: Material(
                color: Colors.black.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  onTap: _stopInlineVideo,
                  borderRadius: BorderRadius.circular(20),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.close_rounded, color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'Image',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    Widget imageWidget;
    if (_pickedBytes != null) {
      imageWidget = Image.memory(_pickedBytes!, fit: BoxFit.cover);
    } else if (_pickedFile != null) {
      imageWidget = Image.file(_pickedFile!, fit: BoxFit.cover);
    } else if (_imageUrl.isNotEmpty) {
      imageWidget = Image.network(
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
      imageWidget = const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate_rounded,
            color: AppColor.primary,
            size: 28,
          ),
          SizedBox(height: 4),
          Text(
            'Choose Ad Image',
            style: TextStyle(fontSize: 12, color: AppColor.textSecondary),
          ),
        ],
      );
    }

    return InkWell(
      onTap: _pickImage,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 150,
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColor.bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _controller.imageError.value ? AppColor.red : AppColor.border,
          ),
        ),
        child: imageWidget,
      ),
    );
  }

  Widget _buildDetailsPlaySection() {
    final rawUrl = _urlCtrl.text.trim();
    final hasVideo = _extractYoutubeId(rawUrl) != null;
    final isPlaying = _inlineVideoController != null && _playingVideoId != null;

    if (_selectedId == null && !hasVideo) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColor.bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColor.border),
      ),
      child: Row(
        children: [
          Icon(
            hasVideo
                ? Icons.smart_display_rounded
                : Icons.videocam_off_outlined,
            size: 20,
            color: hasVideo ? AppColor.primary : AppColor.textSecondary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isPlaying
                  ? 'Playing video in image box'
                  : hasVideo
                  ? 'YouTube video available'
                  : 'No YouTube video URL set',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: hasVideo ? AppColor.deepPrimary : AppColor.textSecondary,
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: hasVideo
                ? (isPlaying ? _stopInlineVideo : () => _playInlineVideo(rawUrl))
                : null,
            icon: Icon(
              isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded,
              size: 18,
            ),
            label: Text(isPlaying ? 'Stop' : 'Play'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primary,
              foregroundColor: AppColor.white,
              disabledBackgroundColor: AppColor.border,
              disabledForegroundColor: AppColor.textSecondary,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final allAds = _controller.filtered;
      final filtered = allAds.where((b) {
        if (_search.isEmpty) return true;
        return b.name.toLowerCase().contains(_search) ||
            (b.youtubeVideoUrl ?? '').toLowerCase().contains(_search) ||
            b.id.toString().contains(_search);
      }).toList();

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
                        'Ads',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColor.deepPrimary,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Manage all your Suwidhaa module ads from one place.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColor.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _startNewAdForm,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Add Ad'),
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
                                      hintText: 'Search ad...',
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
                                        onPressed: () =>
                                            setState(() => _isGridView = false),
                                        icon: Icon(
                                          Icons.view_list_rounded,
                                          color: !_isGridView
                                              ? AppColor.primary
                                              : AppColor.textSecondary,
                                        ),
                                      ),
                                      IconButton(
                                        tooltip: 'Grid View',
                                        onPressed: () =>
                                            setState(() => _isGridView = true),
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
                                  allAds.isEmpty
                                  ? const Center(
                                child: CircularProgressIndicator(),
                              )
                                  : filtered.isEmpty
                                  ? const Center(
                                child: Text(
                                  'No ads found.',
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
                                  mainAxisExtent: 125,
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
                    // Right: Create / Edit Form + Inline Play in Image Box
                    SizedBox(
                      width: 400,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _selectedId == null
                                      ? 'Add Ad'
                                      : 'Ad #$_selectedId Details',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColor.deepPrimary,
                                  ),
                                ),
                                if (_selectedId != null)
                                  TextButton(
                                    onPressed: _startNewAdForm,
                                    child: const Text('Clear'),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            _buildImageOrVideoBox(),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _titleCtrl,
                              decoration: InputDecoration(
                                labelText: 'Ad Title / Name',
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
                            const SizedBox(height: 12),
                            TextField(
                              controller: _urlCtrl,
                              decoration: InputDecoration(
                                labelText: 'YouTube Video URL',
                                hintText: 'https://youtube.com/shorts/...',
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
                            _buildDetailsPlaySection(),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _controller.isSubmitting.value
                                  ? null
                                  : _saveAd,
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
                              child: _controller.isSubmitting.value
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
                                    ? 'Create Ad'
                                    : 'Save Changes',
                              ),
                            ),
                            if (_selectedId != null) ...[
                              const SizedBox(height: 8),
                              OutlinedButton(
                                onPressed: _controller.isSubmitting.value
                                    ? null
                                    : _deleteAd,
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