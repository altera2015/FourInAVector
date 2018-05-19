import 'package:flutter/material.dart';
import 'four_in_a_vector.dart';
import 'player.dart';
import 'dart:async';

class GameBoard extends StatefulWidget {

  final Map<FourPlayer, Player> players;

  GameBoard({Key key, this.title, this.players}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  GameBoardState createState() => GameBoardState(6,7, players);
}

class GameBoardState extends State<GameBoard> {
  FourInAVector _game;
  Map<FourPlayer, Player> _players;

  GameBoardState(int rows, int columns, Map<FourPlayer, Player> players )  {
    _players = players;
    _game = FourInAVector(rows, columns);
    nextTurn();
  }

  String _playerToAssetName( FourPlayer player ) {
    switch ( player ) {
      case FourPlayer.RED:
        return 'images/red.png';
      case FourPlayer.YELLOW:
        return 'images/yellow.png';
      default:
        return 'images/white.png';
    }
  }

  void nextTurn() {

    if ( _game.state == null ) {
      return;
    }

    Future<int> f = _players[_game.state].makeMove(_game);
    f.then((col) {
      setState( (){
        _game.dropPiece(col);
        nextTurn();
      });
    });
  }

  List<TableRow> _buildArenaWidgets(rows, columns) {

    return new List<TableRow>.generate(
        rows + 1,
            (int row) => TableRow(
            children: List<Container>.generate(
            columns,
                (int column) {

              if ( row==0 ) {

                bool validCol = _game.validDrop(column);
                String assetName = validCol ? _playerToAssetName(_game.state ) : "images/white.png";

                return Container(
                    color: Color(0xda000000),

                    child: IconButton(
                        icon: Image.asset( assetName ),
                        iconSize: 40.0,

                        onPressed:() {

                          // game has ended or invalid column clicked!
                          if ( _game.state == null || !validCol ) {
                            return;
                          }

                          /* _players.forEach((FourPlayer id, Player player ) {
                            player.columnClicked(column);
                          });*/
                          _players[_game.state].columnClicked(column);

                        }

                    )

                );

              } else {
                FourPlayer decoration = _game.cellDecoration(row-1, column);
                Color c = decoration == null ? Color(0x1f000000) : Color(0x8000ff00);
                return new Container(
                    child: Image.asset( _playerToAssetName(_game.cellState(row-1, column))),
                    color: c
                );
              }
            }
        )
    )
    );

  }

  Widget _buildArena() {
    return Table(
        defaultColumnWidth: FixedColumnWidth(35.0),
        children: _buildArenaWidgets(_game.rows, _game.columns),
        border: TableBorder.all()
    );
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),

      body: Center(
        child: _buildArena(),
      ),


      persistentFooterButtons: <Widget>[
        FlatButton(
            onPressed: () {
              setState(() {
                _game.restart();
                nextTurn();
              });
            },
            child: Text("Restart")
        )
      ],
    );
  }
}
