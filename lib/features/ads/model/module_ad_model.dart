class ModuleAdModel {
  final int id;
  final String name;
  final String image;
  final String? youtubeVideoUrl;
  final String? createdAt;
  final String? updatedAt;

  ModuleAdModel({
    required this.id,
    required this.name,
    required this.image,
    this.youtubeVideoUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory ModuleAdModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final parsedId = rawId is int
        ? rawId
        : int.tryParse(rawId?.toString() ?? '') ?? 0;

    return ModuleAdModel(
      id: parsedId,
      name: (json['name'] ?? '').toString(),
      image: (json['image'] ?? '').toString(),
      youtubeVideoUrl: json['youtube_video_url']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'youtube_video_url': youtubeVideoUrl,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}