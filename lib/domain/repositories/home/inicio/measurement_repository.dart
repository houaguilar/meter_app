
import '../../../entities/entities.dart';

abstract interface class MeasurementRepository {
  Future<List<Measurement>> getMeasurementItems();
}
