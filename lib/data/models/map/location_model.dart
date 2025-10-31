// lib/data/models/map/location_model.dart
import 'dart:convert';
import '../../../domain/entities/map/location.dart';
import '../../../domain/entities/map/verification_status.dart';
import '../../../domain/entities/map/document_type.dart';

class LocationModel extends LocationMap {
  LocationModel({
    super.id,
    required super.title,
    required super.description,
    required super.latitude,
    required super.longitude,
    required super.address,
    super.userId,
    super.imageUrl,
    super.createdAt,
    // Verificación
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
    // Contacto
    super.whatsapp,
    super.businessHoursJson,
    super.paymentMethodStrings,
    // Estadísticas
    super.rating,
    super.reviewsCount,
    super.ordersCount,
    super.isActive,
    super.updatedAt,
  });

  /// Constructor desde Supabase (snake_case fields)
  factory LocationModel.fromSupabase(Map<String, dynamic> map) {
    return LocationModel(
      id: map['id']?.toString(),
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      address: map['address']?.toString() ?? '',
      userId: map['user_id']?.toString(),
      imageUrl: map['image_url']?.toString(),
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString())
          : null,
      // Verificación
      document: map['document']?.toString(),
      documentType: map['document_type'] != null
          ? DocumentType.fromString(map['document_type'].toString())
          : null,
      phone: map['phone']?.toString(),
      verificationStatus: map['verification_status'] != null
          ? VerificationStatus.fromString(map['verification_status'].toString())
          : VerificationStatus.pendingApproval,
      scheduledDate: map['scheduled_date'] != null
          ? DateTime.tryParse(map['scheduled_date'].toString())
          : null,
      scheduledTime: map['scheduled_time']?.toString(),
      approvalToken: map['approval_token']?.toString(),
      approvedAt: map['approved_at'] != null
          ? DateTime.tryParse(map['approved_at'].toString())
          : null,
      approvedByName: map['approved_by_name']?.toString(),
      verificationNotes: map['verification_notes']?.toString(),
      // Contacto
      whatsapp: map['whatsapp']?.toString(),
      businessHoursJson: map['business_hours'] != null
          ? jsonEncode(map['business_hours'])
          : null,
      paymentMethodStrings: map['payment_methods'] != null
          ? (map['payment_methods'] as List<dynamic>).map((e) => e.toString()).toList()
          : null,
      // Estadísticas
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      reviewsCount: (map['reviews_count'] as num?)?.toInt() ?? 0,
      ordersCount: (map['orders_count'] as num?)?.toInt() ?? 0,
      isActive: (map['is_active'] as bool?) ?? false,
      updatedAt: (map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'].toString())
          : null),
    );
  }

  /// Alias para retrocompatibilidad
  factory LocationModel.fromMap(Map<String, dynamic> map) {
    return LocationModel.fromSupabase(map);
  }

  /// Convierte a Map para Supabase (snake_case)
  Map<String, dynamic> toSupabase() {
    final map = <String, dynamic>{
      'title': title,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'user_id': userId,
      'image_url': imageUrl,
      // Verificación
      'document': document,
      'document_type': documentType?.toDbString(),
      'phone': phone,
      'verification_status': verificationStatus.toDbString(),
      'scheduled_date': scheduledDate?.toIso8601String(),
      'scheduled_time': scheduledTime,
      'approval_token': approvalToken,
      'approved_at': approvedAt?.toIso8601String(),
      'approved_by_name': approvedByName,
      'verification_notes': verificationNotes,
      // Contacto
      'whatsapp': whatsapp,
      'business_hours': businessHoursJson != null
          ? jsonDecode(businessHoursJson!)
          : null,
      'payment_methods': paymentMethodStrings,
      // Estadísticas
      'rating': rating,
      'reviews_count': reviewsCount,
      'orders_count': ordersCount,
      'is_active': isActive,
      'updated_at': updatedAt?.toIso8601String(),
    };

    // Solo incluir ID si no es null
    if (id != null) {
      map['id'] = id;
    }

    // Solo incluir created_at si no es null
    if (createdAt != null) {
      map['created_at'] = createdAt!.toIso8601String();
    }

    // PostGIS point (si hay lat/lng)
    if (latitude != 0.0 && longitude != 0.0) {
      map['location_point'] = 'POINT($longitude $latitude)';
    }

    return map;
  }

  /// Alias para retrocompatibilidad
  Map<String, dynamic> toMap() {
    return toSupabase();
  }

  @override
  LocationModel copyWith({
    String? id,
    String? title,
    String? description,
    double? latitude,
    double? longitude,
    String? address,
    String? userId,
    String? imageUrl,
    DateTime? createdAt,
    // Verificación
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
    // Contacto
    String? whatsapp,
    String? businessHoursJson,
    List<String>? paymentMethodStrings,
    // Estadísticas
    double? rating,
    int? reviewsCount,
    int? ordersCount,
    bool? isActive,
    DateTime? updatedAt,
  }) {
    return LocationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      userId: userId ?? this.userId,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      // Verificación
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
      // Contacto
      whatsapp: whatsapp ?? this.whatsapp,
      businessHoursJson: businessHoursJson ?? this.businessHoursJson,
      paymentMethodStrings: paymentMethodStrings ?? this.paymentMethodStrings,
      // Estadísticas
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      ordersCount: ordersCount ?? this.ordersCount,
      isActive: isActive ?? this.isActive,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}