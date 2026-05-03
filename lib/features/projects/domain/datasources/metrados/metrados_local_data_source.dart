import 'package:meter_app/domain/entities/entities.dart';

abstract interface class MetradosLocalDataSource {
  Future<int> saveMetrado(String name, int projectId);
  Future<List<Metrado>> loadMetrados(int projectId);
  Future<void> deleteMetrado(Metrado metrado);
  Future<void> updateMetrado(Metrado metrado);
}