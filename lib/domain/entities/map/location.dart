import 'dart:convert';
import 'package:flutter/material.dart';
import 'verification_status.dart';
import 'document_type.dart';
import 'business_hours.dart';
import 'payment_method.dart';

class LocationMap {
  // ========== CAMPOS BÁSICOS (existentes) ==========
  final String? id;
  final String title;
  final String description;
  final double latitude;
  final double longitude;
  final String address;
  final String? userId;
  final String? imageUrl;
  final DateTime? createdAt;

  // ========== VERIFICACIÓN (nuevos) ==========
  /// Documento de identidad (DNI 8 dígitos o CE 9 dígitos)
  final String? document;

  /// Tipo de documento
  final DocumentType? documentType;

  /// Teléfono en formato +51XXXXXXXXX
  final String? phone;

  /// Estado de verificación del proveedor
  final VerificationStatus verificationStatus;

  /// Fecha programada para verificación
  final DateTime? scheduledDate;

  /// Hora programada en formato "HH:mm" (ej: "09:00", "14:00")
  final String? scheduledTime;

  /// Token único de aprobación (generado por Supabase)
  final String? approvalToken;

  /// Fecha de aprobación
  final DateTime? approvedAt;

  /// Nombre de quien aprobó
  final String? approvedByName;

  /// Notas de verificación (motivo de rechazo, etc.)
  final String? verificationNotes;

  // ========== CONTACTO (nuevos) ==========
  /// WhatsApp (puede ser diferente al teléfono)
  final String? whatsapp;

  /// Horarios de atención por día (JSON serializado)
  /// Formato: {"lunes": {"open": "08:00", "close": "18:00", "closed": false}, ...}
  final String? businessHoursJson;

  /// Métodos de pago aceptados (lista de strings)
  final List<String>? paymentMethodStrings;

  // ========== ESTADÍSTICAS (nuevos) ==========
  /// Calificación promedio (0.0 a 5.0)
  final double rating;

  /// Cantidad de reseñas
  final int reviewsCount;

  /// Cantidad de pedidos completados
  final int ordersCount;

  /// Si la ubicación está activa y visible en el mapa
  final bool isActive;

  /// Fecha de última actualización
  final DateTime? updatedAt;

  LocationMap({
    this.id,
    required this.title,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.address,
    this.userId,
    this.imageUrl,
    this.createdAt,
    // Verificación
    this.document,
    this.documentType,
    this.phone,
    this.verificationStatus = VerificationStatus.pendingApproval,
    this.scheduledDate,
    this.scheduledTime,
    this.approvalToken,
    this.approvedAt,
    this.approvedByName,
    this.verificationNotes,
    // Contacto
    this.whatsapp,
    this.businessHoursJson,
    this.paymentMethodStrings,
    // Estadísticas
    this.rating = 0.0,
    this.reviewsCount = 0,
    this.ordersCount = 0,
    this.isActive = false,
    this.updatedAt,
  });

  // ========== HELPERS ==========

  /// Obtiene TimeOfDay desde scheduledTime string
  TimeOfDay? get scheduledTimeOfDay {
    if (scheduledTime == null) return null;
    try {
      final parts = scheduledTime!.split(':');
      return TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    } catch (e) {
      return null;
    }
  }

  /// Obtiene los horarios de atención como Map
  Map<String, BusinessHours>? get businessHours {
    if (businessHoursJson == null || businessHoursJson!.isEmpty) return null;
    try {
      final decoded = jsonDecode(businessHoursJson!) as Map<String, dynamic>;
      return decoded.map(
        (key, value) => MapEntry(
          key,
          BusinessHours.fromJson(value as Map<String, dynamic>),
        ),
      );
    } catch (e) {
      return null;
    }
  }

  /// Obtiene los métodos de pago como enums
  List<PaymentMethod>? get paymentMethods {
    return PaymentMethod.fromStringList(paymentMethodStrings);
  }

  /// Si puede configurar productos
  bool get canConfigureProducts {
    return verificationStatus == VerificationStatus.approved ||
        verificationStatus == VerificationStatus.active;
  }

  /// Si está aprobado (cualquier nivel)
  bool get isApproved {
    return verificationStatus == VerificationStatus.approved ||
        verificationStatus == VerificationStatus.active;
  }

  /// Rating formateado
  String get formattedRating {
    return rating.toStringAsFixed(1);
  }

  /// Estrellas del rating
  String get ratingStars {
    final fullStars = rating.floor();
    return '⭐' * fullStars;
  }

  LocationMap copyWith({
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
    DateTime? updatedAt,
  }) {
    return LocationMap(
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
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'LocationMap(id: $id, title: $title, status: ${verificationStatus.displayName}, rating: $formattedRating)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocationMap &&
        other.id == id &&
        other.title == title &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode {
    return Object.hash(id, title, latitude, longitude);
  }
}