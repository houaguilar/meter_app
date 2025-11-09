import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meter_app/config/utils/calculation_loader_extensions.dart';
import 'package:uuid/uuid.dart';

import '../../../../../../config/theme/theme.dart';
import '../../../../../../domain/entities/home/acero/losa_maciza/mesh_enums.dart';
import '../../../../../../domain/entities/home/acero/losa_maciza/steel_slab.dart';
import '../../../../../../domain/entities/home/acero/steel_constants.dart';
import '../../../../../providers/home/acero/losa_maciza/steel_slab_providers.dart';
import '../../../../../widgets/modern_widgets.dart';
import '../../../../../widgets/tutorial/tutorial_overlay.dart';
import '../../widgets/slab_floating_action_button.dart';
import '../../widgets/slab_text_form_field.dart';
import 'models/slab_form_data.dart';

class DatosSteelSlabScreen extends ConsumerStatefulWidget {
  const DatosSteelSlabScreen({super.key});
  static const String route = 'steel-slab-data';

  @override
  ConsumerState<DatosSteelSlabScreen> createState() => _DatosSteelSlabScreenState();
}

class _DatosSteelSlabScreenState extends ConsumerState<DatosSteelSlabScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin, TutorialMixin {

  @override
  bool get wantKeepAlive => true;

  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  List<SlabFormData> _slabs = [];
  List<GlobalKey<FormState>> _formKeys = [];
  int _currentSlabIndex = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeSlabs();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    _disposeSlabControllers();
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

  void _initializeSlabs() {
    _slabs = [SlabFormData.initial()];
    _formKeys = [GlobalKey<FormState>()];

    _tabController = TabController(
      length: _slabs.length,
      vsync: this,
      initialIndex: 0,
    );
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    setState(() {
      _currentSlabIndex = _tabController.index;
    });
  }

  void _disposeSlabControllers() {
    for (final slab in _slabs) {
      slab.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Acero en Losa Maciza'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: AppColors.primary,
            child: TabBar(
              controller: _tabController,
              tabs: _slabs.asMap().entries.map((entry) {
                final index = entry.key;
                final slab = entry.value;
                return Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        slab.descriptionController.text.isEmpty
                            ? 'Losa ${index + 1}'
                            : slab.descriptionController.text,
                        style: const TextStyle(fontSize: 12),
                      ),
                      if (_slabs.length > 1) ...[
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => _removeSlab(index),
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }).toList(),
              indicatorColor: AppColors.white,
              labelColor: AppColors.white,
              unselectedLabelColor: AppColors.white.withOpacity(0.7),
              isScrollable: true,
            ),
          ),
        ),
      ),
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: TabBarView(
          controller: _tabController,
          children: _slabs.asMap().entries.map((entry) {
            final index = entry.key;
            return _buildSlabForm(index); // ← Usa el método existente
          }).toList(),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // FAB 1: Agregar losa
          FloatingActionButton(
            onPressed: _addNewSlab,
            backgroundColor: AppColors.secondary,
            heroTag: "add_slab",
            tooltip: 'Agregar Losa',
            child: const Icon(Icons.add, color: AppColors.white),
          ),
          const SizedBox(height: 12),
          // FAB 2: Calcular
          FloatingActionButton.extended(
            onPressed: _isLoading ? null : _calculateSlabs,
            backgroundColor: AppColors.primary,
            heroTag: "calculate",
            icon: _isLoading
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: AppColors.white,
                strokeWidth: 2,
              ),
            )
                : const Icon(Icons.calculate, color: AppColors.white),
            label: Text(
              _isLoading
                  ? 'Calculando...'
                  : 'Calcular ${_slabs.length} ${_slabs.length == 1 ? 'Losa' : 'Losas'}',
              style: const TextStyle(color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlabForm(int slabIndex) {
    final slabData = _slabs[slabIndex];
    final formKey = _formKeys[slabIndex];

    return Form(
      key: formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSlabHeader(slabIndex),
            const SizedBox(height: 20),
            _buildSlabDimensionsSection(slabData),
            const SizedBox(height: 20),
            _buildDistributionSection(slabData),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildSlabHeader(int slabIndex) {
    return ModernCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.view_module,
              color: AppColors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Losa Maciza ${slabIndex + 1}',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  'Configure los parámetros de esta losa maciza',
                  style: AppTypography.bodyMedium.copyWith(
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

  Widget _buildSlabDimensionsSection(SlabFormData slabData) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.straighten,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Dimensiones de la Losa Maciza',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          SlabTextFormField(
            controller: slabData.descriptionController,
            label: 'Descripción',
            hintText: 'Ej: Losa del primer piso',
            prefixIcon: Icons.label,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'La descripción es obligatoria';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: SlabTextFormField(
                  controller: slabData.lengthController,
                  label: 'Largo',
                  hintText: '0.00',
                  suffixText: 'm',
                  prefixIcon: Icons.straighten,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El largo es obligatorio';
                    }
                    final doubleValue = double.tryParse(value);
                    if (doubleValue == null || doubleValue <= 0) {
                      return 'Debe ser mayor a 0';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SlabTextFormField(
                  controller: slabData.widthController,
                  label: 'Ancho',
                  hintText: '0.00',
                  suffixText: 'm',
                  prefixIcon: Icons.straighten,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El ancho es obligatorio';
                    }
                    final doubleValue = double.tryParse(value);
                    if (doubleValue == null || doubleValue <= 0) {
                      return 'Debe ser mayor a 0';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: SlabTextFormField(
                  controller: slabData.bendLengthController,
                  label: 'Doblez',
                  hintText: '0.00',
                  suffixText: 'm',
                  prefixIcon: Icons.trending_up,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El doblez es obligatorio';
                    }
                    final doubleValue = double.tryParse(value);
                    if (doubleValue == null || doubleValue < 0) {
                      return 'Debe ser un número válido';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SlabTextFormField(
                  controller: slabData.elementsController,
                  label: 'Elementos similares',
                  hintText: '1',
                  suffixText: 'und',
                  prefixIcon: Icons.copy,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Los elementos son obligatorios';
                    }
                    final intValue = int.tryParse(value);
                    if (intValue == null || intValue <= 0) {
                      return 'Debe ser mayor a 0';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          SlabTextFormField(
            controller: slabData.wasteController,
            label: 'Desperdicio',
            hintText: '7.0',
            suffixText: '%',
            prefixIcon: Icons.warning_amber,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,1}')),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'El desperdicio es obligatorio';
              }
              final doubleValue = double.tryParse(value);
              if (doubleValue == null || doubleValue < 0 || doubleValue > 50) {
                return 'Debe estar entre 0% y 50%';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDistributionSection(SlabFormData slabData) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.grid_4x4,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Distribución',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildMeshSection(
            slabData,
            MeshType.inferior,
            isEnabled: true,
            canDisable: false,
          ),
          const SizedBox(height: 20),

          _buildMeshSection(
            slabData,
            MeshType.superior,
            isEnabled: slabData.useSuperiorMesh,
            canDisable: true,
          ),
        ],
      ),
    );
  }

  Widget _buildMeshSection(
      SlabFormData slabData,
      MeshType meshType,
      {required bool isEnabled, required bool canDisable}
      ) {
    final isInferior = meshType == MeshType.inferior;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isEnabled
            ? (isInferior ? AppColors.success.withOpacity(0.05) : AppColors.warning.withOpacity(0.05))
            : AppColors.neutral100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isEnabled
              ? (isInferior ? AppColors.success : AppColors.warning)
              : AppColors.neutral300,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (canDisable) ...[
                Checkbox(
                  value: isEnabled,
                  onChanged: (value) {
                    setState(() {
                      slabData.useSuperiorMesh = value ?? false;
                    });
                  },
                  activeColor: AppColors.warning,
                ),
                const SizedBox(width: 8),
              ],
              Icon(
                isInferior ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                color: isEnabled
                    ? (isInferior ? AppColors.success : AppColors.warning)
                    : AppColors.neutral400,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                meshType.displayName,
                style: AppTypography.labelSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isEnabled
                      ? (isInferior ? AppColors.success : AppColors.warning)
                      : AppColors.neutral400,
                ),
              ),
              if (!canDisable) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'SIEMPRE',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),

          if (isEnabled) ...[
            const SizedBox(height: 16),
            _buildDirectionSection(slabData, meshType, MeshDirection.horizontal),
            const SizedBox(height: 16),
            _buildDirectionSection(slabData, meshType, MeshDirection.vertical),
          ],
        ],
      ),
    );
  }

  Widget _buildDirectionSection(
      SlabFormData slabData,
      MeshType meshType,
      MeshDirection direction,
      ) {
    final controllers = slabData.getMeshControllers(meshType, direction);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              direction == MeshDirection.horizontal
                  ? Icons.horizontal_rule
                  : Icons.vertical_align_center,
              color: AppColors.textSecondary,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              direction.displayName,
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Diámetro',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.neutral300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: controllers['diameter'],
                        isExpanded: true,
                        items: SteelConstants.availableDiameters.map((diameter) {
                          return DropdownMenuItem(
                            value: diameter,
                            child: Text(diameter),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              slabData.setMeshDiameter(meshType, direction, value);
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            Expanded(
              flex: 2,
              child: SlabTextFormField(
                controller: controllers['separation']! as TextEditingController,
                label: 'Separación',
                hintText: '0.20',
                suffixText: 'm',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Requerido';
                  }
                  final doubleValue = double.tryParse(value);
                  if (doubleValue == null || doubleValue <= 0) {
                    return 'Debe ser > 0';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _addNewSlab() {
    setState(() {
      final newSlab = SlabFormData.initial();
      _slabs.add(newSlab);

      _tabController.removeListener(_onTabChanged);
      _tabController.dispose();
      _tabController = TabController(
        length: _slabs.length,
        vsync: this,
        initialIndex: _slabs.length - 1,
      );
      _tabController.addListener(_onTabChanged);
      _currentSlabIndex = _slabs.length - 1;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tabController.animateTo(_slabs.length - 1);
    });
  }

  void _removeSlab(int index) {
    if (_slabs.length <= 1) return;

    setState(() {
      _slabs[index].dispose();
      _slabs.removeAt(index);

      _tabController.removeListener(_onTabChanged);
      _tabController.dispose();
      _tabController = TabController(
        length: _slabs.length,
        vsync: this,
        initialIndex: index > 0 ? index - 1 : 0,
      );
      _tabController.addListener(_onTabChanged);
      _currentSlabIndex = _tabController.index;
    });
  }


  Future<void> _calculateSlabs() async {
    if (!_validateAllSlabs()) return;

    setState(() => _isLoading = true);
    context.showCalculationLoader(message: 'Calculando acero para losas...');

    try {
      ref.read(steelSlabResultProvider.notifier).clearList();

      for (final slabData in _slabs) {
        // Crear listas de barras de malla embebidas
        final meshBarsEmbedded = <SteelMeshBarEmbedded>[];

        // Malla inferior - horizontal
        final inferiorH = SteelMeshBarEmbedded();
        inferiorH.idSteelMeshBar = const Uuid().v4();
        inferiorH.meshType = MeshType.inferior;
        inferiorH.direction = MeshDirection.horizontal;
        inferiorH.diameter = slabData.inferiorHorizontalDiameter;
        inferiorH.separation = double.parse(slabData.inferiorHorizontalSeparationController.text);
        meshBarsEmbedded.add(inferiorH);

        // Malla inferior - vertical
        final inferiorV = SteelMeshBarEmbedded();
        inferiorV.idSteelMeshBar = const Uuid().v4();
        inferiorV.meshType = MeshType.inferior;
        inferiorV.direction = MeshDirection.vertical;
        inferiorV.diameter = slabData.inferiorVerticalDiameter;
        inferiorV.separation = double.parse(slabData.inferiorVerticalSeparationController.text);
        meshBarsEmbedded.add(inferiorV);

        // Malla superior (si está habilitada)
        if (slabData.useSuperiorMesh) {
          // Malla superior - horizontal
          final superiorH = SteelMeshBarEmbedded();
          superiorH.idSteelMeshBar = const Uuid().v4();
          superiorH.meshType = MeshType.superior;
          superiorH.direction = MeshDirection.horizontal;
          superiorH.diameter = slabData.superiorHorizontalDiameter;
          superiorH.separation = double.parse(slabData.superiorHorizontalSeparationController.text);
          meshBarsEmbedded.add(superiorH);

          // Malla superior - vertical
          final superiorV = SteelMeshBarEmbedded();
          superiorV.idSteelMeshBar = const Uuid().v4();
          superiorV.meshType = MeshType.superior;
          superiorV.direction = MeshDirection.vertical;
          superiorV.diameter = slabData.superiorVerticalDiameter;
          superiorV.separation = double.parse(slabData.superiorVerticalSeparationController.text);
          meshBarsEmbedded.add(superiorV);
        }

        // Configuración de malla superior embebida
        final superiorConfig = SuperiorMeshConfigEmbedded();
        superiorConfig.idConfig = const Uuid().v4();
        superiorConfig.enabled = slabData.useSuperiorMesh;

        // Crear losa con listas embebidas
        ref.read(steelSlabResultProvider.notifier).createSteelSlab(
          description: slabData.descriptionController.text,
          waste: double.parse(slabData.wasteController.text) / 100,
          elements: int.parse(slabData.elementsController.text),
          length: double.parse(slabData.lengthController.text),
          width: double.parse(slabData.widthController.text),
          bendLength: double.parse(slabData.bendLengthController.text),
          meshBars: meshBarsEmbedded,
          superiorMeshConfig: superiorConfig,
        );
      }

      context.hideLoader();
      setState(() => _isLoading = false);
      context.pushNamed('steel-slab-results');

    } catch (e) {
      context.hideLoader();
      setState(() => _isLoading = false);
      _showErrorMessage('Error en los cálculos: $e');
    }
  }

  bool _validateAllSlabs() {
    // Validar solo los datos, no los formularios visuales
    for (int i = 0; i < _slabs.length; i++) {
      if (!_validateSlabData(_slabs[i], i + 1)) {
        _tabController.animateTo(i);
        return false;
      }
    }
    return true;
  }

  bool _validateSlabData(SlabFormData slabData, int slabNumber) {
    // Validar campos básicos directamente desde los controladores
    if (slabData.descriptionController.text.isEmpty) {
      _showErrorMessage('La descripción es obligatoria en Losa $slabNumber');
      return false;
    }

    if (slabData.lengthController.text.isEmpty ||
        double.tryParse(slabData.lengthController.text) == null ||
        double.parse(slabData.lengthController.text) <= 0) {
      _showErrorMessage('El largo debe ser un número mayor a 0 en Losa $slabNumber');
      return false;
    }

    if (slabData.widthController.text.isEmpty ||
        double.tryParse(slabData.widthController.text) == null ||
        double.parse(slabData.widthController.text) <= 0) {
      _showErrorMessage('El ancho debe ser un número mayor a 0 en Losa $slabNumber');
      return false;
    }

    if (slabData.bendLengthController.text.isEmpty ||
        double.tryParse(slabData.bendLengthController.text) == null ||
        double.parse(slabData.bendLengthController.text) < 0) {
      _showErrorMessage('El doblez debe ser un número válido en Losa $slabNumber');
      return false;
    }

    if (slabData.elementsController.text.isEmpty ||
        int.tryParse(slabData.elementsController.text) == null ||
        int.parse(slabData.elementsController.text) <= 0) {
      _showErrorMessage('Los elementos deben ser un número mayor a 0 en Losa $slabNumber');
      return false;
    }

    if (slabData.wasteController.text.isEmpty ||
        double.tryParse(slabData.wasteController.text) == null ||
        double.parse(slabData.wasteController.text) < 0 ||
        double.parse(slabData.wasteController.text) > 50) {
      _showErrorMessage('El desperdicio debe estar entre 0% y 50% en Losa $slabNumber');
      return false;
    }

    // Validar malla inferior
    if (slabData.inferiorHorizontalSeparationController.text.isEmpty ||
        double.tryParse(slabData.inferiorHorizontalSeparationController.text) == null ||
        double.parse(slabData.inferiorHorizontalSeparationController.text) <= 0) {
      _showErrorMessage('La separación horizontal inferior debe ser mayor a 0 en Losa $slabNumber');
      return false;
    }

    if (slabData.inferiorVerticalSeparationController.text.isEmpty ||
        double.tryParse(slabData.inferiorVerticalSeparationController.text) == null ||
        double.parse(slabData.inferiorVerticalSeparationController.text) <= 0) {
      _showErrorMessage('La separación vertical inferior debe ser mayor a 0 en Losa $slabNumber');
      return false;
    }

    // Validar malla superior si está habilitada
    if (slabData.useSuperiorMesh) {
      if (slabData.superiorHorizontalSeparationController.text.isEmpty ||
          double.tryParse(slabData.superiorHorizontalSeparationController.text) == null ||
          double.parse(slabData.superiorHorizontalSeparationController.text) <= 0) {
        _showErrorMessage('La separación horizontal superior debe ser mayor a 0 en Losa $slabNumber');
        return false;
      }

      if (slabData.superiorVerticalSeparationController.text.isEmpty ||
          double.tryParse(slabData.superiorVerticalSeparationController.text) == null ||
          double.parse(slabData.superiorVerticalSeparationController.text) <= 0) {
        _showErrorMessage('La separación vertical superior debe ser mayor a 0 en Losa $slabNumber');
        return false;
      }
    }

    return true;
  }

  bool _validateSlab(SlabFormData slabData, int slabNumber) {
    final formKey = _formKeys[slabNumber - 1];

    // Verificar que el formulario existe y está inicializado
    if (formKey.currentState == null) {
      _showErrorMessage('Error de formulario en Losa $slabNumber. Cambia al tab de esa losa e intenta de nuevo.');
      return false;
    }

    if (!formKey.currentState!.validate()) {
      _showErrorMessage('Completa todos los campos en la Losa $slabNumber');
      return false;
    }

    if (slabData.useSuperiorMesh) {
      if (slabData.superiorHorizontalSeparationController.text.isEmpty ||
          double.tryParse(slabData.superiorHorizontalSeparationController.text) == null) {
        _showErrorMessage('Separación horizontal superior inválida en Losa $slabNumber');
        return false;
      }

      if (slabData.superiorVerticalSeparationController.text.isEmpty ||
          double.tryParse(slabData.superiorVerticalSeparationController.text) == null) {
        _showErrorMessage('Separación vertical superior inválida en Losa $slabNumber');
        return false;
      }
    }

    return true;
  }

  void _showErrorMessage(String message) {
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
        duration: const Duration(seconds: 3),
      ),
    );
  }

}