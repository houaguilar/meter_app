// lib/data/datasources/map/location_data_source_impl.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:meter_app/domain/datasources/map/location_data_source.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';

import '../../../config/constants/error/exceptions.dart';
import '../../models/map/location_model.dart';
import '../../models/map/location_model_with_distance.dart';

class LocationDataSourceImpl implements LocationDataSource {
  final SupabaseClient supabaseClient;
  bool? _isPostGISAvailable;

  LocationDataSourceImpl(this.supabaseClient);

  @override
  Future<List<LocationModel>> loadLocations() async {
    try {
      final response = await supabaseClient
          .from('locations')
          .select()
          .order('created_at', ascending: false);

      if (response == null) {
        return [];
      }

      final locations = (response as List)
          .map((json) => LocationModel.fromMap(json))
          .toList();

      return locations;
    } on PostgrestException catch (e) {
      throw ServerException('Error al cargar ubicaciones: ${e.message}');
    } catch (e) {
      throw ServerException('Error inesperado al cargar ubicaciones: $e');
    }
  }

  /// 🚀 NUEVO: Método optimizado para ubicaciones cercanas
  @override
  Future<List<LocationModelWithDistance>> loadNearbyLocations({
    required double userLat,
    required double userLng,
    double radiusKm = 25.0,
    int maxResults = 15,
  }) async {
    try {
      // Verificar PostGIS disponibilidad (solo una vez)
      if (_isPostGISAvailable == null) {
        _isPostGISAvailable = await isPostGISAvailable();
      }

      if (_isPostGISAvailable == true) {
        // 🚀 MÉTODO OPTIMIZADO: Usar PostGIS
        return await _loadNearbyWithPostGIS(
          userLat: userLat,
          userLng: userLng,
          radiusKm: radiusKm,
          maxResults: maxResults,
        );
      } else {
        // 🔄 MÉTODO FALLBACK: Calcular en cliente
        return await _loadNearbyWithClientCalculation(
          userLat: userLat,
          userLng: userLng,
          radiusKm: radiusKm,
          maxResults: maxResults,
        );
      }
    } catch (e) {
      // En caso de error con PostGIS, usar método cliente como fallback
      try {
        return await _loadNearbyWithClientCalculation(
          userLat: userLat,
          userLng: userLng,
          radiusKm: radiusKm,
          maxResults: maxResults,
        );
      } catch (fallbackError) {
        throw ServerException('Error al cargar ubicaciones cercanas: $fallbackError');
      }
    }
  }

  /// 🚀 Método optimizado con PostGIS
  Future<List<LocationModelWithDistance>> _loadNearbyWithPostGIS({
    required double userLat,
    required double userLng,
    required double radiusKm,
    required int maxResults,
  }) async {
    try {
      print('🚀 Usando PostGIS para ubicaciones cercanas');

      final response = await supabaseClient.rpc('get_nearby_locations', params: {
        'user_lat': userLat,
        'user_lng': userLng,
        'radius_km': radiusKm,
        'max_results': maxResults,
      });

      if (response == null) {
        return [];
      }

      final locations = (response as List)
          .map((json) => LocationModelWithDistance.fromMap(json))
          .toList();

      print('🎯 PostGIS encontró ${locations.length} ubicaciones');

      return locations;
    } catch (e) {
      print('❌ Error con PostGIS: $e');
      throw ServerException('Error con PostGIS: $e');
    }
  }

  /// 🔄 Método fallback con cálculo en cliente
  Future<List<LocationModelWithDistance>> _loadNearbyWithClientCalculation({
    required double userLat,
    required double userLng,
    required double radiusKm,
    required int maxResults,
  }) async {
    try {
      print('🔄 Usando cálculo en cliente para ubicaciones cercanas');

      // Cargar todas las ubicaciones
      final allLocations = await loadLocations();

      // Calcular distancias y filtrar
      final locationsWithDistance = <LocationModelWithDistance>[];

      for (final location in allLocations) {
        final distance = Geolocator.distanceBetween(
          userLat,
          userLng,
          location.latitude,
          location.longitude,
        ) / 1000; // Convertir a km

        // Filtrar por radio
        if (distance <= radiusKm) {
          locationsWithDistance.add(LocationModelWithDistance(
            id: location.id,
            title: location.title,
            description: location.description,
            latitude: location.latitude,
            longitude: location.longitude,
            address: location.address,
            userId: location.userId,
            createdAt: location.createdAt,
            imageUrl: location.imageUrl,
            distanceKm: distance,
          ));
        }
      }

      // Ordenar por distancia y limitar resultados
      locationsWithDistance.sort((a, b) => a.distanceKm!.compareTo(b.distanceKm!));
      final result = locationsWithDistance.take(maxResults).toList();

      print('🎯 Cliente encontró ${result.length} ubicaciones');

      return result;
    } catch (e) {
      throw ServerException('Error en cálculo cliente: $e');
    }
  }

  /// 🔧 NUEVO: Verificar disponibilidad PostGIS
  @override
  Future<bool> isPostGISAvailable() async {
    try {
      await supabaseClient.rpc('get_nearby_locations', params: {
        'user_lat': -12.0464,
        'user_lng': -77.0428,
        'radius_km': 25.0,
        'max_results': 1,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 🛠️ NUEVO: Configurar PostGIS
  @override
  Future<bool> setupPostGIS() async {
    try {
      final isAvailable = await isPostGISAvailable();
      _isPostGISAvailable = isAvailable;
      return isAvailable;
    } catch (e) {
      _isPostGISAvailable = false;
      return false;
    }
  }

  /// 📍 NUEVO: Obtener ubicaciones por usuario
  @override
  Future<List<LocationModel>> getLocationsByUser(String userId) async {
    try {
      final response = await supabaseClient
          .from('locations')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      if (response == null) {
        return [];
      }

      return (response as List)
          .map((json) => LocationModel.fromMap(json))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException('Error al cargar ubicaciones del usuario: ${e.message}');
    } catch (e) {
      throw ServerException('Error inesperado: $e');
    }
  }

  /// 🗑️ NUEVO: Eliminar ubicación
  @override
  Future<void> deleteLocation(String locationId) async {
    try {
      await supabaseClient
          .from('locations')
          .delete()
          .eq('id', locationId);
    } on PostgrestException catch (e) {
      throw ServerException('Error al eliminar ubicación: ${e.message}');
    } catch (e) {
      throw ServerException('Error inesperado al eliminar: $e');
    }
  }

  // ============================================================
  // TUS MÉTODOS EXISTENTES - CONSERVADOS INTACTOS ✅
  // ============================================================

  @override
  Future<void> saveLocation(LocationModel location) async {
    try {
      // Validar datos antes de enviar
      _validateLocationData(location);

      final locationMap = location.toMap();

      // Agregar timestamp de creación
      locationMap['created_at'] = DateTime.now().toIso8601String();

      final response = await supabaseClient
          .from('locations')
          .insert(locationMap)
          .select(); // Importante: agregar select() para obtener el resultado

      if (response == null || (response as List).isEmpty) {
        throw const ServerException('No se pudo guardar la ubicación');
      }

    } on PostgrestException catch (e) {
      // Manejar errores específicos de Supabase
      if (e.code == '23505') {
        throw const ServerException('Ya existe una ubicación con estos datos');
      } else if (e.code == '23503') {
        throw const ServerException('Usuario no válido');
      } else {
        throw ServerException('Error de base de datos: ${e.message}');
      }
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException('Error al guardar ubicación: $e');
    }
  }

  @override
  Future<String> uploadImage(File image) async {
    try {
      // Validar que el archivo existe
      if (!await image.exists()) {
        throw const ServerException('El archivo de imagen no existe');
      }

      // Comprimir imagen antes de subir
      final compressedImage = await _compressImage(image);

      // Generar nombre único para la imagen
      const uuid = Uuid();
      final fileName = 'location_${uuid.v4()}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = 'locations/$fileName';

      // Subir imagen a Supabase Storage
      final response = await supabaseClient.storage
          .from('locations')
          .uploadBinary(
        filePath,
        compressedImage,
        fileOptions: const FileOptions(
          cacheControl: '3600',
          upsert: false,
        ),
      );

      if (response.isEmpty) {
        throw const ServerException('Error al subir la imagen');
      }

      // Obtener URL pública
      final publicUrl = supabaseClient.storage
          .from('locations')
          .getPublicUrl(filePath);

      if (publicUrl.isEmpty) {
        throw const ServerException('Error al obtener URL de la imagen');
      }

      return publicUrl;

    } on StorageException catch (e) {
      // Manejar errores específicos de Storage
      if (e.statusCode == '413') {
        throw const ServerException('La imagen es demasiado grande (máximo 5MB)');
      } else if (e.statusCode == '415') {
        throw const ServerException('Formato de imagen no soportado');
      } else {
        throw ServerException('Error de almacenamiento: ${e.message}');
      }
    } on PostgrestException catch (e) {
      throw ServerException('Error de conexión: ${e.message}');
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException('Error al subir imagen: $e');
    }
  }

  // TUS MÉTODOS PRIVADOS EXISTENTES - CONSERVADOS ✅

  void _validateLocationData(LocationModel location) {
    if (location.title.trim().isEmpty) {
      throw const ServerException('El título es obligatorio');
    }

    if (location.title.trim().length < 3) {
      throw const ServerException('El título debe tener al menos 3 caracteres');
    }

    if (location.description.trim().isEmpty) {
      throw const ServerException('La descripción es obligatoria');
    }

    if (location.description.trim().length < 10) {
      throw const ServerException('La descripción debe tener al menos 10 caracteres');
    }

    if (location.latitude < -90 || location.latitude > 90) {
      throw const ServerException('Latitud inválida');
    }

    if (location.longitude < -180 || location.longitude > 180) {
      throw const ServerException('Longitud inválida');
    }

    if (location.userId == null || location.userId!.trim().isEmpty) {
      throw const ServerException('ID de usuario es obligatorio');
    }

    if (location.imageUrl == null || location.imageUrl!.trim().isEmpty) {
      throw const ServerException('La imagen es obligatoria');
    }
  }

  Future<Uint8List> _compressImage(File image) async {
    try {
      // Obtener el tamaño del archivo
      final fileSize = await image.length();

      // Si la imagen es menor a 1MB, no comprimir
      if (fileSize < 1024 * 1024) {
        return await image.readAsBytes();
      }

      // Comprimir imagen
      final compressedImage = await FlutterImageCompress.compressWithFile(
        image.absolute.path,
        minWidth: 1024,
        minHeight: 1024,
        quality: 80,
        rotate: 0,
      );

      if (compressedImage == null) {
        // Si la compresión falla, usar imagen original
        return await image.readAsBytes();
      }

      return compressedImage;
    } catch (e) {
      // Si hay error en compresión, usar imagen original
      return await image.readAsBytes();
    }
  }

  /// Obtener ubicaciones por usuario específico
  Future<List<LocationModel>> _getLocationsByUserInternal(String userId) async {
    try {
      final response = await supabaseClient
          .from('locations')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      if (response == null) {
        return [];
      }

      return (response as List)
          .map((json) => LocationModel.fromMap(json))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException('Error al cargar ubicaciones del usuario: ${e.message}');
    } catch (e) {
      throw ServerException('Error inesperado: $e');
    }
  }

  /// Eliminar una ubicación (para funcionalidad futura)
  Future<void> _deleteLocationInternal(String locationId) async {
    try {
      await supabaseClient
          .from('locations')
          .delete()
          .eq('id', locationId);
    } on PostgrestException catch (e) {
      throw ServerException('Error al eliminar ubicación: ${e.message}');
    } catch (e) {
      throw ServerException('Error inesperado al eliminar: $e');
    }
  }

  /// Verificar si el bucket de almacenamiento existe
  Future<bool> checkStorageBucket() async {
    try {
      final buckets = await supabaseClient.storage.listBuckets();
      return buckets.any((bucket) => bucket.name == 'locations');
    } catch (e) {
      return false;
    }
  }
}