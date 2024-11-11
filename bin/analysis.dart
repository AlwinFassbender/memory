import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:collection/collection.dart';
import 'package:csv/csv.dart';
import 'package:memory/classes/game.dart';
import 'package:memory/classes/player.dart';
import 'package:memory/shared/types.dart';

void main() async {
  // For each game configuration (2-player, 3-player, etc.)
  for (var gameOption in gameOptionsWithName) {
    String name = gameOption['name'];
    List<PlayerOptions> playerOptions = gameOption['options'];

    // Create headers for the CSV file
    int maxPlayers = playerOptions.length;
    List<String> csvHeaders = ['num_pairs', 'winner_index', 'game_length'];
    for (int i = 0; i < maxPlayers; i++) {
      csvHeaders.addAll(['player_${i}_turns', 'player_${i}_cards']);
    }

    List<List<dynamic>> csvData = [csvHeaders];

    // Loop over pair configurations (1 to 50 pairs)
    for (int pairs = 1; pairs <= 50; pairs++) {
      GameOptions optionsWithPairs = GameOptions(
        pairs: pairs,
        players: playerOptions,
      );

      final batchSize = 10;
      final maxConcurrentBatches = 5;
      final gamesTotal = 1000;
      for (int i = 0; i < gamesTotal / (batchSize * maxConcurrentBatches); i++) {
        List<Future<List<List<dynamic>>>> gameFutures = [];
        for (int j = 0; j < maxConcurrentBatches; j++) {
          gameFutures.add(runGamesInIsolate(optionsWithPairs, batchSize));
        }

        var results = await Future.wait(gameFutures);
        for (var result in results.flattened) {
          // Add num_pairs to each result
          csvData.add([pairs, ...result]);
        }
      }
    }

    // Save results with the player option name
    await writeResultsToCsv(csvData, name);
    print('Games completed and results saved to $name.csv');
  }
}

Future<void> runWithLimitedConcurrency(int concurrencyLimit, List<Future Function()> tasks) async {
  final pool = <Future>[];
  for (final task in tasks) {
    if (pool.length >= concurrencyLimit) {
      await Future.any(pool);
    }
    final future = task();
    pool.add(future);
    future.then((_) => pool.remove(future));
  }
  await Future.wait(pool);
}

Future<List<List<dynamic>>> runGamesInIsolate(GameOptions options, int gamesCount) async {
  final receivePort = ReceivePort();
  Isolate isolate = await Isolate.spawn(playGamesInBatch, [receivePort.sendPort, options, gamesCount]);
  final results = await receivePort.first;
  isolate.kill(priority: Isolate.immediate);
  return results;
}

void playGamesInBatch(List<dynamic> args) {
  SendPort sendPort = args[0];
  GameOptions options = args[1];
  int gamesCount = args[2];

  List<List<dynamic>> results = [];
  for (int i = 0; i < gamesCount; i++) {
    MemoryGame game = MemoryGame(
      options,
      verbose: false,
    );

    int gameLength = 0;
    List<int> playerTurns = List.filled(options.players.length, 0);
    List<MoveType> moveTypes = List.filled(options.players.length, MoveType.twoMove);

    while (!game.isOver) {
      if (!game.currentPlayer.options.human) {
        playerTurns[game.currentPlayerIndex]++;
        var aiPicks = game.getAiPicks();
        moveTypes[game.currentPlayerIndex] = aiPicks.moveType;
        game.selectCards(aiPicks.firstPick, aiPicks.secondPick);
      }
      gameLength++;
      if (moveTypes.every((element) => element == MoveType.zeroMove)) {
        break;
      }
    }

    List<int> playerCards = game.players.map((p) => p.matchedCards.length ~/ 2).toList();
    int winnerIndex = playerCards.indexOf(playerCards.reduce((a, b) => a > b ? a : b));
    if (playerCards.every((element) => element == playerCards[0])) {
      winnerIndex = -1;
    }
    List<dynamic> result = [winnerIndex, gameLength];

    // Append turns and cards for each player dynamically
    for (int i = 0; i < options.players.length; i++) {
      result.addAll([playerTurns[i], playerCards[i]]);
    }

    results.add(result);
  }

  sendPort.send(results);
}

Future<void> writeResultsToCsv(List<List<dynamic>> csvData, String fileName) async {
  String csv = const ListToCsvConverter().convert(csvData);

  // Write the CSV to a file with the provided name
  final file = File('assets/data/results/$fileName.csv');
  await file.writeAsString(csv);
}

List<Map<String, dynamic>> gameOptionsWithName = [
  {
    'name': 'perfect_perfect',
    'options': [
      PlayerOptions(memoryChance: 1, useOptimalStrategy: true),
      PlayerOptions(memoryChance: 1, useOptimalStrategy: true),
    ],
  },

  // {
  //   'name': 'random_perfect',
  //   'options': [
  //     PlayerOptions(memoryChance: 0, useOptimalStrategy: false),
  //     PlayerOptions(memoryChance: 1, useOptimalStrategy: true),
  //   ],
  // },

  // {
  //   'name': 'perfect_random',
  //   'options': [
  //     PlayerOptions(memoryChance: 1, useOptimalStrategy: true),
  //     PlayerOptions(memoryChance: 0, useOptimalStrategy: true),
  //   ],
  // },

  // {
  //   'name': 'random_random',
  //   'options': [
  //     PlayerOptions(memoryChance: 0, useOptimalStrategy: true),
  //     PlayerOptions(memoryChance: 0, useOptimalStrategy: true),
  //   ],
  // },

  // {
  //   'name': 'nostrategy_nostrategy',
  //   'options': [
  //     PlayerOptions(memoryChance: 1, useOptimalStrategy: false),
  //     PlayerOptions(memoryChance: 1, useOptimalStrategy: false),
  //   ],
  // },

  // {
  //   'name': 'perfect_nostrategy',
  //   'options': [
  //     PlayerOptions(memoryChance: 1, useOptimalStrategy: true),
  //     PlayerOptions(memoryChance: 1, useOptimalStrategy: false),
  //   ],
  // },

  // {
  //   'name': 'nostrategy_perfect',
  //   'options': [
  //     PlayerOptions(memoryChance: 1, useOptimalStrategy: false),
  //     PlayerOptions(memoryChance: 1, useOptimalStrategy: true),
  //   ],
  // },

  // {
  //   'name': 'random_nostrategy',
  //   'options': [
  //     PlayerOptions(memoryChance: 0, useOptimalStrategy: true),
  //     PlayerOptions(memoryChance: 1, useOptimalStrategy: false),
  //   ],
  // },

  // {
  //   'name': 'nostrategy_random',
  //   'options': [
  //     PlayerOptions(memoryChance: 1, useOptimalStrategy: false),
  //     PlayerOptions(memoryChance: 0, useOptimalStrategy: true),
  //   ],
  // },

  // {
  //   'name': 'three_player_game',
  //   'options': [
  //     PlayerOptions(memoryChance: 1, useOptimalStrategy: true),
  //     PlayerOptions(memoryChance: 1, useOptimalStrategy: true),
  //     PlayerOptions(memoryChance: 1, useOptimalStrategy: true),
  //   ],
  // },
];
