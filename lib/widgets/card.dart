import 'package:flutter/material.dart';
import 'package:memory/classes/card.dart';

class CardBack extends StatelessWidget {
  const CardBack({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      color: Colors.grey,
    );
  }
}

class CardFront extends StatelessWidget {
  final MemoryCard card;
  final Widget face;

  const CardFront(
    this.card, {
    required this.face,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blueAccent,
      child: Center(
        child: face,
      ),
    );
  }
}
