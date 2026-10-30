import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/travel_models.dart';
import '../offline/offline_city_store.dart';

class TravelApiClient {
  static String? customBaseUrl;

  static String get baseUrl {
    if (customBaseUrl != null && customBaseUrl!.isNotEmpty) {
      return customBaseUrl!;
    }
    const envBaseUrl = String.fromEnvironment('API_BASE_URL');
    if (envBaseUrl.isNotEmpty) {
      return envBaseUrl;
    }
    if (kIsWeb) {
      // In web, dynamically resolve from current window origin
      final origin = Uri.base.origin;
      return '$origin/api/v1';
    }
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8080/api/v1';
    }
    return 'http://localhost:8080/api/v1';
  }

  static final http.Client _defaultClient = http.Client();
  @visibleForTesting
  static http.Client? clientOverride;
  static http.Client get _client => clientOverride ?? _defaultClient;

  static Future<List<T>> _offlineList<T>(String city, String key, T Function(Map<String, dynamic>) parse) async {
    final data = await OfflineCityStore.loadCity(city);
    return ((data?[key] as List?) ?? []).map((value) => parse(Map<String, dynamic>.from(value as Map))).toList();
  }

  static Future<void> downloadOfflinePackage(String cityId) async {
    final response = await _client.get(Uri.parse('$baseUrl/offline/packages/${Uri.encodeComponent(cityId)}')).timeout(const Duration(seconds: 15));
    final checksum = response.headers['x-content-sha256'];
    if (response.statusCode != 200 || checksum == null) throw const FormatException('Package download failed');
    await OfflineCityStore.saveCity(cityId, response.bodyBytes, checksum);
  }

  static Future<List<City>> fetchCities({String? country}) async {
    try {
      final uri = Uri.parse(
        '$baseUrl/cities${country != null ? '?country=$country' : ''}',
      );
      final resp = await _client.get(uri).timeout(const Duration(seconds: 4));
      if (resp.statusCode == 200) {
        final List list = jsonDecode(utf8.decode(resp.bodyBytes));
        return list.map((e) => City.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('[API] fetchCities fallback: $e');
    }
    return _getFallbackCities();
  }

  static Future<CoverageRegistry?> fetchCoverage(String cityId) async {
    try {
      final resp = await _client
          .get(Uri.parse('$baseUrl/cities/$cityId/coverage'))
          .timeout(const Duration(seconds: 4));
      if (resp.statusCode == 200) {
        return CoverageRegistry.fromJson(
          jsonDecode(utf8.decode(resp.bodyBytes)),
        );
      }
    } catch (e) {
      debugPrint('[API] fetchCoverage fallback: $e');
    }
    final data = await OfflineCityStore.loadCity(cityId);
    return data?['coverage'] == null ? null : CoverageRegistry.fromJson(data!['coverage']);
  }

  static Future<List<MetroLine>> fetchMetroLines(String cityId) async {
    try {
      final resp = await _client
          .get(Uri.parse('$baseUrl/transit/lines?city_id=$cityId'))
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
      final resp = await _client
          .get(Uri.parse('$baseUrl/transit/stations?city_id=$cityId'))
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
      final resp = await _client
          .get(Uri.parse('$baseUrl/transit/bus/routes?city_id=$cityId'))
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
      final resp = await _client
          .get(Uri.parse('$baseUrl/transit/bus/stops?city_id=$cityId'))
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

  static Future<List<RealtimeArrival>> fetchRealtimeArrivals(
    String stopId,
  ) async {
    try {
      final resp = await _client
          .get(Uri.parse('$baseUrl/transit/arrivals?stop_id=$stopId'))
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
      final resp = await _client
          .post(
            Uri.parse('$baseUrl/transit/plan'),
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

  static Future<List<Place>> fetchPlaces(
    String cityId, {
    String? query,
    String? category,
  }) async {
    try {
      final qParam = query != null ? '&q=$query' : '';
      final cParam = category != null ? '&category=$category' : '';
      final resp = await _client
          .get(Uri.parse('$baseUrl/places?city_id=$cityId$qParam$cParam'))
          .timeout(const Duration(seconds: 4));
      if (resp.statusCode == 200) {
        final List list = jsonDecode(utf8.decode(resp.bodyBytes));
        return list.map((e) => Place.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('[API] fetchPlaces fallback: $e');
    }
    final places = await _offlineList(cityId, 'places', Place.fromJson);
    final search = (query ?? '').toLowerCase();
    return places.where((place) => (category == null || category.isEmpty || place.category.toLowerCase() == category.toLowerCase()) && (search.isEmpty || '${place.name} ${place.englishName} ${place.description}'.toLowerCase().contains(search))).toList();
  }

  static Future<List<Review>> fetchReviews(String placeId) async {
    try {
      final resp = await _client
          .get(Uri.parse('$baseUrl/places/$placeId/reviews'))
          .timeout(const Duration(seconds: 4));
      if (resp.statusCode == 200) {
        final List list = jsonDecode(utf8.decode(resp.bodyBytes));
        return list.map((e) => Review.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('[API] fetchReviews fallback: $e');
    }
    return [];
  }

  static Future<Review?> submitReview(String placeId, Review review) async {
    try {
      final body = jsonEncode({
        'author_name': review.authorName,
        'rating': review.rating,
        'title': review.title,
        'content': review.content,
        'visit_period': review.visitPeriod,
        'travel_type': review.travelType,
        'visit_tip': review.visitTip,
        'language': review.language,
      });
      final resp = await _client
          .post(
            Uri.parse('$baseUrl/places/$placeId/reviews'),
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(const Duration(seconds: 4));
      if (resp.statusCode == 201) {
        return Review.fromJson(jsonDecode(utf8.decode(resp.bodyBytes)));
      }
    } catch (e) {
      debugPrint('[API] submitReview error: $e');
    }
    return null;
  }

  static Future<WeatherReport?> fetchWeather(String cityId) async {
    try {
      final resp = await _client
          .get(Uri.parse('$baseUrl/weather?city_id=$cityId'))
          .timeout(const Duration(seconds: 4));
      if (resp.statusCode == 200) {
        return WeatherReport.fromJson(jsonDecode(utf8.decode(resp.bodyBytes)));
      }
    } catch (e) {
      debugPrint('[API] fetchWeather fallback: $e');
    }
    final data = await OfflineCityStore.loadCity(cityId);
    return data?['weather'] == null ? null : WeatherReport.fromJson(data!['weather']);
  }

  static Future<List<Trip>> fetchTrips() async {
    try {
      final resp = await _client
          .get(Uri.parse('$baseUrl/trips'))
          .timeout(const Duration(seconds: 4));
      if (resp.statusCode == 200) {
        final List list = jsonDecode(utf8.decode(resp.bodyBytes));
        return list.map((e) => Trip.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('[API] fetchTrips fallback: $e');
    }
    return [];
  }

  static Future<Trip?> createTrip(Trip trip) async {
    try {
      final body = jsonEncode({
        'title': trip.title,
        'country_code': trip.countryCode,
        'city_id': trip.cityId,
        'city_name': trip.cityName,
        'start_date': trip.startDate,
        'end_date': trip.endDate,
      });
      final resp = await _client
          .post(
            Uri.parse('$baseUrl/trips'),
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(const Duration(seconds: 4));
      if (resp.statusCode == 201) {
        return Trip.fromJson(jsonDecode(utf8.decode(resp.bodyBytes)));
      }
    } catch (e) {
      debugPrint('[API] createTrip error: $e');
    }
    return null;
  }

  static Future<Trip?> addItineraryItem(
    String tripId,
    int dayNumber,
    ItineraryItem item,
  ) async {
    try {
      final resp = await _client
          .post(
            Uri.parse('$baseUrl/trips/$tripId/items?day=$dayNumber'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(item.toJson()),
          )
          .timeout(const Duration(seconds: 4));
      if (resp.statusCode == 200) {
        return Trip.fromJson(jsonDecode(utf8.decode(resp.bodyBytes)));
      }
    } catch (e) {
      debugPrint('[API] addItineraryItem error: $e');
    }
    return null;
  }

  static Future<List<OfflinePackage>> fetchOfflinePackages() async {
    try {
      final resp = await _client
          .get(Uri.parse('$baseUrl/offline/packages'))
          .timeout(const Duration(seconds: 4));
      if (resp.statusCode == 200) {
        final List list = jsonDecode(utf8.decode(resp.bodyBytes));
        try { await OfflineCityStore.saveCatalogue(list); } catch (_) { /* Public cache can be retried later. */ }
        return list.map((e) => OfflinePackage.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('[API] fetchOfflinePackages fallback: $e');
    }
    return (await OfflineCityStore.catalogue()).map((e) => OfflinePackage.fromJson(e)).toList();
  }

  static Future<Trip?> completeItineraryItem(
    String tripId,
    String itemId,
    bool completed,
  ) async {
    try {
      final resp = await _client
          .patch(
            Uri.parse('$baseUrl/trips/$tripId/items/$itemId'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'is_completed': completed}),
          )
          .timeout(const Duration(seconds: 4));
      if (resp.statusCode == 200) {
        return Trip.fromJson(jsonDecode(utf8.decode(resp.bodyBytes)));
      }
    } catch (e) {
      debugPrint('[API] completeItineraryItem error: $e');
    }
    return null;
  }

  static Future<Trip?> updateTrip(String tripId, Map<String, dynamic> fields) =>
      _changeTrip('PATCH', '/trips/$tripId', fields);

  static Future<Trip?> updateItineraryItem(
    String tripId,
    String itemId,
    Map<String, dynamic> fields,
  ) => _changeTrip('PATCH', '/trips/$tripId/items/$itemId', fields);

  static Future<Trip?> deleteItineraryItem(String tripId, String itemId) =>
      _changeTrip('DELETE', '/trips/$tripId/items/$itemId', null);

  static Future<Trip?> reorderItineraryItems(
    String tripId,
    int day,
    List<String> ids,
  ) => _changeTrip('PUT', '/trips/$tripId/days/$day/order', {'item_ids': ids});

  static Future<Trip?> _changeTrip(
    String method,
    String path,
    Map<String, dynamic>? fields,
  ) async {
    try {
      final request = http.Request(method, Uri.parse('$baseUrl$path'));
      if (fields != null) {
        request.headers['Content-Type'] = 'application/json';
        request.body = jsonEncode(fields);
      }
      final response = await http.Response.fromStream(
        await _client.send(request).timeout(const Duration(seconds: 4)),
      );
      if (response.statusCode == 200) {
        return Trip.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      }
    } catch (e) {
      debugPrint('[API] changeTrip error: $e');
    }
    return null;
  }

  static Future<bool> deleteTrip(String tripId) async {
    try {
      final response = await _client
          .delete(Uri.parse('$baseUrl/trips/$tripId'))
          .timeout(const Duration(seconds: 4));
      return response.statusCode == 204;
    } catch (e) {
      debugPrint('[API] deleteTrip error: $e');
      return false;
    }
  }

  static List<City> _getFallbackCities() {
    return [
      City(
        id: 'seoul',
        countryCode: 'KR',
        name: 'Seoul',
        englishName: 'Seoul',
        localName: '서울',
        latitude: 37.5665,
        longitude: 126.9780,
        timezone: 'Asia/Seoul',
        coverageLevel: 'LEVEL_A',
        transportModes: ['METRO', 'BUS', 'WALK'],
        description: 'South Korea high-tech capital.',
        heroImageUrl: 'https://images.unsplash.com/photo-1538485399081-7191377e8241?auto=format&fit=crop&w=1200&q=80',
      ),
      City(
        id: 'tokyo',
        countryCode: 'JP',
        name: 'Tokyo',
        englishName: 'Tokyo',
        localName: '東京',
        latitude: 35.6762,
        longitude: 139.6503,
        timezone: 'Asia/Tokyo',
        coverageLevel: 'LEVEL_A',
        transportModes: ['METRO', 'BUS', 'WALK'],
        description: 'World populous capital with punctual transit.',
        heroImageUrl: 'https://images.unsplash.com/photo-1503899036084-c55cdd92da26?auto=format&fit=crop&w=1200&q=80',
      ),
    ];
  }
}
