
import 'package:isar/isar.dart';
import '../../../domain/datasources/premium/premium_local_data_source.dart';
import '../../models/premium/premium_status_model.dart';
import '../../../config/constants/error/exceptions.dart';

class PremiumLocalDataSourceImpl implements PremiumLocalDataSource {
  final Isar isar;

  PremiumLocalDataSourceImpl(this.isar);

  @override
  Future<PremiumStatusModel?> getCachedPremiumStatus(String userId) async {
    try {
      final cached = await isar.premiumStatusModels
          .where()
          .userIdEqualTo(userId)
          .findFirst();

      return cached;
    } catch (e) {
      throw LocalException('Error al obtener premium status del cache: $e');
    }
  }

  @override
  Future<void> cachePremiumStatus(String userId, PremiumStatusModel status) async {
    try {
      await isar.writeTxn(() async {
        // Eliminar cache anterior del usuario
        await isar.premiumStatusModels
            .where()
            .userIdEqualTo(userId)
            .deleteAll();

        // Guardar nuevo status
        await isar.premiumStatusModels.put(status);
      });
    } catch (e) {
      throw LocalException('Error al guardar premium status en cache: $e');
    }
  }

  @override
  Future<void> clearPremiumCache(String userId) async {
    try {
      await isar.writeTxn(() async {
        await isar.premiumStatusModels
            .where()
            .userIdEqualTo(userId)
            .deleteAll();
      });
    } catch (e) {
      throw LocalException('Error al limpiar cache premium: $e');
    }
  }

  @override
  Stream<PremiumStatusModel?> watchCachedPremiumStatus(String userId) {
    try {
      return isar.premiumStatusModels
          .where()
          .userIdEqualTo(userId)
          .watch(fireImmediately: true)
          .map((results) => results.isNotEmpty ? results.first : null);
    } catch (e) {
      throw LocalException('Error al observar premium status: $e');
    }
  }
}