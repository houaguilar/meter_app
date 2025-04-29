
import 'package:meter_app/domain/entities/home/tarrajeo/coating.dart';

abstract interface class CoatingRepository {
  Future<List<Coating>> fetchCoatings();
}