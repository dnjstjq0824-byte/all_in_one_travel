package model

import "time"

// CoverageLevel defines verified operational readiness
type CoverageLevel string

const (
	CoverageLevelA CoverageLevel = "LEVEL_A" // FULL_VERIFIED: Metro + Bus + Timetables + Live / Estimates + Places + Weather
	CoverageLevelB CoverageLevel = "LEVEL_B" // SCHEDULE_VERIFIED: Metro + Bus Schedules + Offline Routes + Places + Weather
	CoverageLevelC CoverageLevel = "LEVEL_C" // MAP_ONLY: Schematic Metro Map + Directory + Places + Weather
	CoverageLevelD CoverageLevel = "LEVEL_D" // DESTINATION_ONLY: Places + Weather + Street Map
	CoverageLevelE CoverageLevel = "LEVEL_E" // UNSUPPORTED: No verified data
)

// ArrivalStatus defines real-time arrival quality
type ArrivalStatus string

const (
	StatusLive        ArrivalStatus = "LIVE"
	StatusScheduled   ArrivalStatus = "SCHEDULED"
	StatusEstimated   ArrivalStatus = "ESTIMATED"
	StatusUnavailable ArrivalStatus = "UNAVAILABLE"
	StatusStale       ArrivalStatus = "STALE"
)

type Country struct {
	Code      string `json:"code"`
	Name      string `json:"name"`
	Continent string `json:"continent"`
}

type City struct {
	ID             string        `json:"id"`
	CountryCode    string        `json:"country_code"`
	Name           string        `json:"name"`
	EnglishName    string        `json:"english_name"`
	LocalName      string        `json:"local_name"`
	Latitude       float64       `json:"latitude"`
	Longitude      float64       `json:"longitude"`
	Timezone       string        `json:"timezone"`
	CoverageLevel  CoverageLevel `json:"coverage_level"`
	TransportModes []string      `json:"transport_modes"`
	Description    string        `json:"description"`
	HeroImageURL   string        `json:"hero_image_url"`
}

type CoverageRegistry struct {
	CityID                 string        `json:"city_id"`
	CityName               string        `json:"city_name"`
	CoverageLevel          CoverageLevel `json:"coverage_level"`
	MetroMapAvailable      bool          `json:"metro_map_available"`
	MetroRoutesAvailable   bool          `json:"metro_routes_available"`
	BusRoutesAvailable     bool          `json:"bus_routes_available"`
	ScheduleAvailable      bool          `json:"schedule_available"`
	RealtimeAvailable      bool          `json:"realtime_available"`
	FaresAvailable         bool          `json:"fares_available"`
	AccessibilityAvailable bool          `json:"accessibility_available"`
	OfficialDataProvider   string        `json:"official_data_provider"`
	DataSourceURL          string        `json:"data_source_url"`
	DataLicense            string        `json:"data_license"`
	Attribution            string        `json:"attribution"`
	LastSuccessfulSync     time.Time     `json:"last_successful_sync"`
	DataFreshnessMinutes   int           `json:"data_freshness_minutes"`
	ValidationStatus       string        `json:"validation_status"`
}

type StationExit struct {
	ExitNumber   string   `json:"exit_number"`
	Destinations []string `json:"destinations"`
	HasElevator  bool     `json:"has_elevator"`
	HasEscalator bool     `json:"has_escalator"`
}

type MetroStation struct {
	ID                 string             `json:"id"`
	CityID             string             `json:"city_id"`
	Code               string             `json:"code"`
	Name               string             `json:"name"`
	EnglishName        string             `json:"english_name"`
	LocalName          string             `json:"local_name"`
	Latitude           float64            `json:"latitude"`
	Longitude          float64            `json:"longitude"`
	SchematicX         float64            `json:"schematic_x"`
	SchematicY         float64            `json:"schematic_y"`
	Lines              []string           `json:"lines"` // Line IDs
	Exits              []StationExit      `json:"exits"`
	ElevatorAccessible bool               `json:"elevator_accessible"`
	WheelchairBoarding bool               `json:"wheelchair_boarding"`
	FirstTrain         string             `json:"first_train"`
	LastTrain          string             `json:"last_train"`
	NearbyBusStopIDs   []string           `json:"nearby_bus_stop_ids"`
	NearbyPlaceIDs     []string           `json:"nearby_place_ids"`
	BoardingGuidance   []BoardingGuidance `json:"boarding_guidance,omitempty"`
}

// BoardingGuidance identifies a supplied door recommendation for a specific ride.
// An empty NextLineID indicates exit guidance rather than a transfer.
type BoardingGuidance struct {
	LineID        string `json:"line_id"`
	FromStationID string `json:"from_station_id"`
	NextLineID    string `json:"next_line_id,omitempty"`
	Door          string `json:"door"`
}

type MetroLine struct {
	ID             string   `json:"id"`
	CityID         string   `json:"city_id"`
	LineNumber     string   `json:"line_number"`
	Name           string   `json:"name"`
	EnglishName    string   `json:"english_name"`
	ColorHex       string   `json:"color_hex"`
	TextColorHex   string   `json:"text_color_hex"`
	StationIDs     []string `json:"station_ids"`
	IsCircular     bool     `json:"is_circular"`
	OperatingHours string   `json:"operating_hours"`
}

type BusStop struct {
	ID                   string  `json:"id"`
	CityID               string  `json:"city_id"`
	Code                 string  `json:"code"`
	Name                 string  `json:"name"`
	EnglishName          string  `json:"english_name"`
	Latitude             float64 `json:"latitude"`
	Longitude            float64 `json:"longitude"`
	NearbyMetroStationID string  `json:"nearby_metro_station_id,omitempty"`
}

type BusRoute struct {
	ID          string   `json:"id"`
	CityID      string   `json:"city_id"`
	RouteNumber string   `json:"route_number"`
	Name        string   `json:"name"`
	Operator    string   `json:"operator"`
	Origin      string   `json:"origin"`
	Destination string   `json:"destination"`
	ColorHex    string   `json:"color_hex"`
	StopIDs     []string `json:"stop_ids"`
	LowFloor    bool     `json:"low_floor"`
	IntervalMin int      `json:"interval_min"`
	FirstBus    string   `json:"first_bus"`
	LastBus     string   `json:"last_bus"`
	Fare        string   `json:"fare"`
}

type RealtimeArrival struct {
	StopID         string        `json:"stop_id"`
	RouteID        string        `json:"route_id"`
	RouteNumber    string        `json:"route_number"`
	Destination    string        `json:"destination"`
	MinutesAway    int           `json:"minutes_away"`
	StopsRemaining int           `json:"stops_remaining"`
	Status         ArrivalStatus `json:"status"`
	VehiclePlate   string        `json:"vehicle_plate,omitempty"`
	CrowdingLevel  string        `json:"crowding_level"` // Low, Moderate, High
	UpdatedAt      time.Time     `json:"updated_at"`
}

type LegType string

const (
	LegWalk  LegType = "WALK"
	LegMetro LegType = "METRO"
	LegBus   LegType = "BUS"
	LegRail  LegType = "RAIL"
)

type TransitLeg struct {
	Type              LegType  `json:"type"`
	LineID            string   `json:"line_id,omitempty"`
	LineName          string   `json:"line_name,omitempty"`
	LineColorHex      string   `json:"line_color_hex,omitempty"`
	FromStationID     string   `json:"from_station_id,omitempty"`
	FromStationName   string   `json:"from_station_name"`
	ToStationID       string   `json:"to_station_id,omitempty"`
	ToStationName     string   `json:"to_station_name"`
	IntermediateStops []string `json:"intermediate_stops,omitempty"`
	DurationMinutes   int      `json:"duration_minutes"`
	DistanceMeters    int      `json:"distance_meters"`
	Instruction       string   `json:"instruction"`
	FastTransferDoor  string   `json:"fast_transfer_door,omitempty"`
}

type RouteOption struct {
	ID                string       `json:"id"`
	Summary           string       `json:"summary"`
	TotalMinutes      int          `json:"total_minutes"`
	WalkMinutes       int          `json:"walk_minutes"`
	Transfers         int          `json:"transfers"`
	EstimatedFare     string       `json:"estimated_fare"`
	Accessible        bool         `json:"accessible"`
	AccessibilityNote string       `json:"accessibility_note,omitempty"`
	Legs              []TransitLeg `json:"legs"`
}

type TransitPlanRequest struct {
	CityID     string  `json:"city_id"`
	OriginLat  float64 `json:"origin_lat"`
	OriginLng  float64 `json:"origin_lng"`
	OriginName string  `json:"origin_name"`
	DestLat    float64 `json:"dest_lat"`
	DestLng    float64 `json:"dest_lng"`
	DestName   string  `json:"dest_name"`
	Preference string  `json:"preference"` // "fastest", "min_transfers", "least_walking", "accessible"
}

type TransitPlanResponse struct {
	OriginName string        `json:"origin_name"`
	DestName   string        `json:"dest_name"`
	Options    []RouteOption `json:"options"`
}

type PlaceCategory string

const (
	CategoryLandmark  PlaceCategory = "Landmark"
	CategoryHistoric  PlaceCategory = "Historic & Culture"
	CategoryMuseum    PlaceCategory = "Museum & Art"
	CategoryNature    PlaceCategory = "Nature & Park"
	CategoryFood      PlaceCategory = "Food & Market"
	CategoryNightView PlaceCategory = "Night View"
	CategoryShopping  PlaceCategory = "Shopping"
)

type HourlyPopularity struct {
	Hour       int `json:"hour"`       // 9 to 21
	Popularity int `json:"popularity"` // 0 to 100 percentage
}

type Place struct {
	ID                      string             `json:"id"`
	CityID                  string             `json:"city_id"`
	Category                PlaceCategory      `json:"category"`
	Name                    string             `json:"name"`
	EnglishName             string             `json:"english_name"`
	LocalName               string             `json:"local_name"`
	Description             string             `json:"description"`
	Latitude                float64            `json:"latitude"`
	Longitude               float64            `json:"longitude"`
	Rating                  float64            `json:"rating"`
	ReviewCount             int                `json:"review_count"`
	Address                 string             `json:"address"`
	OpeningHours            string             `json:"opening_hours"`
	AdmissionFee            string             `json:"admission_fee"`
	OfficialWebsite         string             `json:"official_website,omitempty"`
	PhoneNumber             string             `json:"phone_number,omitempty"`
	AccessibilityInfo       string             `json:"accessibility_info"`
	BestTimeToVisit         string             `json:"best_time_to_visit"`
	EstimatedDurationMin    int                `json:"estimated_duration_min"`
	NearestMetroStationID   string             `json:"nearest_metro_station_id"`
	NearestMetroStationName string             `json:"nearest_metro_station_name"`
	NearestBusStopID        string             `json:"nearest_bus_stop_id"`
	PhotoURLs               []string           `json:"photo_urls"`
	Tags                    []string           `json:"tags"`
	PopularTimes            []HourlyPopularity `json:"popular_times,omitempty"`
}

type Review struct {
	ID            string    `json:"id"`
	PlaceID       string    `json:"place_id"`
	AuthorName    string    `json:"author_name"`
	Rating        int       `json:"rating"` // 1-5
	Title         string    `json:"title"`
	Content       string    `json:"content"`
	VisitPeriod   string    `json:"visit_period"`
	TravelType    string    `json:"travel_type"` // Solo, Couple, Family, Friends
	VisitTip      string    `json:"visit_tip,omitempty"`
	HelpfulCount  int       `json:"helpful_count"`
	VerifiedVisit bool      `json:"verified_visit"`
	Language      string    `json:"language"`
	CreatedAt     time.Time `json:"created_at"`
}

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
	Severity    string    `json:"severity"` // Moderate, Severe, Extreme
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
	Condition  string  `json:"condition"` // Sunny, Rainy, Cloudy
	TempMaxC   float64 `json:"temp_max_c"`
	TempMinC   float64 `json:"temp_min_c"`
	PrecipProb int     `json:"precip_prob"` // Percentage
	RainAlert  bool    `json:"rain_alert"`  // true if precip_prob >= 50
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
	SHA256 string `json:"sha256"`
	DownloadURL string `json:"download_url"`
}
