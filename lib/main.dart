import 'package:flutter/material.dart';
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
      home: new MyHomePage(title: 'Four in a Vector'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState(6,7);
}

class _MyHomePageState extends State<MyHomePage> {
  FourInAVector _game;

  _MyHomePageState(int rows, int columns)  {
    _game = FourInAVector(rows, columns);
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

                        if ( _game.state == null || !validCol ) {
                          return;
                        }

                        setState(() {
                          _game.dropPiece(column);
                        });
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
              });
            },
            child: Text("Restart")
        )
      ],
    );
  }
}
