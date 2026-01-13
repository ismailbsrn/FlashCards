import 'package:json_annotation/json_annotation.dart';

part 'study_settings.g.dart';

@JsonSerializable()
class StudySettings {
  final String userId;
  final int maxReviewsPerDay;
  final int maxNewCardsPerDay;
  final bool showAnswerTimer;
  final bool autoPlayAudio; // for future features
  final bool showIntervalButtons;
  final bool darkMode;
  final DateTime updatedAt;

  StudySettings({
    required this.userId,
    this.maxReviewsPerDay = 100,
    this.maxNewCardsPerDay = 20,
    this.showAnswerTimer = true,
    this.autoPlayAudio = false,
    this.showIntervalButtons = false,
    this.darkMode = false,
    required this.updatedAt,
  });

  factory StudySettings.fromJson(Map<String, dynamic> json) =>
      _$StudySettingsFromJson(json);

  Map<String, dynamic> toJson() => _$StudySettingsToJson(this);

  StudySettings copyWith({
    String? userId,
    int? maxReviewsPerDay,
    int? maxNewCardsPerDay,
    bool? showAnswerTimer,
    bool? autoPlayAudio,
    bool? showIntervalButtons,
    bool? darkMode,
    DateTime? updatedAt,
  }) {
    return StudySettings(
      userId: userId ?? this.userId,
      maxReviewsPerDay: maxReviewsPerDay ?? this.maxReviewsPerDay,
      maxNewCardsPerDay: maxNewCardsPerDay ?? this.maxNewCardsPerDay,
      showAnswerTimer: showAnswerTimer ?? this.showAnswerTimer,
      autoPlayAudio: autoPlayAudio ?? this.autoPlayAudio,
      showIntervalButtons: showIntervalButtons ?? this.showIntervalButtons,
      darkMode: darkMode ?? this.darkMode,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
