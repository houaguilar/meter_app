import '../../../domain/entities/entities.dart';

class ProjectModel {
  final String id;
  final String userId;
  final String name;
  final String? uuid;

  ProjectModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.uuid,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      uuid: json['uuid'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'uuid': uuid,
    };
  }

  Project toDomain() {
    return Project(
      userId: userId,
      name: name,
      uuid: id,
    );
  }

  factory ProjectModel.fromDomain(Project project) {
    return ProjectModel(
      id: project.uuid ?? '',
      userId: project.userId ?? '',
      name: project.name,
      uuid: project.uuid,
    );
  }
}

extension ProjectMapper on Project {
  ProjectModel toModel(String userId) {
    return ProjectModel(
      id: uuid ?? '',
      userId: userId,
      name: name,
      uuid: uuid,
    );
  }
}
