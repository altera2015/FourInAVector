/* Min Max algorithm with alpha-beta pruning and recursion limits
 * from Implemented from Artificial Intelligence
 * A Modern Approach, 3rd edition by Russel and Norvig.
 * Optimal Decision cases Section 5.2
 */

import 'player.dart';
import 'four_in_a_vector.dart';
import 'dart:math';
import 'dart:core';
import 'dart:async';

class ScoringFourInAVector extends FourInAVector {

  ScoringFourInAVector.copyState(FourInAVector game) : super.copyState(game);

  // give points for each cell on the board give extra points for
  // each connected cell.
  int _countInARow( int row, int column, int rowInc, int colInc) {

    FourPlayer rootState = cellState(row, column);

    for (int i=1;i<FourInAVector.COUNT;i++ ) {
      if ( cellState(row + i * rowInc, column+i * colInc) != rootState ) {
        return i;
      }
    }

    return FourInAVector.COUNT;
  }


  // iterate over all the cells and give positive points
  // for Player and negative points for opponent.
  double score(FourPlayer player) {

    double s = 0.0;

    for (int column=0;column<columns;column++){
      for (int row=0;row<rows;row++) {

        FourPlayer rootNode = cellState(row, column);
        if ( rootNode == null ) {
          continue;
        }

        directions.forEach((direction) {

          int count = _countInARow(row, column, direction.rowInc, direction.colInc);

          if ( rootNode == player ) {
            s += count;
          } else {
            s -= count;
          }

        });
      }
    }

    return s;

  }

}

// Classic Min Max algorithm with Alpha Beta pruning and recursion limits.
class MinMaxPlayer extends Player {

  int _maxRecursion;
  bool _requestCancel;

  // we needed a number that is big enough to not occur by additions
  // on the board but small enough so that we can subtract single digits.
  // that way we can select a winning outcome based on lowest recursion.
  static const double BIG_POSITIVE = 1e10;
  static const double BIG_NEGATIVE = -1e10;

  MinMaxPlayer(FourPlayer player, int maxRecursion) : super(player) {
    _maxRecursion = maxRecursion;
    _requestCancel = false;
  }

  @override
  void columnClicked(int column) {

  }

  @override
  void cancel() {
    _requestCancel = true;
  }

  double terminalScore( ScoringFourInAVector game ) {

    if ( game.winner == player ) {

      // 'we' won.
      return BIG_POSITIVE;

    } else if ( game.winner != null ) {

      // other player won.
      return BIG_NEGATIVE;
    }

    // it's a tie!
    return 0.0;

  }

  double maxValue( ScoringFourInAVector game, double alpha, double beta, int recursionLevel ) {

    if ( game.state == null ) {
      return terminalScore(game) + recursionLevel;
    }
    if ( recursionLevel >= _maxRecursion ) {
      return game.score(player);
    }

    double v = double.negativeInfinity;
    for (int column=0;column<game.columns;column++){
      if ( game.validDrop(column)) {
        FourInAVector nextState = ScoringFourInAVector.copyState(game);
        nextState.dropPiece(column);
        v = max(v, minValue(nextState, alpha, beta, recursionLevel+1));
        if ( v >= beta ) {
          return v;
        }
        alpha = max(alpha, v);
      }
    }

    return v;
  }

  double minValue( ScoringFourInAVector game, double alpha, double beta, int recursionLevel ) {

    if ( game.state == null ) {
      return terminalScore(game) - recursionLevel;
    }
    if ( recursionLevel >= _maxRecursion ) {
      return game.score(player);
    }

    double v = double.infinity;
    for (int column=0;column<game.columns;column++){
      if ( game.validDrop(column)) {
        FourInAVector nextState = ScoringFourInAVector.copyState(game);
        nextState.dropPiece(column);
        v = min(v, maxValue(nextState, alpha, beta, recursionLevel+1));
        if ( v < alpha ) {
          return v;
        }
        beta = min(beta, v);
      }
    }

    return v;

  }

  int minMaxDecision( FourInAVector game ) {

    int maxColumn = -1;
    double maxValue = 0.0;

    for (int column=0;column<game.columns;column++) {

      if (game.validDrop(column)) {

        ScoringFourInAVector nextState = ScoringFourInAVector.copyState(game);
        nextState.dropPiece(column);

        double v = minValue(nextState, double.negativeInfinity, double.infinity, 1);
        if ( maxColumn==-1 || v > maxValue ) {
          maxColumn = column;
          maxValue = v;
        }

      }

    }

    return maxColumn;

  }


  @override
  Future<int> makeMove( FourInAVector game ) {

    _requestCancel = false;

    return Future<int>.delayed(const Duration(seconds:1), ()
    {

      if ( _requestCancel ) {
        return -1;
      }

      // if center bottom cell is not take, take it!
      // otherwise perform minMax algo.
      int centerColumn = (game.columns / 2).floor();
      if ( game.cellState(game.rows-1, centerColumn ) == null ) {
        return centerColumn;
      }
      return minMaxDecision(game);

    });

  }


}