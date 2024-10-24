import 'dart:math';

import 'package:flutter/material.dart';
import 'package:memory/classes/game.dart';
import 'package:memory/classes/player.dart';
import 'package:memory/widgets/card.dart';
import 'package:memory/widgets/game_options.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late MemoryGame game = MemoryGame(
    verbose: true,
    GameOptions(
      pairs: 8,
      showCardTime: 2,
      players: [
        PlayerOptions(human: false, memoryChance: 1, useOptimalStrategy: true),
        PlayerOptions(human: false, memoryChance: 1, useOptimalStrategy: true),
      ],
    ),
  );

  final List<int> selectedCards = [];

  int get totalCards => game.deck.length;

  @override
  void initState() {
    super.initState();
    _maybePlayAITurn();
  }

  @override
  Widget build(BuildContext context) {
    List<int> gridDimensions = _getGridDimensions(totalCards);
    // int rows = gridDimensions[0];
    int columns = gridDimensions[1];

    const innerPadding = 8.0;
    const verticalOuterPadding = 16.0;
    final horizontalOuterPadding = _getHorizontalOuterPadding(verticalOuterPadding);
    return Scaffold(
      appBar: AppBar(
        title: Text("Player: ${game.currentPlayerIndex}"),
        actions: [IconButton(onPressed: _onSettingsCalled, icon: const Icon(Icons.settings))],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: verticalOuterPadding, horizontal: horizontalOuterPadding),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            childAspectRatio: 1.0,
            crossAxisSpacing: innerPadding,
            mainAxisSpacing: innerPadding,
          ),
          itemCount: totalCards,
          itemBuilder: (context, index) {
            final card = game.deck[index];
            if (card.isMatched) return const SizedBox.shrink();
            bool isFlipped = selectedCards.contains(index) || card.isMatched;

            return GestureDetector(
              onTap: () => _onCardTap(index),
              child: isFlipped ? CardFront(card) : const CardBack(),
            );
          },
        ),
      ),
    );
  }

  void _onSettingsCalled() {
    showDialog(
      context: context,
      builder: (context) {
        return GameOptionsDialog(
            gameOptions: game.options,
            onClosed: (gameOptions) {
              _reset(gameOptions);
              _maybePlayAITurn();
            });
      },
    );
  }

  double _getHorizontalOuterPadding(double verticalOuterPadding) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final statusBarHeight = MediaQuery.of(context).padding.top;
    final availableHeight = screenHeight - kToolbarHeight - statusBarHeight - verticalOuterPadding * 2;

    final test = (screenWidth - availableHeight) / 2;
    return test.isNegative ? verticalOuterPadding : test.abs();
  }

  void _onCardTap(int index) {
    if (!game.currentPlayer.options.human || selectedCards.length == 2 || selectedCards.contains(index)) {
      return;
    }

    setState(() {
      selectedCards.add(index);

      if (selectedCards.length == 2) {
        Future.delayed(Duration(seconds: game.options.showCardTime), () {
          game.selectCards(selectedCards[0], selectedCards[1]);
          setState(() {
            selectedCards.clear();
          });
          _onTurnEnd();
        });
      }
    });
  }

  void _onTurnEnd() {
    if (game.isOver) {
      _endGame();
    } else {
      _maybePlayAITurn();
    }
  }

  Future<void> _maybePlayAITurn() async {
    if (!game.currentPlayer.options.human) {
      final aiPicks = game.getAiPicks();

      selectedCards.add(aiPicks.firstPick);
      await Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          selectedCards.add(aiPicks.secondPick);
        });
      });
      Future.delayed(Duration(seconds: game.options.showCardTime), () {
        setState(() {
          game.selectCards(aiPicks.firstPick, aiPicks.secondPick);
          selectedCards.clear();
          _onTurnEnd();
        });
      });
      // _onTurnEnd();
    } else {
      _endGame();
    }
  }

  void _endGame() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Game Over!"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Player ${game.currentPlayerIndex} wins!"),
              for (final (index, player) in game.players.indexed)
                Text("Player $index matched ${player.matchedCards.length ~/ 2} pairs."),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _reset(game.options);
                _maybePlayAITurn();
              },
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  void _reset(GameOptions options) {
    setState(() {
      selectedCards.clear();
      game = MemoryGame(options);
    });
  }

  List<int> _getGridDimensions(int totalCards) {
    int a = sqrt(totalCards).round();

    while (totalCards % a > 0) {
      a--;
    }
    return [a, totalCards ~/ a];
  }
}
