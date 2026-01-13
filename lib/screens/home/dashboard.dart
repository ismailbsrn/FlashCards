import 'package:flashcards2/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/collection_provider.dart';
import '../../providers/auth_provider.dart';
import '../../repositories/card_repository.dart';
import '../../repositories/review_log_repository.dart';
import '../collections/collection_screen.dart';
import '../study/study_selection_screen.dart';

class DashboardTab extends StatefulWidget {
  final VoidCallback? onViewAllCollections;

  const DashboardTab({super.key, this.onViewAllCollections});

  @override
  State<DashboardTab> createState() => DashboardTabState();
}

class DashboardTabState extends State<DashboardTab>
    with AutomaticKeepAliveClientMixin {
  final CardRepository _cardRepository = CardRepository();
  final ReviewLogRepository _reviewLogRepository = ReviewLogRepository();
  int _totalCards = 0;
  int _dueCards = 0;
  int _studiedToday = 0;
  bool _isLoadingStats = false;
  Map<String, int> _reviewHistory = {};

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadData();
    });
  }

  Future<void> loadData() async {
    if (_isLoadingStats) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final collectionProvider = Provider.of<CollectionProvider>(
      context,
      listen: false,
    );

    if (authProvider.currentUser != null) {
      setState(() => _isLoadingStats = true);

      await collectionProvider.loadCollections(authProvider.currentUser!.id);

      final totalCards = await _cardRepository.getTotalCardCount(
        authProvider.currentUser!.id,
      );
      final dueCards = await _cardRepository.getDueCardCount(
        authProvider.currentUser!.id,
      );
      final studiedToday = await _reviewLogRepository.getReviewCountToday(
        authProvider.currentUser!.id,
      );

      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(days: 29));
      final reviewHistory = await _reviewLogRepository
          .getReviewCountByDateRange(
            authProvider.currentUser!.id,
            startDate,
            endDate,
          );

      if (mounted) {
        setState(() {
          _totalCards = totalCards;
          _dueCards = dueCards;
          _studiedToday = studiedToday;
          _reviewHistory = reviewHistory;
          _isLoadingStats = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
                  'Error: ${collectionProvider.error}',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(onPressed: loadData, child: const Text('Retry')),
              ],
            ),
          );
        }

        final collections = collectionProvider.collections;

        return RefreshIndicator(
          onRefresh: loadData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.welcomeBack,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),

                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context)
                        .push(
                          MaterialPageRoute(
                            builder: (_) => const StudySelectionScreen(),
                          ),
                        )
                        .then((_) => loadData());
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: Text(l10n.studyNow),
                ),
                const SizedBox(height: 24),

                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.4,
                  children: [
                    _buildStatCard(
                      context,
                      l10n.totalDecks,
                      collections.length.toString(),
                      Icons.collections_bookmark,
                      Colors.blue,
                    ),
                    _buildStatCard(
                      context,
                      l10n.totalCards,
                      _totalCards.toString(),
                      Icons.style,
                      Colors.purple,
                    ),
                    _buildStatCard(
                      context,
                      l10n.dueToday,
                      _dueCards.toString(),
                      Icons.today,
                      Colors.orange,
                    ),
                    _buildStatCard(
                      context,
                      l10n.studiedToday,
                      _studiedToday.toString(),
                      Icons.check_circle,
                      Colors.green,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                if (_reviewHistory.isNotEmpty) ...[
                  Text(
                    l10n.studyActivity,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _buildHeatmap(),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.yourDecks,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (collections.isNotEmpty)
                      TextButton(
                        onPressed: widget.onViewAllCollections,
                        child: Text(l10n.viewAll),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                if (collections.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.collections_bookmark,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              l10n.noDecks,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              l10n.createDeck,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  ...collections.take(5).map((collection) {
                    final collectionColor = collection.color != null
                        ? Color(
                            int.parse(
                              collection.color!.replaceFirst('#', '0xff'),
                            ),
                          )
                        : Colors.blue;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context)
                              .push(
                                MaterialPageRoute(
                                  builder: (_) => CollectionDetailScreen(
                                    collection: collection,
                                  ),
                                ),
                              )
                              .then((_) => loadData());
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Container(
                                width: 4,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: collectionColor,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      collection.name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    if (collection.description != null)
                                      Text(
                                        collection.description!,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    const SizedBox(height: 2),
                                    if (collection.tags.isNotEmpty)
                                      Wrap(
                                        spacing: 4,
                                        children: collection.tags.take(2).map((
                                          tag,
                                        ) {
                                          return Chip(
                                            label: Text(tag),
                                            labelStyle: const TextStyle(
                                              fontSize: 10,
                                            ),
                                            padding: EdgeInsets.zero,
                                            visualDensity:
                                                VisualDensity.compact,
                                          );
                                        }).toList(),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),

                if (collections.length > 5)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Center(
                      child: TextButton(
                        onPressed: widget.onViewAllCollections,
                        child: Text(
                          l10n.viewAllCollections,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 28),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeatmap() {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(const Duration(days: 29));

    final days = <Widget>[];

    for (int i = 0; i < 30; i++) {
      final date = startDate.add(Duration(days: i));
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final count = _reviewHistory[dateStr] ?? 0;

      days.add(
        Tooltip(
          message: '${DateFormat('MMM d').format(date)}\n$count reviews',
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: _getHeatmapColor(count),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 6,
          childAspectRatio: 1,
          children: days,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Less', style: TextStyle(fontSize: 12)),
            const SizedBox(width: 8),
            ...[0, 1, 5, 10, 20].map(
              (count) => Container(
                width: 16,
                height: 16,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: _getHeatmapColor(count),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text('More', style: TextStyle(fontSize: 12)),
          ],
        ),
      ],
    );
  }

  Color _getHeatmapColor(int count) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (count == 0) {
      return isDark ? Colors.grey[800]! : Colors.grey[200]!;
    }
    if (count < 5) {
      return isDark ? Colors.green[700]! : Colors.green[200]!;
    }
    if (count < 10) {
      return isDark ? Colors.green[600]! : Colors.green[400]!;
    }
    if (count < 20) {
      return isDark ? Colors.green[500]! : Colors.green[600]!;
    }
    return isDark ? Colors.green[400]! : Colors.green[800]!;
  }
}
