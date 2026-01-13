import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/study_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../models/review_log.dart';
import '../../services/spaced_repetition_service.dart';

class StudySessionScreen extends StatefulWidget {
  final String? collectionId;

  const StudySessionScreen({super.key, this.collectionId});

  @override
  State<StudySessionScreen> createState() => _StudySessionScreenState();
}

class _StudySessionScreenState extends State<StudySessionScreen> {
  final SpacedRepetitionService _srService = SpacedRepetitionService();
  DateTime? _cardStartTime;
  Duration? _lastAnswerDuration;
  String? _lastCardId;
  

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSession();
    });
  }

  void _startTimer() {
    setState(() {
      _cardStartTime = DateTime.now();
      _lastAnswerDuration = null;
    });
  }

  void _stopTimer() {
    if (_cardStartTime != null) {
      setState(() {
        _lastAnswerDuration = DateTime.now().difference(_cardStartTime!);
      });
    }
  }

  void _checkCardChange(String? currentCardId) {
    if (currentCardId != _lastCardId && currentCardId != null) {
      _lastCardId = currentCardId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startTimer();
      });
    }
  }

  Future<void> _loadSession() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final studyProvider = Provider.of<StudyProvider>(context, listen: false);
    final settingsProvider = Provider.of<SettingsProvider>(
      context,
      listen: false,
    );

    if (authProvider.currentUser != null) {
      studyProvider.onSyncNeeded = () {
        authProvider.scheduleDebouncedSync();
      };

      await settingsProvider.loadSettings(authProvider.currentUser!.id);
      final settings = settingsProvider.settings;

      await studyProvider.loadDueCards(
        authProvider.currentUser!.id,
        collectionId: widget.collectionId,
        limit: settings?.maxReviewsPerDay,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.collectionId != null ? 'Study Collection' : 'Study'),
        actions: [
          Consumer<StudyProvider>(
            builder: (context, studyProvider, _) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    '${studyProvider.remainingCards} cards left',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<StudyProvider>(
        builder: (context, studyProvider, _) {
          if (studyProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (studyProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${studyProvider.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadSession,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (!studyProvider.hasMoreCards) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.celebration, size: 100, color: Colors.green),
                  const SizedBox(height: 24),
                  Text(
                    'Great job!',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'You\'ve reviewed ${studyProvider.reviewedToday} cards today',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Done'),
                  ),
                ],
              ),
            );
          }

          final card = studyProvider.currentCard;
          if (card == null) {
            return const Center(child: Text('No cards to study'));
          }

          _checkCardChange(card.id);

          return Column(
            children: [
              LinearProgressIndicator(
                value: studyProvider.dueCards.isEmpty
                    ? 0
                    : (studyProvider.dueCards.length -
                              studyProvider.remainingCards) /
                          studyProvider.dueCards.length,
              ),

              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: GestureDetector(
                      onTap: studyProvider.showAnswer
                          ? null
                          : () {
                              _stopTimer();
                              studyProvider.toggleAnswer();
                            },
                          child: TweenAnimationBuilder<double>(
                        key: ValueKey('${studyProvider.currentCard?.id}_${studyProvider.showAnswer}'),
                        tween: Tween<double>(
                          begin: 0,
                          end: studyProvider.showAnswer ? pi : 0,
                        ),
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                        builder: (context, value, child) {
                          final isFront = value < pi / 2;

                          return Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.001)
                              ..rotateY(value),
                            child: Card(
                              elevation: 8,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(32),
                                child: Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.identity()
                                    ..rotateY(isFront ? 0 : pi),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Builder(builder: (context) {
                                        final collectionName = studyProvider.getCurrentCollectionName();
                                        if (collectionName == null || collectionName.isEmpty) return const SizedBox.shrink();
                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 8.0),
                                          child: Text(
                                            'From: $collectionName',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[700],
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        );
                                      }),
                                      if (isFront) ...[
                                        const Text(
                                          'Question',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 24),
                                        Text(
                                          card.front,
                                          style: const TextStyle(fontSize: 24),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 48),
                                        const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.touch_app,
                                              color: Colors.grey,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              'Tap to reveal',
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ] else ...[
                                        const Text(
                                          'Answer',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 24),
                                        Text(
                                          card.back,
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 16),
                                        const Divider(),
                                        const SizedBox(height: 16),
                                        Text(
                                          card.front,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),

              if (studyProvider.showAnswer)
                Consumer<SettingsProvider>(
                  builder: (context, settingsProvider, _) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          if (settingsProvider.settings?.showAnswerTimer ??
                              false)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                _lastAnswerDuration != null
                                    ? 'Time: ${_lastAnswerDuration!.inSeconds}s'
                                    : '',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          const Text(
                            'How well did you know this?',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildRatingButton(
                                  context,
                                  'Wrong',
                                  Colors.red,
                                  ReviewQuality.wrong,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildRatingButton(
                                  context,
                                  'Hard',
                                  Colors.orange,
                                  ReviewQuality.hard,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildRatingButton(
                                  context,
                                  'Good',
                                  Colors.blue,
                                  ReviewQuality.good,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildRatingButton(
                                  context,
                                  'Easy',
                                  Colors.green,
                                  ReviewQuality.easy,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRatingButton(
    BuildContext context,
    String label,
    Color color,
    ReviewQuality quality,
  ) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, _) {
        final showIntervals =
            settingsProvider.settings?.showIntervalButtons ?? false;

        return ElevatedButton(
          onPressed: () async {
            final authProvider = Provider.of<AuthProvider>(
              context,
              listen: false,
            );
            final studyProvider = Provider.of<StudyProvider>(
              context,
              listen: false,
            );

            if (authProvider.currentUser != null) {
              await studyProvider.submitReview(
                authProvider.currentUser!.id,
                quality,
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: showIntervals
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Consumer<StudyProvider>(
                      builder: (context, studyProvider, _) {
                        final interval = _getIntervalForQuality(
                          studyProvider.currentCard,
                          quality,
                        );
                        return Text(
                          interval,
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ],
                )
              : Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        );
      },
    );
  }

  String _getIntervalForQuality(dynamic card, ReviewQuality quality) {
    if (card == null) return '';

    final result = _srService.calculateNextReview(card, quality);

    if (result.interval == 0) {
      return '<10m';
    } else if (result.interval == 1) {
      return '1d';
    } else if (result.interval < 30) {
      return '${result.interval}d';
    } else if (result.interval < 365) {
      final months = (result.interval / 30).round();
      return '${months}mo';
    } else {
      final years = (result.interval / 365).round();
      return '${years}y';
    }
  }
}
