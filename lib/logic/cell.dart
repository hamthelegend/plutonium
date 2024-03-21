class NegativeMassException extends FormatException {
  final int mass;

  NegativeMassException({required this.mass})
      : super('Cannot create cell of mass $mass. '
            'Mass must be >= 0.');
}

class InvalidPlayerException extends FormatException {
  final int player;

  InvalidPlayerException({required this.player})
      : super('Cannot create cell with player $player. '
            'Player must be >= 0.');
}

class PlayerlessOrbsException extends FormatException {
  final int mass;

  PlayerlessOrbsException({required this.mass})
      : super('Cannot create cell of mass $mass with no players. '
            'A player can only own a cell with orbs.');
}

class OrblessPlayerException extends FormatException {
  final int player;

  OrblessPlayerException({required this.player})
      : super('Cannot create cell of player $player with no orbs. '
            'Player can only own a cell with at least one orb.');
}

class Cell {
  final int? player;
  final int mass;

  Cell({this.player, this.mass = 0}) {
    if (mass < 0) {
      throw NegativeMassException(mass: mass);
    }
    if ((player ?? 0) < 0) {
      throw InvalidPlayerException(player: player!);
    }
    if (player == null && mass > 0) {
      throw PlayerlessOrbsException(mass: mass);
    }
    if (player != null && mass == 0) {
      throw OrblessPlayerException(player: player!);
    }
  }

  @override
  String toString() => 'Cell(player: $player, mass: $mass)';

  @override
  bool operator ==(Object other) =>
      other is Cell && player == other.player && mass == other.mass;

  @override
  int get hashCode {
    int result = player.hashCode;
    result = 31 * result + mass.hashCode;
    return result;
  }
}
