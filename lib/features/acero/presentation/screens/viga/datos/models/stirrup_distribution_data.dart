// Modelo para datos de distribución de estribos
class StirrupDistributionData {
  int quantity;
  double separation;

  StirrupDistributionData({
    required this.quantity,
    required this.separation,
  });

  StirrupDistributionData copyWith({
    int? quantity,
    double? separation,
  }) {
    return StirrupDistributionData(
      quantity: quantity ?? this.quantity,
      separation: separation ?? this.separation,
    );
  }
}