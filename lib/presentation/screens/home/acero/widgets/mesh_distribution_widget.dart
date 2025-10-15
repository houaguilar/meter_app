import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../../config/theme/theme.dart';
import '../../../../../domain/entities/home/acero/steel_constants.dart';
import '../zapata/datos/models/footing_form_data.dart';
import 'modern_steel_text_form_field.dart';

class MeshDistributionWidget extends StatefulWidget {
  final FootingFormData formData;
  final VoidCallback? onChanged;

  const MeshDistributionWidget({
    super.key,
    required this.formData,
    this.onChanged,
  });

  @override
  State<MeshDistributionWidget> createState() => _MeshDistributionWidgetState();
}

class _MeshDistributionWidgetState extends State<MeshDistributionWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.formData.hasSuperiorMesh) {
      _animationController.forward();
    }
  }

  void _onSuperiorMeshToggle(bool enabled) {
    setState(() {
      widget.formData.hasSuperiorMesh = enabled;
      if (enabled) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
    widget.onChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título de la sección
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.grid_4x4,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Distribución',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Malla Inferior (siempre habilitada)
        _buildInferiorMeshSection(),

        const SizedBox(height: 24),

        // Toggle para Malla Superior
        _buildSuperiorMeshToggle(),

        const SizedBox(height: 16),

        // Malla Superior (condicional)
        AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return SizeTransition(
              sizeFactor: _fadeAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: widget.formData.hasSuperiorMesh
                    ? _buildSuperiorMeshSection()
                    : const SizedBox.shrink(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildInferiorMeshSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderFocused),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título de malla inferior
          Row(
            children: [
              Icon(
                Icons.grid_on,
                color: AppColors.success,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Malla Inferior',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Obligatoria',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.success,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Configuración horizontal
          _buildDirectionConfiguration(
            title: 'Horizontal',
            icon: Icons.horizontal_rule,
            diameter: widget.formData.inferiorHorizontalDiameter,
            separationController: widget.formData.inferiorHorizontalSeparationController,
            onDiameterChanged: (value) {
              setState(() {
                widget.formData.inferiorHorizontalDiameter = value;
              });
              widget.onChanged?.call();
            },
          ),

          const SizedBox(height: 16),

          // Configuración vertical
          _buildDirectionConfiguration(
            title: 'Vertical',
            icon: Icons.vertical_align_center,
            diameter: widget.formData.inferiorVerticalDiameter,
            separationController: widget.formData.inferiorVerticalSeparationController,
            onDiameterChanged: (value) {
              setState(() {
                widget.formData.inferiorVerticalDiameter = value;
              });
              widget.onChanged?.call();
            },
          ),

          const SizedBox(height: 16),

          // Doblez
          _buildBendLengthField(),
        ],
      ),
    );
  }

  Widget _buildSuperiorMeshToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.formData.hasSuperiorMesh
            ? AppColors.secondary.withOpacity(0.1)
            : AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.formData.hasSuperiorMesh
              ? AppColors.secondary.withOpacity(0.3)
              : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Transform.scale(
            scale: 1.2,
            child: Checkbox(
              value: widget.formData.hasSuperiorMesh,
              onChanged: (value) => _onSuperiorMeshToggle(value ?? false),
              activeColor: AppColors.secondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Icon(
            Icons.grid_on,
            color: widget.formData.hasSuperiorMesh
                ? AppColors.secondary
                : AppColors.textSecondary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Malla Superior',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: widget.formData.hasSuperiorMesh
                        ? AppColors.secondary
                        : AppColors.textSecondary,
                  ),
                ),
                Text(
                  'Opcional - Se usa en zapatas con cargas importantes',
                  style: TextStyle(
                    fontSize: 12,
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

  Widget _buildSuperiorMeshSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título de malla superior
          Row(
            children: [
              Icon(
                Icons.grid_on,
                color: AppColors.secondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Configuración Malla Superior',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Configuración horizontal superior
          _buildDirectionConfiguration(
            title: 'Horizontal',
            icon: Icons.horizontal_rule,
            diameter: widget.formData.superiorHorizontalDiameter,
            separationController: widget.formData.superiorHorizontalSeparationController,
            onDiameterChanged: (value) {
              setState(() {
                widget.formData.superiorHorizontalDiameter = value;
              });
              widget.onChanged?.call();
            },
          ),

          const SizedBox(height: 16),

          // Configuración vertical superior
          _buildDirectionConfiguration(
            title: 'Vertical',
            icon: Icons.vertical_align_center,
            diameter: widget.formData.superiorVerticalDiameter,
            separationController: widget.formData.superiorVerticalSeparationController,
            onDiameterChanged: (value) {
              setState(() {
                widget.formData.superiorVerticalDiameter = value;
              });
              widget.onChanged?.call();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDirectionConfiguration({
    required String title,
    required IconData icon,
    required String diameter,
    required TextEditingController separationController,
    required ValueChanged<String> onDiameterChanged,
  }) {
    return Row(
      children: [
        // Icono y título
        SizedBox(
          width: 100,
          child: Row(
            children: [
              Icon(icon, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 16),

        // Dropdown de diámetro
        Expanded(
          flex: 2,
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: diameter,
                isExpanded: true,
                items: SteelConstants.availableDiameters.map((dia) {
                  return DropdownMenuItem<String>(
                    value: dia,
                    child: Text(
                      dia,
                      style: const TextStyle(fontSize: 14),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    onDiameterChanged(value);
                  }
                },
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Campo de separación
        Expanded(
          flex: 2,
          child: ModernSteelTextFormField(
            controller: separationController,
            label: 'Separación',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            onChanged: (_) => widget.onChanged?.call(),
          ),
        ),
      ],
    );
  }

  Widget _buildBendLengthField() {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Row(
            children: [
              Icon(Icons.turn_right, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(
                'Doblez',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 16),

        Expanded(
          child: ModernSteelTextFormField(
            controller: widget.formData.inferiorBendLengthController,
            label: 'Longitud de doblez',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            onChanged: (_) => widget.onChanged?.call(),
          ),
        ),
      ],
    );
  }
}