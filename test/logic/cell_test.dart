import 'package:flutter_test/flutter_test.dart';
import 'package:plutonium/logic/cell.dart';

void main() {
  test('Can create a default empty cell', () {
    final cell = Cell();
    expect(cell.player, null);
    expect(cell.mass, 0);
  });

  test('Can create a cell with a player and mass', () {
    final cell = Cell(player: 1, mass: 3);
    expect(cell.player, 1);
    expect(cell.mass, 3);
  });

  test('Cannot create a cell with negative mass', () {
    expect(() => Cell(mass: -1), throwsA(isA<NegativeMassException>()));
  });

  test('Cannot create a cell with negative player', () {
    expect(() => Cell(player: -1), throwsA(isA<InvalidPlayerException>()));
  });

  test('Cannot create a cell with mass and no player', () {
    expect(() => Cell(mass: 1), throwsA(isA<PlayerlessOrbsException>()));
  });

  test('Cannot create a cell with player and no mass', () {
    expect(() => Cell(player: 1), throwsA(isA<OrblessPlayerException>()));
  });

  test('Hash code is consistent with equality', () {
    final cell1 = Cell(player: 1, mass: 3);
    final cell2 = Cell(player: 1, mass: 3);
    expect(cell1, cell2);
    expect(cell1.hashCode, cell2.hashCode);
  });
}