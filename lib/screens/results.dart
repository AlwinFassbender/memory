import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:memory/widgets/int_input.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';

class GameResultsScreen extends StatefulWidget {
  const GameResultsScreen({super.key});

  @override
  createState() => _GameResultsScreenState();
}

class _GameResultsScreenState extends State<GameResultsScreen> {
  Map<String, Map<int, Map<int, int>>> playerWinCountsPerPair = {};
  Map<String, Map<int, double>> averageGameLengthsPerPair = {};

  /// How many cards the winning player had at the end of the game
  Map<String, Map<int, int>> winnerNumCardsPerPair = {};
  Map<int, int> playerWinCounts = {};
  int selectedPairs = 8;
  Map<String, Map<int, int>> maxWinnerNumCardsPerPair = {};
  Map<String, Map<int, int>> minWinnerNumCardsPerPair = {};

  @override
  void initState() {
    super.initState();
    _loadCsvData();
  }

  Future<void> _loadCsvData() async {
    for (final config in ["perfect_perfect", "nostrategy_nostrategy", "random_random"]) {
      final csvString = await rootBundle.loadString('results/$config.csv');
      playerWinCountsPerPair[config] = {};
      List<List<dynamic>> rows = const CsvToListConverter().convert(csvString);
      averageGameLengthsPerPair[config] = {};
      Map<int, int> totalGameLengths = {};
      Map<int, int> gameCount = {};

      for (var i = 1; i < rows.length; i++) {
        int numPairs = rows[i][0];

        if (!gameCount.containsKey(numPairs)) {
          gameCount[numPairs] = 1;
        } else {
          gameCount[numPairs] = gameCount[numPairs]! + 1;
        }

        int winnerIndex = rows[i][1];
        int gameLength = rows[i][2];
        int winnerNumCards = rows[i][4 + winnerIndex * 2];

        if (!playerWinCountsPerPair[config]!.containsKey(numPairs)) {
          playerWinCountsPerPair[config]![numPairs] = {};
        }

        if (playerWinCountsPerPair[config]![numPairs]!.containsKey(winnerIndex)) {
          playerWinCountsPerPair[config]![numPairs]![winnerIndex] =
              playerWinCountsPerPair[config]![numPairs]![winnerIndex]! + 1;
        } else {
          playerWinCountsPerPair[config]![numPairs]![winnerIndex] = 1;
        }

        if (totalGameLengths.containsKey(numPairs)) {
          totalGameLengths[numPairs] = totalGameLengths[numPairs]! + gameLength;
        } else {
          totalGameLengths[numPairs] = gameLength;
        }

        maxWinnerNumCardsPerPair[config]?[numPairs] =
            max(maxWinnerNumCardsPerPair[config]![numPairs] ?? 0, winnerNumCards);
        minWinnerNumCardsPerPair[config]?[numPairs] =
            min(minWinnerNumCardsPerPair[config]![numPairs] ?? 1000, winnerNumCards);
      }

      totalGameLengths.forEach((numPairs, totalLength) {
        averageGameLengthsPerPair[config]![numPairs] = totalLength / gameCount[numPairs]!;
      });
    }
    _updatePlayerWinCounts(selectedPairs);
  }

  void _onNumberPairsChanged(int pairs) {
    setState(() {
      selectedPairs = pairs;
      _updatePlayerWinCounts(pairs);
    });
  }

  void _updatePlayerWinCounts(int numPairs) {
    playerWinCounts = playerWinCountsPerPair["perfect_perfect"]![numPairs] ?? {};
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Game Results'),
      ),
      body: playerWinCountsPerPair.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 200.0),
                      child: Text("""
Let's have a look at the results of hundreds of memory games to get insights into how much luck is involved in winning the game. 
At first, we will see how much the starting position influences the outcome of the game. Two AIs with perfect memory and perfect strategy are playing.
The chart below shows the percentage of wins for each AI. With the number input, you can change how many pairs of cards were in the deck.
              """),
                    ),
                    Text("Syncfusion Bar Chart (Pairs: $selectedPairs)",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SfCartesianChart(
                      primaryXAxis: CategoryAxis(),
                      title: ChartTitle(text: 'Player Wins (Pairs: $selectedPairs)'),
                      primaryYAxis: NumericAxis(
                        title: AxisTitle(text: 'Wins'),
                        minimum: 0,
                        maximum: 1000,
                      ),
                      series: <CartesianSeries>[
                        BarSeries<MapEntry<int, int>, String>(
                          dataSource: playerWinCounts.entries.toList(),
                          xValueMapper: (MapEntry<int, int> data, _) => 'Player ${data.key}',
                          yValueMapper: (MapEntry<int, int> data, _) => data.value,
                          dataLabelSettings: DataLabelSettings(isVisible: true),
                        ),
                      ],
                    ),
                    // Input for selecting number of pairs
                    NumberInputField(
                      initialValue: selectedPairs,
                      onChanged: _onNumberPairsChanged,
                    ),
                    const SizedBox(height: 100),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 200.0),
                      child: Text("""
Instead of looking at the results for each number of pairs separately, we can plot the results for all numbers of pairs in one chart.
On the y-axis, you can see the percentage of games each player won out of a 1000 games. The x-axis separates between between the number of pairs of cards in the deck.
Now what happens when you put two persons that don't know anything about the perfect strategy against each other? What happens when the two players don't have any memory of the cards they have seen before?
              """),
                    ),
                    Text("Two perfect strategy players", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    StackedSeries(playerWinCountsPerPair: playerWinCountsPerPair["perfect_perfect"]!),
                    Text("Two players without strategy", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    StackedSeries(playerWinCountsPerPair: playerWinCountsPerPair["nostrategy_nostrategy"]!),
                    Text("Two players without strategy or memory",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    StackedSeries(playerWinCountsPerPair: playerWinCountsPerPair["random_random"]!),
                    SizedBox(height: 32),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 200.0),
                      child: Text("""
Letting two players without strategy or memory play against each other is effectively as picking cards at random. Of course, this will lead to long-drawn-out games, especially when the number of pairs is high.
Just to see how much longer the games take, take a look at the chart below.
              """),
                    ),

                    _GameLengthChart(averageGameLengthsPerPair: averageGameLengthsPerPair)
                  ],
                ),
              ),
            ),
    );
  }
}

class StackedSeries extends StatelessWidget {
  final Map<int, Map<int, int>> playerWinCountsPerPair; // Tracks player wins per num_pairs

  const StackedSeries({super.key, required this.playerWinCountsPerPair});

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      margin: const EdgeInsets.all(0),
      primaryXAxis: CategoryAxis(
        title: AxisTitle(text: 'Number of pairs'),
        minimum: 0,
        maximum: 50,
        interval: 5,
        // plotOffset: 0,
        // plotOffsetStart: 0,
        // plotOffsetEnd: 0,
      ),
      primaryYAxis: NumericAxis(
        title: AxisTitle(text: 'Percentage of wins'),
        minimum: 0,
        maximum: 100,
      ),
      series: <CartesianSeries>[
        StackedArea100Series<MapEntry<int, Map<int, int>>, String>(
          dataSource: playerWinCountsPerPair.entries.toList(),
          xValueMapper: (MapEntry<int, Map<int, int>> data, _) => '${data.key}',
          yValueMapper: (MapEntry<int, Map<int, int>> data, _) => data.value[0]?.toDouble() ?? 0, // Player 0
          dataLabelSettings: DataLabelSettings(isVisible: false),
        ),
        StackedArea100Series<MapEntry<int, Map<int, int>>, String>(
          dataSource: playerWinCountsPerPair.entries.toList(),
          xValueMapper: (MapEntry<int, Map<int, int>> data, _) => '${data.key}',
          yValueMapper: (MapEntry<int, Map<int, int>> data, _) => data.value[1]?.toDouble() ?? 0, // Player 1
          dataLabelSettings: DataLabelSettings(isVisible: false),
        ),
      ],
    );
  }
}

class _GameLengthChart extends StatefulWidget {
  final Map<String, Map<int, double>> averageGameLengthsPerPair;

  const _GameLengthChart({required this.averageGameLengthsPerPair});

  @override
  createState() => _GameLengthChartState();
}

class _GameLengthChartState extends State<_GameLengthChart> {
  final options = [
    _GameLengthOption("Perfect Strategy", "perfect_perfect"),
    _GameLengthOption("No strategy", "nostrategy_nostrategy"),
    _GameLengthOption("Random / no memory", "random_random"),
  ];
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: options
              .map((option) => [
                    Checkbox(
                      value: option.active,
                      onChanged: (value) {
                        setState(() {
                          option.active = value!;
                        });
                      },
                    ),
                    Text(option.name),
                  ])
              .flattened
              .toList(),
        ),

        // Chart
        SfCartesianChart(
          primaryXAxis: CategoryAxis(),
          title: ChartTitle(text: 'Average Game Length'),
          series: options
              .where((option) => option.active)
              .map((option) => LineSeries<MapEntry<int, double>, String>(
                    dataSource: widget.averageGameLengthsPerPair[option.key]!.entries.toList(),
                    xValueMapper: (MapEntry<int, double> data, _) => '${data.key}',
                    yValueMapper: (MapEntry<int, double> data, _) => data.value,
                    dataLabelSettings: DataLabelSettings(isVisible: false),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

class _GameLengthOption {
  final String name;
  final String key;
  bool active = true;

  _GameLengthOption(
    this.name,
    this.key,
  );
}
