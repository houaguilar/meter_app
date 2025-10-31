import 'package:meter_app/domain/entities/map/verification_status.dart';

import 'document_type.dart';
import 'location.dart';

class LocationWithDistance extends LocationMap {
  final double? distanceKm;

  LocationWithDistance({
    required super.id,
    required super.title,
    required super.description,
    required super.latitude,
    required super.longitude,
    required super.address,
    super.userId,
    super.imageUrl,
    super.createdAt,
    // Heredar todos los nuevos campos con valores por defecto
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

  // Factory method desde LocationMap base
  factory LocationWithDistance.fromLocation(
      LocationMap location, {
        double? distanceKm,
      }) {
    return LocationWithDistance(
      id: location.id,
      title: location.title,
      description: location.description,
      latitude: location.latitude,
      longitude: location.longitude,
      address: location.address,
      userId: location.userId,
      imageUrl: location.imageUrl,
      createdAt: location.createdAt,
      document: location.document,
      documentType: location.documentType,
      phone: location.phone,
      verificationStatus: location.verificationStatus,
      scheduledDate: location.scheduledDate,
      scheduledTime: location.scheduledTime,
      approvalToken: location.approvalToken,
      approvedAt: location.approvedAt,
      approvedByName: location.approvedByName,
      verificationNotes: location.verificationNotes,
      whatsapp: location.whatsapp,
      businessHoursJson: location.businessHoursJson,
      paymentMethodStrings: location.paymentMethodStrings,
      rating: location.rating,
      reviewsCount: location.reviewsCount,
      ordersCount: location.ordersCount,
      updatedAt: location.updatedAt,
      isActive: location.isActive,
      distanceKm: distanceKm,
    );
  }

  @override
  LocationWithDistance copyWith({
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
    // Campo específico de esta clase
    double? distanceKm,
  }) {
    return LocationWithDistance(
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

  @override
  String toString() {
    return 'LocationWithDistance(id: $id, title: $title, distanceKm: $distanceKm)';
  }
}