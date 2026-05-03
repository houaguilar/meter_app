
import 'package:meter_app/domain/entities/entities.dart';

abstract interface class MeasurementRepository {
  Future<List<Measurement>> getMeasurementItems();
}
