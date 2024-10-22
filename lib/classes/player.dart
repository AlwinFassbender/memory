import 'dart:math';

import 'package:collection/collection.dart';
import 'package:memory/classes/picks.dart';
import 'package:memory/shared/types.dart';

class Player {
  final PlayerOptions options;

  /// Maps card id: card position
  final Map<int, Set<int>> cardPositions = {};
  final Deck matchedCards = [];

  Player({
    required this.options,
  });

  // bool _knowsCard(Deck deck, int position) => cardPositions.containsKey(deck[position].id);

  Picks pickPositionsToUncover(Deck deck) {
    // Clear out matched cards of player's memory so that k is accurate
    final matchedCards = deck.where((card) => card.isMatched);
    for (final card in matchedCards) {
      cardPositions.remove(card.id);
    }

    final knownMatches = cardPositions.values.where((positions) => positions.length == 2);
    if (knownMatches.isNotEmpty) {
      final firstPick = knownMatches.first.first;
      final secondPick = knownMatches.first.last;
      return Picks(firstPick, secondPick, moveType: MoveType.twoMove);
    }

    if (options.useOptimalStrategy) {
      final moveType = _getMoveType(deck.length ~/ 2);
      if (moveType == MoveType.zeroMove) {
        final firstPick = cardPositions.values.last.last;
        final secondPick = cardPositions.values.first.first;

        return Picks(firstPick, secondPick, moveType: moveType);
      } else if (moveType == MoveType.oneMove) {
        final firstPick = _pickNewPosition(deck);
        final secondPick = _getMatchingCardPosition(deck, firstPick) ?? cardPositions.values.last.last;
        return Picks(firstPick, secondPick, moveType: moveType);
      }
    }

    final firstPick = _pickNewPosition(deck);
    final secondPick = _getMatchingCardPosition(deck, firstPick) ?? _pickNewPosition(deck, exclude: firstPick);
    return Picks(
      firstPick,
      secondPick,
    );
  }

  void storeCardPosition({required int cardValue, required int cardIndex}) {
    if (options.human) return;
    final rememberCard = Random().nextDouble() < options.memoryChance;
    if (rememberCard) {
      if (cardPositions.containsKey(cardValue)) {
        cardPositions[cardValue]?.add(cardIndex);
      } else {
        cardPositions[cardValue] = {cardIndex};
      }
    }
  }

  int? _getMatchingCardPosition(Deck deck, int cardIndex) {
    final cardValue = deck[cardIndex].id;
    final matches = cardPositions[cardValue];
    return matches?.firstWhereOrNull((element) => element != cardIndex);
  }

  MoveType _getMoveType(int pairs) {
    int k = cardPositions.length;
    int n = pairs;
    if ((n + k).isOdd && k >= (2 * (n + 1)) / 3) {
      return MoveType.zeroMove;
    }
    if (k >= 1 && (n + k).isEven) return MoveType.oneMove;
    if (n == 6 && k == 1) return MoveType.oneMove;
    if (k == 0 || (n + k).isOdd) {
      return MoveType.twoMove;
    }
    return MoveType.twoMove;
  }

  int _pickNewPosition(Deck deck, {int? exclude}) {
    int pick;

    do {
      pick = Random().nextInt(deck.length);
    } while (deck[pick].isMatched || pick == exclude || cardPositions.values.flattened.contains(pick));

    return pick;
  }
}

class PlayerOptions {
  final bool human;
  final double memoryChance;
  final bool useOptimalStrategy;

  PlayerOptions({
    this.human = false,
    this.memoryChance = 1,
    this.useOptimalStrategy = false,
  });

  PlayerOptions copyWith({
    bool? human,
    double? memoryChance,
    bool? useOptimalStrategy,
  }) =>
      PlayerOptions(
        human: human ?? this.human,
        memoryChance: memoryChance ?? this.memoryChance,
        useOptimalStrategy: useOptimalStrategy ?? this.useOptimalStrategy,
      );
}
