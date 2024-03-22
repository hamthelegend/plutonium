import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plutonium/logic/constants.dart';
import 'package:plutonium/ui/homepage/home_page.dart';

class HomePageController extends StatefulWidget {
  const HomePageController({super.key});

  @override
  State<HomePageController> createState() => _HomePageControllerState();
}

class _HomePageControllerState extends State<HomePageController> {
  int playerCount = 2;
  BoardSize boardSize = BoardSize.small;

  @override
  Widget build(final BuildContext context) {
    return HomePage(
      playerCount: playerCount,
      onPlayerCountChange: (final value) => setState(() => playerCount = value),
      boardSize: boardSize,
      onBoardSizeChange: (final value) => setState(() => boardSize = value),
      onPlay: () => context
          .go('/game?playerCount=$playerCount&boardSize=${boardSize.name}'),
    );
  }
}
