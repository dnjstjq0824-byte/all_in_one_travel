package model

import "time"

// ArrivalStatus defines real-time arrival quality
type ArrivalStatus string

const (
	StatusLive        ArrivalStatus = "LIVE"
	StatusScheduled   ArrivalStatus = "SCHEDULED"
	StatusEstimated   ArrivalStatus = "ESTIMATED"
	StatusUnavailable ArrivalStatus = "UNAVAILABLE"
	StatusStale       ArrivalStatus = "STALE"
)

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
	Lines              []string           `json:"lines"`
	Exits              []StationExit      `json:"exits"`
	ElevatorAccessible bool               `json:"elevator_accessible"`
	WheelchairBoarding bool               `json:"wheelchair_boarding"`
	FirstTrain         string             `json:"first_train"`
	LastTrain          string             `json:"last_train"`
	NearbyBusStopIDs   []string           `json:"nearby_bus_stop_ids"`
	NearbyPlaceIDs     []string           `json:"nearby_place_ids"`
	BoardingGuidance   []BoardingGuidance `json:"boarding_guidance,omitempty"`
}

// BoardingGuidance identifies a door recommendation for a ride or transfer.
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
	CrowdingLevel  string        `json:"crowding_level"`
	UpdatedAt      time.Time     `json:"updated_at"`
}

