

import 'package:meter_app/domain/entities/home/losas/slab.dart';

abstract interface class SlabRepository {
  Future<List<Slab>> fetchSlabs();
}