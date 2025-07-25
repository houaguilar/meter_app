// lib/presentation/providers/home/muro/custom_brick_providers.dart

import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'custom_brick_providers.g.dart';

/// Provider para dimensiones del ladrillo personalizado actual
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

  void loadFromConfig(CustomBrickConfig config) {
    state = CustomDimensions(
      length: config.length,
      width: config.width,
      height: config.height,
      customName: config.name,
    );
  }
}

/// Provider para ladrillos personalizados guardados
@riverpod
class SavedCustomBricks extends _$SavedCustomBricks {
  static const String _storageKey = 'saved_custom_bricks';

  @override
  Future<List<CustomBrickConfig>> build() async {
    return await _loadFromStorage();
  }

  Future<List<CustomBrickConfig>> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);

      if (jsonString == null) return [];

      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map((json) => CustomBrickConfig.fromJson(json))
          .toList();
    } catch (e) {
      print('Error loading custom bricks: $e');
      return [];
    }
  }

  Future<void> _saveToStorage(List<CustomBrickConfig> bricks) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(bricks.map((brick) => brick.toJson()).toList());
      await prefs.setString(_storageKey, jsonString);
    } catch (e) {
      print('Error saving custom bricks: $e');
    }
  }

  Future<void> saveCustomBrick(CustomBrickConfig config) async {
    final currentBricks = await future;

    // Evitar duplicados por nombre
    final existingIndex = currentBricks.indexWhere((brick) => brick.name == config.name);

    List<CustomBrickConfig> updatedBricks;
    if (existingIndex != -1) {
      // Actualizar existente
      updatedBricks = [...currentBricks];
      updatedBricks[existingIndex] = config;
    } else {
      // Agregar nuevo
      updatedBricks = [...currentBricks, config];
    }

    // Limitar a máximo 10 ladrillos guardados
    if (updatedBricks.length > 10) {
      updatedBricks = updatedBricks.sublist(updatedBricks.length - 10);
    }

    await _saveToStorage(updatedBricks);
    state = AsyncData(updatedBricks);
  }

  Future<void> deleteCustomBrick(String id) async {
    final currentBricks = await future;
    final updatedBricks = currentBricks.where((brick) => brick.id != id).toList();

    await _saveToStorage(updatedBricks);
    state = AsyncData(updatedBricks);
  }

  Future<void> clearAllCustomBricks() async {
    await _saveToStorage([]);
    state = const AsyncData([]);
  }
}

/// Provider para el ladrillo personalizado seleccionado actualmente
@riverpod
class SelectedCustomBrick extends _$SelectedCustomBrick {
  @override
  CustomBrickConfig? build() => null;

  void selectBrick(CustomBrickConfig? config) {
    state = config;

    // Actualizar las dimensiones actuales
    if (config != null) {
      ref.read(customBrickDimensionsProvider.notifier).loadFromConfig(config);
    }
  }

  void clearSelection() {
    state = null;
  }
}

/// Clase para almacenar dimensiones personalizadas
class CustomDimensions {
  final double length;
  final double width;
  final double height;
  final String customName;

  const CustomDimensions({
    this.length = 24.0,
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

/// Clase para configuración completa de ladrillo personalizado
class CustomBrickConfig {
  final String id;
  final String name;
  final double length;
  final double width;
  final double height;
  final DateTime createdAt;

  const CustomBrickConfig({
    required this.id,
    required this.name,
    required this.length,
    required this.width,
    required this.height,
    required this.createdAt,
  });

  factory CustomBrickConfig.fromJson(Map<String, dynamic> json) {
    return CustomBrickConfig(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Ladrillo Personalizado',
      length: (json['length'] ?? 24.0).toDouble(),
      width: (json['width'] ?? 13.0).toDouble(),
      height: (json['height'] ?? 9.0).toDouble(),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'length': length,
      'width': width,
      'height': height,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  CustomBrickConfig copyWith({
    String? id,
    String? name,
    double? length,
    double? width,
    double? height,
    DateTime? createdAt,
  }) {
    return CustomBrickConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      length: length ?? this.length,
      width: width ?? this.width,
      height: height ?? this.height,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get displaySize => '${length.toStringAsFixed(1)}×${width.toStringAsFixed(1)}×${height.toStringAsFixed(1)} cm';

  double get volume => (length * width * height) / 1000; // en litros

  @override
  String toString() {
    return 'CustomBrickConfig(id: $id, name: $name, ${displaySize})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CustomBrickConfig &&
        other.id == id &&
        other.name == name &&
        other.length == length &&
        other.width == width &&
        other.height == height;
  }

  @override
  int get hashCode {
    return Object.hash(id, name, length, width, height);
  }
}