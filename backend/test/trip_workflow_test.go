package test

import (
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/bookingnetwork/global-travel-app/backend/internal/model"
)

func TestTripItineraryWorkflow(t *testing.T) {
	mux := setupTestServer()

	// Create Trip
	newTrip := model.Trip{
		Title:       "My Tokyo Expedition",
		CountryCode: "JP",
		CityID:      "tokyo",
		CityName:    "Tokyo",
		StartDate:   "2026-11-01",
		EndDate:     "2026-11-05",
	}
	tBody, _ := json.Marshal(newTrip)
	tReq := httptest.NewRequest("POST", "/api/v1/trips", bytes.NewReader(tBody))
	tW := httptest.NewRecorder()
	mux.ServeHTTP(tW, tReq)

	if tW.Code != http.StatusCreated {
		t.Fatalf("expected 201 for trip, got %d", tW.Code)
	}

	var created model.Trip
	_ = json.NewDecoder(tW.Body).Decode(&created)
	if created.ID == "" {
		t.Fatalf("empty trip id")
	}

	// Add Itinerary Item
	item := model.ItineraryItem{
		PlaceID:       "tky_sensoji",
		Title:         "Senso-ji Temple",
		Category:      "Historic & Culture",
		TimeScheduled: "09:00",
		Latitude:      35.7148,
		Longitude:     139.7967,
		DurationMin:   90,
	}
	iBody, _ := json.Marshal(item)
	iReq := httptest.NewRequest("POST", "/api/v1/trips/"+created.ID+"/items?day=1", bytes.NewReader(iBody))
	iW := httptest.NewRecorder()
	mux.ServeHTTP(iW, iReq)

	if iW.Code != http.StatusOK {
		t.Fatalf("expected 200 for adding item, got %d", iW.Code)
	}

	var updated model.Trip
	_ = json.NewDecoder(iW.Body).Decode(&updated)
	if len(updated.Days[0].Items) == 0 {
		t.Errorf("expected items in day 1")
	}
}

