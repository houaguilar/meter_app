
import '../../../entities/entities.dart';
import '../../../repositories/home/inicio/measurement_repository.dart';

class GetMeasurementItems {
  final MeasurementRepository repository;

  GetMeasurementItems(this.repository);

  Future<List<Measurement>> call() async {
    return repository.getMeasurementItems();
  }
}