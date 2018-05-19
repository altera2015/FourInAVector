import 'package:flutter/material.dart';
import 'four_in_a_vector.dart';
import 'player.dart';
import 'dart:async';
import 'boardwidget.dart';

class GameScreen extends StatefulWidget {

  final Map<FourPlayer, Player> players;

  GameScreen({Key key, this.title, this.players}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  GameScreenState createState() => GameScreenState(6,7, players);
}

class GameScreenState extends State<GameScreen> {
  FourInAVector _game;
  Map<FourPlayer, Player> _players;
  StreamSubscription<int> _turnStream;

  GameScreenState(int rows, int columns, Map<FourPlayer, Player> players )  {
    _players = players;
    _game = FourInAVector(rows, columns);
    // _game.preloadState();
    nextTurn();
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

  Widget _buildStack() {
    return Padding(
        padding: new EdgeInsets.all(18.0),
        child: Center(
            child: AspectRatio(
                aspectRatio: 1.1,
                child: GameBoard(
                    game: _game,
                    onTapped: (int column) {
                      if (column != null) {
                        _players[_game.state].columnClicked(column);
                      }
                    }
                )
            )
        )
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
