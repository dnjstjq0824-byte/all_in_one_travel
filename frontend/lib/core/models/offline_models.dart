// Offline Package Domain Models

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
      contents:
          (json['contents'] as List?)?.map((e) => e.toString()).toList() ?? [],
      attribution: json['attribution'] ?? '',
    );
  }
}

