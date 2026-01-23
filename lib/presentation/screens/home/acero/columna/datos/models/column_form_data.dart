
import 'package:flutter/material.dart';
import 'package:meter_app/presentation/screens/home/acero/viga/datos/models/steel_bar_data.dart';
import 'package:meter_app/presentation/screens/home/acero/viga/datos/models/stirrup_distribution_data.dart';

class ColumnFormData {
  // Controladores de texto para datos generales
  late final TextEditingController descriptionController;
  late final TextEditingController wasteController;
  late final TextEditingController elementsController;
  late final TextEditingController coverController;
  late final TextEditingController stirrupCoverController;

  // Controladores para dimensiones básicas
  late final TextEditingController heightController;
  late final TextEditingController lengthController;
  late final TextEditingController widthController;

  // Datos específicos de zapata
  bool hasFooting = false;
  late final TextEditingController footingHeightController;
  late final TextEditingController footingBendController;

  // Acero longitudinal (sin doblez)
  bool useSplice = false;

  // Controladores para estribos
  String stirrupDiameter = '6mm';
  late final TextEditingController stirrupBendLengthController;
  late final TextEditingController restSeparationController;

  // Listas dinámicas
  List<SteelBarData> steelBars = [];
  List<StirrupDistributionData> stirrupDistributions = [];

  ColumnFormData._();

  factory ColumnFormData.initial({int index = 1}) {
    final data = ColumnFormData._();
    data._initializeControllers(index);
    data._initializeDefaultData();
    return data;
  }

  void _initializeControllers(int index) {
    descriptionController = TextEditingController(text: 'COLUMNA $index');
    wasteController = TextEditingController(text: '7');
    elementsController = TextEditingController(text: '1');
    coverController = TextEditingController(text: '4');
    stirrupCoverController = TextEditingController(text: '4');

    // Dimensiones de columna - inicialmente vacías para que el usuario las ingrese
    heightController = TextEditingController();
    lengthController = TextEditingController();
    widthController = TextEditingController();

    // Datos de zapata - valores sugeridos
    footingHeightController = TextEditingController(text: '0.60');
    footingBendController = TextEditingController(text: '0.40');

    // Configuración de estribos - valores sugeridos
    stirrupBendLengthController = TextEditingController(text: '0.08');
    restSeparationController = TextEditingController(text: '0.20');
  }

  void _initializeDefaultData() {
    // Agregar barras de acero por defecto
    steelBars.add(SteelBarData(quantity: 0, diameter: '1/2"'));

    // Agregar distribuciones de estribos por defecto
    stirrupDistributions.add(StirrupDistributionData(quantity: 1, separation: 0.05));
    stirrupDistributions.add(StirrupDistributionData(quantity: 6, separation: 0.10));
    stirrupDistributions.add(StirrupDistributionData(quantity: 4, separation: 0.15));
  }

  bool isValid() {
    try {
      if (descriptionController.text.isEmpty) return false;

      final waste = double.tryParse(wasteController.text);
      if (waste == null || waste < 0 || waste > 50) return false;

      final elements = int.tryParse(elementsController.text);
      if (elements == null || elements <= 0) return false;

      final cover = double.tryParse(coverController.text);
      if (cover == null || cover <= 0) return false;

      final stirrupCover = double.tryParse(stirrupCoverController.text);
      if (stirrupCover == null || stirrupCover <= 0) return false;

      final height = double.tryParse(heightController.text);
      if (height == null || height <= 0) return false;

      final length = double.tryParse(lengthController.text);
      if (length == null || length <= 0) return false;

      final width = double.tryParse(widthController.text);
      if (width == null || width <= 0) return false;

      // Validar datos de zapata si está habilitada
      if (hasFooting) {
        final footingHeight = double.tryParse(footingHeightController.text);
        if (footingHeight == null || footingHeight <= 0) return false;

        final footingBend = double.tryParse(footingBendController.text);
        if (footingBend == null || footingBend < 0) return false;
      }

      final stirrupBendLength = double.tryParse(stirrupBendLengthController.text);
      if (stirrupBendLength == null || stirrupBendLength < 0) return false;

      final restSeparation = double.tryParse(restSeparationController.text);
      if (restSeparation == null || restSeparation <= 0) return false;

      return steelBars.isNotEmpty && stirrupDistributions.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  void dispose() {
    descriptionController.dispose();
    wasteController.dispose();
    elementsController.dispose();
    coverController.dispose();
    stirrupCoverController.dispose();
    heightController.dispose();
    lengthController.dispose();
    widthController.dispose();
    footingHeightController.dispose();
    footingBendController.dispose();
    stirrupBendLengthController.dispose();
    restSeparationController.dispose();
  }
}
