import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:meter_app/domain/entities/entities.dart';

import '../../../../domain/usecases/home/inicio/get_measurement_items.dart';

part 'measurement_event.dart';
part 'measurement_state.dart';

class MeasurementBloc extends Bloc<MeasurementEvent, MeasurementState> {
  final GetMeasurementItems getMeasurementItems;

  MeasurementBloc(this.getMeasurementItems) : super(MeasurementInitial()) {
    on<LoadMeasurementItems>((event, emit) async {
      emit(MeasurementLoading());
      try {
        final items = await getMeasurementItems();
        emit(MeasurementLoaded(items));
      } catch (e) {
        emit(MeasurementError('Failed to load measurement items'));
      }
    });
  }
}
