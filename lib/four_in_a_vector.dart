//  Four in a vector game machine
//
//  Copyright (C) 2018 Ron Bessems
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <https://www.gnu.org/licenses/>.

// Player constants
enum FourPlayer { RED, YELLOW }

// Directions that we should look for items in a row.
class FourDirection {
  final int rowInc;
  final int colInc;
  const FourDirection(this.rowInc, this.colInc);
}

// The main game class.
class FourInAVector {

  int rows;
  int columns;

  // state can be null or any of the enums. This indicates
  // which player is about to start the game. null indicates the
  // game is over.
  FourPlayer state;

  // This is null during a game and set to the winner at the
  // end.
  FourPlayer winner;

  // number of items that must appear in a row
  // to win.
  static const int COUNT = 4;

  // Board is a list of chips. Any of the enums or null for empty.
  List<FourPlayer> pieces;

  // Upon winning the board should color the cells according to the
  // values in here.
  List<FourPlayer> cellDecorations;

  // Down, Left, Down Left, Up Left.
  final List<FourDirection> directions = [ FourDirection(1,0), FourDirection(0,1), FourDirection(1,1), FourDirection(-1,1)];


  // empty constructor.
  FourInAVector.copyState(FourInAVector game) {
    this.rows = game.rows;
    this.columns = game.columns;
    state = game.state;
    pieces = new List<FourPlayer>.from(game.pieces);
    cellDecorations = new List<FourPlayer>( rows * columns );
    cellDecorations.fillRange(0, cellDecorations.length, null);
  }

  // constructor.
  FourInAVector( int rows, int columns ) {
    this.rows = rows;
    this.columns = columns;
    state = FourPlayer.RED;
    pieces = new List<FourPlayer>( rows * columns );
    pieces.fillRange(0, pieces.length, null);
    cellDecorations = new List<FourPlayer>( rows * columns );
    cellDecorations.fillRange(0, cellDecorations.length, null);
  }

  /*
  void preloadState() {

    pieces = [
      null, null, null, null, null, null,null,
      null, null, null, null, null, null,null,
      null,              null,           null,           null,           FourPlayer.RED   , null,              null,
      null,              null,           null,           null,           FourPlayer.YELLOW, null,              null,
      null,              null,           FourPlayer.RED, FourPlayer.RED, FourPlayer.YELLOW, FourPlayer.YELLOW, null,
      FourPlayer.YELLOW, FourPlayer.RED, FourPlayer.RED, FourPlayer.RED, FourPlayer.YELLOW, FourPlayer.YELLOW, null,
      ];

  }*/

  // returns the status of a cell.
  FourPlayer cellState( int row, int column ) {
    if ( row < 0 || row >= rows ) {
      return null;
    }
    if ( column < 0 || column >= columns ) {
      return null;
    }

    return pieces[ row * columns + column ];
  }

  // returns the decoration status of a cell.
  FourPlayer cellDecoration( int row, int column ) {
    if ( row < 0 || row >= rows ) {
      return null;
    }
    if ( column < 0 || column >= columns ) {
      return null;
    }

    return cellDecorations[ row * columns + column ];
  }

  bool _setCellState( int row, int column, FourPlayer player) {
    if ( row < 0 || row >= rows ) {
      return false;
    }
    if ( column < 0 || column >= columns ) {
      return false;
    }

    pieces[row * columns + column] = player;
    return true;
  }

  bool _setCellDecorationState( int row, int column, FourPlayer player) {
    if ( row < 0 || row >= rows ) {
      return false;
    }
    if ( column < 0 || column >= columns ) {
      return false;
    }
    cellDecorations[row * columns + column] = player;
    return true;
  }

  // returns the player ID if there are _COUNT items in a row
  // null otherwise.
  FourPlayer _checkForCountInARow( int row, int column, int rowInc, int colInc) {

    FourPlayer rootState = cellState(row, column);

    if ( rootState == null ) {
      return null;
    }

    for (int i=1;i<COUNT;i++ ) {
      if ( cellState(row + i * rowInc, column+i * colInc) != rootState ) {
        return null;
      }
    }

    return rootState;
  }

  // fills the cell decoration
  void _fillInARow( int row, int column, int rowInc, int colInc, FourPlayer player) {
    for (int i=0;i<COUNT;i++ ) {
      _setCellDecorationState(row + i * rowInc, column+i * colInc, player);
    }
  }

  // check all possible positions for COUNT in a row.
  void _checkForWin( ) {

    for (int column=0;column<columns;column++){
      for (int row=0;row<rows;row++) {
        directions.forEach((direction) {
          FourPlayer w = _checkForCountInARow(row, column, direction.rowInc, direction.colInc);
          if (w != null ) {
            _fillInARow(row, column, direction.rowInc, direction.colInc, w);
            winner = w;
          }
        });
      }
    }
  }



  // Reset the state back to initial.
  void restart() {
    winner = null;
    state = FourPlayer.RED;
    pieces.fillRange(0, pieces.length, null);
    cellDecorations.fillRange(0, pieces.length, null);
  }

  bool validDrop( int column ) {
    return cellState(0, column) == null;
  }

  // Drop a piece according to the current player.
  void dropPiece( int column ) {
    // update the position with the current player.
    var f = (int row, int column) {
      if (_setCellState(row, column, state)) {
        _checkForWin();
        if (winner != null) {
          state = null;
        } else {
          state = state == FourPlayer.RED ? FourPlayer.YELLOW : FourPlayer.RED;

          bool slotAvailable = false;
          for (int column = 0; column < columns; column++) {
            if (cellState(0, column) == null) {
              slotAvailable = true;
            }
          }

          if (!slotAvailable) {
            // it's a tie!
            state = null;
          }
        }
      }
    };

    for (int row = 1; row < rows; row++) {
      // find the first chip in the column.
      if (cellState(row, column) != null) {
        f(row - 1, column);
        return;
      }
    }

    // if no chips are found place a chip in the last row.
    f(rows - 1, column);
  }

}