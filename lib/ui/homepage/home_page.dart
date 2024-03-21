import 'package:flutter/material.dart';

import '../../logic/constants.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.playerCount,
    required this.onPlayerCountChange,
    required this.boardSize,
    required this.onBoardSizeChange,
    required this.onPlay,
  });

  final int playerCount;
  final void Function(int) onPlayerCountChange;
  final BoardSize boardSize;
  final void Function(BoardSize) onBoardSizeChange;
  final void Function() onPlay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 256),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Text(
                      'Plutonium',
                      style: theme.textTheme.displaySmall,
                    ),
                  ),
                  const SizedBox(height: 32),
                  LayoutBuilder(builder: (context, constraints) {
                    return DropdownMenu(
                      width: constraints.maxWidth,
                      onSelected: (value) {
                        onPlayerCountChange(value ?? playerCount);
                      },
                      initialSelection: 2,
                      inputDecorationTheme:
                          const InputDecorationTheme(filled: true),
                      dropdownMenuEntries: [
                        for (final playerCount in playerCounts)
                          DropdownMenuEntry(
                            value: playerCount,
                            label: '$playerCount players',
                          ),
                      ],
                    );
                  }),
                  const SizedBox(height: 16),
                  SegmentedButton(
                    selected: {boardSize},
                    segments: [
                      for (final boardSize in BoardSize.values)
                        ButtonSegment(
                          value: boardSize,
                          label: Text(boardSize.label),
                        ),
                    ],
                    onSelectionChanged: (value) => onBoardSizeChange(value.first),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: onPlay,
                    child: const Text('Play'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
