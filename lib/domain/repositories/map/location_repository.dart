import 'dart:io';

import 'package:fpdart/fpdart.dart';

import '../../../config/constants/error/failures.dart';
import '../../entities/map/location.dart';
import '../../entities/map/location_with_distance.dart';
import '../../entities/map/location_category.dart';
import '../../entities/map/product.dart';
import '../../entities/map/review.dart';
import '../../entities/map/review_stats.dart' as stats;

abstract interface class LocationRepository {
  // ========== MÉTODOS EXISTENTES ==========

  /// Obtener todas las ubicaciones
  Future<Either<Failure, List<LocationMap>>> getAllLocations();

  /// Obtener ubicaciones cercanas optimizadas
  Future<Either<Failure, List<LocationWithDistance>>> getNearbyLocations({
    required double userLat,
    required double userLng,
    double radiusKm = 25.0,
    int maxResults = 15,
  });

  /// Guardar nueva ubicación
  Future<Either<Failure, void>> saveLocation(LocationMap location);

  /// Subir imagen de ubicación
  Future<Either<Failure, String>> uploadImage(File image);

  /// Verificar si PostGIS está disponible
  Future<Either<Failure, bool>> checkPostGISAvailability();

  /// Obtener ubicaciones por usuario
  Future<Either<Failure, List<LocationMap>>> getLocationsByUser(String userId);

  /// Eliminar ubicación
  Future<Either<Failure, void>> deleteLocation(String locationId);

  /// Activar/Desactivar ubicación en el mapa
  Future<Either<Failure, void>> toggleLocationActive({
    required String locationId,
    required bool isActive,
  });

  // ========== NUEVOS MÉTODOS: CATEGORIES ==========

  /// Obtener todas las categorías configuradas de una ubicación
  Future<Either<Failure, List<LocationCategory>>> getLocationCategories(
    String locationId,
  );

  /// Guardar una categoría (insert o update)
  Future<Either<Failure, LocationCategory>> saveLocationCategory(
    LocationCategory category,
  );

  /// Guardar múltiples categorías (batch)
  Future<Either<Failure, void>> saveLocationCategories({
    required String locationId,
    required List<LocationCategory> categories,
  });

  /// Eliminar una categoría
  Future<Either<Failure, void>> deleteLocationCategory(String categoryId);

  /// Actualizar el orden de las categorías
  Future<Either<Failure, void>> updateCategoriesOrder(
    String locationId,
    List<String> categoryIds,
  );

  // ========== NUEVOS MÉTODOS: PRODUCTS ==========

  /// Obtener todos los productos de una ubicación
  Future<Either<Failure, List<Product>>> getLocationProducts(
    String locationId,
  );

  /// Obtener productos por categoría específica
  Future<Either<Failure, List<Product>>> getProductsByCategory({
    required String locationId,
    required String categoryId,
  });

  /// Obtener un producto específico por ID
  Future<Either<Failure, Product>> getProductById(String productId);

  /// Guardar un producto (insert o update)
  Future<Either<Failure, Product>> saveProduct(Product product);

  /// Guardar múltiples productos (batch)
  Future<Either<Failure, void>> saveProducts(List<Product> products);

  /// Eliminar un producto
  Future<Either<Failure, void>> deleteProduct(String productId);

  /// Cambiar disponibilidad de stock de un producto
  Future<Either<Failure, void>> toggleProductStock({
    required String productId,
    required bool available,
  });

  /// Marcar/desmarcar producto como destacado
  Future<Either<Failure, void>> toggleProductFeatured({
    required String productId,
    required bool featured,
  });

  // ========== NUEVOS MÉTODOS: REVIEWS ==========

  /// Obtener todas las reseñas de una ubicación
  Future<Either<Failure, List<Review>>> getLocationReviews(String locationId);

  /// Crear una nueva reseña
  Future<Either<Failure, Review>> createReview(Review review);

  /// Responder a una reseña (solo dueño del negocio)
  Future<Either<Failure, void>> respondToReview({
    required String reviewId,
    required String response,
  });

  /// Obtener estadísticas de reseñas de una ubicación
  Future<Either<Failure, stats.ReviewStats>> getReviewStats(String locationId);

  // ========== NUEVOS MÉTODOS: VERIFICATION ==========

  /// Programar verificación de ubicación
  Future<Either<Failure, void>> scheduleVerification({
    required String locationId,
    required DateTime date,
    required String time,
  });

  /// Actualizar estado de verificación (llamado por n8n webhook)
  Future<Either<Failure, void>> updateVerificationStatus({
    required String locationId,
    required String status,
    String? notes,
  });

  // ========== NUEVOS MÉTODOS: NEARBY CON FILTROS ==========

  /// Obtener ubicaciones cercanas activas (solo verified)
  /// Usa PostGIS en Supabase para búsqueda eficiente
  Future<Either<Failure, List<LocationMap>>> getNearbyActiveLocations({
    required double latitude,
    required double longitude,
    double radiusKm = 5.0,
    int limit = 20,
    List<String>? categoryIds, // Filtrar por categorías
    double? minRating, // Filtrar por rating mínimo
  });

  // ========== NUEVOS MÉTODOS: STATISTICS ==========

  /// Actualizar estadísticas de una ubicación (rating, reviews count, orders count)
  Future<Either<Failure, void>> updateLocationStats({
    required String locationId,
    double? rating,
    int? reviewsCount,
    int? ordersCount,
  });
}