class ModuleItemModel {
  final int id;
  final String name;
  final String image;
  final String? createdAt;
  final String? updatedAt;

  ModuleItemModel({
    required this.id,
    required this.name,
    required this.image,
    this.createdAt,
    this.updatedAt,
  });

  factory ModuleItemModel.fromJson(Map<String, dynamic> json) {
    return ModuleItemModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: (json['name'] ?? '').toString(),
      image: (json['image'] ?? '').toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }
}