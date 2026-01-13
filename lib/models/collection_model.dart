import 'package:json_annotation/json_annotation.dart';

part 'collection_model.g.dart';

@JsonSerializable()
class CollectionModel {
  final String id;
  @JsonKey(name: 'user_id')
  final String userId;
  final String name;
  final String? description;
  final List<String> tags;
  final String? color;
  
  // Sync
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  @JsonKey(name: 'is_deleted')
  final bool isDeleted;
  final int version;
  
  CollectionModel({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    this.tags = const [],
    this.color,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
    this.version = 1,
  });

  factory CollectionModel.fromJson(Map<String, dynamic> json) =>
      _$CollectionModelFromJson(json);

  Map<String, dynamic> toJson() => _$CollectionModelToJson(this);

  CollectionModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    List<String>? tags,
    String? color,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    int? version,
  }) {
    return CollectionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      version: version ?? this.version,
    );
  }
}
