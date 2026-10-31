// Bus Domain Models

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
      stopIds:
          (json['stop_ids'] as List?)?.map((e) => e.toString()).toList() ?? [],
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
  final String status;
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

