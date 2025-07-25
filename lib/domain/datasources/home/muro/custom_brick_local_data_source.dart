import '../../../../domain/entities/home/muro/custom_brick.dart';

abstract class CustomBrickLocalDataSource {
  Future<List<CustomBrick>> getAllCustomBricks();
  Future<CustomBrick?> getCustomBrickById(String customId);
  Future<CustomBrick> saveCustomBrick(CustomBrick brick);
  Future<CustomBrick> updateCustomBrick(CustomBrick brick);
  Future<void> deleteCustomBrick(String customId);
  Future<void> deleteAllCustomBricks();
  Future<bool> existsByName(String name, {String? excludeId});
}