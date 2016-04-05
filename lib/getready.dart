part of headcards;


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

  @override
  dispose() {
    _stub?.close();
    super.dispose();
  }

  void change_position(int new_pos) {
    // debounce the selection
    //if (new_pos == _lastPosition)
    //  return;

    _lastPosition = new_pos;
    if (_lastPosition == _HeadCardsGetReadyState.kCentered) {      
      setState(() { _msg = "${_counter}"; });
    } else {
      _countdownTimer?.cancel();
      _countdownTimer = null;
      _counter = 3; // reset the countdown.
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
      Navigator.popAndPushNamed(context, "/play");
      return;
    }

    setState(() { _msg = "${_counter}"; });
  }

  @override
  Widget build(BuildContext context) {
    if (_countdownTimer == null)
      _countdownTimer = new Timer(const Duration(seconds: 1), countDownTimerFired);

    return new Scaffold(
      body: new Center(
        child: new Text(_msg, 
          style: const TextStyle(color: const Color(0xFF000000), 
            fontSize: 50.0, fontWeight: FontWeight.bold)
          )
        )
      );
    }
}
