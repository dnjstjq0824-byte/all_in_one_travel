import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/travel_models.dart';
import 'api_config.dart';
import 'city_meta_api.dart';
import 'place_api.dart';
import 'transit_api.dart';
import 'trip_api.dart';

class TravelApiClient {
  static String? get customBaseUrl => ApiConfig.customBaseUrl;
  static set customBaseUrl(String? val) => ApiConfig.customBaseUrl = val;

  static String get baseUrl => ApiConfig.baseUrl;

  @visibleForTesting
  static http.Client? get clientOverride => ApiConfig.clientOverride;
  static set clientOverride(http.Client? client) => ApiConfig.clientOverride = client;

  // City & Meta APIs
  static Future<List<City>> fetchCities({String? country}) =>
      CityMetaApi.fetchCities(country: country);

  static Future<CoverageRegistry?> fetchCoverage(String cityId) =>
      CityMetaApi.fetchCoverage(cityId);

  static Future<WeatherReport?> fetchWeather(String cityId) =>
      CityMetaApi.fetchWeather(cityId);

  static Future<List<OfflinePackage>> fetchOfflinePackages() =>
      CityMetaApi.fetchOfflinePackages();

  static Future<void> downloadOfflinePackage(String cityId) =>
      CityMetaApi.downloadOfflinePackage(cityId);

  static Future<ExchangeRateResponse?> fetchExchangeRates() =>
      CityMetaApi.fetchExchangeRates();

  static Future<EmergencyContact?> fetchEmergency(String cityId) =>
      CityMetaApi.fetchEmergency(cityId);

  // Transit APIs
  static Future<List<MetroLine>> fetchMetroLines(String cityId) =>
      TransitApi.fetchMetroLines(cityId);

  static Future<List<MetroStation>> fetchMetroStations(String cityId) =>
      TransitApi.fetchMetroStations(cityId);

  static Future<List<BusRoute>> fetchBusRoutes(String cityId) =>
      TransitApi.fetchBusRoutes(cityId);

  static Future<List<BusStop>> fetchBusStops(String cityId) =>
      TransitApi.fetchBusStops(cityId);

  static Future<List<RealtimeArrival>> fetchRealtimeArrivals(String stopId) =>
      TransitApi.fetchRealtimeArrivals(stopId);

  static Future<List<RouteOption>> planTransit({
    required String cityId,
    required double originLat,
    required double originLng,
    required String originName,
    required double destLat,
    required double destLng,
    required String destName,
    String preference = 'fastest',
  }) => TransitApi.planTransit(
        cityId: cityId,
        originLat: originLat,
        originLng: originLng,
        originName: originName,
        destLat: destLat,
        destLng: destLng,
        destName: destName,
        preference: preference,
      );

  // Place APIs
  static Future<List<Place>> fetchPlaces(
    String cityId, {
    String? query,
    String? category,
  }) => PlaceApi.fetchPlaces(cityId, query: query, category: category);

  static Future<List<Review>> fetchReviews(String placeId) =>
      PlaceApi.fetchReviews(placeId);

  static Future<Review?> submitReview(String placeId, Review review) =>
      PlaceApi.submitReview(placeId, review);

  // Trip APIs
  static Future<List<Trip>> fetchTrips() => TripApi.fetchTrips();

  static Future<Trip?> createTrip(Trip trip) => TripApi.createTrip(trip);

  static Future<Trip?> addItineraryItem(String tripId, int dayNumber, ItineraryItem item) =>
      TripApi.addItineraryItem(tripId, dayNumber, item);

  static Future<Trip?> completeItineraryItem(String tripId, String itemId, bool completed) =>
      TripApi.completeItineraryItem(tripId, itemId, completed);

  static Future<Trip?> updateTrip(String tripId, Map<String, dynamic> fields) =>
      TripApi.updateTrip(tripId, fields);

  static Future<Trip?> updateItineraryItem(String tripId, String itemId, Map<String, dynamic> fields) =>
      TripApi.updateItineraryItem(tripId, itemId, fields);

  static Future<Trip?> deleteItineraryItem(String tripId, String itemId) =>
      TripApi.deleteItineraryItem(tripId, itemId);

  static Future<Trip?> reorderItineraryItems(String tripId, int day, List<String> ids) =>
      TripApi.reorderItineraryItems(tripId, day, ids);

  static Future<bool> deleteTrip(String tripId) => TripApi.deleteTrip(tripId);
}
