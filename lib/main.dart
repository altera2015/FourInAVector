import 'package:flutter/material.dart';
import 'gameboard.dart';
import 'player.dart';
import 'randomplayer.dart';
import 'humanplayer.dart';
import 'four_in_a_vector.dart';

// https://pub.dartlang.org/packages/spritewidget/versions/0.9.16

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Four in a Vector',
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
      home: new HomeScreen(title: 'Four in a Vector'),
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

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: ListView(
          padding: EdgeInsets.zero,
          children: [
            Padding(
              padding: new EdgeInsets.all(18.0),
              child: Center (
                child: Text ("Choose your game mode:"),
              )
            ),
            ListTile (
              title: Text("Two Player"),
              onTap:() {

                Map<FourPlayer, Player> players = Map<FourPlayer, Player>();
                players[FourPlayer.RED]  = HumanPlayer( FourPlayer.RED );
                players[FourPlayer.YELLOW]  = HumanPlayer( FourPlayer.YELLOW );

                Navigator.push(
                  context,
                  new MaterialPageRoute(builder: (context) => GameBoard(title: 'Four in a Vector', players: players)),
                );
              }
            ),
            ListTile(
              title: Text("One Player against AI"),
              onTap: () {

                Map<FourPlayer, Player> players = Map<FourPlayer, Player>();
                players[FourPlayer.RED]  = RandomPlayer( FourPlayer.RED );
                players[FourPlayer.YELLOW]  = HumanPlayer( FourPlayer.YELLOW );

                Navigator.push(
                  context,
                  new MaterialPageRoute(builder: (context) => GameBoard(title: 'Four in a Vector', players: players)),
                );
              }
            )
          ]
        )
    );
  }
}