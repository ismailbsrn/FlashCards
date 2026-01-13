import 'package:flashcards2/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/collection_provider.dart';
import '../../repositories/card_repository.dart';
import 'study_session_screen.dart';

enum CardFilter { all, due, newCards, learning }

class StudySelectionScreen extends StatefulWidget {
  const StudySelectionScreen({super.key});

  @override
  State<StudySelectionScreen> createState() => _StudySelectionScreenState();
}

class _StudySelectionScreenState extends State<StudySelectionScreen> {
  final CardRepository _cardRepository = CardRepository();
  final Set<String> _selectedCollections = {};
  final Set<String> _selectedTags = {};
  CardFilter _selectedFilter = CardFilter.all;
  bool _isLoading = false;
  Set<String> _allTags = {};
  bool _filtersExpanded = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCollections();
    });
  }

  Future<void> _loadCollections() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final collectionProvider = Provider.of<CollectionProvider>(
      context,
      listen: false,
    );

    if (authProvider.currentUser != null) {
      await collectionProvider.loadCollections(authProvider.currentUser!.id);

      final tags = <String>{};
      for (final collection in collectionProvider.collections) {
        tags.addAll(collection.tags);
      }
      setState(() {
        _allTags = tags;
      });
    }
  }

  void _studyAll() async {
    setState(() => _isLoading = true);

    setState(() => _isLoading = false);

    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const StudySessionScreen(collectionId: null),
        ),
      );
    }
  }

  Future<Map<String, int>> _getCollectionCardCounts() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final collectionProvider = Provider.of<CollectionProvider>(
      context,
      listen: false,
    );

    if (authProvider.currentUser == null) return {};

    final counts = <String, int>{};
    for (final collection in collectionProvider.collections) {
      final count = await _getCardCountForCollection(collection.id);
      counts[collection.id] = count;
    }
    return counts;
  }

  Future<int> _getCardCountForCollection(String collectionId) async {
    switch (_selectedFilter) {
      case CardFilter.due:
        final cards = await _cardRepository.getDueCardsByCollection(
          collectionId,
        );
        return cards.length;
      case CardFilter.newCards:
        final cards = await _cardRepository.getCardsByCollection(collectionId);
        return cards.where((card) => card.repetitions == 0).length;
      case CardFilter.learning:
        final cards = await _cardRepository.getCardsByCollection(collectionId);
        return cards
            .where((card) => card.repetitions > 0 && card.interval < 21)
            .length;
      case CardFilter.all:
        final cards = await _cardRepository.getCardsByCollection(collectionId);
        return cards.length;
    }
  }

  void _startStudySession() async {
    final l10n = AppLocalizations.of(context)!;
    if (_selectedCollections.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pleaseSelectAtLeastOneCollection)),
      );
      return;
    }

    setState(() => _isLoading = true);

    final collectionId = _selectedCollections.length == 1
        ? _selectedCollections.first
        : null;

    setState(() => _isLoading = false);

    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => StudySessionScreen(collectionId: collectionId),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.selectStudyDecks),
        actions: [
          if (_selectedCollections.isNotEmpty)
            TextButton(
              onPressed: _isLoading ? null : _startStudySession,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      l10n.start,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
        ],
      ),
      body: Consumer<CollectionProvider>(
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
                  Text('Error: ${collectionProvider.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadCollections,
                    child: Text(l10n.retry),
                  ),
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
                    l10n.noCollections,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(l10n.createCollectionToStartStudying),
                ],
              ),
            );
          }

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _studyAll,
                    icon: Icon(Icons.play_circle_filled),
                    label: Text(
                      l10n.studyAllDueCards,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ),

              const Divider(height: 1),

              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 2,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    ListTile(
                      dense: true,
                      leading: Icon(
                        _filtersExpanded
                            ? Icons.filter_alt
                            : Icons.filter_alt_outlined,
                      ),
                      title: Text(
                        l10n.filters,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          _filtersExpanded
                              ? Icons.expand_less
                              : Icons.expand_more,
                        ),
                        onPressed: () {
                          setState(() {
                            _filtersExpanded = !_filtersExpanded;
                          });
                        },
                      ),
                      onTap: () {
                        setState(() {
                          _filtersExpanded = !_filtersExpanded;
                        });
                      },
                    ),
                    if (_filtersExpanded) ...[
                      const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.filterByCardType,
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: [
                                FilterChip(
                                  label: Text(l10n.all),
                                  selected: _selectedFilter == CardFilter.all,
                                  onSelected: (selected) {
                                    setState(() {
                                      _selectedFilter = CardFilter.all;
                                    });
                                  },
                                ),
                                FilterChip(
                                  label: Text(l10n.due),
                                  selected: _selectedFilter == CardFilter.due,
                                  onSelected: (selected) {
                                    setState(() {
                                      _selectedFilter = CardFilter.due;
                                    });
                                  },
                                ),
                                FilterChip(
                                  label: Text(l10n.labelNew),
                                  selected:
                                      _selectedFilter == CardFilter.newCards,
                                  onSelected: (selected) {
                                    setState(() {
                                      _selectedFilter = CardFilter.newCards;
                                    });
                                  },
                                ),
                                FilterChip(
                                  label: Text(l10n.learning),
                                  selected:
                                      _selectedFilter == CardFilter.learning,
                                  onSelected: (selected) {
                                    setState(() {
                                      _selectedFilter = CardFilter.learning;
                                    });
                                  },
                                ),
                              ],
                            ),

                            if (_allTags.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Text(
                                l10n.filterByTags,
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                children: _allTags.map((tag) {
                                  final isSelected = _selectedTags.contains(
                                    tag,
                                  );
                                  return FilterChip(
                                    label: Text(tag),
                                    selected: isSelected,
                                    onSelected: (selected) {
                                      setState(() {
                                        if (selected) {
                                          _selectedTags.add(tag);
                                        } else {
                                          _selectedTags.remove(tag);
                                        }
                                      });
                                    },
                                  );
                                }).toList(),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 8),

              Expanded(
                child: FutureBuilder<Map<String, int>>(
                  future: _getCollectionCardCounts(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final cardCounts = snapshot.data!;

                    final filteredCollections = _selectedTags.isEmpty
                        ? collectionProvider.collections
                        : collectionProvider.collections.where((collection) {
                            return collection.tags.any(
                              (tag) => _selectedTags.contains(tag),
                            );
                          }).toList();

                    if (filteredCollections.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.filter_alt_off,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              l10n.noMatchingFilters,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(l10n.tryAdjustingFilters),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredCollections.length,
                      itemBuilder: (context, index) {
                        final collection = filteredCollections[index];
                        final cardCount = cardCounts[collection.id] ?? 0;
                        final isSelected = _selectedCollections.contains(
                          collection.id,
                        );
                        final collectionColor = collection.color != null
                            ? Color(
                                int.parse(
                                  collection.color!.replaceFirst('#', '0xff'),
                                ),
                              )
                            : Colors.blue;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          elevation: isSelected ? 4 : 1,
                          child: CheckboxListTile(
                            value: isSelected,
                            onChanged: cardCount > 0
                                ? (checked) {
                                    setState(() {
                                      if (checked == true) {
                                        _selectedCollections.add(collection.id);
                                      } else {
                                        _selectedCollections.remove(
                                          collection.id,
                                        );
                                      }
                                    });
                                  }
                                : null,
                            secondary: Container(
                              width: 4,
                              height: 48,
                              decoration: BoxDecoration(
                                color: collectionColor,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            title: Text(
                              collection.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              cardCount > 0
                                  ? l10n.cardCountWithFilter(
                                      cardCount,
                                      _getFilterLabel(),
                                    )
                                  : l10n.noCardsWithFilter(_getFilterLabel()),
                              style: TextStyle(
                                color: cardCount > 0
                                    ? Colors.grey[600]
                                    : Colors.grey[400],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              if (_selectedCollections.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _startStudySession,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.play_arrow),
                        label: Text(
                          l10n.studyDecksCount(_selectedCollections.length),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  String _getFilterLabel() {
    switch (_selectedFilter) {
      case CardFilter.due:
        return 'due';
      case CardFilter.newCards:
        return 'new';
      case CardFilter.learning:
        return 'learning';
      case CardFilter.all:
        return '';
    }
  }
}
