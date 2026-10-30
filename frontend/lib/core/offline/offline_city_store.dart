import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class OfflineStorage {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> remove(String key);
  Future<Set<String>> keys();
}

class PreferencesOfflineStorage implements OfflineStorage {
  final SharedPreferencesAsync preferences = SharedPreferencesAsync();
  @override
  Future<String?> read(String key) => preferences.getString(key);
  @override
  Future<void> write(String key, String value) => preferences.setString(key, value);
  @override
  Future<void> remove(String key) => preferences.remove(key);
  @override
  Future<Set<String>> keys() => preferences.getKeys();
}

/// Disposable public city data only; never stores authentication or private trips.
class OfflineCityStore {
  static final OfflineStorage _defaultStorage = PreferencesOfflineStorage();
  @visibleForTesting
  static OfflineStorage? storageOverride;
  static OfflineStorage get _storage => storageOverride ?? _defaultStorage;
  static const _prefix = 'travel.offline.v1.city.';
  static const _catalogue = 'travel.offline.v1.catalogue';

  static Future<void> saveCity(String city, List<int> bytes, String expectedHash) async {
    if (bytes.length > 5 * 1024 * 1024) throw const FormatException('Package exceeds 5 MiB');
    final digest = sha256.convert(bytes).toString();
    if (digest != expectedHash.toLowerCase()) throw const FormatException('Package checksum mismatch');
    final payload = utf8.decode(bytes);
    final data = jsonDecode(payload) as Map<String, dynamic>;
    if (data['schema_version'] != 1 || (data['city'] as Map?)?['id'] != city) {
      throw const FormatException('Invalid city package');
    }
    for (final key in ['metro_lines', 'metro_stations', 'bus_routes', 'bus_stops', 'places']) {
      if (data[key] is! List) throw FormatException('Missing $key');
    }
    await _storage.write('$_prefix$city', jsonEncode({'sha256': digest, 'payload': payload}));
  }

  static Future<Map<String, dynamic>?> loadCity(String city) async {
    try {
      final raw = await _storage.read('$_prefix$city');
      if (raw == null) return null;
      final envelope = jsonDecode(raw) as Map<String, dynamic>;
      final payload = envelope['payload'] as String;
      if (sha256.convert(utf8.encode(payload)).toString() != envelope['sha256']) return null;
      final data = jsonDecode(payload) as Map<String, dynamic>;
      if (data['schema_version'] != 1 || (data['city'] as Map?)?['id'] != city) return null;
      return data;
    } catch (_) {
      return null;
    }
  }

  static Future<Set<String>> savedCities() async {
    try {
      final saved = <String>{};
      for (final key in await _storage.keys()) {
        if (!key.startsWith(_prefix)) continue;
        final city = key.substring(_prefix.length);
        if (await loadCity(city) != null) saved.add(city);
      }
      return saved;
    } catch (_) { return {}; }
  }

  static Future<String?> version(String city) async {
    try {
      if (await loadCity(city) == null) return null;
      final raw = await _storage.read('$_prefix$city');
      return (jsonDecode(raw!)['sha256'] as String).substring(0, 16);
    } catch (_) { return null; }
  }

  static Future<void> removeCity(String city) => _storage.remove('$_prefix$city');
  static Future<void> saveCatalogue(List<dynamic> data) => _storage.write(_catalogue, jsonEncode(data));
  static Future<List<dynamic>> catalogue() async {
    try { return jsonDecode(await _storage.read(_catalogue) ?? '[]') as List<dynamic>; }
    catch (_) { return []; }
  }
}
