import 'package:flutter/material.dart';
import 'four_in_a_vector.dart';
import 'player.dart';
import 'boardwidget.dart';

class GameScreen extends StatefulWidget {

  final Map<FourPlayer, Player> players;
  final int rows;
  final int columns;

  GameScreen({Key key, this.title, this.players, this.rows, this.columns}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  GameScreenState createState() => GameScreenState(this.rows,this.columns, players);
}

class GameScreenState extends State<GameScreen> {
  FourInAVector _game;
  Map<FourPlayer, Player> _players;

  GameScreenState(int rows, int columns, Map<FourPlayer, Player> players )  {
    _players = players;
    _game = FourInAVector(rows, columns);
    // _game.preloadState();
  }


  String _PlayerToString( player ) {
    switch ( player) {
      case FourPlayer.RED:
        return "Red";
      case FourPlayer.YELLOW:
        return "Yellow";
      default:
        return "";
    }
  }

  Widget _buildStack() {


    var gameBoard = GameBoard(
        game: _game,
        players: _players
    );
    var gameStack;

    if ( _game.winner != null ) {
      gameStack = Stack(
        alignment: Alignment.center,
        children: <Widget>[

          gameBoard,
          Text( _PlayerToString( _game.winner) + " wins!",
              style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 50.0, color: Colors.black.withOpacity(1.0)),
            textAlign: TextAlign.center,
          ),

        ],
      );

    } else {
      gameStack = gameBoard;
    }
    return Padding(
        padding: new EdgeInsets.all(18.0),
        child: Center(
            child: AspectRatio(
                aspectRatio: 1.1,
                child: gameStack
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
        child: DecoratedBox(
            decoration: BoxDecoration (
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [ Color(0xffa7d3f9), Color(0xfff4caa2)]
                )
            ),
            child: _buildStack(),
        )

      ),


      persistentFooterButtons: <Widget>[
        FlatButton(
            onPressed: () {
              _game.undo();
            },
            child: Text("Undo")
        )
      ],

    );
  }
}
