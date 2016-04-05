library headcards;

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_sprites/flutter_sprites.dart';

import 'package:mojo_services/sensors/sensors.mojom.dart' as mojom;

part 'sound_assets.dart';

part 'gameboard.dart';
part 'getready.dart';
part 'pickcategory.dart';



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

