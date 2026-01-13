import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/card_model.dart';

class CardRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<CardModel>> getCardsByCollection(String collectionId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'cards',
      where: 'collection_id = ? AND is_deleted = ?',
      whereArgs: [collectionId, 0],
      orderBy: 'created_at DESC',
    );

    return result.map((json) => _mapToModel(json)).toList();
  }

  Future<List<CardModel>> getDueCards(String userId, {int? limit}) async {
    final db = await _dbHelper.database;
    final now = DateTime.now().toIso8601String();
    
    String query = '''
      SELECT c.* FROM cards c
      INNER JOIN collections col ON c.collection_id = col.id
      WHERE col.user_id = ? 
      AND c.is_deleted = 0
      AND col.is_deleted = 0
      AND (c.next_review_date IS NULL OR c.next_review_date <= ?)
      ORDER BY c.next_review_date ASC
    ''';
    
    if (limit != null) {
      query += ' LIMIT $limit';
    }
    
    final result = await db.rawQuery(query, [userId, now]);
    return result.map((json) => _mapToModel(json)).toList();
  }

  Future<List<CardModel>> getDueCardsByCollection(
    String collectionId, {
    int? limit,
  }) async {
    final db = await _dbHelper.database;
    final now = DateTime.now().toIso8601String();
    
    String query = '''
      SELECT * FROM cards
      WHERE collection_id = ?
      AND is_deleted = 0
      AND (next_review_date IS NULL OR next_review_date <= ?)
      ORDER BY next_review_date ASC
    ''';
    
    if (limit != null) {
      query += ' LIMIT $limit';
    }
    
    final result = await db.rawQuery(query, [collectionId, now]);
    return result.map((json) => _mapToModel(json)).toList();
  }

  Future<CardModel?> getCardById(String id) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'cards',
      where: 'id = ? AND is_deleted = ?',
      whereArgs: [id, 0],
      limit: 1,
    );

    if (result.isEmpty) return null;
    return _mapToModel(result.first);
  }

  Future<String> createCard(CardModel card) async {
    final db = await _dbHelper.database;
    await db.insert(
      'cards',
      _mapToDb(card),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return card.id;
  }

  Future<void> updateCard(CardModel card) async {
    final db = await _dbHelper.database;
    await db.update(
      'cards',
      _mapToDb(card),
      where: 'id = ?',
      whereArgs: [card.id],
    );
  }

  Future<void> deleteCard(String id) async {
    final db = await _dbHelper.database;
    await db.update(
      'cards',
      {
        'is_deleted': 1,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> getTotalCardCount(String userId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      '''
      SELECT COUNT(*) as count FROM cards c
      INNER JOIN collections col ON c.collection_id = col.id
      WHERE col.user_id = ? AND c.is_deleted = 0 AND col.is_deleted = 0
      ''',
      [userId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getDueCardCount(String userId) async {
    final db = await _dbHelper.database;
    final now = DateTime.now().toIso8601String();
    final result = await db.rawQuery(
      '''
      SELECT COUNT(*) as count FROM cards c
      INNER JOIN collections col ON c.collection_id = col.id
      WHERE col.user_id = ?
      AND c.is_deleted = 0
      AND col.is_deleted = 0
      AND (c.next_review_date IS NULL OR c.next_review_date <= ?)
      ''',
      [userId, now],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  CardModel _mapToModel(Map<String, dynamic> map) {
    return CardModel(
      id: map['id'] as String,
      collectionId: map['collection_id'] as String,
      front: map['front'] as String,
      back: map['back'] as String,
      easeFactor: map['ease_factor'] as double,
      interval: map['interval'] as int,
      repetitions: map['repetitions'] as int,
      nextReviewDate: map['next_review_date'] != null
          ? DateTime.parse(map['next_review_date'] as String)
          : null,
      lastReviewDate: map['last_review_date'] != null
          ? DateTime.parse(map['last_review_date'] as String)
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      isDeleted: (map['is_deleted'] as int) == 1,
      version: map['version'] as int,
    );
  }

  Map<String, dynamic> _mapToDb(CardModel model) {
    return {
      'id': model.id,
      'collection_id': model.collectionId,
      'front': model.front,
      'back': model.back,
      'ease_factor': model.easeFactor,
      'interval': model.interval,
      'repetitions': model.repetitions,
      'next_review_date': model.nextReviewDate?.toIso8601String(),
      'last_review_date': model.lastReviewDate?.toIso8601String(),
      'created_at': model.createdAt.toIso8601String(),
      'updated_at': model.updatedAt.toIso8601String(),
      'is_deleted': model.isDeleted ? 1 : 0,
      'version': model.version,
    };
  }
}
