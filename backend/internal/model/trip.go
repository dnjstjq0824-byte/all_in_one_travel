package model

import "time"

type ItineraryItem struct {
	ID                string       `json:"id"`
	PlaceID           string       `json:"place_id,omitempty"`
	Title             string       `json:"title"`
	Subtitle          string       `json:"subtitle"`
	Category          string       `json:"category"`
	Order             int          `json:"order"`
	TimeScheduled     string       `json:"time_scheduled"`
	Latitude          float64      `json:"latitude"`
	Longitude         float64      `json:"longitude"`
	DurationMin       int          `json:"duration_min"`
	Notes             string       `json:"notes,omitempty"`
	IsCompleted       bool         `json:"is_completed"`
	RouteFromPrevious *RouteOption `json:"route_from_previous,omitempty"`
}

type DayWeatherInfo struct {
	Condition  string  `json:"condition"`
	TempMaxC   float64 `json:"temp_max_c"`
	TempMinC   float64 `json:"temp_min_c"`
	PrecipProb int     `json:"precip_prob"`
	RainAlert  bool    `json:"rain_alert"`
	IndoorTip  string  `json:"indoor_tip,omitempty"`
}

type TripDay struct {
	DayNumber   int             `json:"day_number"`
	DateStr     string          `json:"date_str"`
	CityID      string          `json:"city_id"`
	CityName    string          `json:"city_name"`
	WeatherNote string          `json:"weather_note,omitempty"`
	DayWeather  *DayWeatherInfo `json:"day_weather,omitempty"`
	Items       []ItineraryItem `json:"items"`
}

type Trip struct {
	ID            string    `json:"id"`
	Title         string    `json:"title"`
	CountryCode   string    `json:"country_code"`
	CityID        string    `json:"city_id"`
	CityName      string    `json:"city_name"`
	StartDate     string    `json:"start_date"`
	EndDate       string    `json:"end_date"`
	Days          []TripDay `json:"days"`
	Collaborators []string  `json:"collaborators"`
	CreatedAt     time.Time `json:"created_at"`
	UpdatedAt     time.Time `json:"updated_at"`
}

type OfflinePackage struct {
	CityID      string    `json:"city_id"`
	CityName    string    `json:"city_name"`
	Version     string    `json:"version"`
	SizeBytes   int64     `json:"size_bytes"`
	SizeMB      float64   `json:"size_mb"`
	Contents    []string  `json:"contents"`
	LastUpdated time.Time `json:"last_updated"`
	Attribution string    `json:"attribution"`
	SHA256      string    `json:"sha256"`
	DownloadURL string    `json:"download_url"`
}

