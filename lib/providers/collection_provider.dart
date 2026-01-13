import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/collection_model.dart';
import '../models/sync_queue_item.dart';
import '../repositories/collection_repository.dart';
import '../services/sync_service.dart';

class CollectionProvider with ChangeNotifier {
  final CollectionRepository _repository = CollectionRepository();
  final SyncService _syncService = SyncService();
  final Uuid _uuid = const Uuid();
  
  List<CollectionModel> _collections = [];
  bool _isLoading = false;
  String? _error;

  List<CollectionModel> get collections => _collections;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCollections(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _collections = await _repository.getAllCollections(userId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> createCollection({
    required String userId,
    required String name,
    String? description,
    List<String>? tags,
    String? color,
    Function? onSyncNeeded,
  }) async {
    try {
      final now = DateTime.now();
      final collection = CollectionModel(
        id: _uuid.v4(),
        userId: userId,
        name: name,
        description: description,
        tags: tags ?? [],
        color: color,
        createdAt: now,
        updatedAt: now,
      );

      await _repository.createCollection(collection);
      
      // Queue for sync
      await _syncService.queueSync(
        entityType: EntityType.collection,
        entityId: collection.id,
        operation: SyncOperation.create,
        data: collection.toJson(),
      );

      await loadCollections(userId);
      
      // Trigger debounced sync
      onSyncNeeded?.call();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateCollection(CollectionModel collection, {Function? onSyncNeeded}) async {
    try {
      final updated = collection.copyWith(
        updatedAt: DateTime.now(),
        version: collection.version + 1,
      );

      await _repository.updateCollection(updated);
      
      // Queue for sync
      await _syncService.queueSync(
        entityType: EntityType.collection,
        entityId: updated.id,
        operation: SyncOperation.update,
        data: updated.toJson(),
      );

      final index = _collections.indexWhere((c) => c.id == updated.id);
      if (index != -1) {
        _collections[index] = updated;
        notifyListeners();
      }
      
      // Trigger debounced sync
      onSyncNeeded?.call();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteCollection(String collectionId, String userId, {Function? onSyncNeeded}) async {
    try {
      await _repository.deleteCollection(collectionId);
      
      // Queue for sync
      await _syncService.queueSync(
        entityType: EntityType.collection,
        entityId: collectionId,
        operation: SyncOperation.delete,
        data: {'id': collectionId},
      );

      await loadCollections(userId);
      
      // Trigger debounced sync
      onSyncNeeded?.call();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<int> getCardCount(String collectionId) async {
    return await _repository.getCardCount(collectionId);
  }

  Future<int> getDueCardCount(String collectionId) async {
    return await _repository.getDueCardCount(collectionId);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
