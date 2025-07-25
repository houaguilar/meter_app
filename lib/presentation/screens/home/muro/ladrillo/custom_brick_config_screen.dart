// lib/presentation/screens/home/muro/ladrillo/custom_brick_config_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../config/theme/theme.dart';
import '../../../../providers/home/muro/custom_brick_providers.dart';
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

  // AGREGADO: Focus nodes para gestión del teclado
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
    // AGREGADO: Cleanup focus nodes
    _nameFocus.dispose();
    _lengthFocus.dispose();
    _widthFocus.dispose();
    _heightFocus.dispose();
    super.dispose();
  }

  double get _currentLength => double.tryParse(_lengthController.text) ?? 24.0;
  double get _currentWidth => double.tryParse(_widthController.text) ?? 13.0;
  double get _currentHeight => double.tryParse(_heightController.text) ?? 9.0;

  // AGREGADO: Método para ocultar teclado
  void _hideKeyboard() {
    FocusScope.of(context).unfocus();
  }

  // AGREGADO: Navegación entre campos
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
      // AGREGADO: Ocultar teclado al tocar cualquier parte
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

          // Visualización principal del ladrillo con controles
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
                  right: 20,
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
                  bottom: 80,
                  left: 20,
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
                  right: 20,
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
    // Calcular escala para visualización
    final maxDim = [_currentLength, _currentWidth, _currentHeight].reduce((a, b) => a > b ? a : b);
    final scale = 120 / maxDim; // Escalar a un máximo de 120px

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
              // MEJORADO: Input formatters más robustos
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')), // Máximo 2 decimales
                LengthLimitingTextInputFormatter(6), // Máximo 6 caracteres
              ],
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: color),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: color, width: 2),
                ),
                suffixText: 'cm',
                suffixStyle: TextStyle(color: color, fontSize: 12),
              ),
              // MEJORADO: Validación más robusta
              validator: (value) => _validateDimension(value, min, max, label),
              onFieldSubmitted: (_) => _focusNextField(focusNode),
              onChanged: (value) {
                setState(() {}); // Actualizar vista 3D en tiempo real
              },
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${min.toInt()}-${max.toInt()}cm',
            style: TextStyle(
              color: color.withOpacity(0.7),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameInput() {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.edit, color: AppColors.blueMetraShop, size: 24),
              const SizedBox(width: 12),
              const Text(
                'Nombre del Ladrillo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _nameController,
            focusNode: _nameFocus,
            textCapitalization: TextCapitalization.words,
            maxLength: 50,
            // MEJORADO: Input formatters para nombre
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\s\-_áéíóúÁÉÍÓÚñÑ]')),
            ],
            decoration: InputDecoration(
              hintText: 'Ej: Mi Ladrillo Especial',
              hintStyle: TextStyle(
                color: AppColors.textSecondary.withOpacity(0.6),
              ),
              filled: true,
              fillColor: AppColors.blueMetraShop.withOpacity(0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppColors.blueMetraShop.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppColors.blueMetraShop, width: 2),
              ),
              prefixIcon: Icon(
                Icons.label_outline,
                color: AppColors.blueMetraShop,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
            // MEJORADO: Validación más robusta para nombre
            validator: _validateName,
            onFieldSubmitted: (_) => _hideKeyboard(),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _saveAndContinue,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blueMetraShop,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle_outline, size: 24),
                const SizedBox(width: 12),
                const Text(
                  'Continuar con este Ladrillo',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => context.pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              side: BorderSide(color: AppColors.neutral400),
            ),
            child: const Text(
              'Cancelar',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // MEJORADO: Validaciones más robustas
  String? _validateDimension(String? value, double min, double max, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName requerido';
    }

    final number = double.tryParse(value.trim());
    if (number == null) {
      return 'Número inválido';
    }

    if (number < min) {
      return 'Mín: ${min.toStringAsFixed(1)}cm';
    }

    if (number > max) {
      return 'Máx: ${max.toStringAsFixed(1)}cm';
    }

    // Validar que no tenga más de 2 decimales
    if (value.contains('.') && value.split('.')[1].length > 2) {
      return 'Máx 2 decimales';
    }

    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nombre requerido';
    }

    final trimmedValue = value.trim();

    if (trimmedValue.length < 3) {
      return 'Mínimo 3 caracteres';
    }

    if (trimmedValue.length > 50) {
      return 'Máximo 50 caracteres';
    }

    // Validar que solo contenga caracteres permitidos
    if (!RegExp(r'^[a-zA-Z0-9\s\-_áéíóúÁÉÍÓÚñÑ]+$').hasMatch(trimmedValue)) {
      return 'Solo letras, números, espacios y guiones permitidos';
    }

    return null;
  }

  void _saveAndContinue() {
    _hideKeyboard(); // Ocultar teclado antes de validar

    if (!_formKey.currentState!.validate()) {
      return;
    }

    // MEJORADO: Validaciones adicionales de negocio
    if (!_validateBusinessRules()) {
      return;
    }

    // Guardar dimensiones en provider
    ref.read(customBrickDimensionsProvider.notifier).updateDimensions(
      length: _currentLength,
      width: _currentWidth,
      height: _currentHeight,
      name: _nameController.text.trim(),
    );

    // Establecer tipo custom en provider global
    ref.read(tipoLadrilloProvider.notifier).selectLadrillo('Custom');

    // Navegar a datos normalmente
    context.pushNamed('ladrillo1');
  }

  // AGREGADO: Validaciones de reglas de negocio
  bool _validateBusinessRules() {
    // Validar proporciones razonables
    final ratio = _currentLength / _currentWidth;
    if (ratio < 1.0 || ratio > 4.0) {
      _showErrorMessage('Las proporciones del ladrillo no son recomendadas (ratio largo/ancho: 1.0-4.0)');
      return false;
    }

    // Validar que la altura no sea excesivamente pequeña
    if (_currentHeight < 3.0) {
      _showErrorMessage('La altura mínima recomendada es 3.0 cm');
      return false;
    }

    // Validar volumen mínimo
    final volume = _currentLength * _currentWidth * _currentHeight;
    if (volume < 100) {
      _showErrorMessage('El volumen del ladrillo es muy pequeño (mínimo 100 cm³)');
      return false;
    }

    return true;
  }

  void _showErrorMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
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