/* This AI player simply picks a random column! Easy to beat. */

import 'player.dart';
import 'four_in_a_vector.dart';
import 'dart:math';
import 'dart:core';
import 'dart:async';

class RandomPlayer extends Player {

  Random _rand;

  RandomPlayer(FourPlayer player) : super(player) {
    DateTime dt = DateTime.now();
    _rand = Random( dt.microsecondsSinceEpoch );
  }

  @override
  void columnClicked(int column) {

  }

  @override
  Future<int> makeMove( FourInAVector game ) {

    return Future<int>.delayed(const Duration(seconds:1), ()
    {

      int col;
      do
      {
        col = _rand.nextInt(game.columns);
      }
      while ( !game.validDrop(col) );
      return col;

    });
  }

}