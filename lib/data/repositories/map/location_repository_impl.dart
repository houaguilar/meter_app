import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

import '../../../config/constants/error/failures.dart';
import '../../../config/network/connection_checker.dart';
import '../../../domain/datasources/map/location_data_source.dart';
import '../../../domain/entities/map/location.dart';
import '../../../domain/entities/map/location_with_distance.dart';
import '../../../domain/entities/map/location_category.dart';
import '../../../domain/entities/map/product.dart';
import '../../../domain/entities/map/review.dart';
import '../../../domain/entities/map/review_stats.dart' as stats;
import '../../../domain/repositories/map/location_repository.dart';
import '../../models/map/location_model.dart';
import '../../models/map/location_category_model.dart';
import '../../models/map/product_model.dart';
import '../../models/map/review_model.dart';

class LocationRepositoryImpl implements LocationRepository {
  final LocationDataSource locationRemoteDataSource;
  final ConnectionChecker connectionChecker;

  LocationRepositoryImpl(
      this.locationRemoteDataSource,
      this.connectionChecker,
      );

  @override
  Future<Either<Failure, List<LocationMap>>> getAllLocations() async {
    if (!await connectionChecker.isConnected) {
      return left(Failure(message: 'No internet connection', type: FailureType.general));
    }
    try {
      final locationModels = await locationRemoteDataSource.loadLocations();
      final locations = locationModels.map((model) => model as LocationMap).toList();
      return right(locations);
    } catch (e) {
      return left(Failure(message: e.toString()));
    }
  }

  /// 🚀 NUEVO: Obtener ubicaciones cercanas optimizadas
  @override
  Future<Either<Failure, List<LocationWithDistance>>> getNearbyLocations({
    required double userLat,
    required double userLng,
    double radiusKm = 25.0,
    int maxResults = 15,
  }) async {
    if (!await connectionChecker.isConnected) {
      return left(Failure(
        message: 'No internet connection',
        type: FailureType.general,
      ));
    }

    try {
      // Validar coordenadas de entrada
      if (userLat.abs() > 90 || userLng.abs() > 180) {
        return left(Failure(
          message: 'Coordenadas inválidas: lat=$userLat, lng=$userLng',
          type: FailureType.validation,
        ));
      }

      if (radiusKm <= 0 || radiusKm > 1000) {
        return left(Failure(
          message: 'Radio debe estar entre 1 y 1000 km',
          type: FailureType.validation,
        ));
      }

      // Llamar al datasource optimizado
      final locationModels = await locationRemoteDataSource.loadNearbyLocations(
        userLat: userLat,
        userLng: userLng,
        radiusKm: radiusKm,
        maxResults: maxResults,
      );

      // Convertir a entidades de dominio
      final locations = locationModels
          .map((model) => model.toLocationWithDistance())
          .toList();

      return right(locations);
    } catch (e) {
      return left(Failure(
        message: 'Error al obtener ubicaciones cercanas: $e',
        type: FailureType.server,
      ));
    }
  }

  @override
  Future<Either<Failure, void>> saveLocation(LocationMap location) async {
    if (!await connectionChecker.isConnected) {
      return left(Failure(message: 'No internet connection', type: FailureType.general));
    }
    try {
      final locationModel = LocationModel(
        id: location.id,
        title: location.title,
        description: location.description,
        latitude: location.latitude,
        longitude: location.longitude,
        address: location.address,
        userId: location.userId,
        imageUrl: location.imageUrl,
        createdAt: location.createdAt,
        // Nuevos campos para marketplace
        document: location.document,
        documentType: location.documentType,
        phone: location.phone,
        verificationStatus: location.verificationStatus,
        scheduledDate: location.scheduledDate,
        scheduledTime: location.scheduledTime,
        approvalToken: location.approvalToken,
        approvedAt: location.approvedAt,
        approvedByName: location.approvedByName,
        verificationNotes: location.verificationNotes,
        whatsapp: location.whatsapp,
        businessHoursJson: location.businessHoursJson,
        paymentMethodStrings: location.paymentMethodStrings,
        rating: location.rating,
        reviewsCount: location.reviewsCount,
        ordersCount: location.ordersCount,
        updatedAt: location.updatedAt,
      );
      await locationRemoteDataSource.saveLocation(locationModel);
      return right(null);
    } catch (e) {
      return left(Failure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> uploadImage(File image) async {
    if (!await connectionChecker.isConnected) {
      return left(Failure(message: 'No internet connection'));
    }
    try {
      final imageUrl = await locationRemoteDataSource.uploadImage(image);
      return right(imageUrl);
    } catch (e) {
      return left(Failure(message: e.toString()));
    }
  }

  /// 🔧 NUEVO: Verificar disponibilidad de PostGIS
  @override
  Future<Either<Failure, bool>> checkPostGISAvailability() async {
    if (!await connectionChecker.isConnected) {
      return left(Failure(
        message: 'No internet connection',
        type: FailureType.general,
      ));
    }

    try {
      final isAvailable = await locationRemoteDataSource.isPostGISAvailable();
      return right(isAvailable);
    } catch (e) {
      return left(Failure(
        message: 'Error verificando PostGIS: $e',
        type: FailureType.server,
      ));
    }
  }

  /// 📍 NUEVO: Obtener ubicaciones por usuario
  @override
  Future<Either<Failure, List<LocationMap>>> getLocationsByUser(String userId) async {
    if (!await connectionChecker.isConnected) {
      return left(Failure(
        message: 'No internet connection',
        type: FailureType.general,
      ));
    }

    try {
      if (userId.trim().isEmpty) {
        return left(Failure(
          message: 'ID de usuario no puede estar vacío',
          type: FailureType.validation,
        ));
      }

      final locationModels = await locationRemoteDataSource.getLocationsByUser(userId);
      final locations = locationModels.map((model) => model as LocationMap).toList();

      return right(locations);
    } catch (e) {
      return left(Failure(
        message: 'Error al obtener ubicaciones del usuario: $e',
        type: FailureType.server,
      ));
    }
  }

  /// 🗑️ NUEVO: Eliminar ubicación
  @override
  Future<Either<Failure, void>> deleteLocation(String locationId) async {
    if (!await connectionChecker.isConnected) {
      return left(Failure(
        message: 'No internet connection',
        type: FailureType.general,
      ));
    }

    try {
      if (locationId.trim().isEmpty) {
        return left(Failure(
          message: 'ID de ubicación no puede estar vacío',
          type: FailureType.validation,
        ));
      }

      await locationRemoteDataSource.deleteLocation(locationId);
      return right(null);
    } catch (e) {
      return left(Failure(
        message: 'Error al eliminar ubicación: $e',
        type: FailureType.server,
      ));
    }
  }

  /// ⚡ NUEVO: Activar/Desactivar ubicación en el mapa
  @override
  Future<Either<Failure, void>> toggleLocationActive({
    required String locationId,
    required bool isActive,
  }) async {
    debugPrint('📍 LocationRepository: toggleLocationActive llamado');
    debugPrint('   locationId: $locationId');
    debugPrint('   isActive: $isActive');

    if (!await connectionChecker.isConnected) {
      debugPrint('❌ LocationRepository: Sin conexión a internet');
      return left(Failure(
        message: 'No internet connection',
        type: FailureType.general,
      ));
    }

    try {
      if (locationId.trim().isEmpty) {
        debugPrint('❌ LocationRepository: locationId vacío');
        return left(Failure(
          message: 'ID de ubicación no puede estar vacío',
          type: FailureType.validation,
        ));
      }

      debugPrint('🔄 LocationRepository: Llamando a data source...');
      await locationRemoteDataSource.toggleLocationActive(
        locationId: locationId,
        isActive: isActive,
      );
      debugPrint('✅ LocationRepository: Toggle exitoso');
      return right(null);
    } catch (e) {
      debugPrint('❌ LocationRepository: Error - $e');
      return left(Failure(
        message: 'Error al actualizar estado: $e',
        type: FailureType.server,
      ));
    }
  }

  // ========== MARKETPLACE - CATEGORÍAS (5 métodos) ==========

  @override
  Future<Either<Failure, List<LocationCategory>>> getLocationCategories(String locationId) async {
    if (!await connectionChecker.isConnected) {
      return left(Failure(
        message: 'No internet connection',
        type: FailureType.general,
      ));
    }

    try {
      final categoryModels = await locationRemoteDataSource.getLocationCategories(locationId);
      final categories = categoryModels.map((model) => model as LocationCategory).toList();
      return right(categories);
    } catch (e) {
      return left(Failure(
        message: 'Error al obtener categorías: $e',
        type: FailureType.server,
      ));
    }
  }

  @override
  Future<Either<Failure, LocationCategory>> saveLocationCategory(LocationCategory category) async {
    if (!await connectionChecker.isConnected) {
      return left(Failure(
        message: 'No internet connection',
        type: FailureType.general,
      ));
    }

    try {
      final categoryModel = LocationCategoryModel.fromEntity(category);
      final savedModel = await locationRemoteDataSource.saveLocationCategory(categoryModel);
      return right(savedModel as LocationCategory);
    } catch (e) {
      return left(Failure(
        message: 'Error al guardar categoría: $e',
        type: FailureType.server,
      ));
    }
  }

  @override
  Future<Either<Failure, void>> saveLocationCategories({
    required String locationId,
    required List<LocationCategory> categories,
  }) async {
    if (!await connectionChecker.isConnected) {
      return left(Failure(
        message: 'No internet connection',
        type: FailureType.general,
      ));
    }

    try {
      final categoryModels = categories
          .map((cat) => LocationCategoryModel.fromEntity(cat))
          .toList();
      await locationRemoteDataSource.saveLocationCategories(
        locationId: locationId,
        categories: categoryModels,
      );
      return right(null);
    } catch (e) {
      return left(Failure(
        message: 'Error al guardar categorías: $e',
        type: FailureType.server,
      ));
    }
  }

  @override
  Future<Either<Failure, void>> deleteLocationCategory(String categoryId) async {
    if (!await connectionChecker.isConnected) {
      return left(Failure(
        message: 'No internet connection',
        type: FailureType.general,
      ));
    }

    try {
      await locationRemoteDataSource.deleteLocationCategory(categoryId);
      return right(null);
    } catch (e) {
      return left(Failure(
        message: 'Error al eliminar categoría: $e',
        type: FailureType.server,
      ));
    }
  }

  @override
  Future<Either<Failure, void>> updateCategoriesOrder(String locationId, List<String> categoryIds) async {
    if (!await connectionChecker.isConnected) {
      return left(Failure(
        message: 'No internet connection',
        type: FailureType.general,
      ));
    }

    try {
      await locationRemoteDataSource.updateCategoriesOrder(locationId, categoryIds);
      return right(null);
    } catch (e) {
      return left(Failure(
        message: 'Error al actualizar orden: $e',
        type: FailureType.server,
      ));
    }
  }

  // ========== MARKETPLACE - PRODUCTOS (8 métodos) ==========

  @override
  Future<Either<Failure, List<Product>>> getLocationProducts(String locationId) async {
    if (!await connectionChecker.isConnected) {
      return left(Failure(
        message: 'No internet connection',
        type: FailureType.general,
      ));
    }

    try {
      final productModels = await locationRemoteDataSource.getLocationProducts(locationId);
      final products = productModels.map((model) => model as Product).toList();
      return right(products);
    } catch (e) {
      return left(Failure(
        message: 'Error al obtener productos: $e',
        type: FailureType.server,
      ));
    }
  }

  @override
  Future<Either<Failure, List<Product>>> getProductsByCategory({
    required String locationId,
    required String categoryId,
  }) async {
    if (!await connectionChecker.isConnected) {
      return left(Failure(
        message: 'No internet connection',
        type: FailureType.general,
      ));
    }

    try {
      final productModels = await locationRemoteDataSource.getProductsByCategory(
        locationId: locationId,
        categoryId: categoryId,
      );
      final products = productModels.map((model) => model as Product).toList();
      return right(products);
    } catch (e) {
      return left(Failure(
        message: 'Error al obtener productos: $e',
        type: FailureType.server,
      ));
    }
  }

  @override
  Future<Either<Failure, Product>> getProductById(String productId) async {
    if (!await connectionChecker.isConnected) {
      return left(Failure(
        message: 'No internet connection',
        type: FailureType.general,
      ));
    }

    try {
      final productModel = await locationRemoteDataSource.getProductById(productId);
      return right(productModel as Product);
    } catch (e) {
      return left(Failure(
        message: 'Error al obtener producto: $e',
        type: FailureType.server,
      ));
    }
  }

  @override
  Future<Either<Failure, Product>> saveProduct(Product product) async {
    if (!await connectionChecker.isConnected) {
      return left(Failure(
        message: 'No internet connection',
        type: FailureType.general,
      ));
    }

    try {
      final productModel = ProductModel.fromEntity(product);
      final savedModel = await locationRemoteDataSource.saveProduct(productModel);
      return right(savedModel as Product);
    } catch (e) {
      return left(Failure(
        message: 'Error al guardar producto: $e',
        type: FailureType.server,
      ));
    }
  }

  @override
  Future<Either<Failure, void>> saveProducts(List<Product> products) async {
    if (!await connectionChecker.isConnected) {
      return left(Failure(
        message: 'No internet connection',
        type: FailureType.general,
      ));
    }

    try {
      final productModels = products
          .map((prod) => ProductModel.fromEntity(prod))
          .toList();
      await locationRemoteDataSource.saveProducts(productModels);
      return right(null);
    } catch (e) {
      return left(Failure(
        message: 'Error al guardar productos: $e',
        type: FailureType.server,
      ));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProduct(String productId) async {
    if (!await connectionChecker.isConnected) {
      return left(Failure(
        message: 'No internet connection',
        type: FailureType.general,
      ));
    }

    try {
      await locationRemoteDataSource.deleteProduct(productId);
      return right(null);
    } catch (e) {
      return left(Failure(
        message: 'Error al eliminar producto: $e',
        type: FailureType.server,
      ));
    }
  }

  @override
  Future<Either<Failure, void>> toggleProductStock({
    required String productId,
    required bool available,
  }) async {
    if (!await connectionChecker.isConnected) {
      return left(Failure(
        message: 'No internet connection',
        type: FailureType.general,
      ));
    }

    try {
      await locationRemoteDataSource.toggleProductStock(
        productId: productId,
        available: available,
      );
      return right(null);
    } catch (e) {
      return left(Failure(
        message: 'Error al actualizar stock: $e',
        type: FailureType.server,
      ));
    }
  }

  @override
  Future<Either<Failure, void>> toggleProductFeatured({
    required String productId,
    required bool featured,
  }) async {
    if (!await connectionChecker.isConnected) {
      return left(Failure(
        message: 'No internet connection',
        type: FailureType.general,
      ));
    }

    try {
      await locationRemoteDataSource.toggleProductFeatured(
        productId: productId,
        featured: featured,
      );
      return right(null);
    } catch (e) {
      return left(Failure(
        message: 'Error al actualizar destacado: $e',
        type: FailureType.server,
      ));
    }
  }

  // ========== MARKETPLACE - RESEÑAS (4 métodos) ==========

  @override
  Future<Either<Failure, List<Review>>> getLocationReviews(String locationId) async {
    if (!await connectionChecker.isConnected) {
      return left(Failure(
        message: 'No internet connection',
        type: FailureType.general,
      ));
    }

    try {
      final reviewModels = await locationRemoteDataSource.getLocationReviews(locationId);
      final reviews = reviewModels.map((model) => model as Review).toList();
      return right(reviews);
    } catch (e) {
      return left(Failure(
        message: 'Error al obtener reseñas: $e',
        type: FailureType.server,
      ));
    }
  }

  @override
  Future<Either<Failure, Review>> createReview(Review review) async {
    if (!await connectionChecker.isConnected) {
      return left(Failure(
        message: 'No internet connection',
        type: FailureType.general,
      ));
    }

    try {
      final reviewModel = ReviewModel.fromEntity(review);
      final savedModel = await locationRemoteDataSource.createReview(reviewModel);
      return right(savedModel as Review);
    } catch (e) {
      return left(Failure(
        message: 'Error al crear reseña: $e',
        type: FailureType.server,
      ));
    }
  }

  @override
  Future<Either<Failure, void>> respondToReview({
    required String reviewId,
    required String response,
  }) async {
    if (!await connectionChecker.isConnected) {
      return left(Failure(
        message: 'No internet connection',
        type: FailureType.general,
      ));
    }

    try {
      await locationRemoteDataSource.respondToReview(
        reviewId: reviewId,
        response: response,
      );
      return right(null);
    } catch (e) {
      return left(Failure(
        message: 'Error al responder reseña: $e',
        type: FailureType.server,
      ));
    }
  }

  @override
  Future<Either<Failure, stats.ReviewStats>> getReviewStats(String locationId) async {
    if (!await connectionChecker.isConnected) {
      return left(Failure(
        message: 'No internet connection',
        type: FailureType.general,
      ));
    }

    try {
      final statsMap = await locationRemoteDataSource.getReviewStats(locationId);
      final reviewStats = stats.ReviewStats.fromMap(statsMap);
      return right(reviewStats);
    } catch (e) {
      return left(Failure(
        message: 'Error al obtener estadísticas: $e',
        type: FailureType.server,
      ));
    }
  }

  // ========== MARKETPLACE - VERIFICACIÓN (2 métodos) ==========

  @override
  Future<Either<Failure, void>> scheduleVerification({
    required String locationId,
    required DateTime date,
    required String time,
  }) async {
    if (!await connectionChecker.isConnected) {
      return left(Failure(
        message: 'No internet connection',
        type: FailureType.general,
      ));
    }

    try {
      await locationRemoteDataSource.scheduleVerification(
        locationId: locationId,
        date: date,
        time: time,
      );
      return right(null);
    } catch (e) {
      return left(Failure(
        message: 'Error al agendar verificación: $e',
        type: FailureType.server,
      ));
    }
  }

  @override
  Future<Either<Failure, void>> updateVerificationStatus({
    required String locationId,
    required String status,
    String? notes,
  }) async {
    if (!await connectionChecker.isConnected) {
      return left(Failure(
        message: 'No internet connection',
        type: FailureType.general,
      ));
    }

    try {
      await locationRemoteDataSource.updateVerificationStatus(
        locationId: locationId,
        status: status,
        notes: notes,
      );
      return right(null);
    } catch (e) {
      return left(Failure(
        message: 'Error al actualizar verificación: $e',
        type: FailureType.server,
      ));
    }
  }

  // ========== MARKETPLACE - BÚSQUEDA Y STATS (2 métodos) ==========

  @override
  Future<Either<Failure, List<LocationMap>>> getNearbyActiveLocations({
    required double latitude,
    required double longitude,
    double radiusKm = 5.0,
    int limit = 20,
    List<String>? categoryIds,
    double? minRating,
  }) async {
    if (!await connectionChecker.isConnected) {
      return left(Failure(
        message: 'No internet connection',
        type: FailureType.general,
      ));
    }

    try {
      final locationModels = await locationRemoteDataSource.getNearbyActiveLocations(
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm,
        limit: limit,
        categoryIds: categoryIds,
        minRating: minRating,
      );
      final locations = locationModels.map((model) => model as LocationMap).toList();
      return right(locations);
    } catch (e) {
      return left(Failure(
        message: 'Error al buscar ubicaciones: $e',
        type: FailureType.server,
      ));
    }
  }

  @override
  Future<Either<Failure, void>> updateLocationStats({
    required String locationId,
    double? rating,
    int? reviewsCount,
    int? ordersCount,
  }) async {
    if (!await connectionChecker.isConnected) {
      return left(Failure(
        message: 'No internet connection',
        type: FailureType.general,
      ));
    }

    try {
      await locationRemoteDataSource.updateLocationStats(
        locationId: locationId,
        rating: rating,
        reviewsCount: reviewsCount,
        ordersCount: ordersCount,
      );
      return right(null);
    } catch (e) {
      return left(Failure(
        message: 'Error al actualizar estadísticas: $e',
        type: FailureType.server,
      ));
    }
  }
}