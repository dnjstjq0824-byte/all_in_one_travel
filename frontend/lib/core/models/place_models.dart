// Place and Review Domain Models

class HourlyPopularity {
  final int hour;
  final int popularity;

  HourlyPopularity({required this.hour, required this.popularity});

  factory HourlyPopularity.fromJson(Map<String, dynamic> json) {
    return HourlyPopularity(
      hour: json['hour'] ?? 0,
      popularity: json['popularity'] ?? 0,
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
  final List<HourlyPopularity> popularTimes;

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
    this.popularTimes = const [],
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
      photoUrls:
          (json['photo_urls'] as List?)?.map((e) => e.toString()).toList() ??
          [],
      tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
      popularTimes:
          (json['popular_times'] as List?)
              ?.map((e) => HourlyPopularity.fromJson(e))
              .toList() ??
          [],
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

