package service

import (
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"

	"github.com/bookingnetwork/global-travel-app/backend/internal/data"
	"github.com/bookingnetwork/global-travel-app/backend/internal/model"
)

type savedState struct {
	Version int                       `json:"version"`
	Trips   map[string]model.Trip     `json:"trips"`
	Reviews map[string][]model.Review `json:"reviews"`
}

// NewPersistentServiceContainer opens the single-process local JSON store.
// Invalid existing files fail startup rather than silently discarding user data.
func NewPersistentServiceContainer(store *data.SeedStore, path string) (*ServiceContainer, error) {
	s := NewServiceContainer(store)
	if path == "" {
		return nil, fmt.Errorf("state file path is required")
	}
	s.statePath = path
	body, err := os.ReadFile(path)
	if os.IsNotExist(err) {
		if err := s.writeState(store.Trips, store.Reviews); err != nil {
			return nil, err
		}
		return s, nil
	}
	if err != nil {
		return nil, fmt.Errorf("read state: %w", err)
	}
	var state savedState
	if err := json.Unmarshal(body, &state); err != nil {
		return nil, fmt.Errorf("decode state: %w", err)
	}
	if state.Version != 1 || state.Trips == nil || state.Reviews == nil {
		return nil, fmt.Errorf("unsupported or incomplete state file")
	}
	store.Trips, store.Reviews = state.Trips, state.Reviews
	return s, nil
}

// writeState commits a complete snapshot by syncing a temporary file before rename.
// The old file remains intact if encoding, syncing, or replacing fails.
// The service mutex serializes writers; multiple server processes must not share a file.
func (s *ServiceContainer) writeState(trips map[string]model.Trip, reviews map[string][]model.Review) error {
	if s.database != nil { return s.writeDatabase(trips,reviews) }
	if s.statePath == "" {
		return nil
	}
	body, err := json.Marshal(savedState{Version: 1, Trips: trips, Reviews: reviews})
	if err != nil {
		return fmt.Errorf("encode state: %w", err)
	}
	dir := filepath.Dir(s.statePath)
	if err := os.MkdirAll(dir, 0700); err != nil {
		return fmt.Errorf("create state directory: %w", err)
	}
	f, err := os.CreateTemp(dir, ".travel-state-*")
	if err != nil {
		return fmt.Errorf("create state: %w", err)
	}
	defer os.Remove(f.Name())
	if _, err := f.Write(body); err != nil {
		f.Close()
		return err
	}
	if err := f.Sync(); err != nil {
		f.Close()
		return err
	}
	if err := f.Close(); err != nil {
		return err
	}
	if err := os.Rename(f.Name(), s.statePath); err != nil {
		return fmt.Errorf("commit state: %w", err)
	}
	return nil
}

func (s *ServiceContainer) commitTrip(trip model.Trip) error {
	trips := make(map[string]model.Trip, len(s.Store.Trips)+1)
	for id, existing := range s.Store.Trips {
		trips[id] = existing
	}
	trips[trip.ID] = trip
	if err := s.writeState(trips, s.Store.Reviews); err != nil {
		return err
	}
	s.Store.Trips = trips
	return nil
}
