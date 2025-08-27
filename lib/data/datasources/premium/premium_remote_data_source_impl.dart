
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../domain/datasources/premium/premium_remote_data_source.dart';
import '../../models/premium/premium_status_model.dart';
import '../../../config/constants/error/exceptions.dart';

class PremiumRemoteDataSourceImpl implements PremiumRemoteDataSource {
  final SupabaseClient supabaseClient;

  PremiumRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<PremiumStatusModel> getPremiumStatus(String userId) async {
    try {
      print('🔍 Remote DataSource: Obteniendo premium status para user: $userId');

      final response = await supabaseClient
          .from('profiles')
          .select('''
          id,
          is_premium,
          premium_until,
          premium_source,
          entitlement_id,
          revenuecat_user_id,
          last_verified_at,
          created_at,
          updated_at
        ''')
          .eq('id', userId)
          .maybeSingle(); // Usar maybeSingle en lugar de single

      print('🔍 Remote DataSource: Response de Supabase: $response');

      if (response == null) {
        print('🔍 Remote DataSource: No se encontró el usuario, creando status default');

        // Si no existe el usuario, crear un registro básico
        await supabaseClient
            .from('profiles')
            .upsert({
          'id': userId,
          'is_premium': false,
          'premium_source': 'none',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });

        // Retornar status gratuito por defecto
        return PremiumStatusModel.fromJson({
          'user_id': userId,
          'is_premium': false,
          'premium_until': null,
          'premium_source': 'none',
          'entitlement_id': null,
          'revenuecat_user_id': null,
          'last_verified_at': null,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
      }

      // Preparar datos con valores seguros
      final safeData = {
        'user_id': response['id']?.toString() ?? userId,
        'is_premium': response['is_premium'] ?? false,
        'premium_until': response['premium_until'],
        'premium_source': response['premium_source'] ?? 'none',
        'entitlement_id': response['entitlement_id'],
        'revenuecat_user_id': response['revenuecat_user_id'],
        'last_verified_at': response['last_verified_at'],
        'created_at': response['created_at'] ?? DateTime.now().toIso8601String(),
        'updated_at': response['updated_at'] ?? DateTime.now().toIso8601String(),
      };

      print('🔍 Remote DataSource: Datos seguros preparados: $safeData');

      return PremiumStatusModel.fromJson(safeData);

    } on PostgrestException catch (e) {
      print('🔍 Remote DataSource PostgrestException: ${e.message}');
      throw ServerException('Error al obtener premium status: ${e.message}');
    } catch (e) {
      print('🔍 Remote DataSource Error general: $e');
      throw ServerException('Error inesperado: $e');
    }
  }

  @override
  Future<void> updatePremiumStatus(String userId, PremiumStatusModel status) async {
    try {
      final updateData = {
        'is_premium': status.isPremium,
        'premium_until': status.premiumUntil?.toIso8601String(),
        'premium_source': status.premiumSource,
        'entitlement_id': status.entitlementId,
        'revenuecat_user_id': status.revenueCatUserId,
        'last_verified_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      await supabaseClient
          .from('profiles')
          .update(updateData)
          .eq('id', userId);

    } on PostgrestException catch (e) {
      throw ServerException('Error al actualizar premium status: ${e.message}');
    } catch (e) {
      throw ServerException('Error inesperado: $e');
    }
  }

  @override
  Stream<PremiumStatusModel> watchPremiumStatus(String userId) {
    try {
      return supabaseClient
          .from('profiles')
          .stream(primaryKey: ['id'])
          .eq('id', userId)
          .map((data) {
        if (data.isEmpty) {
          throw const ServerException('Usuario no encontrado');
        }

        final response = data.first;
        return PremiumStatusModel.fromJson({
          'user_id': response['id'],
          'is_premium': response['is_premium'] ?? false,
          'premium_until': response['premium_until'],
          'premium_source': response['premium_source'] ?? 'none',
          'entitlement_id': response['entitlement_id'],
          'revenuecat_user_id': response['revenuecat_user_id'],
          'last_verified_at': response['last_verified_at'],
          'created_at': response['created_at'],
          'updated_at': response['updated_at'],
        });
      });

    } catch (e) {
      throw ServerException('Error al observar premium status: $e');
    }
  }
}