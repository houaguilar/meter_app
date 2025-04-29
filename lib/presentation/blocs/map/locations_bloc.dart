import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meta/meta.dart';

import '../../../config/usecase/usecase.dart';
import '../../../domain/entities/map/location.dart';
import '../../../domain/usecases/map/save_location.dart';
import '../../../domain/usecases/map/get_all_locations.dart';
import '../../../domain/usecases/map/upload_image.dart';

part 'locations_event.dart';
part 'locations_state.dart';

class LocationsBloc extends Bloc<LocationsEvent, LocationsState> {
  final GetAllLocations getAllLocations;
  final SaveLocation saveLocation;
  final UploadImage uploadImage;

  LocationsBloc({
    required this.getAllLocations,
    required this.saveLocation,
    required this.uploadImage,
  }) : super(LocationsLoading()) {
    on<LoadLocations>(_onLoadLocations);
    on<AddNewLocation>(_onAddNewLocation);
    on<UploadImageEvent>(_onUploadImage);
  }

  void _onLoadLocations(
      LoadLocations event, Emitter<LocationsState> emit) async {
    emit(LocationsLoading());
    final result = await getAllLocations(NoParams());
    result.fold(
          (failure) => emit(LocationsError(failure.message)),
          (locations) => emit(LocationsLoaded(locations)),
    );
  }

  void _onAddNewLocation(
      AddNewLocation event, Emitter<LocationsState> emit) async {
    emit(LocationsSaving());
    final result = await saveLocation(event.location);
    result.fold(
          (failure) => emit(LocationsError(failure.message)),
          (_) => emit(LocationSaved()),
    );
  }

  void _onUploadImage(
      UploadImageEvent event, Emitter<LocationsState> emit) async {
    emit(ImageUploading());
    final result = await uploadImage(event.image);
    result.fold(
          (failure) => emit(LocationsError(failure.message)),
          (imageUrl) => emit(ImageUploaded(imageUrl)),
    );
  }

}
