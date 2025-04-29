
import 'package:meter_app/domain/entities/home/piso/floor.dart';

abstract interface class FloorRepository {
  Future<List<Floor>> fetchFloors();
}