package model

import "time"

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
	Hour       int `json:"hour"`
	Popularity int `json:"popularity"`
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
	Rating        int       `json:"rating"`
	Title         string    `json:"title"`
	Content       string    `json:"content"`
	VisitPeriod   string    `json:"visit_period"`
	TravelType    string    `json:"travel_type"`
	VisitTip      string    `json:"visit_tip,omitempty"`
	HelpfulCount  int       `json:"helpful_count"`
	VerifiedVisit bool      `json:"verified_visit"`
	Language      string    `json:"language"`
	CreatedAt     time.Time `json:"created_at"`
}

