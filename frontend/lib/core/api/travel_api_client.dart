import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/travel_models.dart';

class TravelApiClient {
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8080/api/v1';
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8080/api/v1';
    }
    return 'http://localhost:8080/api/v1';
  }

  static final http.Client _client = http.Client();

  static Future<List<City>> fetchCities({String? country}) async {
    try {
      final uri = Uri.parse('$baseUrl/cities${country != null ? '?country=$country' : ''}');
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
      final resp = await _client.get(Uri.parse('$baseUrl/cities/$cityId/coverage')).timeout(const Duration(seconds: 4));
      if (resp.statusCode == 200) {
        return CoverageRegistry.fromJson(jsonDecode(utf8.decode(resp.bodyBytes)));
      }
    } catch (e) {
      debugPrint('[API] fetchCoverage fallback: $e');
    }
    return null;
  }

  static Future<List<MetroLine>> fetchMetroLines(String cityId) async {
    try {
      final resp = await _client.get(Uri.parse('$baseUrl/transit/lines?city_id=$cityId')).timeout(const Duration(seconds: 4));
      if (resp.statusCode == 200) {
        final List list = jsonDecode(utf8.decode(resp.bodyBytes));
        return list.map((e) => MetroLine.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('[API] fetchMetroLines fallback: $e');
    }
    return [];
  }

  static Future<List<MetroStation>> fetchMetroStations(String cityId) async {
    try {
      final resp = await _client.get(Uri.parse('$baseUrl/transit/stations?city_id=$cityId')).timeout(const Duration(seconds: 4));
      if (resp.statusCode == 200) {
        final List list = jsonDecode(utf8.decode(resp.bodyBytes));
        return list.map((e) => MetroStation.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('[API] fetchMetroStations fallback: $e');
    }
    return [];
  }

  static Future<List<BusRoute>> fetchBusRoutes(String cityId) async {
    try {
      final resp = await _client.get(Uri.parse('$baseUrl/transit/bus/routes?city_id=$cityId')).timeout(const Duration(seconds: 4));
      if (resp.statusCode == 200) {
        final List list = jsonDecode(utf8.decode(resp.bodyBytes));
        return list.map((e) => BusRoute.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('[API] fetchBusRoutes fallback: $e');
    }
    return [];
  }

  static Future<List<BusStop>> fetchBusStops(String cityId) async {
    try {
      final resp = await _client.get(Uri.parse('$baseUrl/transit/bus/stops?city_id=$cityId')).timeout(const Duration(seconds: 4));
      if (resp.statusCode == 200) {
        final List list = jsonDecode(utf8.decode(resp.bodyBytes));
        return list.map((e) => BusStop.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('[API] fetchBusStops fallback: $e');
    }
    return [];
  }

  static Future<List<RealtimeArrival>> fetchRealtimeArrivals(String stopId) async {
    try {
      final resp = await _client.get(Uri.parse('$baseUrl/transit/arrivals?stop_id=$stopId')).timeout(const Duration(seconds: 4));
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
      final resp = await _client.post(
        Uri.parse('$baseUrl/transit/plan'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      ).timeout(const Duration(seconds: 4));
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

  static Future<List<Place>> fetchPlaces(String cityId, {String? query, String? category}) async {
    try {
      final qParam = query != null ? '&q=$query' : '';
      final cParam = category != null ? '&category=$category' : '';
      final resp = await _client.get(Uri.parse('$baseUrl/places?city_id=$cityId$qParam$cParam')).timeout(const Duration(seconds: 4));
      if (resp.statusCode == 200) {
        final List list = jsonDecode(utf8.decode(resp.bodyBytes));
        return list.map((e) => Place.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('[API] fetchPlaces fallback: $e');
    }
    return [];
  }

  static Future<List<Review>> fetchReviews(String placeId) async {
    try {
      final resp = await _client.get(Uri.parse('$baseUrl/places/$placeId/reviews')).timeout(const Duration(seconds: 4));
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
      final resp = await _client.post(
        Uri.parse('$baseUrl/places/$placeId/reviews'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      ).timeout(const Duration(seconds: 4));
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
      final resp = await _client.get(Uri.parse('$baseUrl/weather?city_id=$cityId')).timeout(const Duration(seconds: 4));
      if (resp.statusCode == 200) {
        return WeatherReport.fromJson(jsonDecode(utf8.decode(resp.bodyBytes)));
      }
    } catch (e) {
      debugPrint('[API] fetchWeather fallback: $e');
    }
    return null;
  }

  static Future<List<Trip>> fetchTrips() async {
    try {
      final resp = await _client.get(Uri.parse('$baseUrl/trips')).timeout(const Duration(seconds: 4));
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
      final resp = await _client.post(
        Uri.parse('$baseUrl/trips'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      ).timeout(const Duration(seconds: 4));
      if (resp.statusCode == 201) {
        return Trip.fromJson(jsonDecode(utf8.decode(resp.bodyBytes)));
      }
    } catch (e) {
      debugPrint('[API] createTrip error: $e');
    }
    return null;
  }

  static Future<Trip?> addItineraryItem(String tripId, int dayNumber, ItineraryItem item) async {
    try {
      final resp = await _client.post(
        Uri.parse('$baseUrl/trips/$tripId/items?day=$dayNumber'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(item.toJson()),
      ).timeout(const Duration(seconds: 4));
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
      final resp = await _client.get(Uri.parse('$baseUrl/offline/packages')).timeout(const Duration(seconds: 4));
      if (resp.statusCode == 200) {
        final List list = jsonDecode(utf8.decode(resp.bodyBytes));
        return list.map((e) => OfflinePackage.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('[API] fetchOfflinePackages fallback: $e');
    }
    return [];
  }

  static List<City> _getFallbackCities() {
    return [
      City(
        id: 'seoul', countryCode: 'KR', name: 'Seoul', englishName: 'Seoul', localName: '서울',
        latitude: 37.5665, longitude: 126.9780, timezone: 'Asia/Seoul',
        coverageLevel: 'LEVEL_A', transportModes: ['METRO', 'BUS', 'WALK'],
        description: 'South Korea high-tech capital.',
        heroImageUrl: 'https://images.unsplash.com/photo-1538485399081-7191377e8241?auto=format&fit=crop&w=1200&q=80',
      ),
      City(
        id: 'tokyo', countryCode: 'JP', name: 'Tokyo', englishName: 'Tokyo', localName: '東京',
        latitude: 35.6762, longitude: 139.6503, timezone: 'Asia/Tokyo',
        coverageLevel: 'LEVEL_A', transportModes: ['METRO', 'BUS', 'WALK'],
        description: 'World populous capital with punctual transit.',
        heroImageUrl: 'https://images.unsplash.com/photo-1503899036084-c55cdd92da26?auto=format&fit=crop&w=1200&q=80',
      ),
    ];
  }
}
