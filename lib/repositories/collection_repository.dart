import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/collection_model.dart';

class CollectionRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<CollectionModel>> getAllCollections(String userId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'collections',
      where: 'user_id = ? AND is_deleted = ?',
      whereArgs: [userId, 0],
      orderBy: 'created_at DESC',
    );

    return result.map((json) => _mapToModel(json)).toList();
  }

  Future<CollectionModel?> getCollectionById(String id) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'collections',
      where: 'id = ? AND is_deleted = ?',
      whereArgs: [id, 0],
      limit: 1,
    );

    if (result.isEmpty) return null;
    return _mapToModel(result.first);
  }

  Future<String> createCollection(CollectionModel collection) async {
    final db = await _dbHelper.database;
    await db.insert(
      'collections',
      _mapToDb(collection),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return collection.id;
  }

  Future<void> updateCollection(CollectionModel collection) async {
    final db = await _dbHelper.database;
    await db.update(
      'collections',
      _mapToDb(collection),
      where: 'id = ?',
      whereArgs: [collection.id],
    );
  }

  Future<void> deleteCollection(String id) async {
    final db = await _dbHelper.database;
    await db.update(
      'collections',
      {
        'is_deleted': 1,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> getCardCount(String collectionId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM cards WHERE collection_id = ? AND is_deleted = 0',
      [collectionId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getDueCardCount(String collectionId) async {
    final db = await _dbHelper.database;
    final now = DateTime.now().toIso8601String();
    final result = await db.rawQuery(
      '''
      SELECT COUNT(*) as count FROM cards 
      WHERE collection_id = ? 
      AND is_deleted = 0 
      AND (next_review_date IS NULL OR next_review_date <= ?)
      ''',
      [collectionId, now],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  CollectionModel _mapToModel(Map<String, dynamic> map) {
    // Parse tags from JSON string
    List<String> tags = [];
    if (map['tags'] != null && map['tags'] != '') {
      try {
        final tagsString = map['tags'] as String;
        final decoded = tagsString.split(',');
        tags = decoded.where((t) => t.isNotEmpty).toList();
      } catch (_) {
        tags = [];
      }
    }

    return CollectionModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      tags: tags,
      color: map['color'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      isDeleted: (map['is_deleted'] as int) == 1,
      version: map['version'] as int,
    );
  }

  Map<String, dynamic> _mapToDb(CollectionModel model) {
    return {
      'id': model.id,
      'user_id': model.userId,
      'name': model.name,
      'description': model.description,
      'tags': model.tags.join(','),
      'color': model.color,
      'created_at': model.createdAt.toIso8601String(),
      'updated_at': model.updatedAt.toIso8601String(),
      'is_deleted': model.isDeleted ? 1 : 0,
      'version': model.version,
    };
  }
}
