// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudySettings _$StudySettingsFromJson(Map<String, dynamic> json) =>
    StudySettings(
      userId: json['userId'] as String,
      maxReviewsPerDay: (json['maxReviewsPerDay'] as num?)?.toInt() ?? 100,
      maxNewCardsPerDay: (json['maxNewCardsPerDay'] as num?)?.toInt() ?? 20,
      showAnswerTimer: json['showAnswerTimer'] as bool? ?? true,
      autoPlayAudio: json['autoPlayAudio'] as bool? ?? false,
      showIntervalButtons: json['showIntervalButtons'] as bool? ?? false,
      darkMode: json['darkMode'] as bool? ?? false,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$StudySettingsToJson(StudySettings instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'maxReviewsPerDay': instance.maxReviewsPerDay,
      'maxNewCardsPerDay': instance.maxNewCardsPerDay,
      'showAnswerTimer': instance.showAnswerTimer,
      'autoPlayAudio': instance.autoPlayAudio,
      'showIntervalButtons': instance.showIntervalButtons,
      'darkMode': instance.darkMode,
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
