import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import '../../models/collection_model.dart';
import '../../providers/card_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/collection_provider.dart';
import '../../services/import_export_service.dart';
import '../cards/card_editor_screen.dart';
import '../study/study_session_screen.dart';

class CollectionDetailScreen extends StatefulWidget {
  final CollectionModel collection;

  const CollectionDetailScreen({super.key, required this.collection});

  @override
  State<CollectionDetailScreen> createState() => _CollectionDetailScreenState();
}

class _CollectionDetailScreenState extends State<CollectionDetailScreen> {
  final ImportExportService _importExportService = ImportExportService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _selectionMode = false;
  final Set<String> _selectedCards = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCards();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCards() async {
    final cardProvider = Provider.of<CardProvider>(context, listen: false);
    await cardProvider.loadCards(widget.collection.id);
  }

  void _enterSelectionMode(String cardId) {
    setState(() {
      _selectionMode = true;
      _selectedCards.add(cardId);
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _selectionMode = false;
      _selectedCards.clear();
    });
  }

  void _toggleSelection(String cardId) {
    setState(() {
      if (_selectedCards.contains(cardId)) {
        _selectedCards.remove(cardId);
        if (_selectedCards.isEmpty) {
          _selectionMode = false;
        }
      } else {
        _selectedCards.add(cardId);
      }
    });
  }

  void _selectAll() {
    final cardProvider = Provider.of<CardProvider>(context, listen: false);
    setState(() {
      _selectedCards.addAll(cardProvider.cards.map((card) => card.id));
    });
  }

  void _unselectAll() {
    setState(() {
      _selectedCards.clear();
    });
  }

  Future<void> _bulkDeleteCards() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Cards'),
        content: Text(
          'Are you sure you want to delete ${_selectedCards.length} card(s)? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final cardProvider = Provider.of<CardProvider>(context, listen: false);

      for (final cardId in _selectedCards) {
        await cardProvider.deleteCard(
          cardId,
          widget.collection.id,
          onSyncNeeded: () {
            authProvider.scheduleDebouncedSync();
          },
        );
      }
      
      _exitSelectionMode();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cards deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _exportCollection() async {
    final result = await _importExportService.exportCollection(
      widget.collection.id,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['success']
                ? 'Exported to ${result['path']}'
                : 'Export failed: ${result['error']}',
          ),
          backgroundColor: result['success'] ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteCollection() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Collection'),
        content: Text(
          'Are you sure you want to delete "${widget.collection.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final collectionProvider = Provider.of<CollectionProvider>(
        context,
        listen: false,
      );

      if (authProvider.currentUser != null) {
        await collectionProvider.deleteCollection(
          widget.collection.id,
          authProvider.currentUser!.id,
        );

        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CollectionProvider>(
      builder: (context, collectionProvider, _) {
        final currentCollection = collectionProvider.collections.firstWhere(
          (c) => c.id == widget.collection.id,
          orElse: () => widget.collection,
        );

        return Scaffold(
          appBar: AppBar(
            title: Text(currentCollection.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.file_download),
                onPressed: _exportCollection,
                tooltip: 'Export',
              ),
              PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 8),
                        Text('Edit Collection'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text(
                          'Delete Collection',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'delete') {
                    _deleteCollection();
                  } else if (value == 'edit') {
                    _showEditDialog();
                  }
                },
              ),
            ],
          ),
          body: Consumer<CardProvider>(
            builder: (context, cardProvider, _) {
              if (cardProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (cardProvider.error != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error: ${cardProvider.error}'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadCards,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              final allCards = cardProvider.cards;
              final filteredCards = _searchQuery.isEmpty
                  ? allCards
                  : allCards.where((card) {
                      final query = _searchQuery.toLowerCase();
                      final front = card.front.toLowerCase();
                      final back = card.back.toLowerCase();
                      return front.contains(query) || back.contains(query);
                    }).toList();

              if (allCards.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.style, size: 100, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No cards yet',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      const Text('Add your first flashcard'),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search cards...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    _searchController.clear();
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),

                  if (_searchQuery.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          Text(
                            '${filteredCards.length} of ${allCards.length} cards',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),

                  Expanded(
                    child: filteredCards.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No cards found',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Try a different search term',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: filteredCards.length,
                            itemBuilder: (context, index) {
                              final card = filteredCards[index];
                              final isSelected = _selectedCards.contains(card.id);
                              
                              return Card(
                                color: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : null,
                                child: ListTile(
                                  leading: _selectionMode
                                      ? Checkbox(
                                          value: isSelected,
                                          onChanged: (_) => _toggleSelection(card.id),
                                        )
                                      : null,
                                  title: Text(card.front),
                                  subtitle: Text(
                                    card.back,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: _selectionMode
                                      ? null
                                      : IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          onPressed: () async {
                                            final confirmed = await showDialog<bool>(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: const Text('Delete Card'),
                                                content: const Text('Are you sure?'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(context, false),
                                                    child: const Text('Cancel'),
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: () =>
                                                        Navigator.pop(context, true),
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: Colors.red,
                                                    ),
                                                    child: const Text('Delete'),
                                                  ),
                                                ],
                                              ),
                                            );

                                            if (confirmed == true) {
                                              final authProvider =
                                                  Provider.of<AuthProvider>(
                                                    context,
                                                    listen: false,
                                                  );
                                              await cardProvider.deleteCard(
                                                card.id,
                                                widget.collection.id,
                                                onSyncNeeded: () {
                                                  authProvider
                                                      .scheduleDebouncedSync();
                                                },
                                              );
                                            }
                                          },
                                        ),
                                  onTap: () {
                                    if (_selectionMode) {
                                      _toggleSelection(card.id);
                                    } else {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => CardEditorScreen(
                                            collection: widget.collection,
                                            card: card,
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  onLongPress: () {
                                    if (!_selectionMode) {
                                      _enterSelectionMode(card.id);
                                    }
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          ),
          floatingActionButton: Visibility(
            visible: !_selectionMode,
            maintainSize: false,
            maintainAnimation: false,
            maintainState: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 32),
                  child: FloatingActionButton.extended(
                    heroTag: 'study_collection',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => StudySessionScreen(
                            collectionId: widget.collection.id,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.school),
                    label: const Text('Study'),
                  ),
                ),
                FloatingActionButton(
                  heroTag: 'add_card',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            CardEditorScreen(collection: currentCollection),
                      ),
                    );
                  },
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ),
          bottomNavigationBar: _selectionMode
              ? BottomAppBar(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton.icon(
                        onPressed: _exitSelectionMode,
                        icon: const Icon(Icons.close),
                        label: Text('Cancel (${_selectedCards.length})'),
                      ),
                      IconButton(
                        onPressed: () {
                          final cardProvider = Provider.of<CardProvider>(context, listen: false);
                          if (_selectedCards.length == cardProvider.cards.length) {
                            _unselectAll();
                          } else {
                            _selectAll();
                          }
                        },
                        icon: Icon(
                          _selectedCards.length == Provider.of<CardProvider>(context, listen: false).cards.length
                              ? Icons.deselect
                              : Icons.select_all,
                        ),
                        tooltip: _selectedCards.length == Provider.of<CardProvider>(context, listen: false).cards.length
                            ? 'Unselect all'
                            : 'Select all',
                      ),
                      IconButton(
                        onPressed: _selectedCards.isEmpty ? null : _bulkDeleteCards,
                        icon: const Icon(Icons.delete),
                        color: _selectedCards.isEmpty ? Colors.grey : Colors.red,
                        tooltip: 'Delete selected',
                      ),
                    ],
                  ),
                )
              : null,
        );
      },
    );
  }

  Future<void> _showEditDialog() async {
    final nameController = TextEditingController(text: widget.collection.name);
    final descriptionController = TextEditingController(
      text: widget.collection.description ?? '',
    );
    final tagController = TextEditingController();

    final result = await showDialog<Map<String, dynamic>?>(
      context: context,
      builder: (context) {
        List<String> tags = List.from(widget.collection.tags);
        Color selectedColor = widget.collection.color != null
            ? Color(
                int.parse(widget.collection.color!.replaceFirst('#', '0xff')),
              )
            : Colors.blue;

        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('Edit Collection'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Tags',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: tagController,
                          decoration: const InputDecoration(
                            labelText: 'Add tag',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          onSubmitted: (value) {
                            if (value.trim().isNotEmpty &&
                                !tags.contains(value.trim())) {
                              setState(() {
                                tags.add(value.trim());
                                tagController.clear();
                              });
                            }
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          if (tagController.text.trim().isNotEmpty &&
                              !tags.contains(tagController.text.trim())) {
                            setState(() {
                              tags.add(tagController.text.trim());
                              tagController.clear();
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  if (tags.isNotEmpty)
                        Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Wrap(
                        spacing: 8,
                        children: tags.map((tag) {
                          return Chip(
                            label: Text(tag),
                            onDeleted: () {
                              setState(() {
                                tags.remove(tag);
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  const SizedBox(height: 16),

                  const Text(
                    'Color',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ColorPicker(
                    color: selectedColor,
                    onColorChanged: (Color color) {
                      setState(() => selectedColor = color);
                    },
                    width: 40,
                    height: 40,
                    borderRadius: 20,
                    spacing: 5,
                    runSpacing: 5,
                    wheelDiameter: 155,
                    enableShadesSelection: false,
                    pickersEnabled: const {ColorPickerType.wheel: true},
                    heading: const SizedBox.shrink(),
                    subheading: const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(null),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (nameController.text.isNotEmpty) {
                    Navigator.of(context).pop({
                      'name': nameController.text.trim(),
                      'description': descriptionController.text.trim().isEmpty
                          ? null
                          : descriptionController.text.trim(),
                      'tags': tags,
                      'color':
                          '#${selectedColor.value.toRadixString(16).substring(2).toUpperCase()}',
                    });
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
        );
      },
    );

    if (result != null && mounted) {
      final collectionProvider = Provider.of<CollectionProvider>(
        context,
        listen: false,
      );
      final updated = widget.collection.copyWith(
        name: result['name'],
        description: result['description'],
        tags: result['tags'],
        color: result['color'],
      );

      await collectionProvider.updateCollection(updated);
    }

    nameController.dispose();
    descriptionController.dispose();
    tagController.dispose();
  }
}
