import 'package:flutter/material.dart';
import 'gamescreen.dart';
import 'player.dart';
import 'randomplayer.dart';
import 'minmaxplayer.dart';
import 'humanplayer.dart';
import 'four_in_a_vector.dart';

// https://pub.dartlang.org/packages/spritewidget/versions/0.9.16

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Four In a Vector',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
        primarySwatch: Colors.blue,
      ),
      // home: new GameBoard(title: 'Four in a Vector'),
      home: new HomeScreen(title: 'Four In a Vector'),
    );
  }
}

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  bool playerRedHuman = true;
  bool playerYellowHuman = false;
  double playerRedLevel = 0.0;
  double playerYellowLevel = 1.0;
  double _rows = 6.0;
  double _columns = 7.0;

  Widget buildGameTypeCard() {
    return Card(
        child: Padding(
        padding: new EdgeInsets.all(10.0),
        child: Column(children: [
          Padding(
              padding: new EdgeInsets.all(18.0),
              child: Center(
                child: Text(
                  "Game mode",
                  textScaleFactor: 1.5,
                  style: new TextStyle(fontWeight: FontWeight.bold),
                ),
              )),
          Table(
            children: [
              TableRow(children: [
                Center(child: Text("Player Type")),
                Center(child: Text("AI strength"))
              ]),
              TableRow(children: [
                Row(children: [
                  Image.asset("images/red.png"),
                  Switch(
                      value: playerRedHuman,
                      onChanged: (bool v) {
                        setState(() {
                          playerRedHuman = v;
                        });
                      }),
                  Text(playerRedHuman ? "Human" : "AI"),
                ]),
                TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Slider(
                        onChanged: (double v) {
                          setState(() {
                            playerRedLevel = v;
                          });
                        },
                        value: playerRedLevel,
                        min: 0.0,
                        max: 4.0,
                        divisions: 4))
              ]),
              TableRow(children: [
                Row(children: [
                  Image.asset("images/yellow.png"),
                  Switch(
                      value: playerYellowHuman,
                      onChanged: (bool v) {
                        setState(() {
                          playerYellowHuman = v;
                        });
                      }),
                  Text(playerYellowHuman ? "Human" : "AI"),
                ]),
                TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Slider(
                      onChanged: (double v) {
                        setState(() {
                          playerYellowLevel = v;
                        });
                      },
                      value: playerYellowLevel,
                      min: 0.0,
                      max: 4.0,
                      divisions: 4,
                    )),
              ])
            ],
          )
        ])));
  }

  Widget buildBoardSizeMenu() {
    return Card(
        child: Padding(
            padding: new EdgeInsets.all(10.0),
            child: Column(children: [

              Padding(
                  padding: new EdgeInsets.all(18.0),
                  child: Center(
                    child: Text(
                      "Game board size",
                      textScaleFactor: 1.5,
                      style: new TextStyle(fontWeight: FontWeight.bold),
                    ),
                  )),

              Table(children: [
                TableRow(children: [
                  TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Text("Rows: ${_rows.toInt()}")),
                  TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Slider(
                        onChanged: (double v) {
                          setState(() {
                            _rows = v;
                          });
                        },
                        value: _rows,
                        min: 4.0,
                        max: 10.0,
                        divisions: 6,
                      ))
                ]),
                TableRow(children: [
                  TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Text("Columns: ${_columns.toInt()}")),
                  TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Slider(
                        onChanged: (double v) {
                          setState(() {
                            _columns = v;
                          });
                        },
                        value: _columns,
                        min: 4.0,
                        max: 10.0,
                        divisions: 6,
                      ))
                ]),
              ])
            ])));
  }

  Widget buildMenu(BuildContext context) {
    return Padding(
        padding: new EdgeInsets.all(10.0),
        child: Column(


          children: <Widget>[

            buildGameTypeCard(),
            buildBoardSizeMenu(),

            Padding(
                padding: new EdgeInsets.all(10.0),
                child: RaisedButton(
                  child: Text("Play!"),
                  onPressed: () {
                    Map<FourPlayer, Player> players = Map<FourPlayer, Player>();
                    if (playerRedHuman) {
                      players[FourPlayer.RED] = HumanPlayer(FourPlayer.RED);
                    } else {
                      if (playerRedLevel == 0.0) {
                        players[FourPlayer.RED] = RandomPlayer(FourPlayer.RED);
                      } else {
                        int l = playerRedLevel.toInt() * 2;
                        players[FourPlayer.RED] =
                            MinMaxPlayer(FourPlayer.RED, l);
                      }
                    }

                    if (playerYellowHuman) {
                      players[FourPlayer.YELLOW] =
                          HumanPlayer(FourPlayer.YELLOW);
                    } else {
                      if (playerYellowLevel == 0.0) {
                        players[FourPlayer.YELLOW] =
                            RandomPlayer(FourPlayer.YELLOW);
                      } else {
                        int l = playerYellowLevel.toInt() * 2;
                        players[FourPlayer.YELLOW] =
                            MinMaxPlayer(FourPlayer.YELLOW, l);
                      }
                    }

                    Navigator.push(
                      context,
                      new MaterialPageRoute(
                          builder: (context) => GameScreen(
                              title: 'Four in a Vector', players: players, rows: _rows.toInt(), columns: _columns.toInt())),
                    );
                  },
                )),
            Padding(
                padding: new EdgeInsets.all(5.0),
                child: RaisedButton(
                  child: Text("Quick Player against AI"),
                  onPressed: () {
                    Map<FourPlayer, Player> players = Map<FourPlayer, Player>();
                    players[FourPlayer.RED] = MinMaxPlayer(FourPlayer.RED, 2);
                    players[FourPlayer.YELLOW] = HumanPlayer(FourPlayer.YELLOW);

                    Navigator.push(
                      context,
                      new MaterialPageRoute(
                          builder: (context) => GameScreen(
                              title: 'Four in a Vector', players: players, rows: _rows.toInt(), columns: _columns.toInt() )),
                    );
                  },
                )),

          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
        ),
        body: DecoratedBox(
          decoration: BoxDecoration (
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [ Color(0xffa7d3f9), Color(0xffd0e6f9)]
            )
          ),
          child: buildMenu(context)
        )
    );
  }
}
