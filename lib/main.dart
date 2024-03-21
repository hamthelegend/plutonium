import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plutonium/logic/constants.dart';
import 'package:plutonium/ui/game/game_page_controller.dart';
import 'package:plutonium/ui/homepage/home_page.dart';
import 'package:plutonium/ui/homepage/home_page_controller.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final router = GoRouter(routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePageController(),
      routes: [
        GoRoute(
            path: 'game',
            builder: (context, state) => GamePageController(
                  playerCount: int.parse(
                      state.uri.queryParameters['playerCount'] ?? '2'),
                  boardSize: BoardSize.values.byName(
                      state.uri.queryParameters['boardSize'] ?? 'small'),
                ))
      ],
    ),
  ]);

  @override
  Widget build(BuildContext context) {
    var colorSchemeSeed = Colors.green;

    final lightThemeData = ThemeData(
      brightness: Brightness.light,
      colorSchemeSeed: colorSchemeSeed,
      useMaterial3: true,
    );

    final darkThemeData = ThemeData(
      brightness: Brightness.dark,
      colorSchemeSeed: colorSchemeSeed,
      useMaterial3: true,
    );

    return MaterialApp.router(
      routerConfig: router,
      title: 'Plutonium',
      theme: lightThemeData,
      darkTheme: darkThemeData,
    );
  }
}
