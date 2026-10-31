// Trip and Itinerary Domain Models

import 'routing_models.dart';
import 'weather_models.dart';

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
  final RouteOption? routeFromPrevious;

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
    this.routeFromPrevious,
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
      routeFromPrevious: json['route_from_previous'] == null
          ? null
          : RouteOption.fromJson(json['route_from_previous']),
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
  final DayWeatherInfo? dayWeather;
  final List<ItineraryItem> items;

  TripDay({
    required this.dayNumber,
    required this.dateStr,
    required this.cityId,
    required this.cityName,
    this.weatherNote,
    this.dayWeather,
    required this.items,
  });

  factory TripDay.fromJson(Map<String, dynamic> json) {
    return TripDay(
      dayNumber: json['day_number'] ?? 1,
      dateStr: json['date_str'] ?? '',
      cityId: json['city_id'] ?? '',
      cityName: json['city_name'] ?? '',
      weatherNote: json['weather_note'],
      dayWeather: json['day_weather'] != null
          ? DayWeatherInfo.fromJson(json['day_weather'])
          : null,
      items:
          (json['items'] as List?)
              ?.map((e) => ItineraryItem.fromJson(e))
              .toList() ??
          [],
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
      days:
          (json['days'] as List?)?.map((e) => TripDay.fromJson(e)).toList() ??
          [],
      collaborators:
          (json['collaborators'] as List?)?.map((e) => e.toString()).toList() ??
          [],
    );
  }
}

