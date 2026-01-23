// lib/domain/entities/notifications/notification_settings.dart

/// Entity que representa las preferencias de notificaciones del usuario
class NotificationSettings {
  /// Notificaciones generales habilitadas
  final bool generalEnabled;

  /// Notificaciones de actualizaciones de la app
  final bool updatesEnabled;

  /// Notificaciones de proyectos
  final bool projectsEnabled;

  /// Notificaciones de artículos y contenido
  final bool articlesEnabled;

  /// Notificaciones de ubicación (tiendas cercanas, etc.)
  final bool locationEnabled;

  /// Permiso del sistema otorgado
  final bool systemPermissionGranted;

  /// Token FCM del dispositivo
  final String? fcmToken;

  const NotificationSettings({
    this.generalEnabled = false,
    this.updatesEnabled = false,
    this.projectsEnabled = false,
    this.articlesEnabled = false,
    this.locationEnabled = false,
    this.systemPermissionGranted = false,
    this.fcmToken,
  });

  /// Retorna true si al menos una categoría de notificaciones está habilitada
  bool get hasAnyEnabled =>
      generalEnabled ||
      updatesEnabled ||
      projectsEnabled ||
      articlesEnabled ||
      locationEnabled;

  /// Copia con modificaciones
  NotificationSettings copyWith({
    bool? generalEnabled,
    bool? updatesEnabled,
    bool? projectsEnabled,
    bool? articlesEnabled,
    bool? locationEnabled,
    bool? systemPermissionGranted,
    String? fcmToken,
  }) {
    return NotificationSettings(
      generalEnabled: generalEnabled ?? this.generalEnabled,
      updatesEnabled: updatesEnabled ?? this.updatesEnabled,
      projectsEnabled: projectsEnabled ?? this.projectsEnabled,
      articlesEnabled: articlesEnabled ?? this.articlesEnabled,
      locationEnabled: locationEnabled ?? this.locationEnabled,
      systemPermissionGranted:
          systemPermissionGranted ?? this.systemPermissionGranted,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }

  /// Convierte a Map para persistencia
  Map<String, dynamic> toJson() {
    return {
      'generalEnabled': generalEnabled,
      'updatesEnabled': updatesEnabled,
      'projectsEnabled': projectsEnabled,
      'articlesEnabled': articlesEnabled,
      'locationEnabled': locationEnabled,
      'systemPermissionGranted': systemPermissionGranted,
      'fcmToken': fcmToken,
    };
  }

  /// Crea desde Map para persistencia
  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      generalEnabled: json['generalEnabled'] as bool? ?? false,
      updatesEnabled: json['updatesEnabled'] as bool? ?? false,
      projectsEnabled: json['projectsEnabled'] as bool? ?? false,
      articlesEnabled: json['articlesEnabled'] as bool? ?? false,
      locationEnabled: json['locationEnabled'] as bool? ?? false,
      systemPermissionGranted:
          json['systemPermissionGranted'] as bool? ?? false,
      fcmToken: json['fcmToken'] as String?,
    );
  }

  @override
  String toString() {
    return 'NotificationSettings(general: $generalEnabled, updates: $updatesEnabled, '
        'projects: $projectsEnabled, articles: $articlesEnabled, '
        'location: $locationEnabled, permission: $systemPermissionGranted, '
        'token: ${fcmToken?.substring(0, 10)}...)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NotificationSettings &&
        other.generalEnabled == generalEnabled &&
        other.updatesEnabled == updatesEnabled &&
        other.projectsEnabled == projectsEnabled &&
        other.articlesEnabled == articlesEnabled &&
        other.locationEnabled == locationEnabled &&
        other.systemPermissionGranted == systemPermissionGranted &&
        other.fcmToken == fcmToken;
  }

  @override
  int get hashCode {
    return generalEnabled.hashCode ^
        updatesEnabled.hashCode ^
        projectsEnabled.hashCode ^
        articlesEnabled.hashCode ^
        locationEnabled.hashCode ^
        systemPermissionGranted.hashCode ^
        fcmToken.hashCode;
  }
}
