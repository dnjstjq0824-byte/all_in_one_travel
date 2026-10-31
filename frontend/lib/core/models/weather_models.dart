// Weather Domain Models

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
      hourly:
          (json['hourly'] as List?)
              ?.map((e) => HourlyForecast.fromJson(e))
              .toList() ??
          [],
      daily:
          (json['daily'] as List?)
              ?.map((e) => DailyForecast.fromJson(e))
              .toList() ??
          [],
      attribution: json['attribution'] ?? '',
    );
  }
}

class DayWeatherInfo {
  final String condition;
  final double tempMaxC;
  final double tempMinC;
  final int precipProb;
  final bool rainAlert;
  final String? indoorTip;

  DayWeatherInfo({
    required this.condition,
    required this.tempMaxC,
    required this.tempMinC,
    required this.precipProb,
    required this.rainAlert,
    this.indoorTip,
  });

  factory DayWeatherInfo.fromJson(Map<String, dynamic> json) {
    return DayWeatherInfo(
      condition: json['condition'] ?? 'Sunny',
      tempMaxC: (json['temp_max_c'] as num?)?.toDouble() ?? 20.0,
      tempMinC: (json['temp_min_c'] as num?)?.toDouble() ?? 10.0,
      precipProb: json['precip_prob'] ?? 0,
      rainAlert: json['rain_alert'] ?? false,
      indoorTip: json['indoor_tip'],
    );
  }
}

