// lib/presentation/screens/home/acero/losa/datos/models/slab_form_data.dart
import 'package:flutter/material.dart';
import '../../../../../../../domain/entities/home/acero/losa_maciza/mesh_enums.dart';

class SlabFormData {
  // Controladores para dimensiones de la losa
  final TextEditingController descriptionController;
  final TextEditingController lengthController;
  final TextEditingController widthController;
  final TextEditingController bendLengthController;
  final TextEditingController elementsController;
  final TextEditingController wasteController;

  // Controladores para malla inferior (siempre presente)
  final TextEditingController inferiorHorizontalSeparationController;
  final TextEditingController inferiorVerticalSeparationController;

  // Controladores para malla superior (opcional)
  final TextEditingController superiorHorizontalSeparationController;
  final TextEditingController superiorVerticalSeparationController;

  // Diámetros seleccionados para mallas
  String inferiorHorizontalDiameter;
  String inferiorVerticalDiameter;
  String superiorHorizontalDiameter;
  String superiorVerticalDiameter;

  // Estado de malla superior
  bool useSuperiorMesh;

  SlabFormData({
    required this.descriptionController,
    required this.lengthController,
    required this.widthController,
    required this.bendLengthController,
    required this.elementsController,
    required this.wasteController,
    required this.inferiorHorizontalSeparationController,
    required this.inferiorVerticalSeparationController,
    required this.superiorHorizontalSeparationController,
    required this.superiorVerticalSeparationController,
    required this.inferiorHorizontalDiameter,
    required this.inferiorVerticalDiameter,
    required this.superiorHorizontalDiameter,
    required this.superiorVerticalDiameter,
    required this.useSuperiorMesh,
  });

  /// Factory constructor para crear una instancia inicial con valores por defecto
  factory SlabFormData.initial() {
    return SlabFormData(
      descriptionController: TextEditingController(),
      lengthController: TextEditingController(text: '1.8'),
      widthController: TextEditingController(text: '1.2'),
      bendLengthController: TextEditingController(text: '0.10'),
      elementsController: TextEditingController(text: '1'),
      wasteController: TextEditingController(text: '7.0'),

      // Malla inferior - valores por defecto del Excel
      inferiorHorizontalSeparationController: TextEditingController(text: '0.20'),
      inferiorVerticalSeparationController: TextEditingController(text: '0.20'),

      // Malla superior - valores por defecto
      superiorHorizontalSeparationController: TextEditingController(text: '0.20'),
      superiorVerticalSeparationController: TextEditingController(text: '0.20'),

      // Diámetros por defecto (3/8" como en el Excel)
      inferiorHorizontalDiameter: '3/8"',
      inferiorVerticalDiameter: '3/8"',
      superiorHorizontalDiameter: '3/8"',
      superiorVerticalDiameter: '3/8"',

      // Malla superior deshabilitada por defecto
      useSuperiorMesh: false,
    );
  }

  /// Obtiene los controladores para una malla y dirección específica
  Map<String, dynamic> getMeshControllers(MeshType meshType, MeshDirection direction) {
    if (meshType == MeshType.inferior) {
      if (direction == MeshDirection.horizontal) {
        return {
          'diameter': inferiorHorizontalDiameter,
          'separation': inferiorHorizontalSeparationController,
        };
      } else {
        return {
          'diameter': inferiorVerticalDiameter,
          'separation': inferiorVerticalSeparationController,
        };
      }
    } else {
      if (direction == MeshDirection.horizontal) {
        return {
          'diameter': superiorHorizontalDiameter,
          'separation': superiorHorizontalSeparationController,
        };
      } else {
        return {
          'diameter': superiorVerticalDiameter,
          'separation': superiorVerticalSeparationController,
        };
      }
    }
  }

  /// Establece el diámetro para una malla y dirección específica
  void setMeshDiameter(MeshType meshType, MeshDirection direction, String diameter) {
    if (meshType == MeshType.inferior) {
      if (direction == MeshDirection.horizontal) {
        inferiorHorizontalDiameter = diameter;
      } else {
        inferiorVerticalDiameter = diameter;
      }
    } else {
      if (direction == MeshDirection.horizontal) {
        superiorHorizontalDiameter = diameter;
      } else {
        superiorVerticalDiameter = diameter;
      }
    }
  }

  /// Obtiene el diámetro para una malla y dirección específica
  String getMeshDiameter(MeshType meshType, MeshDirection direction) {
    if (meshType == MeshType.inferior) {
      if (direction == MeshDirection.horizontal) {
        return inferiorHorizontalDiameter;
      } else {
        return inferiorVerticalDiameter;
      }
    } else {
      if (direction == MeshDirection.horizontal) {
        return superiorHorizontalDiameter;
      } else {
        return superiorVerticalDiameter;
      }
    }
  }

  /// Obtiene la separación para una malla y dirección específica
  String getMeshSeparation(MeshType meshType, MeshDirection direction) {
    if (meshType == MeshType.inferior) {
      if (direction == MeshDirection.horizontal) {
        return inferiorHorizontalSeparationController.text;
      } else {
        return inferiorVerticalSeparationController.text;
      }
    } else {
      if (direction == MeshDirection.horizontal) {
        return superiorHorizontalSeparationController.text;
      } else {
        return superiorVerticalSeparationController.text;
      }
    }
  }

  /// Valida si todos los campos obligatorios están completos
  bool get isValid {
    // Validar campos básicos
    if (descriptionController.text.isEmpty ||
        lengthController.text.isEmpty ||
        widthController.text.isEmpty ||
        bendLengthController.text.isEmpty ||
        elementsController.text.isEmpty ||
        wasteController.text.isEmpty) {
      return false;
    }

    // Validar malla inferior (siempre obligatoria)
    if (inferiorHorizontalSeparationController.text.isEmpty ||
        inferiorVerticalSeparationController.text.isEmpty) {
      return false;
    }

    // Validar malla superior si está habilitada
    if (useSuperiorMesh) {
      if (superiorHorizontalSeparationController.text.isEmpty ||
          superiorVerticalSeparationController.text.isEmpty) {
        return false;
      }
    }

    return true;
  }

  /// Valida si los valores numéricos son válidos
  bool get hasValidNumbers {
    try {
      double.parse(lengthController.text);
      double.parse(widthController.text);
      double.parse(bendLengthController.text);
      int.parse(elementsController.text);
      double.parse(wasteController.text);

      // Validar separaciones de malla inferior
      double.parse(inferiorHorizontalSeparationController.text);
      double.parse(inferiorVerticalSeparationController.text);

      // Validar separaciones de malla superior si está habilitada
      if (useSuperiorMesh) {
        double.parse(superiorHorizontalSeparationController.text);
        double.parse(superiorVerticalSeparationController.text);
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Obtiene un resumen de la configuración actual
  String get summary {
    final description = descriptionController.text.isNotEmpty
        ? descriptionController.text
        : 'Sin descripción';

    final dimensions = '${lengthController.text}m × ${widthController.text}m';

    final meshInfo = useSuperiorMesh
        ? 'Malla inferior + superior'
        : 'Solo malla inferior';

    return '$description ($dimensions) - $meshInfo';
  }

  /// Crea una copia de los datos actuales
  SlabFormData copy() {
    return SlabFormData(
      descriptionController: TextEditingController(text: descriptionController.text),
      lengthController: TextEditingController(text: lengthController.text),
      widthController: TextEditingController(text: widthController.text),
      bendLengthController: TextEditingController(text: bendLengthController.text),
      elementsController: TextEditingController(text: elementsController.text),
      wasteController: TextEditingController(text: wasteController.text),
      inferiorHorizontalSeparationController: TextEditingController(text: inferiorHorizontalSeparationController.text),
      inferiorVerticalSeparationController: TextEditingController(text: inferiorVerticalSeparationController.text),
      superiorHorizontalSeparationController: TextEditingController(text: superiorHorizontalSeparationController.text),
      superiorVerticalSeparationController: TextEditingController(text: superiorVerticalSeparationController.text),
      inferiorHorizontalDiameter: inferiorHorizontalDiameter,
      inferiorVerticalDiameter: inferiorVerticalDiameter,
      superiorHorizontalDiameter: superiorHorizontalDiameter,
      superiorVerticalDiameter: superiorVerticalDiameter,
      useSuperiorMesh: useSuperiorMesh,
    );
  }

  /// Limpia todos los controladores para evitar memory leaks
  void dispose() {
    descriptionController.dispose();
    lengthController.dispose();
    widthController.dispose();
    bendLengthController.dispose();
    elementsController.dispose();
    wasteController.dispose();
    inferiorHorizontalSeparationController.dispose();
    inferiorVerticalSeparationController.dispose();
    superiorHorizontalSeparationController.dispose();
    superiorVerticalSeparationController.dispose();
  }

  /// Restablece todos los campos a valores por defecto
  void reset() {
    descriptionController.clear();
    lengthController.text = '1.8';
    widthController.text = '1.2';
    bendLengthController.text = '0.10';
    elementsController.text = '1';
    wasteController.text = '7.0';

    inferiorHorizontalSeparationController.text = '0.20';
    inferiorVerticalSeparationController.text = '0.20';
    superiorHorizontalSeparationController.text = '0.20';
    superiorVerticalSeparationController.text = '0.20';

    inferiorHorizontalDiameter = '3/8"';
    inferiorVerticalDiameter = '3/8"';
    superiorHorizontalDiameter = '3/8"';
    superiorVerticalDiameter = '3/8"';

    useSuperiorMesh = false;
  }

  /// Serializa los datos a un Map para debugging o logging
  Map<String, dynamic> toMap() {
    return {
      'description': descriptionController.text,
      'length': lengthController.text,
      'width': widthController.text,
      'bendLength': bendLengthController.text,
      'elements': elementsController.text,
      'waste': wasteController.text,
      'inferiorHorizontal': {
        'diameter': inferiorHorizontalDiameter,
        'separation': inferiorHorizontalSeparationController.text,
      },
      'inferiorVertical': {
        'diameter': inferiorVerticalDiameter,
        'separation': inferiorVerticalSeparationController.text,
      },
      'superiorHorizontal': {
        'diameter': superiorHorizontalDiameter,
        'separation': superiorHorizontalSeparationController.text,
      },
      'superiorVertical': {
        'diameter': superiorVerticalDiameter,
        'separation': superiorVerticalSeparationController.text,
      },
      'useSuperiorMesh': useSuperiorMesh,
    };
  }

  @override
  String toString() {
    return 'SlabFormData(${toMap()})';
  }
}