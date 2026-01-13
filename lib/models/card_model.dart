import 'package:json_annotation/json_annotation.dart';

part 'card_model.g.dart';

@JsonSerializable()
class CardModel {
  final String id;
  @JsonKey(name: 'collection_id')
  final String collectionId;
  final String front;
  final String back;
  
  //SM-2 Algorithm
  @JsonKey(name: 'ease_factor')
  final double easeFactor; //starts at 2.5
  final int interval; // days until next review
  final int repetitions; // number of successful repetitions
  @JsonKey(name: 'next_review_date')
  final DateTime? nextReviewDate;
  @JsonKey(name: 'last_review_date')
  final DateTime? lastReviewDate;
  
  // Sync
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  @JsonKey(name: 'is_deleted')
  final bool isDeleted;
  final int version;
  
  CardModel({
    required this.id,
    required this.collectionId,
    required this.front,
    required this.back,
    this.easeFactor = 2.5,
    this.interval = 0,
    this.repetitions = 0,
    this.nextReviewDate,
    this.lastReviewDate,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
    this.version = 1,
  });

  factory CardModel.fromJson(Map<String, dynamic> json) =>
      _$CardModelFromJson(json);

  Map<String, dynamic> toJson() => _$CardModelToJson(this);

  CardModel copyWith({
    String? id,
    String? collectionId,
    String? front,
    String? back,
    double? easeFactor,
    int? interval,
    int? repetitions,
    DateTime? nextReviewDate,
    DateTime? lastReviewDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    int? version,
  }) {
    return CardModel(
      id: id ?? this.id,
      collectionId: collectionId ?? this.collectionId,
      front: front ?? this.front,
      back: back ?? this.back,
      easeFactor: easeFactor ?? this.easeFactor,
      interval: interval ?? this.interval,
      repetitions: repetitions ?? this.repetitions,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      lastReviewDate: lastReviewDate ?? this.lastReviewDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      version: version ?? this.version,
    );
  }
}
