package service

import (
	"crypto/rand"
	"database/sql"
	"encoding/hex"
	"fmt"
	"net/http"
	"strings"
	"sync"
	"time"

	"github.com/bookingnetwork/global-travel-app/backend/internal/data"
	"github.com/bookingnetwork/global-travel-app/backend/internal/model"
	"github.com/bookingnetwork/global-travel-app/backend/internal/routing"
)

type ServiceContainer struct {
	Store         *data.SeedStore
	RoutingEngine *routing.Engine
	mu            sync.RWMutex
	statePath     string
	database      *sql.DB
	stateRevision int64
	HTTPClient    *http.Client
}

func NewServiceContainer(store *data.SeedStore) *ServiceContainer {
	return &ServiceContainer{
		Store:         store,
		RoutingEngine: routing.NewEngine(store),
		HTTPClient:    &http.Client{Timeout: 5 * time.Second},
	}
}

func randomID(prefix string) string {
	b := make([]byte, 8)
	_, _ = rand.Read(b)
	return prefix + "_" + hex.EncodeToString(b)
}

func (s *ServiceContainer) ListTrips() []model.Trip {
	s.mu.RLock()
	defer s.mu.RUnlock()

	trips := make([]model.Trip, 0, len(s.Store.Trips))
	for _, t := range s.Store.Trips {
		trips = append(trips, s.enrichTrip(t))
	}
	return trips
}

func (s *ServiceContainer) GetTrip(tripID string) (*model.Trip, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()

	trip, exists := s.Store.Trips[tripID]
	if !exists {
		return nil, fmt.Errorf("%w: trip %s", ErrNotFound, tripID)
	}
	enriched := s.enrichTrip(trip)
	return &enriched, nil
}

func (s *ServiceContainer) CreateTrip(trip model.Trip) (*model.Trip, error) {
	start, err := time.Parse("2006-01-02", trip.StartDate)
	if err != nil {
		return nil, fmt.Errorf("%w: invalid start date", ErrInvalidInput)
	}
	end, err := time.Parse("2006-01-02", trip.EndDate)
	if err != nil || end.Before(start) || end.Sub(start) > 365*24*time.Hour {
		return nil, fmt.Errorf("%w: end date must be within 365 days of start date", ErrInvalidInput)
	}
	if strings.TrimSpace(trip.Title) == "" || len(trip.Title) > 200 {
		return nil, fmt.Errorf("%w: trip title is required", ErrInvalidInput)
	}
	city, err := s.GetCity(trip.CityID)
	if err != nil {
		return nil, fmt.Errorf("%w: city not found", ErrInvalidInput)
	}
	trip.CityName, trip.CountryCode = city.Name, city.CountryCode
	s.mu.Lock()
	defer s.mu.Unlock()

	trip.ID = randomID("trip")
	trip.CreatedAt = time.Now()
	trip.UpdatedAt = time.Now()

	trip.Days = make([]model.TripDay, 0)
	for date := start; !date.After(end); date = date.AddDate(0, 0, 1) {
		trip.Days = append(trip.Days, model.TripDay{
			DayNumber: len(trip.Days) + 1,
			DateStr:   date.Format("2006-01-02"),
			CityID:    trip.CityID,
			CityName:  trip.CityName,
			Items:     []model.ItineraryItem{},
		})
	}

	if err := s.commitTrip(trip); err != nil {
		return nil, err
	}
	result := s.enrichTrip(trip)
	return &result, nil
}

func (s *ServiceContainer) AddItineraryItem(tripID string, dayNumber int, item model.ItineraryItem) (*model.Trip, error) {
	s.mu.Lock()
	defer s.mu.Unlock()

	trip, ok := s.Store.Trips[tripID]
	if !ok {
		return nil, fmt.Errorf("%w: trip %s", ErrNotFound, tripID)
	}
	if dayNumber < 1 || dayNumber > len(trip.Days) || strings.TrimSpace(item.Title) == "" {
		return nil, fmt.Errorf("%w: valid day and item title are required", ErrInvalidInput)
	}
	if err := validateItem(item); err != nil {
		return nil, err
	}
	item.RouteFromPrevious = nil
	trip = cloneTrip(trip)

	item.ID = randomID("item")
	dayFound := false
	for i := range trip.Days {
		if trip.Days[i].DayNumber == dayNumber {
			item.Order = len(trip.Days[i].Items) + 1
			trip.Days[i].Items = append(trip.Days[i].Items, item)
			dayFound = true
			break
		}
	}

	if !dayFound {
		return nil, fmt.Errorf("%w: day not found", ErrInvalidInput)
	}

	trip.UpdatedAt = time.Now()
	if err := s.commitTrip(trip); err != nil {
		return nil, err
	}
	result := s.enrichTrip(trip)
	return &result, nil
}

func (s *ServiceContainer) GetOfflinePackages() []model.OfflinePackage {
	return s.Store.OfflinePackages
}
