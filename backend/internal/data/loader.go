package data

import (
	"embed"
	"encoding/json"
	"fmt"
	"log"

	"github.com/bookingnetwork/global-travel-app/backend/internal/model"
)

//go:embed seed/*.json
var seedFS embed.FS

type SeedStore struct {
	Countries        []model.Country                   `json:"countries"`
	Cities           []model.City                      `json:"cities"`
	Coverage         map[string]model.CoverageRegistry `json:"coverage"`
	MetroLines       map[string][]model.MetroLine      `json:"metro_lines"`
	MetroStations    map[string][]model.MetroStation   `json:"metro_stations"`
	BusRoutes        map[string][]model.BusRoute       `json:"bus_routes"`
	BusStops         map[string][]model.BusStop        `json:"bus_stops"`
	RealtimeArrivals map[string][]model.RealtimeArrival`json:"realtime_arrivals"`
	Places           map[string][]model.Place          `json:"places"`
	Reviews          map[string][]model.Review         `json:"reviews"`
	WeatherReports   map[string]model.WeatherReport    `json:"weather_reports"`
	Trips            map[string]model.Trip             `json:"trips"`
	OfflinePackages  []model.OfflinePackage            `json:"offline_packages"`
	Emergencies      map[string]model.EmergencyInfo    `json:"emergencies"`
}

func loadResource(filename string, target any) error {
	data, err := seedFS.ReadFile("seed/" + filename)
	if err != nil {
		return fmt.Errorf("read seed/%s: %w", filename, err)
	}
	if err := json.Unmarshal(data, target); err != nil {
		return fmt.Errorf("unmarshal seed/%s: %w", filename, err)
	}
	return nil
}

func NewSeedStore() *SeedStore {
	store := &SeedStore{
		Coverage:         make(map[string]model.CoverageRegistry),
		MetroLines:       make(map[string][]model.MetroLine),
		MetroStations:    make(map[string][]model.MetroStation),
		BusRoutes:        make(map[string][]model.BusRoute),
		BusStops:         make(map[string][]model.BusStop),
		RealtimeArrivals: make(map[string][]model.RealtimeArrival),
		Places:           make(map[string][]model.Place),
		Reviews:          make(map[string][]model.Review),
		WeatherReports:   make(map[string]model.WeatherReport),
		Trips:            make(map[string]model.Trip),
		Emergencies:      make(map[string]model.EmergencyInfo),
	}

	mustLoad := func(filename string, target any) {
		if err := loadResource(filename, target); err != nil {
			log.Fatalf("[SEED] Fatal error loading %s: %v", filename, err)
		}
	}

	mustLoad("countries.json", &store.Countries)
	mustLoad("cities.json", &store.Cities)
	mustLoad("coverage.json", &store.Coverage)
	mustLoad("metro_lines.json", &store.MetroLines)
	mustLoad("metro_stations.json", &store.MetroStations)
	mustLoad("bus_routes.json", &store.BusRoutes)
	mustLoad("bus_stops.json", &store.BusStops)
	mustLoad("realtime_arrivals.json", &store.RealtimeArrivals)
	mustLoad("places.json", &store.Places)
	mustLoad("reviews.json", &store.Reviews)
	mustLoad("trips.json", &store.Trips)
	mustLoad("offline_packages.json", &store.OfflinePackages)
	mustLoad("emergencies.json", &store.Emergencies)

	// Sync place review_counts to actual reviews length to eliminate discrepancy (L-03)
	for cityID, places := range store.Places {
		for i := range places {
			if revs, exists := store.Reviews[places[i].ID]; exists {
				places[i].ReviewCount = len(revs)
			}
		}
		store.Places[cityID] = places
	}

	return store
}
