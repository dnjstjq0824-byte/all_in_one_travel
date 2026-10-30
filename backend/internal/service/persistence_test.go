package service

import (
	"errors"
	"os"
	"path/filepath"
	"testing"

	"github.com/bookingnetwork/global-travel-app/backend/internal/data"
	"github.com/bookingnetwork/global-travel-app/backend/internal/model"
)

func TestPersistentTripEditDeleteAndRestore(t *testing.T) {
	path := filepath.Join(t.TempDir(), "state.json")
	s, err := NewPersistentServiceContainer(data.NewSeedStore(), path)
	if err != nil {
		t.Fatal(err)
	}
	trip, err := s.CreateTrip(model.Trip{Title: "Trip", CityID: "seoul", StartDate: "2026-11-01", EndDate: "2026-11-02"})
	if err != nil {
		t.Fatal(err)
	}
	var ids []string
	for _, title := range []string{"A", "B"} {
		trip, err = s.AddItineraryItem(trip.ID, 1, model.ItineraryItem{Title: title, TimeScheduled: "10:00", Latitude: 37.57, Longitude: 126.98})
		if err != nil {
			t.Fatal(err)
		}
		ids = append(ids, trip.Days[0].Items[len(ids)].ID)
	}
	if _, err = s.ReorderItineraryItems(trip.ID, 1, []string{ids[0], ids[0]}); !errors.Is(err, ErrInvalidInput) {
		t.Fatal("duplicate reorder must fail")
	}
	trip, err = s.ReorderItineraryItems(trip.ID, 1, []string{ids[1], ids[0]})
	if err != nil || trip.Days[0].Items[0].ID != ids[1] {
		t.Fatal("reorder failed", err)
	}
	title, completed := "Renamed", true
	trip, err = s.UpdateItineraryItem(trip.ID, ids[1], ItemPatch{Title: &title, IsCompleted: &completed})
	if err != nil {
		t.Fatal(err)
	}
	exclude := "2026-11-02"
	if _, err := s.UpdateTrip(trip.ID, TripPatch{StartDate: &exclude}); !errors.Is(err, ErrInvalidInput) {
		t.Fatal("date change discarded activities")
	}
	if _, err := s.AddReview(model.Review{PlaceID: "sel_gyeongbokgung", AuthorName: "Traveler", Rating: 4}); err != nil {
		t.Fatal(err)
	}
	// A copied snapshot serves as an explicit backup and can be restored independently.
	body, err := os.ReadFile(path)
	if err != nil {
		t.Fatal(err)
	}
	backup := filepath.Join(t.TempDir(), "backup.json")
	if err := os.WriteFile(backup, body, 0600); err != nil {
		t.Fatal(err)
	}
	restored, err := NewPersistentServiceContainer(data.NewSeedStore(), backup)
	if err != nil {
		t.Fatal(err)
	}
	reloaded, err := restored.GetTrip(trip.ID)
	if err != nil || reloaded.Days[0].Items[0].Title != title || !reloaded.Days[0].Items[0].IsCompleted {
		t.Fatal("restore lost edits", err)
	}
	reviews := restored.GetReviews("sel_gyeongbokgung")
	if len(reviews) == 0 || reviews[0].AuthorName != "Traveler" {
		t.Fatal("review not restored")
	}
	trip, err = restored.DeleteItineraryItem(trip.ID, ids[1])
	if err != nil || len(trip.Days[0].Items) != 1 || trip.Days[0].Items[0].Order != 1 {
		t.Fatal("delete/renumber failed", err)
	}
	if err := restored.DeleteTrip(trip.ID); err != nil {
		t.Fatal(err)
	}
	restarted, err := NewPersistentServiceContainer(data.NewSeedStore(), backup)
	if err != nil {
		t.Fatal(err)
	}
	if _, err := restarted.GetTrip(trip.ID); err == nil {
		t.Fatal("deleted trip returned after restart")
	}
}

func TestFailedWriteDoesNotChangeMemoryOrOriginalFile(t *testing.T) {
	path := filepath.Join(t.TempDir(), "state.json")
	s, err := NewPersistentServiceContainer(data.NewSeedStore(), path)
	if err != nil {
		t.Fatal(err)
	}
	trip, err := s.CreateTrip(model.Trip{Title: "Original", CityID: "seoul", StartDate: "2026-11-01", EndDate: "2026-11-01"})
	if err != nil {
		t.Fatal(err)
	}
	original, _ := os.ReadFile(path)
	s.statePath = filepath.Join(path, "cannot-create-child-of-file.json")
	title := "Must not persist"
	if _, err := s.UpdateTrip(trip.ID, TripPatch{Title: &title}); err == nil {
		t.Fatal("expected storage error")
	}
	reloaded, _ := s.GetTrip(trip.ID)
	if reloaded.Title != "Original" {
		t.Fatal("memory changed after failed write")
	}
	unchanged, _ := os.ReadFile(path)
	if string(unchanged) != string(original) {
		t.Fatal("original file changed")
	}
}

func TestCorruptStateFailsWithoutOverwriting(t *testing.T) {
	path := filepath.Join(t.TempDir(), "state.json")
	if err := os.WriteFile(path, []byte("broken"), 0600); err != nil {
		t.Fatal(err)
	}
	if _, err := NewPersistentServiceContainer(data.NewSeedStore(), path); err == nil {
		t.Fatal("expected corrupt-state error")
	}
	body, _ := os.ReadFile(path)
	if string(body) != "broken" {
		t.Fatal("corrupt data overwritten")
	}
}
