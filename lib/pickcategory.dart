part of headcards;

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
