
import 'package:isar/isar.dart';
import 'package:meter_app/domain/entities/entities.dart';
import 'package:uuid/uuid.dart';

part 'project.g.dart';

@collection
class Project {
  Id id = Isar.autoIncrement;

  @Index(unique: true, name: 'uuid')
  final String uuid;

  @Index(unique: true, name: 'name')
  final String name;

  @Backlink(to: 'project')
  final IsarLinks<Metrado> metrados = IsarLinks<Metrado>();

  Project({
    required this.name
  }): uuid = const Uuid().v4();

  Project copyWith({String? name}) {
    return Project(
      name: name ?? this.name,
    )..id = id;
  }
}