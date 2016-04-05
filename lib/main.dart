library headcards;

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_sprites/flutter_sprites.dart';

import 'package:mojo_services/sensors/sensors.mojom.dart' as mojom;

part 'sound_assets.dart';


void main() {
  runApp(
    new MaterialApp(
      title: 'Head Cards',
      routes: <String, WidgetBuilder>{
        '/': (BuildContext context) => new HeadCardsPickCategory(),
        '/play': (BuildContext context) => new HeadCardsGameBoard(),
      }
    )
  );
}


// ----------------------------------------------------------------------------
// HeadCardsPickCategory
//
// Widget to select a category of words to play
//
class HeadCardsPickCategory extends StatefulWidget {
  HeadCardsPickCategory({ Key key }) : super(key: key);

  @override
  _HeadCardsPickCategoryState createState() => new _HeadCardsPickCategoryState();
}

class _HeadCardsPickCategoryState 
      extends State<HeadCardsPickCategory> {

  Map<String, List<String>> _games;
  List<String> _categories;

  loadGames() async {
    String json = await DefaultAssetBundle.of(context).loadString('assets/games.json');
    _games = JSON.decode(json);
    _categories = _games['categories'];

    // debug
    for (var cat in _categories)
      print("${cat['words'].length} words");
  }

  @override
  void initState() {
    super.initState();

    // load cached state.
    loadGames();

    // TODO : attempt to load an update over-the-air aysnc

  }

  void _playGame() {
    Navigator.push(context, new MaterialPageRoute<Null>(
      builder: (BuildContext context) => new HeadCardsGameBoard()
    ));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Select a Catgory')
      ),
      //body: new Center(
      //  child: new Text('Button tapped $_counter time${ _counter == 1 ? '' : 's' }.')
      //),
      floatingActionButton: new FloatingActionButton(
        onPressed: _playGame,
        tooltip: 'Play',
        child: new Icon(
          icon: Icons.play_arrow
        )
      )
    );
  }
}


// ----------------------------------------------------------------------------
// HeadCardsGameBoard
//
// The main game screen.
//
class HeadCardsGameBoard extends StatefulWidget {
  HeadCardsGameBoard({ Key key}) : super(key: key);

  @override
  _GameState createState() => new _GameState();
}

class _GameState
      extends State<HeadCardsGameBoard> 
      implements mojom.SensorListener {

  static const int kUnknown = 0;
  static const int kCentered = 1;
  static const int kPassed = 2;
  static const int kWon = 3;

  final mojom.SensorServiceProxy _sens = new mojom.SensorServiceProxy.unbound();
  mojom.SensorListenerStub _stub;
  List<String> _words = <String>['Mickey Mouse', 'Donald Duck', 'Frozone', 'Stitch', 'Baymax'];
  Timer _wordTimer = null;
  int _wordIndex = 0;
  int _lastPosition = _GameState.kUnknown;
  SoundAssets _sounds = null;

  @override
  initState() {
    super.initState();
    _words.shuffle();
    _wordIndex = 0;

    _sounds = new SoundAssets(DefaultAssetBundle.of(context));
    _sounds.load('bell');
    _sounds.load('buzzer');

    // Note: the serivcename is ignored, but not be null.
    shell.connectToService("", _sens);
    _stub = new mojom.SensorListenerStub.unbound()..impl = this;
    _sens.ptr.addListener(mojom.SensorType.accelerometer, _stub);
    _sens.close();
  }


  void change_position(int new_pos) {
    // debounce the selection
    if (new_pos == _lastPosition)
      return;

    _lastPosition = new_pos;
    switch(_lastPosition) {
      case _GameState.kWon:
        print("** SUCCESS **");
        _sounds.play('bell');
        break;
      case _GameState.kPassed:
        print("** PASS **");
        _sounds.play('buzzer');
        break;
      case _GameState.kCentered:
        print("** Centered **");
        break;
    }
  }

  onAccuracyChanged(int accuracy) {}

  onSensorChanged(mojom.SensorData data) {
    //print("OnSensorChanged: ${data.values[2]}");
    if (data.values[2] > 8.0)
      change_position(_GameState.kPassed);
    if (data.values[2] < -8.0)
      change_position(_GameState.kWon);
    else
      change_position(_GameState.kCentered);
  }

  void gameOverTimerFired() {
    _wordTimer = null;
   
    // TODO : display score
    /*
    if ((_wordIndex+1) >= _words.length) {
      _wordTimer = null;
      Navigator.pop(context);
    } else
      setState(() { _wordIndex++; });*/
  }

  @override
  Widget build(BuildContext context) {
    if (_wordTimer == null)
      _wordTimer = new Timer(const Duration(seconds: 10), gameOverTimerFired);

    return new Scaffold(
      body: new Center(
        child: new Text(_words[_wordIndex], 
          style: const TextStyle(color: const Color(0xFF000000), 
            fontSize: 48.0, fontWeight: FontWeight.bold)
          )
        )
      );
    }
}
