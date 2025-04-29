
import 'package:meter_app/domain/entities/home/tarrajeo/coating.dart';
import 'package:meter_app/domain/repositories/home/tarrajeo/coating_repository.dart';

class GetCoatingsUseCase {
  final CoatingRepository repository;

  GetCoatingsUseCase(this.repository);

  Future<List<Coating>> call() async {
    return await repository.fetchCoatings();
  }
}