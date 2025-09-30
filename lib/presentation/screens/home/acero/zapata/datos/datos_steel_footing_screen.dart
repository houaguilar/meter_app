import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:meter_app/config/utils/calculation_loader_extensions.dart';
import 'package:meter_app/presentation/screens/home/acero/widgets/modern_steel_text_form_field.dart';

import '../../../../../../config/theme/theme.dart';
import '../../../../../providers/home/acero/zapata/steel_footing_providers.dart';
import '../../../../../widgets/modern_widgets.dart';
import '../../../../../widgets/tutorial/tutorial_overlay.dart';
import '../../../../../widgets/widgets.dart';
import '../../widgets/mesh_distribution_widget.dart';
import 'models/footing_form_data.dart';

class DatosSteelFootingScreen extends ConsumerStatefulWidget {
  const DatosSteelFootingScreen({super.key});
  static const String route = 'steel-footing-data';

  @override
  ConsumerState<DatosSteelFootingScreen> createState() => _DatosSteelFootingScreenState();
}

class _DatosSteelFootingScreenState extends ConsumerState<DatosSteelFootingScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin, TutorialMixin {

  @override
  bool get wantKeepAlive => true;

  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Lista de zapatas con sus datos
  List<FootingFormData> _footings = [];
  int _currentFootingIndex = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeFootings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    _disposeFootingControllers();
    super.dispose();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  void _initializeFootings() {
    // Inicializar con una zapata por defecto
    _footings = [FootingFormData.initial()];
    _tabController = TabController(
      length: _footings.length,
      vsync: this,
      initialIndex: 0,
    );
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    setState(() {
      _currentFootingIndex = _tabController.index;
    });
  }

  void _disposeFootingControllers() {
    for (final footing in _footings) {
      footing.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Acero en Zapatas'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            onPressed: _addNewFooting,
            icon: const Icon(Icons.add),
            tooltip: 'Agregar zapata',
          ),
          if (_footings.length > 1)
            IconButton(
              onPressed: _removeCurrentFooting,
              icon: const Icon(Icons.delete),
              tooltip: 'Eliminar zapata actual',
            ),
        ],
        bottom: _footings.length > 1 ? TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppColors.white,
          labelColor: AppColors.white,
          unselectedLabelColor: AppColors.white.withOpacity(0.7),
          tabs: _footings.asMap().entries.map((entry) {
            final index = entry.key;
            final footing = entry.value;
            return Tab(
              text: footing.descriptionController.text.isEmpty
                  ? 'Zapata ${index + 1}'
                  : footing.descriptionController.text,
            );
          }).toList(),
        ) : null,
      ),
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: _buildBody(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading ? null : _calculateFootings,
        backgroundColor: _isLoading ? AppColors.border : AppColors.secondary,
        icon: _isLoading
            ? SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
          ),
        )
            : const Icon(Icons.calculate, color: AppColors.white),
        label: Text(
          _isLoading ? 'Calculando...' : 'Calcular',
          style: const TextStyle(color: AppColors.white),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_footings.isEmpty) {
      return const Center(
        child: Text('No hay zapatas configuradas'),
      );
    }

    return TabBarView(
      controller: _tabController,
      children: _footings.map((footing) =>
          _buildFootingForm(footing)
      ).toList(),
    );
  }

  Widget _buildFootingForm(FootingFormData formData) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Datos generales
          _buildGeneralDataSection(formData),

          const SizedBox(height: 24),

          // Dimensiones de la zapata
          _buildDimensionsSection(formData),

          const SizedBox(height: 24),

          // Distribución (reemplaza acero longitudinal y estribos)
          MeshDistributionWidget(
            formData: formData,
            onChanged: () {
              setState(() {
                // Trigger rebuild para actualizar validaciones
              });
            },
          ),

          const SizedBox(height: 100), // Espacio para FAB
        ],
      ),
    );
  }

  Widget _buildGeneralDataSection(FootingFormData formData) {
    return ModernCard(
 //     title: 'Datos Generales',
  //    icon: Icons.info_outline,
      child: Column(
        children: [
          ModernSteelTextFormField(
            controller: formData.descriptionController,
            label: 'Descripción',
            prefixIcon: Icons.label_outline,
            onChanged: (_) => _updateTabTitle(),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: ModernSteelTextFormField(
                  controller: formData.wasteController,
                  label: 'Desperdicio',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,1}')),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: ModernSteelTextFormField(
                  controller: formData.elementsController,
                  label: 'Elementos',
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          ModernSteelTextFormField(
            controller: formData.coverController,
            label: 'Recubrimiento',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,1}')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDimensionsSection(FootingFormData formData) {
    return ModernCard(
//      title: 'Dimensiones de la Zapata',
//      icon: Icons.architecture,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ModernSteelTextFormField(
                  controller: formData.lengthController,
                  label: 'Largo',
     //             suffixText: 'm',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: ModernSteelTextFormField(
                  controller: formData.widthController,
                  label: 'Ancho',
   //               suffixText: 'm',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _addNewFooting() {
    setState(() {
      final newIndex = _footings.length + 1;
      final newfooting = FootingFormData.initial(index: newIndex);
      _footings.add(newfooting);

      // Recrear el TabController con la nueva longitud
      _tabController.dispose();
      _tabController = TabController(
        length: _footings.length,
        vsync: this,
        initialIndex: _footings.length - 1,
      );
      _tabController.addListener(_onTabChanged);
      _currentFootingIndex = _footings.length - 1;
    });
  }

  void _removeCurrentFooting() {
    if (_footings.length <= 1) return;

    setState(() {
      final removedfooting = _footings.removeAt(_currentFootingIndex);
      removedfooting.dispose();

      // Ajustar el índice actual si es necesario
      if (_currentFootingIndex >= _footings.length) {
        _currentFootingIndex = _footings.length - 1;
      }

      // Recrear el TabController
      _tabController.dispose();
      _tabController = TabController(
        length: _footings.length,
        vsync: this,
        initialIndex: _currentFootingIndex,
      );
      _tabController.addListener(_onTabChanged);
    });
  }

  void _updateTabTitle() {
    setState(() {
      // Trigger rebuild para actualizar el título del tab
    });
  }

  Future<void> _calculateFootings() async {
    if (!_validateAllFootings()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Limpiar datos anteriores
//      ref.read(clearAllFoundationDataProvider.call)();

      // Procesar cada zapata
      for (final formData in _footings) {
        await _processFooting(formData);
      }

      // Mostrar loader y navegar
      if (mounted) {
        context.showCalculationLoader();
        await Future.delayed(const Duration(milliseconds: 500));

        if (mounted) {
          context.pushNamed('steel-footing-results');
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage('Error al procesar las zapatas: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  bool _validateAllFootings() {
    for (int i = 0; i < _footings.length; i++) {
      final footing = _footings[i];
      if (!footing.isValid) {
        _showErrorMessage(
            'Por favor complete todos los campos requeridos en la zapata ${i + 1}'
        );

        // Cambiar al tab con error
        _tabController.animateTo(i);
        return false;
      }
    }
    return true;
  }

  Future<void> _processFooting(FootingFormData formData) async {
    try {
      ref.read(steelFootingResultProvider.notifier).createSteelFooting(
        description: formData.descriptionController.text.trim(),
        waste: formData.waste / 100, // Convertir porcentaje a decimal
        elements: formData.elements,
        cover: formData.cover, // Ya convertido de cm a m
        length: formData.length,
        width: formData.width,
        inferiorHorizontalDiameter: formData.inferiorHorizontalDiameter,
        inferiorHorizontalSeparation: formData.inferiorHorizontalSeparation,
        inferiorVerticalDiameter: formData.inferiorVerticalDiameter,
        inferiorVerticalSeparation: formData.inferiorVerticalSeparation,
        inferiorBendLength: formData.inferiorBendLength,
        hasSuperiorMesh: formData.hasSuperiorMesh,
        superiorHorizontalDiameter: formData.hasSuperiorMesh
            ? formData.superiorHorizontalDiameter
            : null,
        superiorHorizontalSeparation: formData.hasSuperiorMesh
            ? formData.superiorHorizontalSeparation
            : null,
        superiorVerticalDiameter: formData.hasSuperiorMesh
            ? formData.superiorVerticalDiameter
            : null,
        superiorVerticalSeparation: formData.hasSuperiorMesh
            ? formData.superiorVerticalSeparation
            : null,
      );
    } catch (e) {
      throw Exception('Error al procesar zapata "${formData.descriptionController.text}": $e');
    }
  }

  void _showErrorMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showSuccessMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}