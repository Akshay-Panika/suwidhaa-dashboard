// lib/feature/recent_users/model/recent_user_model.dart
class RecentUserModel {
  final int id;
  final int? userId;
  final String phoneNumber;
  final String name;
  final String address;
  final String email;
  final String profileImage;
  final String createdAt;
  final String updatedAt;

  RecentUserModel({
    required this.id,
    this.userId,
    required this.phoneNumber,
    required this.name,
    required this.address,
    required this.email,
    required this.profileImage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RecentUserModel.fromJson(Map<String, dynamic> json) {
    return RecentUserModel(
      id: _toInt(json['id']) ?? 0,
      userId: _toInt(json['user_id']),
      phoneNumber: json['phone_number']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      profileImage: json['profile_image']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'phone_number': phoneNumber,
      'name': name,
      'address': address,
      'email': email,
      'profile_image': profileImage,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  DateTime? get createdAtDate => DateTime.tryParse(createdAt);

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}