import 'package:isar/isar.dart';

part 'key_value.g.dart';

@collection
class KeyValue {
  Id isarId = Isar.autoIncrement; // ID de Isar como entero seguro

  @Index(unique: true)
  late String key;
  late String value;

  KeyValue({required this.key, required this.value});
}
