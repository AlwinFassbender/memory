import 'package:flutter/material.dart';
import 'package:memory/screens/game.dart';
import 'package:memory/screens/results.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                onPressed: () =>
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const GameScreen())),
                child: const Text("play game")),
            ElevatedButton(
                onPressed: () =>
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const GameResultsScreen())),
                child: Text("Results"))
          ],
        ),
      ),
    );
  }
}
