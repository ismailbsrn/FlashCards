import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/card_model.dart';
import '../models/sync_queue_item.dart';
import '../repositories/card_repository.dart';
import '../services/sync_service.dart';

class CardProvider with ChangeNotifier {
  final CardRepository _repository = CardRepository();
  final SyncService _syncService = SyncService();
  final Uuid _uuid = const Uuid();
  
  List<CardModel> _cards = [];
  bool _isLoading = false;
  String? _error;

  List<CardModel> get cards => _cards;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCards(String collectionId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _cards = await _repository.getCardsByCollection(collectionId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> createCard({
    required String collectionId,
    required String front,
    required String back,
    Function? onSyncNeeded,
  }) async {
    try {
      final now = DateTime.now();
      final card = CardModel(
        id: _uuid.v4(),
        collectionId: collectionId,
        front: front,
        back: back,
        createdAt: now,
        updatedAt: now,
      );

      await _repository.createCard(card);
      
      // Queue for sync
      await _syncService.queueSync(
        entityType: EntityType.card,
        entityId: card.id,
        operation: SyncOperation.create,
        data: card.toJson(),
      );

      await loadCards(collectionId);
      
      // Trigger debounced sync
      onSyncNeeded?.call();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateCard(CardModel card, String front, String back, {Function? onSyncNeeded}) async {
    try {
      final updated = card.copyWith(
        front: front,
        back: back,
        updatedAt: DateTime.now(),
        version: card.version + 1,
      );

      await _repository.updateCard(updated);
      
      // Queue for sync
      await _syncService.queueSync(
        entityType: EntityType.card,
        entityId: updated.id,
        operation: SyncOperation.update,
        data: updated.toJson(),
      );

      final index = _cards.indexWhere((c) => c.id == updated.id);
      if (index != -1) {
        _cards[index] = updated;
        notifyListeners();
      }
      
      // Trigger debounced sync
      onSyncNeeded?.call();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteCard(String cardId, String collectionId, {Function? onSyncNeeded}) async {
    try {
      await _repository.deleteCard(cardId);
      
      // Queue for sync
      await _syncService.queueSync(
        entityType: EntityType.card,
        entityId: cardId,
        operation: SyncOperation.delete,
        data: {'id': cardId},
      );

      await loadCards(collectionId);
      
      // Trigger debounced sync
      onSyncNeeded?.call();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
