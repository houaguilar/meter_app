import 'package:flutter/material.dart';
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
    super.dispose();
  }

  double get _currentLength => double.tryParse(_lengthController.text) ?? 24.0;
  double get _currentWidth => double.tryParse(_widthController.text) ?? 13.0;
  double get _currentHeight => double.tryParse(_heightController.text) ?? 9.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                // Ladrillo 3D en el centro
                AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: _buildBrick3D(),
                    );
                  },
                ),

                // Control de Largo (arriba)
                Positioned(
                  top: 20,
                  child: _buildDimensionControl(
                    'Largo',
                    _lengthController,
                    _currentLength,
                    5,
                    50,
                    Icons.swap_horiz,
                    AppColors.success,
                  ),
                ),

                // Control de Ancho (derecha)
                Positioned(
                  right: 20,
                  child: _buildDimensionControl(
                    'Ancho',
                    _widthController,
                    _currentWidth,
                    5,
                    30,
                    Icons.swap_vert,
                    AppColors.warning,
                  ),
                ),

                // Control de Alto (abajo)
                Positioned(
                  bottom: 20,
                  child: _buildDimensionControl(
                    'Alto',
                    _heightController,
                    _currentHeight,
                    3,
                    20,
                    Icons.height,
                    AppColors.error,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          _buildDimensionsInfo(),
        ],
      ),
    );
  }

  Widget _buildBrick3D() {
    // Escalar las dimensiones para la visualización (mantener proporciones)
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
          const SizedBox(height: 8),
          SizedBox(
            width: 80,
            child: TextFormField(
              controller: controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                suffixText: 'cm',
                suffixStyle: TextStyle(color: color.withOpacity(0.7), fontSize: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: color.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: color, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              ),
              validator: (value) => _validateDimension(value, min, max),
              onChanged: (value) {
                setState(() {}); // Rebuild para actualizar el ladrillo
              },
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${min.toInt()}-${max.toInt()}cm',
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

  Widget _buildDimensionsInfo() {
    final volume = (_currentLength * _currentWidth * _currentHeight) / 1000; // cm³ a litros

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoItem('Dimensiones', '${_currentLength.toStringAsFixed(1)} × ${_currentWidth.toStringAsFixed(1)} × ${_currentHeight.toStringAsFixed(1)} cm'),
          Container(width: 1, height: 30, color: AppColors.neutral300),
          _buildInfoItem('Volumen', '${volume.toStringAsFixed(2)} L'),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
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
          const SizedBox(height: 16),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: 'Ej: Ladrillo especial para fachada',
              prefixIcon: Icon(Icons.label_outline, color: AppColors.blueMetraShop),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.neutral300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.blueMetraShop, width: 2),
              ),
            ),
            validator: (value) => value?.trim().isEmpty == true ? 'Ingresa un nombre descriptivo' : null,
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

  String? _validateDimension(String? value, double min, double max) {
    if (value?.trim().isEmpty == true) return 'Requerido';

    final number = double.tryParse(value!);
    if (number == null) return 'Número inválido';
    if (number < min || number > max) return '${min.toInt()}-${max.toInt()}cm';

    return null;
  }

  void _saveAndContinue() {
    if (!_formKey.currentState!.validate()) return;

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

    // Bordes y líneas de detalle
    canvas.drawRRect(
      RRect.fromRectAndRadius(frontRect, const Radius.circular(4)),
      strokePaint,
    );
    canvas.drawPath(topPath, strokePaint);
    canvas.drawPath(rightPath, strokePaint);

    // Líneas de conexión
    canvas.drawLine(
      Offset(frontRect.left, frontRect.top),
      Offset(frontRect.left + offsetX, frontRect.top - offsetY),
      strokePaint,
    );
    canvas.drawLine(
      Offset(frontRect.right, frontRect.top),
      Offset(frontRect.right + offsetX, frontRect.top - offsetY),
      strokePaint,
    );
    canvas.drawLine(
      Offset(frontRect.right, frontRect.bottom),
      Offset(frontRect.right + offsetX, frontRect.bottom - offsetY),
      strokePaint,
    );

    // Textura del ladrillo (líneas horizontales)
    final texturePaint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..strokeWidth = 1;

    for (int i = 1; i < 3; i++) {
      final y = frontRect.top + (frontRect.height / 3) * i;
      canvas.drawLine(
        Offset(frontRect.left + 4, y),
        Offset(frontRect.right - 4, y),
        texturePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
