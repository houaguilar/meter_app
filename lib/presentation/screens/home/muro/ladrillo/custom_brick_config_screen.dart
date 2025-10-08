// lib/presentation/screens/home/muro/ladrillo/custom_brick_config_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../config/theme/theme.dart';
import '../../../../../domain/entities/home/muro/custom_brick.dart';
import '../../../../providers/home/muro/custom_brick_providers.dart';
import '../../../../providers/home/muro/custom_brick_isar_providers.dart';
import '../../../../providers/providers.dart';

class CustomBrickConfigScreen extends ConsumerStatefulWidget {
  const CustomBrickConfigScreen({super.key});

  @override
  ConsumerState<CustomBrickConfigScreen> createState() => _CustomBrickConfigScreenState();
}

class _CustomBrickConfigScreenState extends ConsumerState<CustomBrickConfigScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'Mi Ladrillo');
  final _lengthController = TextEditingController(text: '24.0');
  final _widthController = TextEditingController(text: '13.0');
  final _heightController = TextEditingController(text: '9.0');

  // Focus nodes para gestión del teclado
  final _nameFocus = FocusNode();
  final _lengthFocus = FocusNode();
  final _widthFocus = FocusNode();
  final _heightFocus = FocusNode();

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Cargar dimensiones existentes si las hay
    final currentConfig = ref.read(customBrickDimensionsProvider);
    _lengthController.text = currentConfig.length.toString();
    _widthController.text = currentConfig.width.toString();
    _heightController.text = currentConfig.height.toString();
    _nameController.text = currentConfig.customName;

    // Animación para el ladrillo
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _lengthController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    _nameController.dispose();
    _nameFocus.dispose();
    _lengthFocus.dispose();
    _widthFocus.dispose();
    _heightFocus.dispose();
    super.dispose();
  }

  double get _currentLength => double.tryParse(_lengthController.text) ?? 24.0;
  double get _currentWidth => double.tryParse(_widthController.text) ?? 13.0;
  double get _currentHeight => double.tryParse(_heightController.text) ?? 9.0;

  // Método para ocultar teclado
  void _hideKeyboard() {
    FocusScope.of(context).unfocus();
  }

  // Navegación entre campos
  void _focusNextField(FocusNode currentFocus) {
    if (currentFocus == _lengthFocus) {
      _widthFocus.requestFocus();
    } else if (currentFocus == _widthFocus) {
      _heightFocus.requestFocus();
    } else if (currentFocus == _heightFocus) {
      _nameFocus.requestFocus();
    } else {
      _hideKeyboard();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _hideKeyboard(),
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          title: const Text(
            'Configurar Ladrillo',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: AppColors.blueMetraShop,
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 32),
                _buildBrickVisualizationSection(),
                const SizedBox(height: 32),
                _buildNameInput(),
                const SizedBox(height: 32),
                _buildActions(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.blueMetraShop.withOpacity(0.1),
            AppColors.blueMetraShop.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.blueMetraShop.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.blueMetraShop.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.tune,
              color: AppColors.blueMetraShop,
              size: 32,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ladrillo Personalizado',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Ajusta las dimensiones moviendo los controles',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrickVisualizationSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.view_in_ar, color: AppColors.blueMetraShop, size: 24),
              const SizedBox(width: 12),
              const Text(
                'Vista en 3D de tu Ladrillo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 400,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Ladrillo 3D central
                _build3DBrick(),
                // Controles de dimensiones
                Positioned(
                  top: 20,
                  right: 40,
                  child: _buildDimensionControl(
                    'Largo',
                    _lengthController,
                    _lengthFocus,
                    _currentLength,
                    5.0,
                    50.0,
                    Icons.straighten,
                    AppColors.primary,
                  ),
                ),
                Positioned(
                  bottom: 20,
                  right: 110,
                  child: _buildDimensionControl(
                    'Ancho',
                    _widthController,
                    _widthFocus,
                    _currentWidth,
                    5.0,
                    30.0,
                    Icons.height,
                    AppColors.success,
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 110,
                  child: _buildDimensionControl(
                    'Alto',
                    _heightController,
                    _heightFocus,
                    _currentHeight,
                    3.0,
                    20.0,
                    Icons.arrow_upward,
                    AppColors.warning,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _build3DBrick() {
    final maxDim = [_currentLength, _currentWidth, _currentHeight].reduce((a, b) => a > b ? a : b);
    final scale = 120 / maxDim;

    final displayLength = _currentLength * scale;
    final displayWidth = _currentWidth * scale;
    final displayHeight = _currentHeight * scale;

    return Container(
      width: 200,
      height: 200,
      child: CustomPaint(
        painter: Brick3DPainter(
          length: displayLength,
          width: displayWidth,
          height: displayHeight,
        ),
        child: Container(),
      ),
    );
  }

  Widget _buildDimensionControl(
      String label,
      TextEditingController controller,
      FocusNode focusNode,
      double currentValue,
      double min,
      double max,
      IconData icon,
      Color color,
      ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: 80,
            child: TextFormField(
              controller: controller,
              focusNode: focusNode,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                LengthLimitingTextInputFormatter(6),
              ],
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: color.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: color, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 12,
                ),
                suffix: Text(
                  'cm',
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              validator: (value) {
                final numValue = double.tryParse(value ?? '');
                if (numValue == null) return 'Requerido';
                if (numValue < min || numValue > max) {
                  return '$min-${max.toInt()}';
                }
                return null;
              },
              onChanged: (value) {
                setState(() {});
              },
              onFieldSubmitted: (_) => _focusNextField(focusNode),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${min.toInt()}-${max.toInt()} cm',
            style: TextStyle(
              color: color.withOpacity(0.7),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameInput() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.label, color: AppColors.blueMetraShop, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Nombre del Ladrillo',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nameController,
            focusNode: _nameFocus,
            decoration: InputDecoration(
              hintText: 'Ej: Ladrillo Casa Principal',
              prefixIcon: Icon(Icons.edit, color: AppColors.blueMetraShop),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.neutral300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.blueMetraShop, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Por favor ingresa un nombre';
              }
              if (value.trim().length < 2) {
                return 'El nombre debe tener al menos 2 caracteres';
              }
              return null;
            },
            onFieldSubmitted: (_) => _continueToCalculation(),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Column(
      children: [
        // Botón principal para continuar
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _continueToCalculation,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blueMetraShop,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            icon: const Icon(Icons.calculate, size: 20),
            label: const Text(
              'Continuar con Cálculo',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Botón para cancelar
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'Cancelar',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  // NUEVOS MÉTODOS PARA LA FUNCIONALIDAD DE GUARDADO

  void _continueToCalculation() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Actualizar las dimensiones para el cálculo
    ref.read(customBrickDimensionsProvider.notifier).updateDimensions(
      length: _currentLength,
      width: _currentWidth,
      height: _currentHeight,
      name: _nameController.text.trim(),
    );

    // Establecer el tipo como Custom
    ref.read(tipoLadrilloProvider.notifier).selectLadrillo('Custom');

    // Mostrar diálogo de guardado
    _showSaveDialog();
  }

  void _showSaveDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.favorite_outline,
                color: AppColors.success,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Guardar Configuración',
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '¿Quieres guardar esta configuración de ladrillo para usarla en futuros proyectos?',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.neutral100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nombre: ${_nameController.text.trim()}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Dimensiones: ${_currentLength.toStringAsFixed(1)}×${_currentWidth.toStringAsFixed(1)}×${_currentHeight.toStringAsFixed(1)} cm',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _proceedToNextScreen();
              },
              child: Text(
                'No Guardar',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                _saveAndProceed();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.favorite, size: 18),
              label: const Text(
                'Sí, Guardar',
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        );
      },
    );
  }

  void _proceedToNextScreen() {
    context.pushNamed('ladrillo1');
  }

  void _saveAndProceed() async {
    try {
      final name = _nameController.text.trim();

      final saveNotifier = ref.read(customBrickSaveStateProvider.notifier);
      final nameExists = await saveNotifier.checkNameExists(name);

      if (nameExists) {
        _showNameConflictDialog();
        return;
      }

      final customBrick = CustomBrick.fromConfig(
        '',
        name,
        _currentLength,
        _currentWidth,
        _currentHeight,
        description: 'Ladrillo personalizado creado el ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
      );

      await saveNotifier.saveCustomBrick(customBrick);

      _showQuickSuccessMessage();

      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          context.pushNamed('ladrillo1');
        }
      });

    } catch (e) {
      _showErrorMessage('Error al guardar: $e');
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          context.pushNamed('ladrillo1');
        }
      });
    }
  }

  void _showNameConflictDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nombre ya existe'),
        content: Text('Ya tienes un ladrillo guardado con el nombre "${_nameController.text.trim()}".'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _proceedToNextScreen();
            },
            child: const Text('Continuar sin guardar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showRenameDialog();
            },
            child: const Text('Cambiar nombre'),
          ),
        ],
      ),
    );
  }

  void _showRenameDialog() {
    final renameController = TextEditingController(text: _nameController.text.trim());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nuevo nombre'),
        content: TextFormField(
          controller: renameController,
          decoration: const InputDecoration(
            labelText: 'Nombre del ladrillo',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _proceedToNextScreen();
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = renameController.text.trim();
              if (newName.isNotEmpty) {
                _nameController.text = newName;
                Navigator.of(context).pop();
                _saveAndProceed();
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showQuickSuccessMessage() {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle,
              color: AppColors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text('¡Ladrillo guardado exitosamente!'),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1200),
      ),
    );
  }

  void _showErrorMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline,
              color: AppColors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

/// Painter personalizado para dibujar el ladrillo en 3D
class Brick3DPainter extends CustomPainter {
  final double length;
  final double width;
  final double height;

  Brick3DPainter({
    required this.length,
    required this.width,
    required this.height,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.black54;

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Offset para efecto 3D
    final offsetX = width * 0.3;
    final offsetY = height * 0.3;

    // Cara frontal (más clara)
    paint.color = const Color(0xFFD84315); // Naranja ladrillo
    final frontRect = Rect.fromCenter(
      center: Offset(centerX, centerY),
      width: length,
      height: height,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(frontRect, const Radius.circular(4)),
      paint,
    );

    // Cara superior (más oscura)
    paint.color = const Color(0xFFBF360C); // Naranja más oscuro
    final topPath = Path()
      ..moveTo(frontRect.left, frontRect.top)
      ..lineTo(frontRect.left + offsetX, frontRect.top - offsetY)
      ..lineTo(frontRect.right + offsetX, frontRect.top - offsetY)
      ..lineTo(frontRect.right, frontRect.top)
      ..close();
    canvas.drawPath(topPath, paint);

    // Cara derecha (tonalidad media)
    paint.color = const Color(0xFFD84315).withOpacity(0.8);
    final rightPath = Path()
      ..moveTo(frontRect.right, frontRect.top)
      ..lineTo(frontRect.right + offsetX, frontRect.top - offsetY)
      ..lineTo(frontRect.right + offsetX, frontRect.bottom - offsetY)
      ..lineTo(frontRect.right, frontRect.bottom)
      ..close();
    canvas.drawPath(rightPath, paint);

    // Contornos
    canvas.drawRRect(
      RRect.fromRectAndRadius(frontRect, const Radius.circular(4)),
      strokePaint,
    );
    canvas.drawPath(topPath, strokePaint);
    canvas.drawPath(rightPath, strokePaint);
  }

  @override
  bool shouldRepaint(Brick3DPainter oldDelegate) {
    return length != oldDelegate.length ||
        width != oldDelegate.width ||
        height != oldDelegate.height;
  }
}