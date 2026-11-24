class ModuleBannerModel {
  final int id;
  final String name;
  final String image;
  final String? youtubeVideoUrl;
  final String? createdAt;
  final String? updatedAt;

  const ModuleBannerModel({
    required this.id,
    required this.name,
    required this.image,
    this.youtubeVideoUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory ModuleBannerModel.fromJson(Map<String, dynamic> json) {
    final rawYoutube = json['youtube_video_url'];
    final parsedYoutube =
    (rawYoutube == null || rawYoutube.toString().trim().isEmpty)
        ? null
        : rawYoutube.toString().trim();

    return ModuleBannerModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] ?? '').toString(),
      image: (json['image'] ?? '').toString(),
      youtubeVideoUrl: parsedYoutube,
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }
}