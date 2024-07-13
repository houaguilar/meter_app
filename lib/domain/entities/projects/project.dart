
import 'package:isar/isar.dart';
import 'package:meter_app/domain/entities/entities.dart';
import 'package:uuid/uuid.dart';

part 'project.g.dart';

@collection
class Project {
  Id id = Isar.autoIncrement;

  @Index()
  final String? userId;

  @Index(unique: true, name: 'name')
  final String name;

  @Index(unique: true, name: 'uuid')
  final String? uuid;

  @Backlink(to: 'project')
  final IsarLinks<Metrado> metrados = IsarLinks<Metrado>();

  Project({
    this.userId,
    required this.name,
    String? uuid,
  }): uuid = uuid ?? const Uuid().v4();

  Project copyWith({String? userId, String? name, String? uuid}) {
    return Project(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      uuid: uuid ?? this.uuid,
    )..id = id;
  }
}