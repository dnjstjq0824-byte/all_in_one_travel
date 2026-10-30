package service

import (
	"fmt"
	"strings"
	"time"

	"github.com/bookingnetwork/global-travel-app/backend/internal/model"
	"github.com/bookingnetwork/global-travel-app/backend/internal/routing"
)

type TripPatch struct {
	Title     *string `json:"title"`
	StartDate *string `json:"start_date"`
	EndDate   *string `json:"end_date"`
}

type ItemPatch struct {
	Title         *string  `json:"title"`
	TimeScheduled *string  `json:"time_scheduled"`
	DurationMin   *int     `json:"duration_min"`
	Notes         *string  `json:"notes"`
	Latitude      *float64 `json:"latitude"`
	Longitude     *float64 `json:"longitude"`
	IsCompleted   *bool    `json:"is_completed"`
}

func validateItem(item model.ItineraryItem) error {
	if strings.TrimSpace(item.Title) == "" || len(item.Title) > 200 || len(item.Notes) > 4000 || item.DurationMin < 0 || item.DurationMin > 1440 {
		return fmt.Errorf("%w: item title, duration, or notes are invalid", ErrInvalidInput)
	}
	if item.TimeScheduled != "" {
		if _, err := time.Parse("15:04", item.TimeScheduled); err != nil {
			return fmt.Errorf("%w: time must be HH:MM", ErrInvalidInput)
		}
	}
	if err := routing.ValidateRequest(model.TransitPlanRequest{OriginLat: item.Latitude, OriginLng: item.Longitude}); err != nil {
		return fmt.Errorf("%w: %s", ErrInvalidInput, err)
	}
	return nil
}

func (s *ServiceContainer) UpdateTrip(tripID string, patch TripPatch) (*model.Trip, error) {
	s.mu.Lock()
	defer s.mu.Unlock()
	trip, ok := s.Store.Trips[tripID]
	if !ok {
		return nil, fmt.Errorf("%w: trip", ErrNotFound)
	}
	trip = cloneTrip(trip)
	if patch.Title != nil {
		trip.Title = strings.TrimSpace(*patch.Title)
	}
	if patch.StartDate != nil {
		trip.StartDate = *patch.StartDate
	}
	if patch.EndDate != nil {
		trip.EndDate = *patch.EndDate
	}
	start, startErr := time.Parse("2006-01-02", trip.StartDate)
	end, endErr := time.Parse("2006-01-02", trip.EndDate)
	if startErr != nil || endErr != nil || end.Before(start) || end.Sub(start) > 365*24*time.Hour || trip.Title == "" || len(trip.Title) > 200 {
		return nil, fmt.Errorf("%w: invalid title or date range", ErrInvalidInput)
	}
	byDate := make(map[string]model.TripDay, len(trip.Days))
	for _, day := range trip.Days {
		if (day.DateStr < trip.StartDate || day.DateStr > trip.EndDate) && len(day.Items) > 0 {
			return nil, fmt.Errorf("%w: remove activities from excluded dates first", ErrInvalidInput)
		}
		byDate[day.DateStr] = day
	}
	trip.Days = []model.TripDay{}
	for date := start; !date.After(end); date = date.AddDate(0, 0, 1) {
		dateStr := date.Format("2006-01-02")
		day, ok := byDate[dateStr]
		if !ok {
			day = model.TripDay{DateStr: dateStr, CityID: trip.CityID, CityName: trip.CityName, Items: []model.ItineraryItem{}}
		}
		day.DayNumber = len(trip.Days) + 1
		trip.Days = append(trip.Days, day)
	}
	trip.UpdatedAt = time.Now()
	if err := s.commitTrip(trip); err != nil {
		return nil, err
	}
	result := s.enrichTrip(trip)
	return &result, nil
}

func (s *ServiceContainer) DeleteTrip(tripID string) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	if _, ok := s.Store.Trips[tripID]; !ok {
		return fmt.Errorf("%w: trip", ErrNotFound)
	}
	trips := make(map[string]model.Trip, len(s.Store.Trips))
	for id, trip := range s.Store.Trips {
		if id != tripID {
			trips[id] = trip
		}
	}
	if err := s.writeState(trips, s.Store.Reviews); err != nil {
		return err
	}
	s.Store.Trips = trips
	return nil
}

func (s *ServiceContainer) UpdateItineraryItem(tripID, itemID string, patch ItemPatch) (*model.Trip, error) {
	return s.editItem(tripID, itemID, func(items []model.ItineraryItem, i int) ([]model.ItineraryItem, error) {
		item := items[i]
		if patch.Title != nil {
			item.Title = strings.TrimSpace(*patch.Title)
		}
		if patch.TimeScheduled != nil {
			item.TimeScheduled = *patch.TimeScheduled
		}
		if patch.DurationMin != nil {
			item.DurationMin = *patch.DurationMin
		}
		if patch.Notes != nil {
			item.Notes = *patch.Notes
		}
		if patch.Latitude != nil {
			item.Latitude = *patch.Latitude
		}
		if patch.Longitude != nil {
			item.Longitude = *patch.Longitude
		}
		if patch.IsCompleted != nil {
			item.IsCompleted = *patch.IsCompleted
		}
		if err := validateItem(item); err != nil {
			return nil, err
		}
		items[i] = item
		return items, nil
	})
}

func (s *ServiceContainer) DeleteItineraryItem(tripID, itemID string) (*model.Trip, error) {
	return s.editItem(tripID, itemID, func(items []model.ItineraryItem, i int) ([]model.ItineraryItem, error) {
		return append(items[:i], items[i+1:]...), nil
	})
}

func (s *ServiceContainer) editItem(tripID, itemID string, edit func([]model.ItineraryItem, int) ([]model.ItineraryItem, error)) (*model.Trip, error) {
	s.mu.Lock()
	defer s.mu.Unlock()
	trip, ok := s.Store.Trips[tripID]
	if !ok {
		return nil, fmt.Errorf("%w: trip", ErrNotFound)
	}
	trip = cloneTrip(trip)
	for d := range trip.Days {
		for i, item := range trip.Days[d].Items {
			if item.ID != itemID {
				continue
			}
			items, err := edit(trip.Days[d].Items, i)
			if err != nil {
				return nil, err
			}
			for j := range items {
				items[j].Order = j + 1
			}
			trip.Days[d].Items = items
			trip.UpdatedAt = time.Now()
			if err := s.commitTrip(trip); err != nil {
				return nil, err
			}
			result := s.enrichTrip(trip)
			return &result, nil
		}
	}
	return nil, fmt.Errorf("%w: item", ErrNotFound)
}

func (s *ServiceContainer) ReorderItineraryItems(tripID string, dayNumber int, ids []string) (*model.Trip, error) {
	s.mu.Lock()
	defer s.mu.Unlock()
	trip, ok := s.Store.Trips[tripID]
	if !ok {
		return nil, fmt.Errorf("%w: trip", ErrNotFound)
	}
	trip = cloneTrip(trip)
	for d := range trip.Days {
		if trip.Days[d].DayNumber != dayNumber {
			continue
		}
		items := trip.Days[d].Items
		if len(ids) != len(items) {
			return nil, fmt.Errorf("%w: include each item exactly once", ErrInvalidInput)
		}
		byID := make(map[string]model.ItineraryItem, len(items))
		for _, item := range items {
			byID[item.ID] = item
		}
		ordered := make([]model.ItineraryItem, 0, len(items))
		for i, id := range ids {
			item, ok := byID[id]
			if !ok {
				return nil, fmt.Errorf("%w: duplicate or unknown item", ErrInvalidInput)
			}
			delete(byID, id)
			item.Order = i + 1
			ordered = append(ordered, item)
		}
		trip.Days[d].Items = ordered
		trip.UpdatedAt = time.Now()
		if err := s.commitTrip(trip); err != nil {
			return nil, err
		}
		result := s.enrichTrip(trip)
		return &result, nil
	}
	return nil, fmt.Errorf("%w: day", ErrInvalidInput)
}
