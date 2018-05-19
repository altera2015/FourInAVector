import "dart:async";
import "four_in_a_vector.dart";

abstract class AIPlayer {

  final FourPlayer player;

  AIPlayer( this.player );

  Future<int> makeMove( FourInAVector game );

}


