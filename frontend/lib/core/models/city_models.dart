// City and Coverage Domain Models

class Country {
  final String code;
  final String name;
  final String continent;

  Country({required this.code, required this.name, required this.continent});

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      continent: json['continent'] ?? '',
    );
  }
}

class City {
  final String id;
  final String countryCode;
  final String name;
  final String englishName;
  final String localName;
  final double latitude;
  final double longitude;
  final String timezone;
  final String coverageLevel;
  final List<String> transportModes;
  final String description;
  final String heroImageUrl;

  City({
    required this.id,
    required this.countryCode,
    required this.name,
    required this.englishName,
    required this.localName,
    required this.latitude,
    required this.longitude,
    required this.timezone,
    required this.coverageLevel,
    required this.transportModes,
    required this.description,
    required this.heroImageUrl,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'] ?? '',
      countryCode: json['country_code'] ?? '',
      name: json['name'] ?? '',
      englishName: json['english_name'] ?? '',
      localName: json['local_name'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      timezone: json['timezone'] ?? '',
      coverageLevel: json['coverage_level'] ?? 'LEVEL_E',
      transportModes:
          (json['transport_modes'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      description: json['description'] ?? '',
      heroImageUrl: json['hero_image_url'] ?? '',
    );
  }
}

class CoverageRegistry {
  final String cityId;
  final String cityName;
  final String coverageLevel;
  final bool metroMapAvailable;
  final bool metroRoutesAvailable;
  final bool busRoutesAvailable;
  final bool scheduleAvailable;
  final bool realtimeAvailable;
  final bool faresAvailable;
  final bool accessibilityAvailable;
  final String officialDataProvider;
  final String dataSourceUrl;
  final String dataLicense;
  final String attribution;
  final String lastSuccessfulSync;
  final int dataFreshnessMinutes;
  final String validationStatus;

  CoverageRegistry({
    required this.cityId,
    required this.cityName,
    required this.coverageLevel,
    required this.metroMapAvailable,
    required this.metroRoutesAvailable,
    required this.busRoutesAvailable,
    required this.scheduleAvailable,
    required this.realtimeAvailable,
    required this.faresAvailable,
    required this.accessibilityAvailable,
    required this.officialDataProvider,
    required this.dataSourceUrl,
    required this.dataLicense,
    required this.attribution,
    required this.lastSuccessfulSync,
    required this.dataFreshnessMinutes,
    required this.validationStatus,
  });

  factory CoverageRegistry.fromJson(Map<String, dynamic> json) {
    return CoverageRegistry(
      cityId: json['city_id'] ?? '',
      cityName: json['city_name'] ?? '',
      coverageLevel: json['coverage_level'] ?? 'LEVEL_E',
      metroMapAvailable: json['metro_map_available'] ?? false,
      metroRoutesAvailable: json['metro_routes_available'] ?? false,
      busRoutesAvailable: json['bus_routes_available'] ?? false,
      scheduleAvailable: json['schedule_available'] ?? false,
      realtimeAvailable: json['realtime_available'] ?? false,
      faresAvailable: json['fares_available'] ?? false,
      accessibilityAvailable: json['accessibility_available'] ?? false,
      officialDataProvider: json['official_data_provider'] ?? '',
      dataSourceUrl: json['data_source_url'] ?? '',
      dataLicense: json['data_license'] ?? '',
      attribution: json['attribution'] ?? '',
      lastSuccessfulSync: json['last_successful_sync'] ?? '',
      dataFreshnessMinutes: json['data_freshness_minutes'] ?? 0,
      validationStatus: json['validation_status'] ?? '',
    );
  }
}

