import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../models/collection_model.dart';
import '../models/card_model.dart';
import '../models/sync_queue_item.dart';
import '../repositories/collection_repository.dart';
import '../repositories/card_repository.dart';
import 'sync_service.dart';

class ImportExportService {
  final CollectionRepository _collectionRepository = CollectionRepository();
  final CardRepository _cardRepository = CardRepository();
  final SyncService _syncService = SyncService();
  final Uuid _uuid = const Uuid();

  Future<Map<String, dynamic>> exportCollection(String collectionId) async {
    try {
      final collection = await _collectionRepository.getCollectionById(collectionId);
      if (collection == null) {
        return {'success': false, 'error': 'Collection not found'};
      }

      final cards = await _cardRepository.getCardsByCollection(collectionId);

      final exportData = {
        'version': '1.0',
        'exported_at': DateTime.now().toIso8601String(),
        'collection': {
          'name': collection.name,
          'description': collection.description,
          'tags': collection.tags,
          'color': collection.color,
        },
        'cards': cards.map((card) => {
          'front': card.front,
          'back': card.back,
        }).toList(),
      };

      final directory = await getApplicationDocumentsDirectory();
      final fileName = '${collection.name.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}_${DateTime.now().millisecondsSinceEpoch}.json';
      final filePath = '${directory.path}/$fileName';
      
      final file = File(filePath);
      const encoder = JsonEncoder.withIndent('  ');
      await file.writeAsString(encoder.convert(exportData));

      return {'success': true, 'path': filePath};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> exportCollections(List<String> collectionIds) async {
    try {
      final collections = <Map<String, dynamic>>[];
      
      for (final collectionId in collectionIds) {
        final collection = await _collectionRepository.getCollectionById(collectionId);
        if (collection != null) {
          final cards = await _cardRepository.getCardsByCollection(collectionId);
          collections.add({
            'collection': {
              'name': collection.name,
              'description': collection.description,
              'tags': collection.tags,
              'color': collection.color,
            },
            'cards': cards.map((card) => {
              'front': card.front,
              'back': card.back,
            }).toList(),
          });
        }
      }

      final exportData = {
        'version': '1.0',
        'exported_at': DateTime.now().toIso8601String(),
        'collections': collections,
      };

      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'flashcards_export_${DateTime.now().millisecondsSinceEpoch}.json';
      final filePath = '${directory.path}/$fileName';
      
      final file = File(filePath);
      const encoder = JsonEncoder.withIndent('  ');
      await file.writeAsString(encoder.convert(exportData));

      return {'success': true, 'path': filePath};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> importCollection(String userId) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: true,
      );

      if (result == null || result.files.isEmpty) {
        return {'success': false, 'error': 'No file selected'};
      }

      int importedCollections = 0;
      int importedCards = 0;
      int failedFiles = 0;

      for (final fileData in result.files) {
        if (fileData.path == null) {
          failedFiles++;
          continue;
        }

        try {
          final file = File(fileData.path!);
          final content = await file.readAsString();
          final data = json.decode(content);

          if (data['collections'] != null) {
            for (final collectionData in data['collections']) {
              final result = await _importSingleCollection(
                userId,
                collectionData['collection'],
                collectionData['cards'],
              );
              importedCollections += result['collections'] ?? 0;
              importedCards += result['cards'] ?? 0;
            }
          } else if (data['collection'] != null) {
            final result = await _importSingleCollection(
              userId,
              data['collection'],
              data['cards'],
            );
            importedCollections += result['collections'] ?? 0;
            importedCards += result['cards'] ?? 0;
          } else {
            failedFiles++;
          }
        } catch (e) {
          failedFiles++;
        }
      }

      if (importedCollections == 0) {
        return {'success': false, 'error': 'No valid collections found in selected files'};
      }

      return {
        'success': true,
        'collections': importedCollections,
        'cards': importedCards,
        'failedFiles': failedFiles,
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> importMultipleCollections(String userId) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: true,
      );

      if (result == null || result.files.isEmpty) {
        return {'success': false, 'message': 'No files selected'};
      }

      int totalCollections = 0;
      int totalCards = 0;
      int failedFiles = 0;

      for (final file in result.files) {
        if (file.path == null) continue;

        try {
          final fileContent = await File(file.path!).readAsString();
          final data = json.decode(fileContent);

          if (data['collections'] != null) {
            for (final collectionData in data['collections']) {
              final importResult = await _importSingleCollection(
                userId,
                collectionData['collection'],
                collectionData['cards'],
              );
              totalCollections += importResult['collections'] ?? 0;
              totalCards += importResult['cards'] ?? 0;
            }
          } else if (data['collection'] != null) {
            final importResult = await _importSingleCollection(
              userId,
              data['collection'],
              data['cards'],
            );
            totalCollections += importResult['collections'] ?? 0;
            totalCards += importResult['cards'] ?? 0;
          } else {
            failedFiles++;
          }
        } catch (e) {
          failedFiles++;
        }
      }

      if (totalCollections == 0) {
        return {
          'success': false,
          'message': 'No valid collections found in selected files',
        };
      }

      return {
        'success': true,
        'message': 'Imported $totalCollections collection(s) with $totalCards card(s)${failedFiles > 0 ? ' ($failedFiles file(s) failed)' : ''}',
      };
    } catch (e) {
      return {'success': false, 'message': 'Import failed: ${e.toString()}'};
    }
  }

  Future<Map<String, int>> _importSingleCollection(
    String userId,
    Map<String, dynamic> collectionJson,
    List<dynamic> cardsJson,
  ) async {
    final newCollectionId = _uuid.v4();
    final now = DateTime.now();

    final collection = CollectionModel(
      id: newCollectionId,
      userId: userId,
      name: collectionJson['name'],
      description: collectionJson['description'],
      tags: collectionJson['tags'] != null 
          ? List<String>.from(collectionJson['tags']) 
          : [],
      color: collectionJson['color'],
      createdAt: now,
      updatedAt: now,
    );

    await _collectionRepository.createCollection(collection);
    
    await _syncService.queueSync(
      entityType: EntityType.collection,
      entityId: newCollectionId,
      operation: SyncOperation.create,
      data: collection.toJson(),
    );

    int cardCount = 0;
    for (final cardJson in cardsJson) {
      final cardId = _uuid.v4();
      final card = CardModel(
        id: cardId,
        collectionId: newCollectionId,
        front: cardJson['front'],
        back: cardJson['back'],
        createdAt: now,
        updatedAt: now,
      );
      
      await _cardRepository.createCard(card);
      
      await _syncService.queueSync(
        entityType: EntityType.card,
        entityId: cardId,
        operation: SyncOperation.create,
        data: card.toJson(),
      );
      
      cardCount++;
    }

    return {'collections': 1, 'cards': cardCount};
  }
}
