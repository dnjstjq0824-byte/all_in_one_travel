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

