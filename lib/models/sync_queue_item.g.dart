// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_queue_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SyncQueueItem _$SyncQueueItemFromJson(Map<String, dynamic> json) =>
    SyncQueueItem(
      id: json['id'] as String,
      entityType: $enumDecode(_$EntityTypeEnumMap, json['entityType']),
      entityId: json['entityId'] as String,
      operation: $enumDecode(_$SyncOperationEnumMap, json['operation']),
      data: json['data'] as Map<String, dynamic>,
      createdAt: DateTime.parse(json['createdAt'] as String),
      retryCount: (json['retryCount'] as num?)?.toInt() ?? 0,
      error: json['error'] as String?,
    );

Map<String, dynamic> _$SyncQueueItemToJson(SyncQueueItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'entityType': _$EntityTypeEnumMap[instance.entityType]!,
      'entityId': instance.entityId,
      'operation': _$SyncOperationEnumMap[instance.operation]!,
      'data': instance.data,
      'createdAt': instance.createdAt.toIso8601String(),
      'retryCount': instance.retryCount,
      'error': instance.error,
    };

const _$EntityTypeEnumMap = {
  EntityType.collection: 'collection',
  EntityType.card: 'card',
  EntityType.reviewLog: 'review_log',
};

const _$SyncOperationEnumMap = {
  SyncOperation.create: 'create',
  SyncOperation.update: 'update',
  SyncOperation.delete: 'delete',
};
