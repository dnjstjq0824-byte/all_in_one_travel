package model

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
	Preference string  `json:"preference"`
}

type TransitPlanResponse struct {
	OriginName string        `json:"origin_name"`
	DestName   string        `json:"dest_name"`
	Options    []RouteOption `json:"options"`
}

