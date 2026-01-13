// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: json['id'] as String,
  email: json['email'] as String,
  displayName: json['display_name'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  lastSyncAt: json['last_sync_at'] == null
      ? null
      : DateTime.parse(json['last_sync_at'] as String),
  isEmailVerified: json['is_email_verified'] as bool? ?? false,
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'display_name': instance.displayName,
  'created_at': instance.createdAt.toIso8601String(),
  'last_sync_at': instance.lastSyncAt?.toIso8601String(),
  'is_email_verified': instance.isEmailVerified,
};
