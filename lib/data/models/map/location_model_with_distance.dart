// Modelo extendido que incluye distancia para PostGIS
import '../../../domain/entities/map/document_type.dart';
import '../../../domain/entities/map/location_with_distance.dart';
import '../../../domain/entities/map/verification_status.dart';
import 'location_model.dart';

class LocationModelWithDistance extends LocationModel {
  final double? distanceKm;

  LocationModelWithDistance({
    required super.id,
    required super.title,
    required super.description,
    required super.latitude,
    required super.longitude,
    required super.address,
    super.userId,
    super.imageUrl,
    super.createdAt,
    // Heredar todos los nuevos campos
    super.document,
    super.documentType,
    super.phone,
    super.verificationStatus,
    super.scheduledDate,
    super.scheduledTime,
    super.approvalToken,
    super.approvedAt,
    super.approvedByName,
    super.verificationNotes,
    super.whatsapp,
    super.businessHoursJson,
    super.paymentMethodStrings,
    super.rating,
    super.reviewsCount,
    super.ordersCount,
    super.updatedAt,
    super.isActive,
    this.distanceKm,
  });

  factory LocationModelWithDistance.fromMap(Map<String, dynamic> map) {
    final baseLocation = LocationModel.fromSupabase(map);
    return LocationModelWithDistance(
      id: baseLocation.id,
      title: baseLocation.title,
      description: baseLocation.description,
      latitude: baseLocation.latitude,
      longitude: baseLocation.longitude,
      address: baseLocation.address,
      userId: baseLocation.userId,
      imageUrl: baseLocation.imageUrl,
      createdAt: baseLocation.createdAt,
      // Nuevos campos
      document: baseLocation.document,
      documentType: baseLocation.documentType,
      phone: baseLocation.phone,
      verificationStatus: baseLocation.verificationStatus,
      scheduledDate: baseLocation.scheduledDate,
      scheduledTime: baseLocation.scheduledTime,
      approvalToken: baseLocation.approvalToken,
      approvedAt: baseLocation.approvedAt,
      approvedByName: baseLocation.approvedByName,
      verificationNotes: baseLocation.verificationNotes,
      whatsapp: baseLocation.whatsapp,
      businessHoursJson: baseLocation.businessHoursJson,
      paymentMethodStrings: baseLocation.paymentMethodStrings,
      rating: baseLocation.rating,
      reviewsCount: baseLocation.reviewsCount,
      ordersCount: baseLocation.ordersCount,
      updatedAt: baseLocation.updatedAt,
      isActive: baseLocation.isActive,
      // Campo específico
      distanceKm: (map['distance_km'] as num?)?.toDouble(),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    if (distanceKm != null) {
      map['distance_km'] = distanceKm;
    }
    return map;
  }

  // Convertir a LocationWithDistance (entidad)
  LocationWithDistance toLocationWithDistance() {
    return LocationWithDistance(
      id: id,
      title: title,
      description: description,
      latitude: latitude,
      longitude: longitude,
      address: address,
      userId: userId,
      imageUrl: imageUrl,
      createdAt: createdAt,
      // Nuevos campos
      document: document,
      documentType: documentType,
      phone: phone,
      verificationStatus: verificationStatus,
      scheduledDate: scheduledDate,
      scheduledTime: scheduledTime,
      approvalToken: approvalToken,
      approvedAt: approvedAt,
      approvedByName: approvedByName,
      verificationNotes: verificationNotes,
      whatsapp: whatsapp,
      businessHoursJson: businessHoursJson,
      paymentMethodStrings: paymentMethodStrings,
      rating: rating,
      reviewsCount: reviewsCount,
      ordersCount: ordersCount,
      updatedAt: updatedAt,
      isActive: isActive,
      // Campo específico
      distanceKm: distanceKm,
    );
  }

  @override
  LocationModelWithDistance copyWith({
    String? id,
    String? title,
    String? description,
    double? latitude,
    double? longitude,
    String? address,
    String? userId,
    String? imageUrl,
    DateTime? createdAt,
    // Nuevos campos
    String? document,
    DocumentType? documentType,
    String? phone,
    VerificationStatus? verificationStatus,
    DateTime? scheduledDate,
    String? scheduledTime,
    String? approvalToken,
    DateTime? approvedAt,
    String? approvedByName,
    String? verificationNotes,
    String? whatsapp,
    String? businessHoursJson,
    List<String>? paymentMethodStrings,
    double? rating,
    int? reviewsCount,
    int? ordersCount,
    DateTime? updatedAt,
    bool? isActive,
    // Campo específico
    double? distanceKm,
  }) {
    return LocationModelWithDistance(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      userId: userId ?? this.userId,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      // Nuevos campos
      document: document ?? this.document,
      documentType: documentType ?? this.documentType,
      phone: phone ?? this.phone,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      approvalToken: approvalToken ?? this.approvalToken,
      approvedAt: approvedAt ?? this.approvedAt,
      approvedByName: approvedByName ?? this.approvedByName,
      verificationNotes: verificationNotes ?? this.verificationNotes,
      whatsapp: whatsapp ?? this.whatsapp,
      businessHoursJson: businessHoursJson ?? this.businessHoursJson,
      paymentMethodStrings: paymentMethodStrings ?? this.paymentMethodStrings,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      ordersCount: ordersCount ?? this.ordersCount,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      // Campo específico
      distanceKm: distanceKm ?? this.distanceKm,
    );
  }
}