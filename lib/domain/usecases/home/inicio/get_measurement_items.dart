
import 'package:meter_app/domain/entities/entities.dart';
import 'package:meter_app/domain/repositories/home/inicio/measurement_repository.dart';

class GetMeasurementItems {
  final MeasurementRepository repository;

  GetMeasurementItems(this.repository);

  Future<List<Measurement>> call() async {
    return repository.getMeasurementItems();
  }
}