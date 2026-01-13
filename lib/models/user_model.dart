import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final String id;
  final String email;
  @JsonKey(name: 'display_name')
  final String? displayName;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'last_sync_at')
  final DateTime? lastSyncAt;
  @JsonKey(name: 'is_email_verified')
  final bool isEmailVerified;
  
  UserModel({
    required this.id,
    required this.email,
    this.displayName,
    required this.createdAt,
    this.lastSyncAt,
    this.isEmailVerified = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    DateTime? createdAt,
    DateTime? lastSyncAt,
    bool? isEmailVerified,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    );
  }
}
