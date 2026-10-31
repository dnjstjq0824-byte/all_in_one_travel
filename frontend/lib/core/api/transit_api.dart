import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/travel_models.dart';
import '../offline/offline_city_store.dart';
import 'api_config.dart';

class TransitApi {
  static Future<List<T>> _offlineList<T>(
    String city,
    String key,
    T Function(Map<String, dynamic>) parse,
  ) async {
    final data = await OfflineCityStore.loadCity(city);
    return ((data?[key] as List?) ?? [])
        .map((value) => parse(Map<String, dynamic>.from(value as Map)))
        .toList();
  }

  static Future<List<MetroLine>> fetchMetroLines(String cityId) async {
    try {
      final resp = await ApiConfig.client
          .get(Uri.parse('${ApiConfig.baseUrl}/transit/lines?city_id=$cityId'))
          .timeout(const Duration(seconds: 4));
      if (resp.statusCode == 200) {
        final List list = jsonDecode(utf8.decode(resp.bodyBytes));
        return list.map((e) => MetroLine.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('[API] fetchMetroLines fallback: $e');
    }
    return _offlineList(cityId, 'metro_lines', MetroLine.fromJson);
  }

  static Future<List<MetroStation>> fetchMetroStations(String cityId) async {
    try {
      final resp = await ApiConfig.client
          .get(Uri.parse('${ApiConfig.baseUrl}/transit/stations?city_id=$cityId'))
          .timeout(const Duration(seconds: 4));
      if (resp.statusCode == 200) {
        final List list = jsonDecode(utf8.decode(resp.bodyBytes));
        return list.map((e) => MetroStation.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('[API] fetchMetroStations fallback: $e');
    }
    return _offlineList(cityId, 'metro_stations', MetroStation.fromJson);
  }

  static Future<List<BusRoute>> fetchBusRoutes(String cityId) async {
    try {
      final resp = await ApiConfig.client
          .get(Uri.parse('${ApiConfig.baseUrl}/transit/bus/routes?city_id=$cityId'))
          .timeout(const Duration(seconds: 4));
      if (resp.statusCode == 200) {
        final List list = jsonDecode(utf8.decode(resp.bodyBytes));
        return list.map((e) => BusRoute.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('[API] fetchBusRoutes fallback: $e');
    }
    return _offlineList(cityId, 'bus_routes', BusRoute.fromJson);
  }

  static Future<List<BusStop>> fetchBusStops(String cityId) async {
    try {
      final resp = await ApiConfig.client
          .get(Uri.parse('${ApiConfig.baseUrl}/transit/bus/stops?city_id=$cityId'))
          .timeout(const Duration(seconds: 4));
      if (resp.statusCode == 200) {
        final List list = jsonDecode(utf8.decode(resp.bodyBytes));
        return list.map((e) => BusStop.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('[API] fetchBusStops fallback: $e');
    }
    return _offlineList(cityId, 'bus_stops', BusStop.fromJson);
  }

  static Future<List<RealtimeArrival>> fetchRealtimeArrivals(String stopId) async {
    try {
      final resp = await ApiConfig.client
          .get(Uri.parse('${ApiConfig.baseUrl}/transit/arrivals?stop_id=$stopId'))
          .timeout(const Duration(seconds: 4));
      if (resp.statusCode == 200) {
        final List list = jsonDecode(utf8.decode(resp.bodyBytes));
        return list.map((e) => RealtimeArrival.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('[API] fetchRealtimeArrivals fallback: $e');
    }
    return [];
  }

  static Future<List<RouteOption>> planTransit({
    required String cityId,
    required double originLat,
    required double originLng,
    required String originName,
    required double destLat,
    required double destLng,
    required String destName,
    String preference = 'fastest',
  }) async {
    try {
      final body = jsonEncode({
        'city_id': cityId,
        'origin_lat': originLat,
        'origin_lng': originLng,
        'origin_name': originName,
        'dest_lat': destLat,
        'dest_lng': destLng,
        'dest_name': destName,
        'preference': preference,
      });
      final resp = await ApiConfig.client
          .post(
            Uri.parse('${ApiConfig.baseUrl}/transit/plan'),
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(const Duration(seconds: 4));
      if (resp.statusCode == 200) {
        final data = jsonDecode(utf8.decode(resp.bodyBytes));
        final List list = data['options'] ?? [];
        return list.map((e) => RouteOption.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('[API] planTransit fallback: $e');
    }
    return [];
  }
}

