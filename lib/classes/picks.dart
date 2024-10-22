import 'package:memory/shared/types.dart';

class Picks {
  int firstPick;
  int secondPick;
  MoveType moveType;

  Picks(this.firstPick, this.secondPick, {this.moveType = MoveType.twoMove});
}
