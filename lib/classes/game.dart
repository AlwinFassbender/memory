import 'package:flutter/material.dart';
import 'package:memory/classes/card.dart';
import 'package:memory/classes/player.dart';
import 'package:memory/shared/types.dart';

class MemoryGame {
  final Deck deck;
  final GameOptions options;
  int currentPlayerIndex = 0;
  final List<Player> players;

  /// Print out what happens during the game
  bool verbose;

  bool get isOver => deck.every((card) => card.isMatched);
  Player get currentPlayer => players[currentPlayerIndex];

  MemoryGame(this.options, {this.verbose = false})
      : deck = List.generate(options.pairs * 2, (index) => MemoryCard(index ~/ 2)),
        players = options.players.map((option) => Player(options: option)).toList() {
    deck.shuffle();
  }

  void selectCards(int firstIndex, int secondIndex) {
    final firstCard = deck[firstIndex];
    final secondCard = deck[secondIndex];

    if (verbose) {
      debugPrint(
          'Player $currentPlayerIndex picks cards $firstIndex (${deck[firstIndex].id}) and $secondIndex (${deck[secondIndex].id}).');
    }
    assert(!firstCard.isMatched, "Can't pick a matched card.");
    assert(!secondCard.isMatched, "Can't pick a matched card.");

    for (final (playerIndex, player) in players.indexed) {
      player.storeCardPosition(cardIndex: firstIndex, cardValue: firstCard.id);
      player.storeCardPosition(cardIndex: secondIndex, cardValue: secondCard.id);
      if (verbose) {
        debugPrint('Player $playerIndex knows cards ${player.cardPositions}).');
      }
    }
    if (firstCard.id == secondCard.id) {
      if (verbose) debugPrint('Match!');
      firstCard.matchedByPlayer = currentPlayerIndex;
      secondCard.matchedByPlayer = currentPlayerIndex;

      players[currentPlayerIndex].matchedCards.add(firstCard);
      players[currentPlayerIndex].matchedCards.add(secondCard);
    } else {
      if (verbose) debugPrint('Not a match.');
      currentPlayerIndex = (currentPlayerIndex + 1) % players.length;
    }
  }

  List<int> getAiPicks() {
    final picks = currentPlayer.pickPositionsToUncover(deck);

    // if (picks.moveType == MoveType.zeroMove) {
    //   if (verbose) debugPrint('Both players made a 0-move. Aborting game.');
    //   return [];
    // } else
    if (verbose) {
      debugPrint('MoveType: ${picks.moveType}');
    }

    return [picks.firstPick, picks.secondPick];
  }
  // void play() {
  //   while (deck.any((card) => !card.isMatched)) {
  //     for (final (index, currentPlayer) in players.indexed) {
  //       bool hasMatched = true;
  //       while (hasMatched) {
  //         final picks = currentPlayer.pickCards(deck);
  //         _rememberCards(picks);

  //         if (deck[picks.firstPick].id == deck[picks.secondPick].id) {
  //           if (verbose) print('It\'s a match!');
  //           deck[picks.firstPick].matchedByPlayer = currentPlayerIndex;
  //           deck[picks.secondPick].matchedByPlayer = currentPlayerIndex;
  //           currentPlayer.matchedCards.add(deck[picks.firstPick]);
  //         } else {
  //           hasMatched = false;
  //         }
  //       }
  //     }

  //   if (verbose) {
  //     print(
  //         'Player $currentPlayerIndex picks cards $firstPick (${deck[firstPick].id}) and $secondPick (${deck[secondPick].id}).');
  //   }
  //   if (moveType == MoveType.zeroMove) {
  //     if (_lastMoveType == MoveType.zeroMove) {
  //       print('Both players made a 0-move. Aborting game.');
  //       break;
  //     }
  //   } else if (verbose) {
  //     print('MoveType: $moveType');
  //   }
  //   _lastMoveType = moveType;
  // }

  void printResults() {
    print('\nGame over!');
    for (Player player in players) {
      print('Player $currentPlayerIndex matched ${player.matchedCards.length ~/ 2} pairs.');
    }

    if (players[0].matchedCards.length > players[1].matchedCards.length) {
      print('Player 0 wins!');
    } else if (players[0].matchedCards.length < players[1].matchedCards.length) {
      print('Player 1 wins!');
    } else {
      print('It\'s a tie!');
    }
  }

  int? determineWinner() {
    if (players[0].matchedCards.length > players[1].matchedCards.length) {
      return 0;
    } else if (players[0].matchedCards.length < players[1].matchedCards.length) {
      return 1;
    } else {
      return null;
    }
  }
}

class GameOptions {
  final int pairs;
  final int showCardTime;
  final List<PlayerOptions> players;

  GameOptions({
    required this.pairs,
    this.showCardTime = 2,
    required this.players,
  });

  GameOptions copyWith({int? pairs, int? showCardTime, List<PlayerOptions>? players}) {
    return GameOptions(
      pairs: pairs ?? this.pairs,
      showCardTime: showCardTime ?? this.showCardTime,
      players: players ?? this.players,
    );
  }
}