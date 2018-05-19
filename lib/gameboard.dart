import 'package:flutter/material.dart';
import 'four_in_a_vector.dart';
import 'player.dart';
import 'dart:async';
import 'framepainter.dart';

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
  StreamSubscription<int> _turnStream;

  GameBoardState(int rows, int columns, Map<FourPlayer, Player> players )  {
    _players = players;
    _game = FourInAVector(rows, columns);
    // _game.preloadState();
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

  Color _playerToChipColor( FourPlayer player ) {
    switch ( player ) {
      case FourPlayer.RED:
        return RedChipColor;
      case FourPlayer.YELLOW:
        return YellowChipColor;
      default:
        return Color(0);
    }
  }

  void nextTurn() {

    if ( _game.state == null ) {
      return;
    }

    Future<int> f = _players[_game.state].makeMove(_game);
    _turnStream = f.asStream().listen((col){

      _turnStream.cancel();
      _turnStream = null;
      setState( (){
        if ( col >= 0 ) {
          _game.dropPiece(col);
          if ( _game.state != null ) {
            nextTurn();
          }
        }
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


  List<TableRow> _buildArenaWidgets2(rows, columns) {

    return new List<TableRow>.generate(
        rows + 1,
            (int row) => TableRow(
            children: List<Widget>.generate(
            columns, (int column) {

                if ( row == 0 ) {

                  bool validCol = _game.validDrop(column);
                  if ( !validCol ) {
                    return CustomPaint(
                        size: Size(37.0, 37.0),
                        painter: ChipPainter( Color(0), false )
                    );
                  }

                  return GestureDetector(
                    onTap: () {
                      // game has ended or invalid column clicked!
                      if ( _game.state == null || !validCol ) {
                        return;
                      }

                      _players[_game.state].columnClicked(column);

                    },
                    child: CustomPaint(
                        size: Size(37.0, 37.0),
                        painter: ChipPainter( _playerToChipColor(_game.state), false )
                    )
                  );

                } else {


                  FourPlayer state = _game.cellState(row-1, column);

                  if ( state==null) {
                    return CustomPaint(
                        size: Size(37.0, 37.0),
                        painter: FramePainter( )
                    );

                  } else {

                    var cp = ChipPainter( _playerToChipColor(state), true  );

                    if ( _game.cellDecoration(row-1, column)!=null) {
                      cp.frameColor = Color(0xff88ee88);
                    }

                    return CustomPaint(
                        size: Size(37.0, 37.0),
                        painter: cp
                    );

                  }

                }

            }
        )
    )
    );

  }

  Widget _buildArena() {
    return Table(
        defaultColumnWidth: FixedColumnWidth(37.0),
        children: _buildArenaWidgets2(_game.rows, _game.columns),
        border: TableBorder()
      );
  }



  Widget _buildStack() {

    return Center(
          child: _buildArena()
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
        child: _buildStack(),
      ),


      persistentFooterButtons: <Widget>[
        FlatButton(
            onPressed: () {
              setState(() {
                if ( _turnStream != null ) {
                  _turnStream.cancel();
                  _turnStream = null;
                }
                _game.undo();
                nextTurn();
              });
            },
            child: Text("Undo")
        )
      ],

    );
  }
}
