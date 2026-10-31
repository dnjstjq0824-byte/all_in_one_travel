package test

import (
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/bookingnetwork/global-travel-app/backend/internal/model"
)

func TestTransitRoutingDirectAndTransfer(t *testing.T) {
	mux := setupTestServer()

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
	if plan.Options[0].TotalMinutes <= 0 || len(plan.Options[0].Legs) == 0 {
		t.Errorf("invalid route option legs or minutes")
	}
}

func TestPlacesAndReviewSubmission(t *testing.T) {
	mux := setupTestServer()

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

	// Verify review count matches initial reviews
	if p.ReviewCount != 2 {
		t.Errorf("expected review_count to be 2, got %d", p.ReviewCount)
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

	// Fetch reviews via query parameter (L-03)
	queryReq := httptest.NewRequest("GET", "/api/v1/reviews?place_id="+p.ID, nil)
	queryW := httptest.NewRecorder()
	mux.ServeHTTP(queryW, queryReq)
	if queryW.Code != http.StatusOK {
		t.Fatalf("expected 200 for /api/v1/reviews?place_id, got %d", queryW.Code)
	}

	// Truncated/Invalid place_id must return 404 JSON (L-03)
	errReq := httptest.NewRequest("GET", "/api/v1/reviews?place_id=sel_gyeongbokgu", nil)
	errW := httptest.NewRecorder()
	mux.ServeHTTP(errW, errReq)
	if errW.Code != http.StatusNotFound {
		t.Fatalf("expected 404 for invalid place_id, got %d", errW.Code)
	}
}

