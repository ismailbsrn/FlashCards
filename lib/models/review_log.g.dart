// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReviewLog _$ReviewLogFromJson(Map<String, dynamic> json) => ReviewLog(
  id: json['id'] as String,
  cardId: json['card_id'] as String,
  userId: json['user_id'] as String,
  quality: $enumDecode(_$ReviewQualityEnumMap, json['quality']),
  reviewedAt: DateTime.parse(json['reviewed_at'] as String),
  intervalBefore: (json['interval_before'] as num).toInt(),
  intervalAfter: (json['interval_after'] as num).toInt(),
  easeFactorBefore: (json['ease_factor_before'] as num).toDouble(),
  easeFactorAfter: (json['ease_factor_after'] as num).toDouble(),
);

Map<String, dynamic> _$ReviewLogToJson(ReviewLog instance) => <String, dynamic>{
  'id': instance.id,
  'card_id': instance.cardId,
  'user_id': instance.userId,
  'quality': _$ReviewQualityEnumMap[instance.quality]!,
  'reviewed_at': instance.reviewedAt.toIso8601String(),
  'interval_before': instance.intervalBefore,
  'interval_after': instance.intervalAfter,
  'ease_factor_before': instance.easeFactorBefore,
  'ease_factor_after': instance.easeFactorAfter,
};

const _$ReviewQualityEnumMap = {
  ReviewQuality.wrong: 'wrong',
  ReviewQuality.hard: 'hard',
  ReviewQuality.good: 'good',
  ReviewQuality.easy: 'easy',
};
