import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/study_settings.dart';

class SettingsRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<StudySettings?> getSettings(String userId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'study_settings',
      where: 'user_id = ?',
      whereArgs: [userId],
      limit: 1,
    );

    if (result.isEmpty) return null;
    return _mapToModel(result.first);
  }

  Future<void> saveSettings(StudySettings settings) async {
    final db = await _dbHelper.database;
    await db.insert(
      'study_settings',
      _mapToDb(settings),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<StudySettings> getOrCreateSettings(String userId) async {
    final existing = await getSettings(userId);
    if (existing != null) return existing;

    final defaultSettings = StudySettings(
      userId: userId,
      updatedAt: DateTime.now(),
    );
    await saveSettings(defaultSettings);
    return defaultSettings;
  }

  StudySettings _mapToModel(Map<String, dynamic> map) {
    return StudySettings(
      userId: map['user_id'] as String,
      maxReviewsPerDay: map['max_reviews_per_day'] as int,
      maxNewCardsPerDay: map['max_new_cards_per_day'] as int,
      showAnswerTimer: (map['show_answer_timer'] as int) == 1,
      autoPlayAudio: (map['auto_play_audio'] as int) == 1,
      showIntervalButtons: (map['show_interval_buttons'] as int?) == 1,
      darkMode: (map['dark_mode'] as int?) == 1,
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> _mapToDb(StudySettings model) {
    return {
      'user_id': model.userId,
      'max_reviews_per_day': model.maxReviewsPerDay,
      'max_new_cards_per_day': model.maxNewCardsPerDay,
      'show_answer_timer': model.showAnswerTimer ? 1 : 0,
      'auto_play_audio': model.autoPlayAudio ? 1 : 0,
      'show_interval_buttons': model.showIntervalButtons ? 1 : 0,
      'dark_mode': model.darkMode ? 1 : 0,
      'updated_at': model.updatedAt.toIso8601String(),
    };
  }
}
