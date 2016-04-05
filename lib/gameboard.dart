part of headcards;


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
