import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/travel_models.dart';
import '../offline/offline_city_store.dart';
import 'api_config.dart';

class PlaceApi {
  static Future<List<Place>> fetchPlaces(
    String cityId, {
    String? query,
    String? category,
  }) async {
    try {
      final qParam = query != null ? '&q=$query' : '';
      final cParam = category != null ? '&category=$category' : '';
      final resp = await ApiConfig.client
          .get(Uri.parse('${ApiConfig.baseUrl}/places?city_id=$cityId$qParam$cParam'))
          .timeout(const Duration(seconds: 4));
      if (resp.statusCode == 200) {
        final List list = jsonDecode(utf8.decode(resp.bodyBytes));
        return list.map((e) => Place.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('[API] fetchPlaces fallback: $e');
    }
    final data = await OfflineCityStore.loadCity(cityId);
    final rawPlaces = ((data?['places'] as List?) ?? [])
        .map((v) => Place.fromJson(Map<String, dynamic>.from(v as Map)))
        .toList();
    final search = (query ?? '').toLowerCase();
    return rawPlaces.where((place) =>
        (category == null || category.isEmpty || place.category.toLowerCase() == category.toLowerCase()) &&
        (search.isEmpty || '${place.name} ${place.englishName} ${place.description}'.toLowerCase().contains(search))
    ).toList();
  }

  static Future<List<Review>> fetchReviews(String placeId) async {
    try {
      final resp = await ApiConfig.client
          .get(Uri.parse('${ApiConfig.baseUrl}/places/$placeId/reviews'))
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
      final resp = await ApiConfig.client
          .post(
            Uri.parse('${ApiConfig.baseUrl}/places/$placeId/reviews'),
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
}

