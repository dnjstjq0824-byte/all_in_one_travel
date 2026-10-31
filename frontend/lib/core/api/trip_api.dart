import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/travel_models.dart';
import 'api_config.dart';

class TripApi {
  static Future<List<Trip>> fetchTrips() async {
    try {
      final resp = await ApiConfig.client
          .get(Uri.parse('${ApiConfig.baseUrl}/trips'))
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
      final resp = await ApiConfig.client
          .post(
            Uri.parse('${ApiConfig.baseUrl}/trips'),
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

  static Future<Trip?> addItineraryItem(String tripId, int dayNumber, ItineraryItem item) async {
    try {
      final resp = await ApiConfig.client
          .post(
            Uri.parse('${ApiConfig.baseUrl}/trips/$tripId/items?day=$dayNumber'),
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

  static Future<Trip?> completeItineraryItem(String tripId, String itemId, bool completed) async {
    try {
      final resp = await ApiConfig.client
          .patch(
            Uri.parse('${ApiConfig.baseUrl}/trips/$tripId/items/$itemId'),
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

  static Future<Trip?> updateItineraryItem(String tripId, String itemId, Map<String, dynamic> fields) =>
      _changeTrip('PATCH', '/trips/$tripId/items/$itemId', fields);

  static Future<Trip?> deleteItineraryItem(String tripId, String itemId) =>
      _changeTrip('DELETE', '/trips/$tripId/items/$itemId', null);

  static Future<Trip?> reorderItineraryItems(String tripId, int day, List<String> ids) =>
      _changeTrip('PUT', '/trips/$tripId/days/$day/order', {'item_ids': ids});

  static Future<Trip?> _changeTrip(String method, String path, Map<String, dynamic>? fields) async {
    try {
      final request = http.Request(method, Uri.parse('${ApiConfig.baseUrl}$path'));
      if (fields != null) {
        request.headers['Content-Type'] = 'application/json';
        request.body = jsonEncode(fields);
      }
      final response = await http.Response.fromStream(
        await ApiConfig.client.send(request).timeout(const Duration(seconds: 4)),
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
      final response = await ApiConfig.client
          .delete(Uri.parse('${ApiConfig.baseUrl}/trips/$tripId'))
          .timeout(const Duration(seconds: 4));
      return response.statusCode == 204;
    } catch (e) {
      debugPrint('[API] deleteTrip error: $e');
      return false;
    }
  }
}

