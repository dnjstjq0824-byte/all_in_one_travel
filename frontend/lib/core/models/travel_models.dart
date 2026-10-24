// Domain Models matching API contracts

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
      transportModes: (json['transport_modes'] as List?)?.map((e) => e.toString()).toList() ?? [],
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

class StationExit {
  final String exitNumber;
  final List<String> destinations;
  final bool hasElevator;
  final bool hasEscalator;

  StationExit({
    required this.exitNumber,
    required this.destinations,
    required this.hasElevator,
    required this.hasEscalator,
  });

  factory StationExit.fromJson(Map<String, dynamic> json) {
    return StationExit(
      exitNumber: json['exit_number'] ?? '',
      destinations: (json['destinations'] as List?)?.map((e) => e.toString()).toList() ?? [],
      hasElevator: json['has_elevator'] ?? false,
      hasEscalator: json['has_escalator'] ?? false,
    );
  }
}

class MetroStation {
  final String id;
  final String cityId;
  final String code;
  final String name;
  final String englishName;
  final String localName;
  final double latitude;
  final double longitude;
  final double schematicX;
  final double schematicY;
  final List<String> lines;
  final List<StationExit> exits;
  final bool elevatorAccessible;
  final bool wheelchairBoarding;
  final String firstTrain;
  final String lastTrain;
  final List<String> nearbyBusStopIds;
  final List<String> nearbyPlaceIds;

  MetroStation({
    required this.id,
    required this.cityId,
    required this.code,
    required this.name,
    required this.englishName,
    required this.localName,
    required this.latitude,
    required this.longitude,
    required this.schematicX,
    required this.schematicY,
    required this.lines,
    required this.exits,
    required this.elevatorAccessible,
    required this.wheelchairBoarding,
    required this.firstTrain,
    required this.lastTrain,
    required this.nearbyBusStopIds,
    required this.nearbyPlaceIds,
  });

  factory MetroStation.fromJson(Map<String, dynamic> json) {
    return MetroStation(
      id: json['id'] ?? '',
      cityId: json['city_id'] ?? '',
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      englishName: json['english_name'] ?? '',
      localName: json['local_name'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      schematicX: (json['schematic_x'] as num?)?.toDouble() ?? 0.0,
      schematicY: (json['schematic_y'] as num?)?.toDouble() ?? 0.0,
      lines: (json['lines'] as List?)?.map((e) => e.toString()).toList() ?? [],
      exits: (json['exits'] as List?)?.map((e) => StationExit.fromJson(e)).toList() ?? [],
      elevatorAccessible: json['elevator_accessible'] ?? false,
      wheelchairBoarding: json['wheelchair_boarding'] ?? false,
      firstTrain: json['first_train'] ?? '',
      lastTrain: json['last_train'] ?? '',
      nearbyBusStopIds: (json['nearby_bus_stop_ids'] as List?)?.map((e) => e.toString()).toList() ?? [],
      nearbyPlaceIds: (json['nearby_place_ids'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

class MetroLine {
  final String id;
  final String cityId;
  final String lineNumber;
  final String name;
  final String englishName;
  final String colorHex;
  final String textColorHex;
  final List<String> stationIds;
  final bool isCircular;
  final String operatingHours;

  MetroLine({
    required this.id,
    required this.cityId,
    required this.lineNumber,
    required this.name,
    required this.englishName,
    required this.colorHex,
    required this.textColorHex,
    required this.stationIds,
    required this.isCircular,
    required this.operatingHours,
  });

  factory MetroLine.fromJson(Map<String, dynamic> json) {
    return MetroLine(
      id: json['id'] ?? '',
      cityId: json['city_id'] ?? '',
      lineNumber: json['line_number'] ?? '',
      name: json['name'] ?? '',
      englishName: json['english_name'] ?? '',
      colorHex: json['color_hex'] ?? '#0052A4',
      textColorHex: json['text_color_hex'] ?? '#FFFFFF',
      stationIds: (json['station_ids'] as List?)?.map((e) => e.toString()).toList() ?? [],
      isCircular: json['is_circular'] ?? false,
      operatingHours: json['operating_hours'] ?? '',
    );
  }
}

class BusStop {
  final String id;
  final String cityId;
  final String code;
  final String name;
  final String englishName;
  final double latitude;
  final double longitude;
  final String? nearbyMetroStationId;

  BusStop({
    required this.id,
    required this.cityId,
    required this.code,
    required this.name,
    required this.englishName,
    required this.latitude,
    required this.longitude,
    this.nearbyMetroStationId,
  });

  factory BusStop.fromJson(Map<String, dynamic> json) {
    return BusStop(
      id: json['id'] ?? '',
      cityId: json['city_id'] ?? '',
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      englishName: json['english_name'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      nearbyMetroStationId: json['nearby_metro_station_id'],
    );
  }
}

class BusRoute {
  final String id;
  final String cityId;
  final String routeNumber;
  final String name;
  final String operator;
  final String origin;
  final String destination;
  final String colorHex;
  final List<String> stopIds;
  final bool lowFloor;
  final int intervalMin;
  final String firstBus;
  final String lastBus;
  final String fare;

  BusRoute({
    required this.id,
    required this.cityId,
    required this.routeNumber,
    required this.name,
    required this.operator,
    required this.origin,
    required this.destination,
    required this.colorHex,
    required this.stopIds,
    required this.lowFloor,
    required this.intervalMin,
    required this.firstBus,
    required this.lastBus,
    required this.fare,
  });

  factory BusRoute.fromJson(Map<String, dynamic> json) {
    return BusRoute(
      id: json['id'] ?? '',
      cityId: json['city_id'] ?? '',
      routeNumber: json['route_number'] ?? '',
      name: json['name'] ?? '',
      operator: json['operator'] ?? '',
      origin: json['origin'] ?? '',
      destination: json['destination'] ?? '',
      colorHex: json['color_hex'] ?? '#0052A4',
      stopIds: (json['stop_ids'] as List?)?.map((e) => e.toString()).toList() ?? [],
      lowFloor: json['low_floor'] ?? false,
      intervalMin: json['interval_min'] ?? 10,
      firstBus: json['first_bus'] ?? '',
      lastBus: json['last_bus'] ?? '',
      fare: json['fare'] ?? '',
    );
  }
}

class RealtimeArrival {
  final String stopId;
  final String routeId;
  final String routeNumber;
  final String destination;
  final int minutesAway;
  final int stopsRemaining;
  final String status; // LIVE, SCHEDULED, ESTIMATED, UNAVAILABLE, STALE
  final String? vehiclePlate;
  final String crowdingLevel;

  RealtimeArrival({
    required this.stopId,
    required this.routeId,
    required this.routeNumber,
    required this.destination,
    required this.minutesAway,
    required this.stopsRemaining,
    required this.status,
    this.vehiclePlate,
    required this.crowdingLevel,
  });

  factory RealtimeArrival.fromJson(Map<String, dynamic> json) {
    return RealtimeArrival(
      stopId: json['stop_id'] ?? '',
      routeId: json['route_id'] ?? '',
      routeNumber: json['route_number'] ?? '',
      destination: json['destination'] ?? '',
      minutesAway: json['minutes_away'] ?? 0,
      stopsRemaining: json['stops_remaining'] ?? 0,
      status: json['status'] ?? 'SCHEDULED',
      vehiclePlate: json['vehicle_plate'],
      crowdingLevel: json['crowding_level'] ?? 'Low',
    );
  }
}

class TransitLeg {
  final String type; // WALK, METRO, BUS, RAIL
  final String? lineId;
  final String? lineName;
  final String? lineColorHex;
  final String? fromStationId;
  final String fromStationName;
  final String? toStationId;
  final String toStationName;
  final List<String> intermediateStops;
  final int durationMinutes;
  final int distanceMeters;
  final String instruction;

  TransitLeg({
    required this.type,
    this.lineId,
    this.lineName,
    this.lineColorHex,
    this.fromStationId,
    required this.fromStationName,
    this.toStationId,
    required this.toStationName,
    required this.intermediateStops,
    required this.durationMinutes,
    required this.distanceMeters,
    required this.instruction,
  });

  factory TransitLeg.fromJson(Map<String, dynamic> json) {
    return TransitLeg(
      type: json['type'] ?? 'WALK',
      lineId: json['line_id'],
      lineName: json['line_name'],
      lineColorHex: json['line_color_hex'],
      fromStationId: json['from_station_id'],
      fromStationName: json['from_station_name'] ?? '',
      toStationId: json['to_station_id'],
      toStationName: json['to_station_name'] ?? '',
      intermediateStops: (json['intermediate_stops'] as List?)?.map((e) => e.toString()).toList() ?? [],
      durationMinutes: json['duration_minutes'] ?? 0,
      distanceMeters: json['distance_meters'] ?? 0,
      instruction: json['instruction'] ?? '',
    );
  }
}

class RouteOption {
  final String id;
  final String summary;
  final int totalMinutes;
  final int walkMinutes;
  final int transfers;
  final String estimatedFare;
  final bool accessible;
  final List<TransitLeg> legs;

  RouteOption({
    required this.id,
    required this.summary,
    required this.totalMinutes,
    required this.walkMinutes,
    required this.transfers,
    required this.estimatedFare,
    required this.accessible,
    required this.legs,
  });

  factory RouteOption.fromJson(Map<String, dynamic> json) {
    return RouteOption(
      id: json['id'] ?? '',
      summary: json['summary'] ?? '',
      totalMinutes: json['total_minutes'] ?? 0,
      walkMinutes: json['walk_minutes'] ?? 0,
      transfers: json['transfers'] ?? 0,
      estimatedFare: json['estimated_fare'] ?? '',
      accessible: json['accessible'] ?? false,
      legs: (json['legs'] as List?)?.map((e) => TransitLeg.fromJson(e)).toList() ?? [],
    );
  }
}

class Place {
  final String id;
  final String cityId;
  final String category;
  final String name;
  final String englishName;
  final String localName;
  final String description;
  final double latitude;
  final double longitude;
  final double rating;
  final int reviewCount;
  final String address;
  final String openingHours;
  final String admissionFee;
  final String? officialWebsite;
  final String? phoneNumber;
  final String accessibilityInfo;
  final String bestTimeToVisit;
  final int estimatedDurationMin;
  final String nearestMetroStationId;
  final String nearestMetroStationName;
  final String nearestBusStopId;
  final List<String> photoUrls;
  final List<String> tags;

  Place({
    required this.id,
    required this.cityId,
    required this.category,
    required this.name,
    required this.englishName,
    required this.localName,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.rating,
    required this.reviewCount,
    required this.address,
    required this.openingHours,
    required this.admissionFee,
    this.officialWebsite,
    this.phoneNumber,
    required this.accessibilityInfo,
    required this.bestTimeToVisit,
    required this.estimatedDurationMin,
    required this.nearestMetroStationId,
    required this.nearestMetroStationName,
    required this.nearestBusStopId,
    required this.photoUrls,
    required this.tags,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id'] ?? '',
      cityId: json['city_id'] ?? '',
      category: json['category'] ?? '',
      name: json['name'] ?? '',
      englishName: json['english_name'] ?? '',
      localName: json['local_name'] ?? '',
      description: json['description'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['review_count'] ?? 0,
      address: json['address'] ?? '',
      openingHours: json['opening_hours'] ?? '',
      admissionFee: json['admission_fee'] ?? '',
      officialWebsite: json['official_website'],
      phoneNumber: json['phone_number'],
      accessibilityInfo: json['accessibility_info'] ?? '',
      bestTimeToVisit: json['best_time_to_visit'] ?? '',
      estimatedDurationMin: json['estimated_duration_min'] ?? 60,
      nearestMetroStationId: json['nearest_metro_station_id'] ?? '',
      nearestMetroStationName: json['nearest_metro_station_name'] ?? '',
      nearestBusStopId: json['nearest_bus_stop_id'] ?? '',
      photoUrls: (json['photo_urls'] as List?)?.map((e) => e.toString()).toList() ?? [],
      tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

class Review {
  final String id;
  final String placeId;
  final String authorName;
  final int rating;
  final String title;
  final String content;
  final String visitPeriod;
  final String travelType;
  final String? visitTip;
  final int helpfulCount;
  final bool verifiedVisit;
  final String language;

  Review({
    required this.id,
    required this.placeId,
    required this.authorName,
    required this.rating,
    required this.title,
    required this.content,
    required this.visitPeriod,
    required this.travelType,
    this.visitTip,
    required this.helpfulCount,
    required this.verifiedVisit,
    required this.language,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] ?? '',
      placeId: json['place_id'] ?? '',
      authorName: json['author_name'] ?? '',
      rating: json['rating'] ?? 5,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      visitPeriod: json['visit_period'] ?? '',
      travelType: json['travel_type'] ?? '',
      visitTip: json['visit_tip'],
      helpfulCount: json['helpful_count'] ?? 0,
      verifiedVisit: json['verified_visit'] ?? false,
      language: json['language'] ?? 'en',
    );
  }
}

class HourlyForecast {
  final String hour;
  final double tempC;
  final String condition;
  final int precipProb;
  final String icon;

  HourlyForecast({
    required this.hour,
    required this.tempC,
    required this.condition,
    required this.precipProb,
    required this.icon,
  });

  factory HourlyForecast.fromJson(Map<String, dynamic> json) {
    return HourlyForecast(
      hour: json['hour'] ?? '',
      tempC: (json['temp_c'] as num?)?.toDouble() ?? 0.0,
      condition: json['condition'] ?? '',
      precipProb: json['precip_prob'] ?? 0,
      icon: json['icon'] ?? 'partly_cloudy',
    );
  }
}

class DailyForecast {
  final String date;
  final String dayOfWeek;
  final double tempMinC;
  final double tempMaxC;
  final String condition;
  final int precipProb;
  final String icon;

  DailyForecast({
    required this.date,
    required this.dayOfWeek,
    required this.tempMinC,
    required this.tempMaxC,
    required this.condition,
    required this.precipProb,
    required this.icon,
  });

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    return DailyForecast(
      date: json['date'] ?? '',
      dayOfWeek: json['day_of_week'] ?? '',
      tempMinC: (json['temp_min_c'] as num?)?.toDouble() ?? 0.0,
      tempMaxC: (json['temp_max_c'] as num?)?.toDouble() ?? 0.0,
      condition: json['condition'] ?? '',
      precipProb: json['precip_prob'] ?? 0,
      icon: json['icon'] ?? 'sunny',
    );
  }
}

class WeatherReport {
  final String cityId;
  final String cityName;
  final double latitude;
  final double longitude;
  final double currentTempC;
  final double feelsLikeC;
  final String condition;
  final String conditionKorean;
  final int humidity;
  final double windSpeedKmH;
  final int uvIndex;
  final int precipProb;
  final String airQualityIndex;
  final String sunrise;
  final String sunset;
  final List<HourlyForecast> hourly;
  final List<DailyForecast> daily;
  final String attribution;

  WeatherReport({
    required this.cityId,
    required this.cityName,
    required this.latitude,
    required this.longitude,
    required this.currentTempC,
    required this.feelsLikeC,
    required this.condition,
    required this.conditionKorean,
    required this.humidity,
    required this.windSpeedKmH,
    required this.uvIndex,
    required this.precipProb,
    required this.airQualityIndex,
    required this.sunrise,
    required this.sunset,
    required this.hourly,
    required this.daily,
    required this.attribution,
  });

  factory WeatherReport.fromJson(Map<String, dynamic> json) {
    return WeatherReport(
      cityId: json['city_id'] ?? '',
      cityName: json['city_name'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      currentTempC: (json['current_temp_c'] as num?)?.toDouble() ?? 0.0,
      feelsLikeC: (json['feels_like_c'] as num?)?.toDouble() ?? 0.0,
      condition: json['condition'] ?? 'Clear',
      conditionKorean: json['condition_korean'] ?? '맑음',
      humidity: json['humidity'] ?? 50,
      windSpeedKmH: (json['wind_speed_kmh'] as num?)?.toDouble() ?? 0.0,
      uvIndex: json['uv_index'] ?? 3,
      precipProb: json['precip_prob'] ?? 0,
      airQualityIndex: json['air_quality_index'] ?? 'Good',
      sunrise: json['sunrise'] ?? '06:00',
      sunset: json['sunset'] ?? '18:00',
      hourly: (json['hourly'] as List?)?.map((e) => HourlyForecast.fromJson(e)).toList() ?? [],
      daily: (json['daily'] as List?)?.map((e) => DailyForecast.fromJson(e)).toList() ?? [],
      attribution: json['attribution'] ?? '',
    );
  }
}

class ItineraryItem {
  final String id;
  final String? placeId;
  final String title;
  final String subtitle;
  final String category;
  final int order;
  final String timeScheduled;
  final double latitude;
  final double longitude;
  final int durationMin;
  final String? notes;
  final bool isCompleted;

  ItineraryItem({
    required this.id,
    this.placeId,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.order,
    required this.timeScheduled,
    required this.latitude,
    required this.longitude,
    required this.durationMin,
    this.notes,
    required this.isCompleted,
  });

  factory ItineraryItem.fromJson(Map<String, dynamic> json) {
    return ItineraryItem(
      id: json['id'] ?? '',
      placeId: json['place_id'],
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      category: json['category'] ?? '',
      order: json['order'] ?? 1,
      timeScheduled: json['time_scheduled'] ?? '10:00',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      durationMin: json['duration_min'] ?? 60,
      notes: json['notes'],
      isCompleted: json['is_completed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'place_id': placeId,
    'title': title,
    'subtitle': subtitle,
    'category': category,
    'order': order,
    'time_scheduled': timeScheduled,
    'latitude': latitude,
    'longitude': longitude,
    'duration_min': durationMin,
    'notes': notes,
    'is_completed': isCompleted,
  };
}

class TripDay {
  final int dayNumber;
  final String dateStr;
  final String cityId;
  final String cityName;
  final String? weatherNote;
  final List<ItineraryItem> items;

  TripDay({
    required this.dayNumber,
    required this.dateStr,
    required this.cityId,
    required this.cityName,
    this.weatherNote,
    required this.items,
  });

  factory TripDay.fromJson(Map<String, dynamic> json) {
    return TripDay(
      dayNumber: json['day_number'] ?? 1,
      dateStr: json['date_str'] ?? '',
      cityId: json['city_id'] ?? '',
      cityName: json['city_name'] ?? '',
      weatherNote: json['weather_note'],
      items: (json['items'] as List?)?.map((e) => ItineraryItem.fromJson(e)).toList() ?? [],
    );
  }
}

class Trip {
  final String id;
  final String title;
  final String countryCode;
  final String cityId;
  final String cityName;
  final String startDate;
  final String endDate;
  final List<TripDay> days;
  final List<String> collaborators;

  Trip({
    required this.id,
    required this.title,
    required this.countryCode,
    required this.cityId,
    required this.cityName,
    required this.startDate,
    required this.endDate,
    required this.days,
    required this.collaborators,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      countryCode: json['country_code'] ?? '',
      cityId: json['city_id'] ?? '',
      cityName: json['city_name'] ?? '',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      days: (json['days'] as List?)?.map((e) => TripDay.fromJson(e)).toList() ?? [],
      collaborators: (json['collaborators'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

class OfflinePackage {
  final String cityId;
  final String cityName;
  final String version;
  final double sizeMb;
  final List<String> contents;
  final String attribution;

  OfflinePackage({
    required this.cityId,
    required this.cityName,
    required this.version,
    required this.sizeMb,
    required this.contents,
    required this.attribution,
  });

  factory OfflinePackage.fromJson(Map<String, dynamic> json) {
    return OfflinePackage(
      cityId: json['city_id'] ?? '',
      cityName: json['city_name'] ?? '',
      version: json['version'] ?? '',
      sizeMb: (json['size_mb'] as num?)?.toDouble() ?? 0.0,
      contents: (json['contents'] as List?)?.map((e) => e.toString()).toList() ?? [],
      attribution: json['attribution'] ?? '',
    );
  }
}

