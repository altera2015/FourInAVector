/* This player pick a column by clicking on the top row. */

import 'dart:core';
import 'dart:async';
import 'four_in_a_vector.dart';
import 'player.dart';

class HumanPlayer extends Player {

  StreamController<int> _streamController;

  HumanPlayer(FourPlayer player) : super(player) {
    _streamController = StreamController<int>.broadcast();
  }

  @override
  void columnClicked(int column) {
    _streamController.add(column);
  }

  @override
  Future<int> makeMove( FourInAVector game ) {
    return _streamController.stream.first;
  }

}
