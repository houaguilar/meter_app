import 'dart:io';

import '../../../data/models/map/location_category_model.dart';
import '../../../data/models/map/location_model.dart';
import '../../../data/models/map/location_model_with_distance.dart';
import '../../../data/models/map/product_model.dart';
import '../../../data/models/map/review_model.dart';

abstract interface class LocationDataSource {

  /// Cargar todas las ubicaciones
  Future<List<LocationModel>> loadLocations();

  /// Cargar ubicaciones cercanas con PostGIS
  Future<List<LocationModelWithDistance>> loadNearbyLocations({
    required double userLat,
    required double userLng,
    double radiusKm = 25.0,
    int maxResults = 15,
  });

  /// Guardar nueva ubicación
  Future<void> saveLocation(LocationModel location);

  /// Subir imagen de ubicación
  Future<String> uploadImage(File image);

  /// Verificar si PostGIS está disponible
  Future<bool> isPostGISAvailable();

  /// Configurar PostGIS
  Future<bool> setupPostGIS();

  /// Obtener ubicaciones por usuario específico
  Future<List<LocationModel>> getLocationsByUser(String userId);

  /// Eliminar una ubicación
  Future<void> deleteLocation(String locationId);

  /// Activar/Desactivar visibilidad en el mapa
  Future<void> toggleLocationActive({
    required String locationId,
    required bool isActive,
  });

  // ========== CATEGORÍAS (5 métodos) ==========

  /// Obtener categorías de una ubicación
  Future<List<LocationCategoryModel>> getLocationCategories(String locationId);

  /// Guardar una categoría
  Future<LocationCategoryModel> saveLocationCategory(LocationCategoryModel category);

  /// Guardar múltiples categorías
  Future<void> saveLocationCategories({
    required String locationId,
    required List<LocationCategoryModel> categories,
  });

  /// Eliminar una categoría
  Future<void> deleteLocationCategory(String categoryId);

  /// Actualizar orden de categorías
  Future<void> updateCategoriesOrder(String locationId, List<String> categoryIds);

  // ========== PRODUCTOS (8 métodos) ==========

  /// Obtener todos los productos de una ubicación
  Future<List<ProductModel>> getLocationProducts(String locationId);

  /// Obtener productos por categoría
  Future<List<ProductModel>> getProductsByCategory({
    required String locationId,
    required String categoryId,
  });

  /// Obtener un producto por ID
  Future<ProductModel> getProductById(String productId);

  /// Guardar un producto
  Future<ProductModel> saveProduct(ProductModel product);

  /// Guardar múltiples productos
  Future<void> saveProducts(List<ProductModel> products);

  /// Eliminar un producto
  Future<void> deleteProduct(String productId);

  /// Cambiar disponibilidad de stock
  Future<void> toggleProductStock({
    required String productId,
    required bool available,
  });

  /// Cambiar si un producto es destacado
  Future<void> toggleProductFeatured({
    required String productId,
    required bool featured,
  });

  // ========== RESEÑAS (4 métodos) ==========

  /// Obtener reseñas de una ubicación
  Future<List<ReviewModel>> getLocationReviews(String locationId);

  /// Crear una reseña
  Future<ReviewModel> createReview(ReviewModel review);

  /// Responder a una reseña
  Future<void> respondToReview({
    required String reviewId,
    required String response,
  });

  /// Obtener estadísticas de reseñas
  Future<Map<String, dynamic>> getReviewStats(String locationId);

  // ========== VERIFICACIÓN (2 métodos) ==========

  /// Agendar verificación
  Future<void> scheduleVerification({
    required String locationId,
    required DateTime date,
    required String time,
  });

  /// Actualizar estado de verificación
  Future<void> updateVerificationStatus({
    required String locationId,
    required String status,
    String? notes,
  });

  // ========== BÚSQUEDA Y STATS (2 métodos) ==========

  /// Obtener ubicaciones activas cercanas con filtros
  Future<List<LocationModelWithDistance>> getNearbyActiveLocations({
    required double latitude,
    required double longitude,
    double radiusKm = 5.0,
    int limit = 20,
    List<String>? categoryIds,
    double? minRating,
  });

  /// Actualizar estadísticas de una ubicación
  Future<void> updateLocationStats({
    required String locationId,
    double? rating,
    int? reviewsCount,
    int? ordersCount,
  });
}