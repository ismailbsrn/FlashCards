import 'package:flashcards2/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/collection_provider.dart';
import '../../services/import_export_service.dart';
import 'collection_screen.dart';

class CollectionsListScreen extends StatefulWidget {
  final Function(bool)? onSelectionModeChanged;

  const CollectionsListScreen({super.key, this.onSelectionModeChanged});

  @override
  State<CollectionsListScreen> createState() => _CollectionsListScreenState();
}

class _CollectionsListScreenState extends State<CollectionsListScreen> {
  bool _selectionMode = false;
  final Set<String> _selectedCollections = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final collectionProvider = Provider.of<CollectionProvider>(
      context,
      listen: false,
    );

    if (authProvider.currentUser != null) {
      await collectionProvider.loadCollections(authProvider.currentUser!.id);
    }
  }

  void _enterSelectionMode(String collectionId) {
    setState(() {
      _selectionMode = true;
      _selectedCollections.add(collectionId);
    });
    widget.onSelectionModeChanged?.call(true);
  }

  void _exitSelectionMode() {
    setState(() {
      _selectionMode = false;
      _selectedCollections.clear();
    });
    widget.onSelectionModeChanged?.call(false);
  }

  void _toggleSelection(String collectionId) {
    setState(() {
      if (_selectedCollections.contains(collectionId)) {
        _selectedCollections.remove(collectionId);
        if (_selectedCollections.isEmpty) {
          _selectionMode = false;
        }
      } else {
        _selectedCollections.add(collectionId);
      }
    });
  }

  void _selectAll() {
    final collectionProvider = Provider.of<CollectionProvider>(
      context,
      listen: false,
    );
    setState(() {
      _selectedCollections.clear();
      _selectedCollections.addAll(
        collectionProvider.collections.map((c) => c.id),
      );
    });
  }

  void _unselectAll() {
    setState(() {
      _selectedCollections.clear();
    });
  }

  Future<void> _bulkDelete() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteCollections),
        content: Text(
          l10n.deleteCollectionsConfirm(_selectedCollections.length),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.delete),
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
        for (final collectionId in _selectedCollections) {
          await collectionProvider.deleteCollection(
            collectionId,
            authProvider.currentUser!.id,
          );
        }
        _exitSelectionMode();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.collectionsDeletedSuccessfully),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    }
  }

  Future<void> _bulkExport() async {
    final l10n = AppLocalizations.of(context)!;
    final importExportService = ImportExportService();
    int successCount = 0;
    int errorCount = 0;

    for (final collectionId in _selectedCollections) {
      final result = await importExportService.exportCollection(collectionId);
      if (result['success']) {
        successCount++;
      } else {
        errorCount++;
      }
    }

    _exitSelectionMode();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.exportedCollections(
              successCount,
              errorCount > 0 ? ' ($errorCount failed)' : '',
            ),
          ),
          backgroundColor: errorCount == 0 ? Colors.green : Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<CollectionProvider>(
      builder: (context, collectionProvider, _) {
        if (collectionProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (collectionProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  l10n.errorWithMessage(collectionProvider.error!),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(onPressed: _loadData, child: Text(l10n.retry)),
              ],
            ),
          );
        }

        if (collectionProvider.collections.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.collections_bookmark,
                  size: 100,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.noCollectionsYet,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(l10n.createFirstCollection),
              ],
            ),
          );
        }

        return Scaffold(
          body: RefreshIndicator(
            onRefresh: _loadData,
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: collectionProvider.collections.length,
              itemBuilder: (context, index) {
                final collection = collectionProvider.collections[index];
                final collectionColor = collection.color != null
                    ? Color(
                        int.parse(collection.color!.replaceFirst('#', '0xff')),
                      )
                    : null;
                final isSelected = _selectedCollections.contains(collection.id);

                return Card(
                  margin: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 8,
                  ),
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                      : null,
                  child: ListTile(
                    leading: _selectionMode
                        ? Checkbox(
                            value: isSelected,
                            onChanged: (_) => _toggleSelection(collection.id),
                          )
                        : CircleAvatar(
                            backgroundColor:
                                collectionColor ??
                                Theme.of(context).colorScheme.primary,
                            child: Icon(
                              Icons.collections_bookmark,
                              color: collectionColor != null
                                  ? Colors.white
                                  : null,
                            ),
                          ),
                    title: Text(collection.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (collection.description != null)
                          Text(collection.description!),
                        if (collection.tags.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Wrap(
                              spacing: 4,
                              children: collection.tags.take(3).map((tag) {
                                return Chip(
                                  label: Text(tag),
                                  labelStyle: const TextStyle(fontSize: 10),
                                  padding: EdgeInsets.zero,
                                  visualDensity: VisualDensity.compact,
                                );
                              }).toList(),
                            ),
                          ),
                      ],
                    ),
                    trailing: _selectionMode
                        ? null
                        : const Icon(Icons.chevron_right),
                    onTap: () {
                      if (_selectionMode) {
                        _toggleSelection(collection.id);
                      } else {
                        Navigator.of(context)
                            .push(
                              MaterialPageRoute(
                                builder: (_) => CollectionDetailScreen(
                                  collection: collection,
                                ),
                              ),
                            )
                            .then((_) => _loadData());
                      }
                    },
                    onLongPress: () {
                      if (!_selectionMode) {
                        _enterSelectionMode(collection.id);
                      }
                    },
                  ),
                );
              },
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
                        label: Text(
                          l10n.cancelWithCount(_selectedCollections.length),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          final collectionProvider =
                              Provider.of<CollectionProvider>(
                                context,
                                listen: false,
                              );
                          if (_selectedCollections.length ==
                              collectionProvider.collections.length) {
                            _unselectAll();
                          } else {
                            _selectAll();
                          }
                        },
                        icon: Icon(
                          _selectedCollections.length ==
                                  Provider.of<CollectionProvider>(
                                    context,
                                    listen: false,
                                  ).collections.length
                              ? Icons.deselect
                              : Icons.select_all,
                        ),
                        tooltip:
                            _selectedCollections.length ==
                                Provider.of<CollectionProvider>(
                                  context,
                                  listen: false,
                                ).collections.length
                            ? l10n.unselectAll
                            : l10n.selectAll,
                      ),
                      IconButton(
                        onPressed: _selectedCollections.isEmpty
                            ? null
                            : _bulkExport,
                        icon: const Icon(Icons.download),
                        tooltip: l10n.exportCollections,
                      ),
                      IconButton(
                        onPressed: _selectedCollections.isEmpty
                            ? null
                            : _bulkDelete,
                        icon: const Icon(Icons.delete),
                        color: _selectedCollections.isEmpty
                            ? Colors.grey
                            : Colors.red,
                        tooltip: l10n.deleteSelected,
                      ),
                    ],
                  ),
                )
              : null,
        );
      },
    );
  }
}
