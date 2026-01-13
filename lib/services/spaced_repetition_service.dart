import 'dart:math';
import '../models/card_model.dart';
import '../models/review_log.dart';

class SpacedRepetitionService {
  /// FSRS Algorithm implementation
  /// Free Spaced Repetition Scheduler - a modern alternative to SM-2
  /// 
  /// Quality ratings:
  /// - Wrong (0): Complete blackout - card is forgotten
  /// - Hard (1): Correct response recalled with serious difficulty
  /// - Good (2): Correct response with some hesitation
  /// - Easy (3): Perfect response
  
  // FSRS parameters (optimized defaults)
  static const List<double> defaultWeights = [
    0.4072, 1.1829, 3.1262, 15.4722, 7.2102,
    0.5316, 1.0651, 0.0234, 1.616, 0.1544,
    1.0824, 1.9813, 0.0953, 0.2975, 2.2042,
    0.2407, 2.9466, 0.5034, 0.6567
  ];
  
  static const double requestRetention = 0.9; // Target retention rate
  static const double maximumInterval = 36500.0; // 100 years in days
  static const double minimumInterval = 1.0;
  
  /// Calculate new card state after review
  ReviewResult calculateNextReview(CardModel card, ReviewQuality quality) {
    final now = DateTime.now();
    
    // Convert card state to FSRS state
    double stability = card.interval.toDouble();
    double difficulty = _easeToDifficulty(card.easeFactor);
    int repetitions = card.repetitions;
    
    // Handle new cards (no previous reviews)
    if (card.nextReviewDate == null || repetitions == 0) {
      return _handleNewCard(quality, now);
    }
    
    // Calculate elapsed days since last review
    final elapsedDays = max(0, now.difference(card.nextReviewDate!).inDays);
    
    // Calculate retrievability (probability of recall)
    final retrievability = _calculateRetrievability(stability, elapsedDays.toDouble());
    
    // Update stability and difficulty based on review quality
    double newStability;
    double newDifficulty;
    int newRepetitions;
    
    if (quality == ReviewQuality.wrong) {
      // Card forgotten - reset with short interval
      newStability = _calculateNewStabilityAfterLapse(stability, difficulty);
      newDifficulty = _updateDifficultyAfterLapse(difficulty);
      newRepetitions = 0;
    } else {
      // Card remembered - increase stability
      newStability = _calculateNewStabilityAfterSuccess(
        stability,
        difficulty,
        retrievability,
        quality,
      );
      newDifficulty = _updateDifficultyAfterSuccess(difficulty, quality);
      newRepetitions = repetitions + 1;
    }
    
    // Calculate interval from stability
    final newInterval = _stabilityToInterval(newStability).round();
    
    // Calculate next review date
    final nextReviewDate = now.add(Duration(days: newInterval));
    
    // Convert difficulty back to ease factor for compatibility
    final newEaseFactor = _difficultyToEase(newDifficulty);
    
    return ReviewResult(
      easeFactor: newEaseFactor,
      interval: newInterval,
      repetitions: newRepetitions,
      nextReviewDate: nextReviewDate,
    );
  }
  
  ReviewResult _handleNewCard(ReviewQuality quality, DateTime now) {
    double initialStability;
    double difficulty = 5.0; // Default difficulty for new cards
    
    switch (quality) {
      case ReviewQuality.wrong:
        // Relearn immediately
        initialStability = defaultWeights[0];
        difficulty = 7.0;
        return ReviewResult(
          easeFactor: 2.5,
          interval: 0,
          repetitions: 0,
          nextReviewDate: now.add(const Duration(minutes: 10)),
        );
      
      case ReviewQuality.hard:
        initialStability = defaultWeights[1];
        difficulty = 6.0;
        break;
      
      case ReviewQuality.good:
        initialStability = defaultWeights[2];
        difficulty = 5.0;
        break;
      
      case ReviewQuality.easy:
        initialStability = defaultWeights[3];
        difficulty = 4.0;
        break;
    }
    
    final interval = _stabilityToInterval(initialStability).round();
    
    return ReviewResult(
      easeFactor: _difficultyToEase(difficulty),
      interval: interval,
      repetitions: 1,
      nextReviewDate: now.add(Duration(days: interval)),
    );
  }
  
  double _calculateRetrievability(double stability, double elapsedDays) {
    return pow(1 + elapsedDays / (9 * stability), -1).toDouble();
  }
  
  double _calculateNewStabilityAfterSuccess(
    double oldStability,
    double difficulty,
    double retrievability,
    ReviewQuality quality,
  ) {
    final hardPenalty = quality == ReviewQuality.hard ? defaultWeights[15] : 1.0;
    final easyBonus = quality == ReviewQuality.easy
        ? defaultWeights[16]
        : 1.0;
    
    return oldStability *
        (1 +
            exp(defaultWeights[8]) *
                (11 - difficulty) *
                pow(oldStability, -defaultWeights[9]) *
                (exp((1 - retrievability) * defaultWeights[10]) - 1) *
                hardPenalty *
                easyBonus);
  }
  
  double _calculateNewStabilityAfterLapse(double oldStability, double difficulty) {
    return max(
      minimumInterval,
      defaultWeights[11] *
          pow(difficulty, -defaultWeights[12]) *
          (pow(oldStability + 1, defaultWeights[13]) - 1) *
          exp((1 - 1) * defaultWeights[14]),
    );
  }
  
  double _updateDifficultyAfterSuccess(double difficulty, ReviewQuality quality) {
    final deltaD = -defaultWeights[6] * (_qualityToGrade(quality) - 3);
    return _constrainDifficulty(difficulty + deltaD);
  }
  
  double _updateDifficultyAfterLapse(double difficulty) {
    return _constrainDifficulty(difficulty + defaultWeights[7]);
  }
  
  double _constrainDifficulty(double difficulty) {
    return max(1.0, min(10.0, difficulty));
  }
  
  double _stabilityToInterval(double stability) {
    final interval = stability * 9 * (1 / requestRetention - 1);
    return max(minimumInterval, min(maximumInterval, interval));
  }
  
  int _qualityToGrade(ReviewQuality quality) {
    switch (quality) {
      case ReviewQuality.wrong:
        return 1;
      case ReviewQuality.hard:
        return 2;
      case ReviewQuality.good:
        return 3;
      case ReviewQuality.easy:
        return 4;
    }
  }
  
  // Helper methods to convert between ease factor and difficulty
  double _easeToDifficulty(double easeFactor) {
    // Convert ease factor (1.3-3.0) to difficulty (1-10)
    // Higher ease = lower difficulty
    return max(1.0, min(10.0, 11 - (easeFactor * 3)));
  }
  
  double _difficultyToEase(double difficulty) {
    // Convert difficulty (1-10) to ease factor (1.3-3.0)
    final ease = (11 - difficulty) / 3;
    return max(1.3, min(3.0, ease));
  }
  
  /// Get cards due for review today
  bool isCardDue(CardModel card) {
    if (card.nextReviewDate == null) {
      return true; // New card
    }
    return card.nextReviewDate!.isBefore(DateTime.now()) ||
        card.nextReviewDate!.isAtSameMomentAs(DateTime.now());
  }
  
  /// Get the number of days until next review
  int getDaysUntilReview(CardModel card) {
    if (card.nextReviewDate == null) {
      return 0;
    }
    final difference = card.nextReviewDate!.difference(DateTime.now());
    return difference.inDays;
  }
}

class ReviewResult {
  final double easeFactor;
  final int interval;
  final int repetitions;
  final DateTime nextReviewDate;

  ReviewResult({
    required this.easeFactor,
    required this.interval,
    required this.repetitions,
    required this.nextReviewDate,
  });
}