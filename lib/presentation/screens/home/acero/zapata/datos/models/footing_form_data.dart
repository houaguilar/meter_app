import 'package:flutter/material.dart';

/// Modelo para los datos del formulario de una zapata
class FootingFormData {
  // Controladores de texto para datos generales
  late final TextEditingController descriptionController;
  late final TextEditingController wasteController;
  late final TextEditingController elementsController;
  late final TextEditingController coverController;

  // Controladores para dimensiones
  late final TextEditingController lengthController;
  late final TextEditingController widthController;

  // Controladores para malla inferior (siempre habilitada)
  String inferiorHorizontalDiameter = '1/2"';
  late final TextEditingController inferiorHorizontalSeparationController;
  String inferiorVerticalDiameter = '1/2"';
  late final TextEditingController inferiorVerticalSeparationController;
  late final TextEditingController inferiorBendLengthController;

  // Configuración de malla superior (opcional)
  bool hasSuperiorMesh = false;
  String superiorHorizontalDiameter = '1/2"';
  late final TextEditingController superiorHorizontalSeparationController;
  String superiorVerticalDiameter = '1/2"';
  late final TextEditingController superiorVerticalSeparationController;

  FootingFormData._();

  factory FootingFormData.initial({int index = 1}) {
    final data = FootingFormData._();
    data._initializeControllers(index);
    data._initializeDefaultData();
    return data;
  }

  void _initializeControllers(int index) {
    // Datos generales
    descriptionController = TextEditingController(text: 'ZAPATA $index');
    wasteController = TextEditingController(text: '7');
    elementsController = TextEditingController(text: '1');
    coverController = TextEditingController(text: '7.5');

    // Dimensiones
    lengthController = TextEditingController(text: '1.8');
    widthController = TextEditingController(text: '1.2');

    // Malla inferior
    inferiorHorizontalSeparationController = TextEditingController(text: '0.2');
    inferiorVerticalSeparationController = TextEditingController(text: '0.2');
    inferiorBendLengthController = TextEditingController(text: '0.15');

    // Malla superior
    superiorHorizontalSeparationController = TextEditingController(text: '0.25');
    superiorVerticalSeparationController = TextEditingController(text: '0.25');
  }

  void _initializeDefaultData() {
    // Los valores por defecto ya están configurados en los controladores
    // Aquí se pueden agregar configuraciones adicionales si es necesario
  }

  // Métodos para obtener valores numéricos
  double get waste => double.tryParse(wasteController.text) ?? 0.0;
  int get elements => int.tryParse(elementsController.text) ?? 1;
  double get cover => (double.tryParse(coverController.text) ?? 0.0) / 100; // Convertir cm a m
  double get length => double.tryParse(lengthController.text) ?? 0.0;
  double get width => double.tryParse(widthController.text) ?? 0.0;

  // Malla inferior
  double get inferiorHorizontalSeparation => double.tryParse(inferiorHorizontalSeparationController.text) ?? 0.0;
  double get inferiorVerticalSeparation => double.tryParse(inferiorVerticalSeparationController.text) ?? 0.0;
  double get inferiorBendLength => double.tryParse(inferiorBendLengthController.text) ?? 0.0;

  // Malla superior
  double get superiorHorizontalSeparation => double.tryParse(superiorHorizontalSeparationController.text) ?? 0.0;
  double get superiorVerticalSeparation => double.tryParse(superiorVerticalSeparationController.text) ?? 0.0;

  // Validación
  bool get isValid {
    return length > 0 &&
        width > 0 &&
        elements > 0 &&
        inferiorHorizontalSeparation > 0 &&
        inferiorVerticalSeparation > 0 &&
        (!hasSuperiorMesh || (superiorHorizontalSeparation > 0 && superiorVerticalSeparation > 0));
  }

  // Método para limpiar recursos
  void dispose() {
    descriptionController.dispose();
    wasteController.dispose();
    elementsController.dispose();
    coverController.dispose();
    lengthController.dispose();
    widthController.dispose();
    inferiorHorizontalSeparationController.dispose();
    inferiorVerticalSeparationController.dispose();
    inferiorBendLengthController.dispose();
    superiorHorizontalSeparationController.dispose();
    superiorVerticalSeparationController.dispose();
  }

  // Método para copiar datos
  FootingFormData copyWith({
    String? description,
    double? waste,
    int? elements,
    double? cover,
    double? length,
    double? width,
    String? inferiorHorizontalDiameter,
    double? inferiorHorizontalSeparation,
    String? inferiorVerticalDiameter,
    double? inferiorVerticalSeparation,
    double? inferiorBendLength,
    bool? hasSuperiorMesh,
    String? superiorHorizontalDiameter,
    double? superiorHorizontalSeparation,
    String? superiorVerticalDiameter,
    double? superiorVerticalSeparation,
  }) {
    final newData = FootingFormData._();

    // Copiar controladores con nuevos valores
    newData.descriptionController = TextEditingController(text: description ?? descriptionController.text);
    newData.wasteController = TextEditingController(text: waste?.toString() ?? wasteController.text);
    newData.elementsController = TextEditingController(text: elements?.toString() ?? elementsController.text);
    newData.coverController = TextEditingController(text: cover?.toString() ?? coverController.text);
    newData.lengthController = TextEditingController(text: length?.toString() ?? lengthController.text);
    newData.widthController = TextEditingController(text: width?.toString() ?? widthController.text);

    // Malla inferior
    newData.inferiorHorizontalDiameter = inferiorHorizontalDiameter ?? this.inferiorHorizontalDiameter;
    newData.inferiorHorizontalSeparationController = TextEditingController(
        text: inferiorHorizontalSeparation?.toString() ?? inferiorHorizontalSeparationController.text
    );
    newData.inferiorVerticalDiameter = inferiorVerticalDiameter ?? this.inferiorVerticalDiameter;
    newData.inferiorVerticalSeparationController = TextEditingController(
        text: inferiorVerticalSeparation?.toString() ?? inferiorVerticalSeparationController.text
    );
    newData.inferiorBendLengthController = TextEditingController(
        text: inferiorBendLength?.toString() ?? inferiorBendLengthController.text
    );

    // Malla superior
    newData.hasSuperiorMesh = hasSuperiorMesh ?? this.hasSuperiorMesh;
    newData.superiorHorizontalDiameter = superiorHorizontalDiameter ?? this.superiorHorizontalDiameter;
    newData.superiorHorizontalSeparationController = TextEditingController(
        text: superiorHorizontalSeparation?.toString() ?? superiorHorizontalSeparationController.text
    );
    newData.superiorVerticalDiameter = superiorVerticalDiameter ?? this.superiorVerticalDiameter;
    newData.superiorVerticalSeparationController = TextEditingController(
        text: superiorVerticalSeparation?.toString() ?? superiorVerticalSeparationController.text
    );

    return newData;
  }
}