import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/card_model.dart';
import '../models/review_log.dart';
import '../models/sync_queue_item.dart';
import '../repositories/card_repository.dart';
import '../repositories/review_log_repository.dart';
import '../services/spaced_repetition_service.dart';
import '../services/sync_service.dart';
import '../repositories/collection_repository.dart';

class StudyProvider with ChangeNotifier {
  Function? onSyncNeeded;
  final CardRepository _cardRepository = CardRepository();
  final ReviewLogRepository _reviewLogRepository = ReviewLogRepository();
  final SpacedRepetitionService _srService = SpacedRepetitionService();
  final SyncService _syncService = SyncService();
  final Uuid _uuid = const Uuid();
  
  List<CardModel> _dueCards = [];
  final Map<String, String> _collectionNames = {};
  int _currentCardIndex = 0;
  bool _isLoading = false;
  bool _showAnswer = false;
  String? _error;
  int _reviewedToday = 0;

  List<CardModel> get dueCards => _dueCards;
  CardModel? get currentCard => 
      _dueCards.isNotEmpty && _currentCardIndex < _dueCards.length 
          ? _dueCards[_currentCardIndex] 
          : null;
  String? getCurrentCollectionName() {
    final card = currentCard;
    if (card == null) return null;
    return _collectionNames[card.collectionId];
  }
  bool get isLoading => _isLoading;
  bool get showAnswer => _showAnswer;
  String? get error => _error;
  int get reviewedToday => _reviewedToday;
  int get remainingCards => _dueCards.length - _currentCardIndex;
  bool get hasMoreCards => _currentCardIndex < _dueCards.length;

  Future<void> loadDueCards(String userId, {String? collectionId, int? limit}) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (collectionId != null) {
        _dueCards = await _cardRepository.getDueCardsByCollection(
          collectionId,
          limit: limit,
        );
      } else {
        _dueCards = await _cardRepository.getDueCards(userId, limit: limit);
      }
      // Load collection names for due cards (cache)
      _collectionNames.clear();
      final repo = CollectionRepository();
      final collectionIds = _dueCards.map((c) => c.collectionId).toSet();
      for (final id in collectionIds) {
        try {
          final col = await repo.getCollectionById(id);
          if (col != null) _collectionNames[id] = col.name;
        } catch (_) {
          // ignore collection load errors
        }
      }
      
      _currentCardIndex = 0;
      _showAnswer = false;
      _reviewedToday = await _reviewLogRepository.getReviewCountToday(userId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  void toggleAnswer() {
    _showAnswer = !_showAnswer;
    notifyListeners();
  }

  Future<void> submitReview(String userId, ReviewQuality quality) async {
    if (currentCard == null) return;

    try {
      final card = currentCard!;
      final result = _srService.calculateNextReview(card, quality);

      // Update card with new review data
      final updatedCard = card.copyWith(
        easeFactor: result.easeFactor,
        interval: result.interval,
        repetitions: result.repetitions,
        nextReviewDate: result.nextReviewDate,
        lastReviewDate: DateTime.now(),
        updatedAt: DateTime.now(),
        version: card.version + 1,
      );

      await _cardRepository.updateCard(updatedCard);

      // Create review log
      final reviewLog = ReviewLog(
        id: _uuid.v4(),
        cardId: card.id,
        userId: userId,
        quality: quality,
        reviewedAt: DateTime.now(),
        intervalBefore: card.interval,
        intervalAfter: result.interval,
        easeFactorBefore: card.easeFactor,
        easeFactorAfter: result.easeFactor,
      );

      await _reviewLogRepository.createReviewLog(reviewLog);

      // Queue for sync
      await _syncService.queueSync(
        entityType: EntityType.card,
        entityId: updatedCard.id,
        operation: SyncOperation.update,
        data: updatedCard.toJson(),
      );

      await _syncService.queueSync(
        entityType: EntityType.reviewLog,
        entityId: reviewLog.id,
        operation: SyncOperation.create,
        data: reviewLog.toJson(),
      );

      // Trigger debounced sync
      onSyncNeeded?.call();

      // Ensure next card starts on front side
      _showAnswer = false;

      // Move to next card
      _currentCardIndex++;
      _reviewedToday++;

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void reset() {
    _dueCards = [];
    _currentCardIndex = 0;
    _showAnswer = false;
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
