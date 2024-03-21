enum CellType {
  corner(criticalMass: 2),
  edge(criticalMass: 3),
  interior(criticalMass: 4);

  const CellType({required this.criticalMass});

  final int criticalMass;
}