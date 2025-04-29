part of 'measurement_bloc.dart';

@immutable
sealed class MeasurementState {}

final class MeasurementInitial extends MeasurementState {}

class MeasurementLoading extends MeasurementState {}

class MeasurementLoaded extends MeasurementState {
  final List<Measurement> items;

  MeasurementLoaded(this.items);
}

class MeasurementError extends MeasurementState {
  final String message;

  MeasurementError(this.message);
}