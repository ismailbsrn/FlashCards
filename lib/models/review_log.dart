import 'package:json_annotation/json_annotation.dart';

part 'review_log.g.dart';

enum ReviewQuality {
  @JsonValue('wrong')
  wrong, // complete blackout
  @JsonValue('hard')
  hard, // incorrect response; correct one remembered after reveal
  @JsonValue('good')
  good, // correct response recalled with serious difficulty
  @JsonValue('easy')
  easy, // correct response with hesitation
}

@JsonSerializable()
class ReviewLog {
  final String id;
  @JsonKey(name: 'card_id')
  final String cardId;
  @JsonKey(name: 'user_id')
  final String userId;
  final ReviewQuality quality;
  @JsonKey(name: 'reviewed_at')
  final DateTime reviewedAt;
  @JsonKey(name: 'interval_before')
  final int intervalBefore;
  @JsonKey(name: 'interval_after')
  final int intervalAfter;
  @JsonKey(name: 'ease_factor_before')
  final double easeFactorBefore;
  @JsonKey(name: 'ease_factor_after')
  final double easeFactorAfter;
  
  ReviewLog({
    required this.id,
    required this.cardId,
    required this.userId,
    required this.quality,
    required this.reviewedAt,
    required this.intervalBefore,
    required this.intervalAfter,
    required this.easeFactorBefore,
    required this.easeFactorAfter,
  });

  factory ReviewLog.fromJson(Map<String, dynamic> json) =>
      _$ReviewLogFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewLogToJson(this);
}
