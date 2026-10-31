// Metro Domain Models

enum MetroViewMode { schematic, geographic }

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
      destinations:
          (json['destinations'] as List?)?.map((e) => e.toString()).toList() ??
          [],
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
      exits:
          (json['exits'] as List?)
              ?.map((e) => StationExit.fromJson(e))
              .toList() ??
          [],
      elevatorAccessible: json['elevator_accessible'] ?? false,
      wheelchairBoarding: json['wheelchair_boarding'] ?? false,
      firstTrain: json['first_train'] ?? '',
      lastTrain: json['last_train'] ?? '',
      nearbyBusStopIds:
          (json['nearby_bus_stop_ids'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      nearbyPlaceIds:
          (json['nearby_place_ids'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
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
      stationIds:
          (json['station_ids'] as List?)?.map((e) => e.toString()).toList() ??
          [],
      isCircular: json['is_circular'] ?? false,
      operatingHours: json['operating_hours'] ?? '',
    );
  }
}
