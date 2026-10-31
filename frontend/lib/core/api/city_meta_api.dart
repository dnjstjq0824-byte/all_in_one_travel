import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/travel_models.dart';
import '../offline/offline_city_store.dart';
import 'api_config.dart';

class CityMetaApi {
  static Future<List<City>> fetchCities({String? country}) async {
    try {
      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/cities${country != null ? '?country=$country' : ''}',
      );
      final resp = await ApiConfig.client.get(uri).timeout(const Duration(seconds: 4));
      if (resp.statusCode == 200) {
        final List list = jsonDecode(utf8.decode(resp.bodyBytes));
        return list.map((e) => City.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('[API] fetchCities error: $e');
    }
    return [];
  }

  static Future<CoverageRegistry?> fetchCoverage(String cityId) async {
    try {
      final resp = await ApiConfig.client
          .get(Uri.parse('${ApiConfig.baseUrl}/cities/$cityId/coverage'))
          .timeout(const Duration(seconds: 4));
      if (resp.statusCode == 200) {
        return CoverageRegistry.fromJson(jsonDecode(utf8.decode(resp.bodyBytes)));
      }
    } catch (e) {
      debugPrint('[API] fetchCoverage fallback: $e');
    }
    final data = await OfflineCityStore.loadCity(cityId);
    return data?['coverage'] == null ? null : CoverageRegistry.fromJson(data!['coverage']);
  }

  static Future<WeatherReport?> fetchWeather(String cityId) async {
    try {
      final resp = await ApiConfig.client
          .get(Uri.parse('${ApiConfig.baseUrl}/weather?city_id=$cityId'))
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

  static Future<List<OfflinePackage>> fetchOfflinePackages() async {
    try {
      final resp = await ApiConfig.client
          .get(Uri.parse('${ApiConfig.baseUrl}/offline/packages'))
          .timeout(const Duration(seconds: 4));
      if (resp.statusCode == 200) {
        final List list = jsonDecode(utf8.decode(resp.bodyBytes));
        try {
          await OfflineCityStore.saveCatalogue(list);
        } catch (_) {}
        return list.map((e) => OfflinePackage.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('[API] fetchOfflinePackages fallback: $e');
    }
    return (await OfflineCityStore.catalogue()).map((e) => OfflinePackage.fromJson(e)).toList();
  }

  static Future<void> downloadOfflinePackage(String cityId) async {
    final response = await ApiConfig.client
        .get(Uri.parse('${ApiConfig.baseUrl}/offline/packages/${Uri.encodeComponent(cityId)}'))
        .timeout(const Duration(seconds: 15));
    final checksum = response.headers['x-content-sha256'];
    if (response.statusCode != 200 || checksum == null) {
      throw const FormatException('Package download failed');
    }
    await OfflineCityStore.saveCity(cityId, response.bodyBytes, checksum);
  }

  static Future<ExchangeRateResponse?> fetchExchangeRates() async {
    try {
      final resp = await ApiConfig.client
          .get(Uri.parse('${ApiConfig.baseUrl}/exchange-rates'))
          .timeout(const Duration(seconds: 4));
      if (resp.statusCode == 200) {
        return ExchangeRateResponse.fromJson(jsonDecode(utf8.decode(resp.bodyBytes)));
      }
      if (resp.statusCode == 503) {
        final err = jsonDecode(utf8.decode(resp.bodyBytes));
        debugPrint('[API] Exchange rates unconfigured: ${err['error']?['message']}');
      }
    } catch (e) {
      debugPrint('[API] fetchExchangeRates error: $e');
    }
    return null;
  }

  static Future<EmergencyContact?> fetchEmergency(String cityId) async {
    try {
      final resp = await ApiConfig.client
          .get(Uri.parse('${ApiConfig.baseUrl}/emergency?city_id=$cityId'))
          .timeout(const Duration(seconds: 4));
      if (resp.statusCode == 200) {
        return EmergencyContact.fromJson(jsonDecode(utf8.decode(resp.bodyBytes)));
      }
    } catch (e) {
      debugPrint('[API] fetchEmergency error: $e');
    }
    return null;
  }
}

