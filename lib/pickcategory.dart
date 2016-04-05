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
  List<String> _game_categories = new List<String>();

  loadGames() async {
    String json = await DefaultAssetBundle.of(context).loadString('assets/games.json');
    _games = JSON.decode(json);
    _game_categories = _games['categories'];

    // debug
    for (var cat in _game_categories)
      print("${cat['words'].length} words");

      // 'dirty' the state object.
      setState(() {});
  }

  @override
  void initState() {
    super.initState();

    // load cached state.
    loadGames();

    print("config = ${config.toString()}");

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
    print("_game_categories -> ${_game_categories.toString()}");
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Select a Category')
      ),
      body: new MaterialList(
        type: MaterialListType.oneLineWithAvatar,
        children: _game_categories.map((String title_) {
          return new CategoryListItem(title: title_);
          })
      )
      /*floatingActionButton: new FloatingActionButton(
        onPressed: _playGame,
        tooltip: 'Play',
        child: new Icon(
          icon: Icons.play_arrow
        )
      )*/
    );
  }
}


class CategoryListItem extends StatelessWidget {
  CategoryListItem({String title}) 
    : title = title, super(key: new ObjectKey(title));

  final String title;

  //final CartChangedCallback onCartChanged;


   Color _getColor(BuildContext context) {
    return Colors.black54; //return inCart ? Colors.black54 : Theme.of(context).primaryColor;
  }

   TextStyle _getTextStyle(BuildContext context) {
    //if (inCart) {
      return DefaultTextStyle.of(context).copyWith(
          color: Colors.black54, decoration: TextDecoration.lineThrough);
    //}
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return new ListItem(
      //onTap: () => onCartChanged(product, !inCart),
      leading: new CircleAvatar(
        backgroundColor: _getColor(context),
        child: new Text(title)
      ),
      title: new Text(title, style: _getTextStyle(context))
    );
  }
}

/*
class CategoryList extends StatefulWidget {
  CategoryList({ Key key, this.products }) : super(key: key);

  final List<String> products;

  @override
  _CategoryListState createState() => new _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  Set<Product> _shoppingCart = new Set<Product>();

  void _handleCartChanged(Product product, bool inCart) {
    setState(() {
      if (inCart)
        _shoppingCart.add(product);
      else
        _shoppingCart.remove(product);
    });
  }

  @override
  Widget build(BuildContext context)  {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Shopping List')
      ),
      body: new MaterialList(
        type: MaterialListType.oneLineWithAvatar,
        children: config.products.map((Product product) {
          return new CategoryListItem(
            name: product,
            //inCart: _shoppingCart.contains(product),
            onCartChanged: _handleCartChanged
          );
        })
      )
    );
  }
}
*/