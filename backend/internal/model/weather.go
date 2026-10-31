package model

import "time"

type HourlyForecast struct {
	Hour       string  `json:"hour"`
	TempC      float64 `json:"temp_c"`
	Condition  string  `json:"condition"`
	PrecipProb int     `json:"precip_prob"`
	Icon       string  `json:"icon"`
}

type DailyForecast struct {
	Date       string  `json:"date"`
	DayOfWeek  string  `json:"day_of_week"`
	TempMinC   float64 `json:"temp_min_c"`
	TempMaxC   float64 `json:"temp_max_c"`
	Condition  string  `json:"condition"`
	PrecipProb int     `json:"precip_prob"`
	Icon       string  `json:"icon"`
}

type WeatherAlert struct {
	Title       string    `json:"title"`
	Severity    string    `json:"severity"`
	Description string    `json:"description"`
	IssuedBy    string    `json:"issued_by"`
	ValidUntil  time.Time `json:"valid_until"`
}

type WeatherReport struct {
	CityID          string           `json:"city_id"`
	CityName        string           `json:"city_name"`
	Latitude        float64          `json:"latitude"`
	Longitude       float64          `json:"longitude"`
	CurrentTempC    float64          `json:"current_temp_c"`
	FeelsLikeC      float64          `json:"feels_like_c"`
	Condition       string           `json:"condition"`
	ConditionKorean string           `json:"condition_korean"`
	Humidity        int              `json:"humidity"`
	WindSpeedKmH    float64          `json:"wind_speed_kmh"`
	UVIndex         int              `json:"uv_index"`
	PrecipProb      int              `json:"precip_prob"`
	AirQualityIndex string           `json:"air_quality_index"`
	Sunrise         string           `json:"sunrise"`
	Sunset          string           `json:"sunset"`
	Hourly          []HourlyForecast `json:"hourly"`
	Daily           []DailyForecast  `json:"daily"`
	Alerts          []WeatherAlert   `json:"alerts,omitempty"`
	Attribution     string           `json:"attribution"`
	ObservedAt      time.Time        `json:"observed_at"`
}

