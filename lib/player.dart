import "dart:async";
import "four_in_a_vector.dart";

abstract class Player {

  final FourPlayer player;

  Player( this.player );

  void columnClicked(int column);

  Future<int> makeMove( FourInAVector game );

}
