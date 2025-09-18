// Modelo para datos de barras de acero
class SteelBarData {
  int quantity;
  String diameter;

  SteelBarData({
    required this.quantity,
    required this.diameter,
  });

  SteelBarData copyWith({
    int? quantity,
    String? diameter,
  }) {
    return SteelBarData(
      quantity: quantity ?? this.quantity,
      diameter: diameter ?? this.diameter,
    );
  }
}
