import 'package:dars_4/ember_quest.dart';
import 'package:dars_4/overlays/next_level.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'overlays/overlays.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set the preferred orientations to landscape only
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
  ]);

  runApp(
    GameWidget<EmberQuestGame>.controlled(
      gameFactory: EmberQuestGame.new,
      overlayBuilderMap: {
        'MainMenu': (_, game) => MainMenu(game: game),
        'GameOver': (_, game) => GameOver(game: game),
        'GameControls': (_, game) => GameControls(game: game),
        'NextLevel': (_, game) => NextLevelOverlay(game: game),
      },
      initialActiveOverlays: const ['MainMenu', 'GameControls'],
    ),
  );
}
