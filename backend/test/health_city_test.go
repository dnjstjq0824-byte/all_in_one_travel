package test

import (
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

	req := httptest.NewRequest("GET", "/api/v1/countries", nil)
	w := httptest.NewRecorder()
	mux.ServeHTTP(w, req)
	if w.Code != http.StatusOK {
		t.Fatalf("expected 200 for countries, got %d", w.Code)
	}

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

