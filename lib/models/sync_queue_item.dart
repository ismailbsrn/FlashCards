import 'package:json_annotation/json_annotation.dart';

part 'sync_queue_item.g.dart';

enum SyncOperation {
  @JsonValue('create')
  create,
  @JsonValue('update')
  update,
  @JsonValue('delete')
  delete,
}

enum EntityType {
  @JsonValue('collection')
  collection,
  @JsonValue('card')
  card,
  @JsonValue('review_log')
  reviewLog,
}

@JsonSerializable()
class SyncQueueItem {
  final String id;
  final EntityType entityType;
  final String entityId;
  final SyncOperation operation;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final int retryCount;
  final String? error;
  
  SyncQueueItem({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.data,
    required this.createdAt,
    this.retryCount = 0,
    this.error,
  });

  factory SyncQueueItem.fromJson(Map<String, dynamic> json) =>
      _$SyncQueueItemFromJson(json);

  Map<String, dynamic> toJson() => _$SyncQueueItemToJson(this);

  SyncQueueItem copyWith({
    String? id,
    EntityType? entityType,
    String? entityId,
    SyncOperation? operation,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    int? retryCount,
    String? error,
  }) {
    return SyncQueueItem(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      operation: operation ?? this.operation,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      retryCount: retryCount ?? this.retryCount,
      error: error ?? this.error,
    );
  }
}
