package test

import (
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/bookingnetwork/global-travel-app/backend/internal/api"
	"github.com/bookingnetwork/global-travel-app/backend/internal/data"
	"github.com/bookingnetwork/global-travel-app/backend/internal/model"
	"github.com/bookingnetwork/global-travel-app/backend/internal/service"
)

func setupTestServer() *http.ServeMux {
	store := data.NewSeedStore()
	svc := service.NewServiceContainer(store)
	mux := http.NewServeMux()
	handler := api.NewAPIHandler(svc)
	handler.RegisterRoutes(mux)
	return mux
}

func TestHealthCheck(t *testing.T) {
	mux := setupTestServer()
	req := httptest.NewRequest("GET", "/api/v1/health", nil)
	w := httptest.NewRecorder()
	mux.ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Fatalf("expected 200, got %d", w.Code)
	}

	var res map[string]interface{}
	if err := json.NewDecoder(w.Body).Decode(&res); err != nil {
		t.Fatalf("failed to parse json: %v", err)
	}

	if res["status"] != "healthy" {
		t.Errorf("expected status healthy, got %v", res["status"])
	}
}

func TestCountriesAndCities(t *testing.T) {
	mux := setupTestServer()

	// Countries
	req := httptest.NewRequest("GET", "/api/v1/countries", nil)
	w := httptest.NewRecorder()
	mux.ServeHTTP(w, req)
	if w.Code != http.StatusOK {
		t.Fatalf("expected 200 for countries, got %d", w.Code)
	}

	// Cities in Korea
	reqCities := httptest.NewRequest("GET", "/api/v1/cities?country=KR", nil)
	wCities := httptest.NewRecorder()
	mux.ServeHTTP(wCities, reqCities)
	if wCities.Code != http.StatusOK {
		t.Fatalf("expected 200 for cities, got %d", wCities.Code)
	}

	var cities []model.City
	if err := json.NewDecoder(wCities.Body).Decode(&cities); err != nil {
		t.Fatalf("failed to decode cities: %v", err)
	}
	if len(cities) == 0 {
		t.Fatalf("expected at least 1 city for KR")
	}
	if cities[0].ID != "seoul" {
		t.Errorf("expected seoul, got %s", cities[0].ID)
	}
}

func TestCoverageRegistryLevels(t *testing.T) {
	mux := setupTestServer()

	// Seoul -> Level A
	req := httptest.NewRequest("GET", "/api/v1/cities/seoul/coverage", nil)
	w := httptest.NewRecorder()
	mux.ServeHTTP(w, req)
	if w.Code != http.StatusOK {
		t.Fatalf("expected 200, got %d", w.Code)
	}

	var cov model.CoverageRegistry
	_ = json.NewDecoder(w.Body).Decode(&cov)
	if cov.CoverageLevel != model.CoverageLevelA {
		t.Errorf("expected Seoul to be LEVEL_A, got %s", cov.CoverageLevel)
	}
	if !cov.MetroMapAvailable || !cov.RealtimeAvailable {
		t.Errorf("expected Seoul to have MetroMap and Realtime available")
	}
}

func TestTransitRoutingDirectAndTransfer(t *testing.T) {
	mux := setupTestServer()

	// Plan from Gyeongbokgung to City Hall (Seoul Line 3/1 or direct transit)
	planReq := model.TransitPlanRequest{
		CityID:     "seoul",
		OriginLat:  37.5759,
		OriginLng:  126.9735,
		OriginName: "Gyeongbokgung Station",
		DestLat:    37.5657,
		DestLng:    126.9769,
		DestName:   "City Hall Station",
		Preference: "fastest",
	}

	body, _ := json.Marshal(planReq)
	req := httptest.NewRequest("POST", "/api/v1/transit/plan", bytes.NewReader(body))
	w := httptest.NewRecorder()
	mux.ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Fatalf("expected 200 for plan, got %d", w.Code)
	}

	var plan model.TransitPlanResponse
	if err := json.NewDecoder(w.Body).Decode(&plan); err != nil {
		t.Fatalf("failed to decode plan response: %v", err)
	}

	if len(plan.Options) == 0 {
		t.Fatalf("expected at least 1 transit option")
	}

	opt := plan.Options[0]
	if opt.TotalMinutes <= 0 {
		t.Errorf("invalid total minutes: %d", opt.TotalMinutes)
	}
	if len(opt.Legs) == 0 {
		t.Errorf("expected legs in transit route option")
	}
}

func TestPlacesAndReviewSubmission(t *testing.T) {
	mux := setupTestServer()

	// Search places in Seoul
	req := httptest.NewRequest("GET", "/api/v1/places?city_id=seoul&q=경복궁", nil)
	w := httptest.NewRecorder()
	mux.ServeHTTP(w, req)
	if w.Code != http.StatusOK {
		t.Fatalf("expected 200, got %d", w.Code)
	}

	var places []model.Place
	_ = json.NewDecoder(w.Body).Decode(&places)
	if len(places) == 0 {
		t.Fatalf("expected to find Gyeongbokgung palace")
	}
	p := places[0]
	if p.NearestMetroStationID == "" {
		t.Errorf("expected NearestMetroStationID to be connected")
	}

	// Post review to Gyeongbokgung
	newRev := model.Review{
		AuthorName:  "Test Traveler",
		Rating:      5,
		Title:       "Remarkable Palace",
		Content:     "Fascinating architecture and very easy to reach via subway exit 5.",
		VisitPeriod: "October 2026",
		TravelType:  "Solo",
		Language:    "en",
	}
	revBody, _ := json.Marshal(newRev)
	revReq := httptest.NewRequest("POST", "/api/v1/places/"+p.ID+"/reviews", bytes.NewReader(revBody))
	revW := httptest.NewRecorder()
	mux.ServeHTTP(revW, revReq)

	if revW.Code != http.StatusCreated {
		t.Fatalf("expected 201 for review creation, got %d", revW.Code)
	}

	var created model.Review
	_ = json.NewDecoder(revW.Body).Decode(&created)
	if created.ID == "" || created.AuthorName != "Test Traveler" {
		t.Errorf("invalid review created: %+v", created)
	}
}

func TestWeatherEndpoint(t *testing.T) {
	mux := setupTestServer()

	req := httptest.NewRequest("GET", "/api/v1/weather?city_id=seoul", nil)
	w := httptest.NewRecorder()
	mux.ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Fatalf("expected 200 for weather, got %d", w.Code)
	}

	var weather model.WeatherReport
	if err := json.NewDecoder(w.Body).Decode(&weather); err != nil {
		t.Fatalf("failed to decode weather report: %v", err)
	}

	if weather.CityID != "seoul" {
		t.Errorf("expected seoul, got %s", weather.CityID)
	}
	if weather.CurrentTempC == 0 && weather.Humidity == 0 {
		t.Errorf("unpopulated weather data")
	}
}

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
