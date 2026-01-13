import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/user_model.dart';

class UserRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<UserModel?> getCurrentUser() async {
    final db = await _dbHelper.database;
    final result = await db.query('users', limit: 1);

    if (result.isEmpty) return null;
    return _mapToModel(result.first);
  }

  Future<void> saveUser(UserModel user) async {
    final db = await _dbHelper.database;
    await db.insert(
      'users',
      _mapToDb(user),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateLastSync(String userId) async {
    final db = await _dbHelper.database;
    await db.update(
      'users',
      {'last_sync_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<void> deleteUser(String userId) async {
    final db = await _dbHelper.database;
    await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<void> clearAllData() async {
    final db = await _dbHelper.database;
    await db.delete('users');
    await db.delete('collections');
    await db.delete('cards');
    await db.delete('review_logs');
    await db.delete('sync_queue');
    await db.delete('study_settings');
  }

  UserModel _mapToModel(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      email: map['email'] as String,
      displayName: map['display_name'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      lastSyncAt: map['last_sync_at'] != null
          ? DateTime.parse(map['last_sync_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> _mapToDb(UserModel model) {
    return {
      'id': model.id,
      'email': model.email,
      'display_name': model.displayName,
      'created_at': model.createdAt.toIso8601String(),
      'last_sync_at': model.lastSyncAt?.toIso8601String(),
    };
  }
}
