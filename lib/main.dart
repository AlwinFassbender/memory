import 'package:flutter/material.dart';
// import 'package:memory/screens/home.dart';
import 'package:memory/screens/results.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: GameResultsScreen());
  }
}
