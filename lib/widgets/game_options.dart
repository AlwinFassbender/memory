import 'package:flutter/material.dart';
import 'package:memory/classes/game.dart';
import 'package:memory/classes/player.dart';
import 'package:memory/widgets/int_input.dart';
import 'package:memory/widgets/player_options.dart';

class GameOptionsDialog extends StatefulWidget {
  final GameOptions gameOptions;
  final void Function(GameOptions) onClosed;

  const GameOptionsDialog({
    super.key,
    required this.gameOptions,
    required this.onClosed,
  });

  @override
  State<GameOptionsDialog> createState() => _GameOptionsDialogState();
}

class _GameOptionsDialogState extends State<GameOptionsDialog> {
  late GameOptions gameOptions = widget.gameOptions;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: const Text("Settings"),
        actions: [
          TextButton(
            onPressed: () {
              widget.onClosed(gameOptions);
              Navigator.of(context).pop();
            },
            child: const Text("Start game"),
          ),
        ],
        content: Column(children: [
          const Text("Number of card pairs"),
          NumberInputField(initialValue: widget.gameOptions.pairs, onChanged: _onNumberPairsChanged),
          const SizedBox(height: 42),
          for (var i = 0; i < gameOptions.players.length; i++) ...[
            PlayerOptionsWidget(
              playerIndex: i,
              initialOptions: gameOptions.players[i],
              onPlayerRemoved: i < 2
                  ? null
                  : () {
                      setState(() {
                        gameOptions.players.removeAt(i);
                      });
                    },
              onOptionsChanged: (value) => _onPlayerOptionsChanged(i, value),
            ),
            const SizedBox(height: 42),
          ],
          const Text("Add player"),
          IconButton(onPressed: _addPlayer, icon: const Icon(Icons.add)),
        ]));
  }

  void _onPlayerOptionsChanged(int i, PlayerOptions value) {
    gameOptions.players[i] = value;
  }

  void _onNumberPairsChanged(int value) {
    gameOptions = gameOptions.copyWith(pairs: value);
  }

  void _addPlayer() {
    setState(() {
      gameOptions.players.add(PlayerOptions(memoryChance: 1, useOptimalStrategy: false));
    });
  }
}
