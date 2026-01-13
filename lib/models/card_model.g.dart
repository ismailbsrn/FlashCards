// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CardModel _$CardModelFromJson(Map<String, dynamic> json) => CardModel(
  id: json['id'] as String,
  collectionId: json['collection_id'] as String,
  front: json['front'] as String,
  back: json['back'] as String,
  easeFactor: (json['ease_factor'] as num?)?.toDouble() ?? 2.5,
  interval: (json['interval'] as num?)?.toInt() ?? 0,
  repetitions: (json['repetitions'] as num?)?.toInt() ?? 0,
  nextReviewDate: json['next_review_date'] == null
      ? null
      : DateTime.parse(json['next_review_date'] as String),
  lastReviewDate: json['last_review_date'] == null
      ? null
      : DateTime.parse(json['last_review_date'] as String),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  isDeleted: json['is_deleted'] as bool? ?? false,
  version: (json['version'] as num?)?.toInt() ?? 1,
);

Map<String, dynamic> _$CardModelToJson(CardModel instance) => <String, dynamic>{
  'id': instance.id,
  'collection_id': instance.collectionId,
  'front': instance.front,
  'back': instance.back,
  'ease_factor': instance.easeFactor,
  'interval': instance.interval,
  'repetitions': instance.repetitions,
  'next_review_date': instance.nextReviewDate?.toIso8601String(),
  'last_review_date': instance.lastReviewDate?.toIso8601String(),
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'is_deleted': instance.isDeleted,
  'version': instance.version,
};
