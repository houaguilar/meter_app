import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'custom_brick_providers.g.dart';

/// Provider para dimensiones del ladrillo personalizado
@riverpod
class CustomBrickDimensions extends _$CustomBrickDimensions {
  @override
  CustomDimensions build() => const CustomDimensions();

  void updateDimensions({
    double? length,
    double? width,
    double? height,
    String? name,
  }) {
    state = state.copyWith(
      length: length,
      width: width,
      height: height,
      customName: name,
    );
  }

  void clearDimensions() {
    state = const CustomDimensions();
  }
}

/// Clase para almacenar dimensiones personalizadas
class CustomDimensions {
  final double length;
  final double width;
  final double height;
  final String customName;

  const CustomDimensions({
    this.length = 24.0,  // Valores por defecto similares a King Kong
    this.width = 13.0,
    this.height = 9.0,
    this.customName = 'Ladrillo Personalizado',
  });

  CustomDimensions copyWith({
    double? length,
    double? width,
    double? height,
    String? customName,
  }) {
    return CustomDimensions(
      length: length ?? this.length,
      width: width ?? this.width,
      height: height ?? this.height,
      customName: customName ?? this.customName,
    );
  }

  @override
  String toString() {
    return 'CustomDimensions(length: $length, width: $width, height: $height, name: $customName)';
  }
}