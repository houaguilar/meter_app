// lib/presentation/screens/home/acero/viga/datos/models/beam_form_data.dart
import 'package:flutter/material.dart';
import 'package:meter_app/presentation/screens/home/acero/viga/datos/models/steel_bar_data.dart';
import 'package:meter_app/presentation/screens/home/acero/viga/datos/models/stirrup_distribution_data.dart';

// Modelo para los datos del formulario de una viga
class BeamFormData {
  // Controladores de texto para datos generales
  late final TextEditingController descriptionController;
  late final TextEditingController wasteController;
  late final TextEditingController elementsController;
  late final TextEditingController coverController;

  // Controladores para dimensiones
  late final TextEditingController heightController;
  late final TextEditingController lengthController;
  late final TextEditingController widthController;
  late final TextEditingController supportA1Controller;
  late final TextEditingController supportA2Controller;

  // Controladores para acero longitudinal
  late final TextEditingController bendLengthController;
  bool useSplice = false;

  // Controladores para estribos
  String stirrupDiameter = '6mm';
  late final TextEditingController stirrupBendLengthController;
  late final TextEditingController restSeparationController;

  // Listas dinámicas
  List<SteelBarData> steelBars = [];
  List<StirrupDistributionData> stirrupDistributions = [];

  BeamFormData._();

  factory BeamFormData.initial({int index = 1}) {
    final data = BeamFormData._();
    data._initializeControllers(index);
    data._initializeDefaultData();
    return data;
  }

  void _initializeControllers(int index) {
    descriptionController = TextEditingController(text: 'VIGA $index');
    wasteController = TextEditingController(text: '7');
    elementsController = TextEditingController(text: '1');
    coverController = TextEditingController(text: '2.5');

    heightController = TextEditingController(text: '0.60');
    lengthController = TextEditingController(text: '6.00');
    widthController = TextEditingController(text: '0.30');
    supportA1Controller = TextEditingController(text: '0.50');
    supportA2Controller = TextEditingController(text: '0.50');

    bendLengthController = TextEditingController(text: '0.15');
    stirrupBendLengthController = TextEditingController(text: '0.10');
    restSeparationController = TextEditingController(text: '0.25');
  }

  void _initializeDefaultData() {
    // Agregar una barra de acero por defecto
    steelBars.add(SteelBarData(quantity: 4, diameter: '1/2"'));

    // Agregar una distribución de estribos por defecto
    stirrupDistributions.add(StirrupDistributionData(quantity: 5, separation: 0.10));
  }

  bool isValid() {
    // Validar que todos los campos requeridos tengan valores válidos
    try {
      if (descriptionController.text.isEmpty) return false;

      final waste = double.tryParse(wasteController.text);
      if (waste == null || waste < 0 || waste > 50) return false;

      final elements = int.tryParse(elementsController.text);
      if (elements == null || elements <= 0) return false;

      final cover = double.tryParse(coverController.text);
      if (cover == null || cover <= 0) return false;

      final height = double.tryParse(heightController.text);
      if (height == null || height <= 0) return false;

      final length = double.tryParse(lengthController.text);
      if (length == null || length <= 0) return false;

      final width = double.tryParse(widthController.text);
      if (width == null || width <= 0) return false;

      final supportA1 = double.tryParse(supportA1Controller.text);
      if (supportA1 == null || supportA1 < 0) return false;

      final supportA2 = double.tryParse(supportA2Controller.text);
      if (supportA2 == null || supportA2 < 0) return false;

      final bendLength = double.tryParse(bendLengthController.text);
      if (bendLength == null || bendLength < 0) return false;

      final stirrupBendLength = double.tryParse(stirrupBendLengthController.text);
      if (stirrupBendLength == null || stirrupBendLength < 0) return false;

      final restSeparation = double.tryParse(restSeparationController.text);
      if (restSeparation == null || restSeparation <= 0) return false;

      // Validar que exista al menos una barra de acero
      if (steelBars.isEmpty) return false;
      for (final bar in steelBars) {
        if (bar.quantity <= 0) return false;
      }

      // Validar que exista al menos una distribución de estribos
      if (stirrupDistributions.isEmpty) return false;
      for (final distribution in stirrupDistributions) {
        if (distribution.quantity <= 0 || distribution.separation <= 0) return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  void dispose() {
    descriptionController.dispose();
    wasteController.dispose();
    elementsController.dispose();
    coverController.dispose();
    heightController.dispose();
    lengthController.dispose();
    widthController.dispose();
    supportA1Controller.dispose();
    supportA2Controller.dispose();
    bendLengthController.dispose();
    stirrupBendLengthController.dispose();
    restSeparationController.dispose();
  }
}
