// Routing and Navigation Domain Models

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
  final String? fastTransferDoor;

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
    this.fastTransferDoor,
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
      intermediateStops:
          (json['intermediate_stops'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      durationMinutes: json['duration_minutes'] ?? 0,
      distanceMeters: json['distance_meters'] ?? 0,
      instruction: json['instruction'] ?? '',
      fastTransferDoor: json['fast_transfer_door'],
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
  final String? accessibilityNote;
  final List<TransitLeg> legs;

  RouteOption({
    required this.id,
    required this.summary,
    required this.totalMinutes,
    required this.walkMinutes,
    required this.transfers,
    required this.estimatedFare,
    required this.accessible,
    this.accessibilityNote,
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
      accessibilityNote: json['accessibility_note'],
      legs:
          (json['legs'] as List?)
              ?.map((e) => TransitLeg.fromJson(e))
              .toList() ??
          [],
    );
  }
}

