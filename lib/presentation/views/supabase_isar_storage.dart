import 'package:isar/isar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'key_value.dart';

class SupabaseIsarStorage extends LocalStorage {
  final Isar _isar;

  SupabaseIsarStorage(this._isar);

  @override
  Future<void> initialize() async {
    // Ya se inicializó Isar en main.dart
  }

  @override
  Future<void> persistSession(String persistSessionString) async {
    await _isar.writeTxn(() async {
      await _isar.keyValues.put(KeyValue(key: 'session', value: persistSessionString));
    });
  }

  @override
  Future<void> removePersistedSession() async {
    await _isar.writeTxn(() async {
      await _isar.keyValues.filter().keyEqualTo('session').deleteFirst();
    });
  }

  @override
  Future<String?> accessToken() async {
    final keyValue = await _isar.keyValues.filter().keyEqualTo('access_token').findFirst();
    return keyValue?.value;
  }

  @override
  Future<bool> hasAccessToken() async {
    final keyValue = await _isar.keyValues.filter().keyEqualTo('access_token').findFirst();
    return keyValue != null;
  }

  @override
  Future<void> persistAccessToken(String accessToken) async {
    await _isar.writeTxn(() async {
      await _isar.keyValues.put(KeyValue(key: 'access_token', value: accessToken));
    });
  }
}
