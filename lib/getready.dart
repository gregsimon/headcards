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

  Timer _countdownTimer = null;
  int _counter = 3;
  int _lastPosition = _HeadCardsGetReadyState.kUnknown;
  String _msg = "";

  @override
  initState() {
    super.initState();
    _countdownTimer = new Timer(const Duration(seconds: 1), countDownTimerFired);
  }

  @override
  dispose() {
    super.dispose();
  }

  void countDownTimerFired() {
    if (0 == (_counter-1)) {
      Navigator.popAndPushNamed(context, "/play");
      return;
    }

    _countdownTimer = new Timer(const Duration(seconds: 1), countDownTimerFired);
    setState( () { _counter--; });
  }

  @override
  Widget build(BuildContext context) {

    return new Scaffold(
      body: new Center(
        child: new Text("Ready in ${_counter}...",
          style: const TextStyle(color: const Color(0xFF000000), 
            fontSize: 58.0, fontWeight: FontWeight.bold)
          )
        )
      );
    }
}
