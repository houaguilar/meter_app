/// Formatea un valor decimal para mostrar en resultados de cálculo.
///
/// Reglas:
/// - Si el valor es exactamente 0 → "0.00" (sin material requerido)
/// - Si el valor es > 0 pero se redondea a "0.00" → "0.01" (cantidad mínima)
/// - Cualquier otro valor positivo → formateado con [decimals] decimales
String formatResultValue(double value, {int decimals = 2}) {
  if (value <= 0) return (0.0).toStringAsFixed(decimals);
  final formatted = value.toStringAsFixed(decimals);
  if (formatted == (0.0).toStringAsFixed(decimals)) {
    return (0.01).toStringAsFixed(decimals);
  }
  return formatted;
}
