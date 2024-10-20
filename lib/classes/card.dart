class MemoryCard {
  final int id;
  int? matchedByPlayer;
  bool get isMatched => matchedByPlayer != null;

  MemoryCard(this.id);
}
