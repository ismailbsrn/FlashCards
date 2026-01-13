import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../models/sync_queue_item.dart';
import '../models/collection_model.dart';
import '../models/card_model.dart';
import '../repositories/sync_repository.dart';
import '../repositories/collection_repository.dart';
import '../repositories/card_repository.dart';
import '../repositories/user_repository.dart';
import '../repositories/review_log_repository.dart';
import '../models/review_log.dart';
import 'auth_service.dart';
import '../config/app_config.dart';

class SyncService {
  static String get baseUrl => AppConfig.baseUrl;
  
  final SyncRepository _syncRepository = SyncRepository();
  final CollectionRepository _collectionRepository = CollectionRepository();
  final CardRepository _cardRepository = CardRepository();
  final ReviewLogRepository _reviewLogRepository = ReviewLogRepository();
  final UserRepository _userRepository = UserRepository();
  final AuthService _authService = AuthService();
  final Uuid _uuid = const Uuid();

  bool _isSyncing = false;

  Future<void> queueSync({
    required EntityType entityType,
    required String entityId,
    required SyncOperation operation,
    required Map<String, dynamic> data,
  }) async {
    final item = SyncQueueItem(
      id: _uuid.v4(),
      entityType: entityType,
      entityId: entityId,
      operation: operation,
      data: data,
      createdAt: DateTime.now(),
    );
    
    await _syncRepository.addToQueue(item);
  }

  Future<Map<String, dynamic>> sync() async {
    if (_isSyncing) {
      return {'success': false, 'error': 'Sync already in progress'};
    }

    _isSyncing = true;
    
    try {
      final pushResult = await _pushChanges();
      if (!pushResult['success']) {
        _isSyncing = false;
        return pushResult;
      }

      final pullResult = await _pullChanges();
      if (!pullResult['success']) {
        _isSyncing = false;
        return pullResult;
      }

      final userId = await _authService.getUserId();
      if (userId != null) {
        await _userRepository.updateLastSync(userId);
      }

      _isSyncing = false;
      return {'success': true};
    } catch (e) {
      _isSyncing = false;
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> _pushChanges() async {
    try {
      final pendingItems = await _syncRepository.getPendingItems(limit: 100);
      final headers = await _authService.getAuthHeaders();

      var hadPushFailures = false;

      for (final item in pendingItems) {
        try {
          final endpoint = _getEndpoint(item.entityType, item.operation);
          final url = Uri.parse('$baseUrl$endpoint');

          http.Response response;
          
          switch (item.operation) {
            case SyncOperation.create:
            case SyncOperation.update:
              response = await http.post(
                url,
                headers: headers,
                body: json.encode(item.data),
              );
              break;
            case SyncOperation.delete:
              response = await http.delete(
                Uri.parse('$baseUrl$endpoint/${item.entityId}'),
                headers: headers,
              );
              break;
          }

          if (response.statusCode == 401) {
            await _authService.logout();
            return {'success': false, 'error': 'Unauthorized', 'unauthorized': true};
          }

          if (response.statusCode >= 200 && response.statusCode < 300) {
            await _syncRepository.removeFromQueue(item.id);
          } else {
            hadPushFailures = true;
            final newRetryCount = item.retryCount + 1;
            if (newRetryCount > 5) {
              await _syncRepository.removeFromQueue(item.id);
            } else {
              await _syncRepository.updateRetryCount(
                item.id,
                newRetryCount,
                'HTTP ${response.statusCode}: ${response.body}',
              );
            }
          }
        } catch (e) {
          hadPushFailures = true;
          final newRetryCount = item.retryCount + 1;
          if (newRetryCount > 5) {
            await _syncRepository.removeFromQueue(item.id);
          } else {
            await _syncRepository.updateRetryCount(
              item.id,
              newRetryCount,
              e.toString(),
            );
          }
        }
      }

      if (hadPushFailures) {
        return {'success': false, 'error': 'Failed to push some items'};
      }

      return {'success': true};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> _pullChanges() async {
    try {
      final headers = await _authService.getAuthHeaders();
      final user = await _userRepository.getCurrentUser();
      
      if (user == null) {
        return {'success': false, 'error': 'No user found'};
      }

      final userId = await _authService.getUserId();
      if (userId == null) {
        return {'success': false, 'error': 'User ID not found'};
      }
      
      final lastSync = user.lastSyncAt?.toIso8601String();
      final collectionsUrl = lastSync != null 
          ? '$baseUrl/collections?since=$lastSync'
          : '$baseUrl/collections';
      
      final collectionsResponse = await http.get(
        Uri.parse(collectionsUrl),
        headers: headers,
      );

      if (collectionsResponse.statusCode == 401) {
        await _authService.logout();
        return {'success': false, 'error': 'Unauthorized', 'unauthorized': true};
      }

      if (collectionsResponse.statusCode == 200) {
        final collectionsData = json.decode(collectionsResponse.body) as List;
        for (final collectionJson in collectionsData) {
          final remoteCollection = CollectionModel.fromJson(collectionJson);
          final localCollection = await _collectionRepository.getCollectionById(remoteCollection.id);
          
          if (localCollection == null || remoteCollection.updatedAt.isAfter(localCollection.updatedAt)) {
            await _collectionRepository.createCollection(remoteCollection);
          }
        }
      } else {
        return {'success': false, 'error': 'Failed to pull collections: HTTP ${collectionsResponse.statusCode}'};
      }

      final cardsUrl = lastSync != null 
          ? '$baseUrl/cards?since=$lastSync'
          : '$baseUrl/cards';
      final cardsResponse = await http.get(
        Uri.parse(cardsUrl),
        headers: headers,
      );

      if (cardsResponse.statusCode == 401) {
        await _authService.logout();
        return {'success': false, 'error': 'Unauthorized', 'unauthorized': true};
      }

      if (cardsResponse.statusCode == 200) {
        final cardsData = json.decode(cardsResponse.body) as List;
        for (final cardJson in cardsData) {
          final remoteCard = CardModel.fromJson(cardJson);
          final localCard = await _cardRepository.getCardById(remoteCard.id);
          
          if (localCard == null || remoteCard.updatedAt.isAfter(localCard.updatedAt)) {
            await _cardRepository.createCard(remoteCard);
          }
        }
      } else {
        return {'success': false, 'error': 'Failed to pull cards: HTTP ${cardsResponse.statusCode}'};
      }

      final reviewLogsUrl = lastSync != null
          ? '$baseUrl/review-logs?since=$lastSync'
          : '$baseUrl/review-logs';
      final reviewLogsResponse = await http.get(
        Uri.parse(reviewLogsUrl),
        headers: headers,
      );

      if (reviewLogsResponse.statusCode == 401) {
        await _authService.logout();
        return {'success': false, 'error': 'Unauthorized', 'unauthorized': true};
      }

      if (reviewLogsResponse.statusCode == 200) {
        final reviewLogsData = json.decode(reviewLogsResponse.body) as List;
        for (final reviewJson in reviewLogsData) {
          try {
            final remoteLog = ReviewLog.fromJson(reviewJson);
            await _reviewLogRepository.createReviewLog(remoteLog);
          } catch (_) {}
        }
      } else {
        return {'success': false, 'error': 'Failed to pull review logs: HTTP ${reviewLogsResponse.statusCode}'};
      }

      return {'success': true};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  String _getEndpoint(EntityType entityType, SyncOperation operation) {
    switch (entityType) {
      case EntityType.collection:
        return '/collections';
      case EntityType.card:
        return '/cards';
      case EntityType.reviewLog:
        return '/review-logs';
    }
  }

  Future<int> getPendingSyncCount() async {
    return await _syncRepository.getQueueSize();
  }

  Future<void> clearSyncQueue() async {
    await _syncRepository.clearQueue();
  }
}
