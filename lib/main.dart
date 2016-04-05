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
        '/getready': (BuildContext context) => new HeadCardsGetReady(),
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
      //builder: (BuildContext context) => new HeadCardsGameBoard()
      builder: (BuildContext context) => new HeadCardsGetReady()
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
// HeadCardsGetReady
//
// The main game screen.
//
class HeadCardsGetReady extends StatefulWidget {
  HeadCardsGetReady({ Key key}) : super(key: key);

  @override
  _HeadCardsGetReadyState createState() => new _HeadCardsGetReadyState();
}

class _HeadCardsGetReadyState
      extends State<HeadCardsGetReady> 
      implements mojom.SensorListener {

  static const int kUnknown = 0;
  static const int kCentered = 1;
  static const int kPassed = 2;
  static const int kWon = 3;

  final mojom.SensorServiceProxy _sens = new mojom.SensorServiceProxy.unbound();
  mojom.SensorListenerStub _stub;
  Timer _countdownTimer = null;
  int _counter = 3;
  int _lastPosition = _HeadCardsGetReadyState.kUnknown;
  String _msg = "";

  @override
  initState() {
    super.initState();

    // Note: the serivcename is ignored, but not be null.
    shell.connectToService("", _sens);
    _stub = new mojom.SensorListenerStub.unbound()..impl = this;
    _sens.ptr.addListener(mojom.SensorType.accelerometer, _stub);
    _sens.close();
  }


  void change_position(int new_pos) {
    // debounce the selection
    //if (new_pos == _lastPosition)
    //  return;

    _lastPosition = new_pos;
    if (_lastPosition == _HeadCardsGetReadyState.kCentered) {      
      setState(() { _msg = null; });
    } else {
      _countdownTimer?.cancel();
      _countdownTimer = null;
      setState(() { _msg = "Hold device vertical to start!"; });
    }
  }

  onAccuracyChanged(int accuracy) {}

  onSensorChanged(mojom.SensorData data) {
    //print("OnSensorChanged: ${data.values[0]}  ..  ${data.values[1]}  ..  ${data.values[2]}");
    if (data.values[2] > 5.0)
      change_position(_GameState.kPassed);
    else if (data.values[2] <= -9.0)
      change_position(_GameState.kWon);
    else
      change_position(_GameState.kCentered);
  }

  void countDownTimerFired() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    _counter--;

    if (0 == _counter) {
      _stub?.close();
      Navigator.popAndPushNamed(context, "/play");
      return;
    }

    setState(() { _msg = null; });
  }

  @override
  Widget build(BuildContext context) {
    String msg =_msg;
    if (_msg == null)
      msg = "${_counter}";

    if (_countdownTimer == null)
      _countdownTimer = new Timer(const Duration(seconds: 1), countDownTimerFired);

    return new Scaffold(
      body: new Center(
        child: new Text(msg, 
          style: const TextStyle(color: const Color(0xFF000000), 
            fontSize: 50.0, fontWeight: FontWeight.bold)
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
  Timer _gameTimer = null;
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

    _gameTimer = new Timer(const Duration(seconds: 10), gameOverTimerFired);    
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
        next_word();
        break;
      case _GameState.kPassed:
        print("** PASS **");
        _sounds.play('buzzer');
        next_word();
        break;
      case _GameState.kCentered:
        print("** Centered **");
        break;
    }
  }

  onAccuracyChanged(int accuracy) {}

  onSensorChanged(mojom.SensorData data) {
    print("OnSensorChanged: ${data.values[0]}  ..  ${data.values[1]}  ..  ${data.values[2]}");
    if (data.values[2] > 5.0)
      change_position(_GameState.kPassed);
    else if (data.values[2] <= -9.0)
      change_position(_GameState.kWon);
    else
      change_position(_GameState.kCentered);
  }

  void next_word() {
    if ((_wordIndex+1) >= _words.length) {
      do_game_over();
    } else {
      setState(() {_wordIndex++;});
    }
  }

  void do_game_over() {

    // TODO : display score
    
    _stub?.close();
    Navigator.pop(context);
  }

  void gameOverTimerFired() {
    _gameTimer = null;
    do_game_over();   
  }

  @override
  Widget build(BuildContext context) {
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
