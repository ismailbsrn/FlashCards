import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/review_log.dart';

class ReviewLogRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<void> createReviewLog(ReviewLog log) async {
    final db = await _dbHelper.database;
    await db.insert(
      'review_logs',
      _mapToDb(log),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ReviewLog>> getReviewLogsByCard(String cardId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'review_logs',
      where: 'card_id = ?',
      whereArgs: [cardId],
      orderBy: 'reviewed_at DESC',
    );

    return result.map((json) => _mapToModel(json)).toList();
  }

  Future<List<ReviewLog>> getReviewLogsByUser(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await _dbHelper.database;
    
    String whereClause = 'user_id = ?';
    List<dynamic> whereArgs = [userId];

    if (startDate != null) {
      whereClause += ' AND reviewed_at >= ?';
      whereArgs.add(startDate.toIso8601String());
    }

    if (endDate != null) {
      whereClause += ' AND reviewed_at <= ?';
      whereArgs.add(endDate.toIso8601String());
    }

    final result = await db.query(
      'review_logs',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'reviewed_at DESC',
    );

    return result.map((json) => _mapToModel(json)).toList();
  }

  Future<int> getReviewCountToday(String userId) async {
    final db = await _dbHelper.database;
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    
    final result = await db.rawQuery(
      '''
      SELECT COUNT(*) as count FROM review_logs
      WHERE user_id = ? AND reviewed_at >= ?
      ''',
      [userId, startOfDay.toIso8601String()],
    );
    
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<Map<String, int>> getReviewCountByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _dbHelper.database;
    
    final result = await db.rawQuery(
      '''
      SELECT DATE(reviewed_at) as date, COUNT(*) as count 
      FROM review_logs
      WHERE user_id = ? 
      AND reviewed_at >= ? 
      AND reviewed_at <= ?
      GROUP BY DATE(reviewed_at)
      ''',
      [
        userId,
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ],
    );
    
    final Map<String, int> counts = {};
    for (final row in result) {
      final dateStr = row['date'] as String;
      final count = row['count'] as int;
      counts[dateStr] = count;
    }
    
    return counts;
  }

  ReviewLog _mapToModel(Map<String, dynamic> map) {
    return ReviewLog(
      id: map['id'] as String,
      cardId: map['card_id'] as String,
      userId: map['user_id'] as String,
      quality: ReviewQuality.values[map['quality'] as int],
      reviewedAt: DateTime.parse(map['reviewed_at'] as String),
      intervalBefore: map['interval_before'] as int,
      intervalAfter: map['interval_after'] as int,
      easeFactorBefore: map['ease_factor_before'] as double,
      easeFactorAfter: map['ease_factor_after'] as double,
    );
  }

  Map<String, dynamic> _mapToDb(ReviewLog model) {
    return {
      'id': model.id,
      'card_id': model.cardId,
      'user_id': model.userId,
      'quality': model.quality.index,
      'reviewed_at': model.reviewedAt.toIso8601String(),
      'interval_before': model.intervalBefore,
      'interval_after': model.intervalAfter,
      'ease_factor_before': model.easeFactorBefore,
      'ease_factor_after': model.easeFactorAfter,
    };
  }
}
