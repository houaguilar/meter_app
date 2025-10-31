import 'package:fpdart/fpdart.dart';
import '../../../config/constants/error/failures.dart';
import '../../repositories/map/location_repository.dart';

/// Activa o desactiva la visibilidad de una ubicación en el mapa
///
/// Casos de uso:
/// - Activar: El proveedor quiere ser visible en el mapa (is_active = true)
/// - Desactivar: El proveedor quiere ocultarse temporalmente (is_active = false)
///
/// Requiere que el proveedor esté aprobado (verification_status = 'approved')
class ToggleLocationActive {
  final LocationRepository repository;

  ToggleLocationActive(this.repository);

  Future<Either<Failure, void>> call({
    required String locationId,
    required bool isActive,
  }) async {
    return await repository.toggleLocationActive(
      locationId: locationId,
      isActive: isActive,
    );
  }
}
