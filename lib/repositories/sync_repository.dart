import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/sync_queue_item.dart';

class SyncRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<void> addToQueue(SyncQueueItem item) async {
    final db = await _dbHelper.database;
    await db.insert(
      'sync_queue',
      _mapToDb(item),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<SyncQueueItem>> getPendingItems({int? limit}) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'sync_queue',
      orderBy: 'created_at ASC',
      limit: limit,
    );

    return result.map((json) => _mapToModel(json)).toList();
  }

  Future<void> removeFromQueue(String id) async {
    final db = await _dbHelper.database;
    await db.delete(
      'sync_queue',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateRetryCount(String id, int retryCount, String? error) async {
    final db = await _dbHelper.database;
    await db.update(
      'sync_queue',
      {
        'retry_count': retryCount,
        'error': error,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearQueue() async {
    final db = await _dbHelper.database;
    await db.delete('sync_queue');
  }

  Future<int> getQueueSize() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM sync_queue');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  SyncQueueItem _mapToModel(Map<String, dynamic> map) {
    return SyncQueueItem(
      id: map['id'] as String,
      entityType: EntityType.values.firstWhere(
        (e) => e.toString().split('.').last == map['entity_type'],
      ),
      entityId: map['entity_id'] as String,
      operation: SyncOperation.values.firstWhere(
        (e) => e.toString().split('.').last == map['operation'],
      ),
      data: json.decode(map['data'] as String) as Map<String, dynamic>,
      createdAt: DateTime.parse(map['created_at'] as String),
      retryCount: map['retry_count'] as int,
      error: map['error'] as String?,
    );
  }

  Map<String, dynamic> _mapToDb(SyncQueueItem model) {
    return {
      'id': model.id,
      'entity_type': model.entityType.toString().split('.').last,
      'entity_id': model.entityId,
      'operation': model.operation.toString().split('.').last,
      'data': json.encode(model.data),
      'created_at': model.createdAt.toIso8601String(),
      'retry_count': model.retryCount,
      'error': model.error,
    };
  }
}
