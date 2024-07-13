import 'package:meter_app/domain/datasources/map/location_data_source.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../config/constants/error/exceptions.dart';
import '../../models/map/location_model.dart';

class LocationDataSourceImpl implements LocationDataSource {
  final SupabaseClient supabaseClient;

  LocationDataSourceImpl(this.supabaseClient);

  @override
  Future<List<LocationModel>> loadLocations() async {
    final response = await supabaseClient
        .from('locations')
        .select();

    final locations = (response as List)
        .map((json) => LocationModel.fromMap(json))
        .toList();
    return locations;
  }

  @override
  Future<void> saveLocation(LocationModel location) async {
    try {
       await supabaseClient
          .from('locations')
          .insert(location.toMap());

    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }



  }
}