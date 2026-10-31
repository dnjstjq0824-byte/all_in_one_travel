package test

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"github.com/bookingnetwork/global-travel-app/backend/internal/model"
)

func TestWeatherEndpoint(t *testing.T) {
	mux := setupTestServer()

	req := httptest.NewRequest("GET", "/api/v1/weather?city_id=seoul", nil)
	w := httptest.NewRecorder()
	mux.ServeHTTP(w, req)

	// Since live network might be available or fail, response must be either 200 with today date, or 503 fail-closed JSON
	if w.Code == http.StatusOK {
		var weather model.WeatherReport
		if err := json.NewDecoder(w.Body).Decode(&weather); err != nil {
			t.Fatalf("failed to decode weather report: %v", err)
		}
		if weather.CityID != "seoul" {
			t.Errorf("expected seoul, got %s", weather.CityID)
		}
		if len(weather.Daily) > 0 {
			today := time.Now().Format("2006-01-02")
			if weather.Daily[0].Date != today {
				t.Errorf("expected daily[0] to be today %s, got %s", today, weather.Daily[0].Date)
			}
		}
	} else if w.Code != http.StatusServiceUnavailable {
		t.Fatalf("expected 200 or 503, got %d", w.Code)
	}
}

func TestExchangeRatesFailClosed(t *testing.T) {
	mux := setupTestServer()

	req := httptest.NewRequest("GET", "/api/v1/exchange-rates", nil)
	w := httptest.NewRecorder()
	mux.ServeHTTP(w, req)

	// In test environment without EXCHANGE_API_URL, must return 503 Fail-Closed with error JSON (L-01, G-2)
	if w.Code != http.StatusServiceUnavailable {
		t.Fatalf("expected 503 for unconfigured provider, got %d", w.Code)
	}

	var res map[string]interface{}
	if err := json.NewDecoder(w.Body).Decode(&res); err != nil {
		t.Fatalf("failed to decode error json: %v", err)
	}
	errObj, ok := res["error"].(map[string]interface{})
	if !ok || errObj["code"] != "exchange_provider_not_configured" {
		t.Errorf("expected code exchange_provider_not_configured, got %v", errObj)
	}
}

func TestEmergencyEndpoint(t *testing.T) {
	mux := setupTestServer()

	// 1. Existing city
	req := httptest.NewRequest("GET", "/api/v1/emergency?city_id=seoul", nil)
	w := httptest.NewRecorder()
	mux.ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Fatalf("expected 200 for seoul emergency, got %d", w.Code)
	}

	var info model.EmergencyInfo
	if err := json.NewDecoder(w.Body).Decode(&info); err != nil {
		t.Fatalf("failed to decode emergency info: %v", err)
	}
	if info.Police != "112" || info.Ambulance != "119" {
		t.Errorf("unexpected emergency numbers: %+v", info)
	}

	// 2. Non-existent city -> 404 JSON
	reqErr := httptest.NewRequest("GET", "/api/v1/emergency?city_id=unknown_city", nil)
	wErr := httptest.NewRecorder()
	mux.ServeHTTP(wErr, reqErr)

	if wErr.Code != http.StatusNotFound {
		t.Fatalf("expected 404 for unknown city, got %d", wErr.Code)
	}
}

func TestSPAFallbackBlocksAPI(t *testing.T) {
	mux := setupTestServer()

	// L-04: Any unmatched /api/ request must return 404 JSON, NOT 200 HTML!
	req := httptest.NewRequest("GET", "/api/v1/this_route_does_not_exist", nil)
	w := httptest.NewRecorder()
	mux.ServeHTTP(w, req)

	if w.Code != http.StatusNotFound {
		t.Fatalf("expected 404 for undefined API, got %d", w.Code)
	}
	if w.Header().Get("Content-Type") != "application/json; charset=utf-8" {
		t.Errorf("expected application/json, got %s", w.Header().Get("Content-Type"))
	}
}

