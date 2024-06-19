import 'package:isar/isar.dart';

import '../../entities.dart';

part 'metrado.g.dart';


@collection
class Metrado {
  Id id = Isar.autoIncrement;
  late final String name;

  @Index()
  final int projectId;

  final IsarLink<Project> project = IsarLink<Project>();

  @Backlink(to: 'metrado')
  final IsarLinks<Ladrillo> ladrilloLink = IsarLinks<Ladrillo>();

  @Backlink(to: 'metrado')
  final IsarLinks<Bloqueta> bloquetaLink = IsarLinks<Bloqueta>();

  @Backlink(to: 'metrado')
  final IsarLinks<Piso> pisoLink = IsarLinks<Piso>();

  Metrado({
    required this.name,
    required this.projectId,
  });

  Metrado copyWith({
    String? name,
  }) {
    return Metrado(
      name: name ?? this.name,
      projectId: projectId,
    )..id = id;
  }
}