import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/theme/theme.dart';
import '../../../../domain/entities/map/location.dart';
import '../../../../domain/entities/map/verification_status.dart';
import '../../../blocs/map/locations_bloc.dart';
import '../../../widgets/app_bar/app_bar_widget.dart';

class ProviderProfileScreen extends StatefulWidget {
  final LocationMap location;

  const ProviderProfileScreen({
    super.key,
    required this.location,
  });

  @override
  State<ProviderProfileScreen> createState() => _ProviderProfileScreenState();
}

class _ProviderProfileScreenState extends State<ProviderProfileScreen> {
  bool _isTogglingActive = false;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _isActive = widget.location.isActive;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LocationsBloc, LocationsState>(
      listener: (context, state) {
        if (state is LocationActiveToggled) {
          debugPrint('✅ LocationActiveToggled: ${state.locationId} -> ${state.isActive}');
        } else if (state is LocationsError) {
          debugPrint('❌ LocationsError: ${state.message}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBarWidget(titleAppBar: 'Mi Perfil'),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Header con información básica
              _buildProfileHeader(),

              // Estado de verificación
              _buildVerificationStatus(),

              // Información del negocio
              _buildBusinessInfo(),

              // Documentación
              _buildDocumentationInfo(),

              // Contacto
              _buildContactInfo(),

              // Ubicación
              _buildLocationInfo(),

              // Controles de activación (solo si está aprobado)
              if (widget.location.canConfigureProducts)
                _buildActivationControls(),

              // Acciones
              _buildActions(),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Avatar
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: widget.location.imageUrl != null
                    ? ClipOval(
                        child: Image.network(
                          widget.location.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.store,
                              size: 48,
                              color: AppColors.primary,
                            );
                          },
                        ),
                      )
                    : Icon(
                        Icons.store,
                        size: 48,
                        color: AppColors.primary,
                      ),
              ),

              const SizedBox(height: 16),

              // Nombre del negocio
              Text(
                widget.location.title,
                style: AppTypography.h3.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              // Descripción
              if (widget.location.description.isNotEmpty)
                Text(
                  widget.location.description,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.white.withOpacity(0.9),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerificationStatus() {
    final status = widget.location.verificationStatus;
    final statusColor = _getStatusColor(status);
    final statusIcon = _getStatusIcon(status);
    final statusMessage = _getStatusMessage(status);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.3), width: 2),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(statusIcon, color: statusColor, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Estado de Verificación',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      status.displayName,
                      style: AppTypography.titleMedium.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: statusColor, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    statusMessage,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Información de verificación programada
          if (status == VerificationStatus.pendingApproval &&
              widget.location.scheduledDate != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: AppColors.primary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Verificación Programada',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_formatDate(widget.location.scheduledDate!)} a las ${widget.location.scheduledTime ?? "00:00"}',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Información de aprobación
          if (status == VerificationStatus.approved &&
              widget.location.approvedAt != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: AppColors.success, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Aprobado el ${_formatDate(widget.location.approvedAt!)}',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (widget.location.approvedByName != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Por: ${widget.location.approvedByName}',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Notas de verificación
          if (widget.location.verificationNotes != null &&
              widget.location.verificationNotes!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.notes, color: AppColors.textSecondary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Notas',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.location.verificationNotes!,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBusinessInfo() {
    return _buildInfoSection(
      title: 'Información del Negocio',
      icon: Icons.store,
      items: [
        _InfoItem(
          icon: Icons.business,
          label: 'Nombre',
          value: widget.location.title,
        ),
        if (widget.location.description.isNotEmpty)
          _InfoItem(
            icon: Icons.description,
            label: 'Descripción',
            value: widget.location.description,
          ),
        if (widget.location.rating > 0)
          _InfoItem(
            icon: Icons.star,
            label: 'Calificación',
            value: '${widget.location.rating.toStringAsFixed(1)} ⭐ (${widget.location.reviewsCount} reseñas)',
          ),
        if (widget.location.ordersCount > 0)
          _InfoItem(
            icon: Icons.shopping_cart,
            label: 'Pedidos',
            value: '${widget.location.ordersCount} pedidos',
          ),
      ],
    );
  }

  Widget _buildDocumentationInfo() {
    return _buildInfoSection(
      title: 'Documentación',
      icon: Icons.badge,
      items: [
        if (widget.location.document != null)
          _InfoItem(
            icon: Icons.badge,
            label: widget.location.documentType == null
                ? 'Documento'
                : widget.location.documentType!.name.toUpperCase(),
            value: widget.location.document!,
          ),
      ],
    );
  }

  Widget _buildContactInfo() {
    return _buildInfoSection(
      title: 'Contacto',
      icon: Icons.contact_phone,
      items: [
        if (widget.location.phone != null)
          _InfoItem(
            icon: Icons.phone,
            label: 'Teléfono',
            value: widget.location.phone!,
          ),
        if (widget.location.whatsapp != null)
          _InfoItem(
            icon: Icons.chat,
            label: 'WhatsApp',
            value: widget.location.whatsapp!,
          ),
      ],
    );
  }

  Widget _buildLocationInfo() {
    return _buildInfoSection(
      title: 'Ubicación',
      icon: Icons.location_on,
      items: [
        _InfoItem(
          icon: Icons.location_on,
          label: 'Dirección',
          value: widget.location.address,
        ),
        _InfoItem(
          icon: Icons.pin_drop,
          label: 'Coordenadas',
          value: '${widget.location.latitude.toStringAsFixed(6)}, ${widget.location.longitude.toStringAsFixed(6)}',
        ),
      ],
    );
  }

  Widget _buildInfoSection({
    required String title,
    required IconData icon,
    required List<_InfoItem> items,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.neutral200),
          ...items.map((item) => _buildInfoItem(item)),
        ],
      ),
    );
  }

  Widget _buildInfoItem(_InfoItem item) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(item.icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.value,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivationControls() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
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
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.visibility, color: AppColors.primary, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Visibilidad en el Mapa',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.neutral200),

          // Estado actual
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _isActive
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.neutral200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _isActive ? Icons.check_circle : Icons.cancel,
                    color: _isActive ? AppColors.success : AppColors.textSecondary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isActive ? 'Activo' : 'Inactivo',
                        style: AppTypography.h3.copyWith(
                          color: _isActive ? AppColors.success : AppColors.textSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isActive
                            ? 'Tu negocio es visible en el mapa'
                            : 'Tu negocio no es visible en el mapa',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Toggle switch
                Switch(
                  value: _isActive,
                  onChanged: _isTogglingActive ? null : _handleToggleActive,
                  activeColor: AppColors.success,
                ),
              ],
            ),
          ),

          // Botón de eliminar registro
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: _handleDeleteLocation,
                icon: const Icon(Icons.delete_forever),
                label: const Text('Eliminar Registro de Proveedor'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: BorderSide(color: AppColors.error, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Botón para configurar productos (solo si está aprobado o activo)
          if (widget.location.canConfigureProducts)
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _navigateToConfigureProducts,
                icon: const Icon(Icons.inventory),
                label: const Text('Configurar Productos'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

          const SizedBox(height: 12),

          // Botón para editar información
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton.icon(
              onPressed: _editProfile,
              icon: const Icon(Icons.edit),
              label: const Text('Editar Información'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(color: AppColors.primary, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleToggleActive(bool value) async {
    debugPrint('🔄 Intentando cambiar is_active a: $value para location: ${widget.location.id}');

    setState(() {
      _isTogglingActive = true;
    });

    try {
      debugPrint('📤 Disparando ToggleLocationActiveEvent...');
      context.read<LocationsBloc>().add(
            ToggleLocationActiveEvent(
              locationId: widget.location.id!,
              isActive: value,
            ),
          );

      // Esperar un momento para que el BLoC procese
      await Future.delayed(const Duration(milliseconds: 500));

      setState(() {
        _isActive = value;
        _isTogglingActive = false;
      });

      debugPrint('✅ Estado local actualizado a: $_isActive');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              value
                  ? '¡Negocio activado! Ahora eres visible en el mapa'
                  : 'Negocio desactivado. Ya no eres visible en el mapa',
            ),
            backgroundColor: value ? AppColors.success : AppColors.info,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error en _handleToggleActive: $e');
      setState(() {
        _isTogglingActive = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cambiar estado: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _handleDeleteLocation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Registro'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar tu registro como proveedor?\n\n'
          'Esta acción no se puede deshacer y perderás:\n'
          '• Todos tus productos configurados\n'
          '• Tus calificaciones y reseñas\n'
          '• Tu historial de pedidos\n\n'
          'Tendrás que volver a registrarte si deseas ser proveedor nuevamente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<LocationsBloc>().add(
            DeleteLocationEvent(widget.location.id!),
          );

      // Mostrar mensaje y navegar de vuelta
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registro de proveedor eliminado'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Navegar de vuelta al home después de un breve delay
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        context.pop();
      }
    }
  }

  Color _getStatusColor(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.pendingApproval:
        return AppColors.warning;
      case VerificationStatus.approved:
        return AppColors.success;
      case VerificationStatus.rejected:
        return AppColors.error;
      case VerificationStatus.active:
        return AppColors.success;
    }
  }

  IconData _getStatusIcon(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.pendingApproval:
        return Icons.hourglass_empty;
      case VerificationStatus.approved:
        return Icons.check_circle;
      case VerificationStatus.rejected:
        return Icons.cancel;
      case VerificationStatus.active:
        return Icons.verified;
    }
  }

  String _getStatusMessage(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.pendingApproval:
        return 'Tu solicitud está siendo revisada. Un verificador visitará tu negocio en la fecha programada.';
      case VerificationStatus.approved:
        return 'Tu negocio ha sido verificado y aprobado. Ahora puedes configurar tus productos.';
      case VerificationStatus.rejected:
        return 'Tu solicitud ha sido rechazada. Por favor, revisa las notas del verificador.';
      case VerificationStatus.active:
        return 'Tu negocio está activo y visible en el mapa para los clientes.';
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre'
    ];

    return '${date.day} de ${months[date.month - 1]} de ${date.year}';
  }

  void _navigateToConfigureProducts() {
    context.pushNamed(
      'configure-products',
      pathParameters: {'locationId': widget.location.id!},
    );
  }

  void _editProfile() {
    // TODO: Navegar a EditProfileScreen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Editar Información (Por implementar)'),
        backgroundColor: AppColors.info,
      ),
    );
  }
}

class _InfoItem {
  final IconData icon;
  final String label;
  final String value;

  _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });
}
