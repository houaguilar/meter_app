part of 'measurement_bloc.dart';

@immutable
sealed class MeasurementEvent {}

class LoadMeasurementItems extends MeasurementEvent {}
