package api

import (
	"encoding/json"
	"net/http"
	"strconv"
	"strings"

	"github.com/bookingnetwork/global-travel-app/backend/internal/model"
	"github.com/bookingnetwork/global-travel-app/backend/internal/service"
)

type APIHandler struct {
	svc *service.ServiceContainer
}

func NewAPIHandler(svc *service.ServiceContainer) *APIHandler {
	return &APIHandler{svc: svc}
}

func (h *APIHandler) RegisterRoutes(mux *http.ServeMux) {
	// Health check
	mux.HandleFunc("GET /api/v1/health", h.handleHealth)

	// Countries & Cities
	mux.HandleFunc("GET /api/v1/countries", h.handleGetCountries)
	mux.HandleFunc("GET /api/v1/cities", h.handleGetCities)
	mux.HandleFunc("GET /api/v1/cities/{id}", h.handleGetCity)
	mux.HandleFunc("GET /api/v1/cities/{id}/coverage", h.handleGetCityCoverage)
	mux.HandleFunc("GET /api/v1/coverage", h.handleListCoverage)

	// Transit (Metro & Bus)
	mux.HandleFunc("GET /api/v1/transit/lines", h.handleGetTransitLines)
	mux.HandleFunc("GET /api/v1/transit/stations", h.handleGetTransitStations)
	mux.HandleFunc("GET /api/v1/transit/stations/{id}", h.handleGetTransitStation)
	mux.HandleFunc("GET /api/v1/transit/bus/routes", h.handleGetBusRoutes)
	mux.HandleFunc("GET /api/v1/transit/bus/stops", h.handleGetBusStops)
	mux.HandleFunc("GET /api/v1/transit/arrivals", h.handleGetRealtimeArrivals)
	mux.HandleFunc("POST /api/v1/transit/plan", h.handlePlanTransit)

	// Places & Reviews
	mux.HandleFunc("GET /api/v1/places", h.handleSearchPlaces)
	mux.HandleFunc("GET /api/v1/places/{id}", h.handleGetPlace)
	mux.HandleFunc("GET /api/v1/places/{id}/reviews", h.handleGetReviews)
	mux.HandleFunc("POST /api/v1/places/{id}/reviews", h.handleAddReview)

	// Weather
	mux.HandleFunc("GET /api/v1/weather", h.handleGetWeather)

	// Trips & Itinerary
	mux.HandleFunc("GET /api/v1/trips", h.handleListTrips)
	mux.HandleFunc("POST /api/v1/trips", h.handleCreateTrip)
	mux.HandleFunc("GET /api/v1/trips/{id}", h.handleGetTrip)
	mux.HandleFunc("POST /api/v1/trips/{id}/items", h.handleAddItineraryItem)

	// Offline Packages
	mux.HandleFunc("GET /api/v1/offline/packages", h.handleGetOfflinePackages)

	// Static Web Portal & Release Artifacts
	mux.HandleFunc("GET /", func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Path == "/" || r.URL.Path == "/index.html" {
			http.ServeFile(w, r, "release/portal/index.html")
			return
		}
		if strings.HasPrefix(r.URL.Path, "/apk/") {
			http.StripPrefix("/apk/", http.FileServer(http.Dir("release/apk"))).ServeHTTP(w, r)
			return
		}
		if strings.HasPrefix(r.URL.Path, "/web/") {
			http.StripPrefix("/web/", http.FileServer(http.Dir("release/web"))).ServeHTTP(w, r)
			return
		}
		http.ServeFile(w, r, "release/portal/index.html")
	})
}

func (h *APIHandler) handleHealth(w http.ResponseWriter, r *http.Request) {
	respondJSON(w, http.StatusOK, map[string]interface{}{
		"status":  "healthy",
		"service": "Global Travel Essential API",
		"version": "1.0.0",
		"cities":  len(h.svc.Store.Cities),
	})
}

func (h *APIHandler) handleGetCountries(w http.ResponseWriter, r *http.Request) {
	respondJSON(w, http.StatusOK, h.svc.GetCountries())
}

func (h *APIHandler) handleGetCities(w http.ResponseWriter, r *http.Request) {
	country := r.URL.Query().Get("country")
	respondJSON(w, http.StatusOK, h.svc.GetCities(country))
}

func (h *APIHandler) handleGetCity(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")
	city, err := h.svc.GetCity(id)
	if err != nil {
		respondError(w, http.StatusNotFound, err.Error())
		return
	}
	respondJSON(w, http.StatusOK, city)
}

func (h *APIHandler) handleGetCityCoverage(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")
	cov, err := h.svc.GetCoverage(id)
	if err != nil {
		respondError(w, http.StatusNotFound, err.Error())
		return
	}
	respondJSON(w, http.StatusOK, cov)
}

func (h *APIHandler) handleListCoverage(w http.ResponseWriter, r *http.Request) {
	respondJSON(w, http.StatusOK, h.svc.ListCoverage())
}

func (h *APIHandler) handleGetTransitLines(w http.ResponseWriter, r *http.Request) {
	cityID := r.URL.Query().Get("city_id")
	if cityID == "" {
		cityID = "seoul"
	}
	lines := h.svc.GetMetroLines(cityID)
	respondJSON(w, http.StatusOK, lines)
}

func (h *APIHandler) handleGetTransitStations(w http.ResponseWriter, r *http.Request) {
	cityID := r.URL.Query().Get("city_id")
	if cityID == "" {
		cityID = "seoul"
	}
	stations := h.svc.GetMetroStations(cityID)
	respondJSON(w, http.StatusOK, stations)
}

func (h *APIHandler) handleGetTransitStation(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")
	cityID := r.URL.Query().Get("city_id")
	if cityID == "" {
		cityID = "seoul"
	}
	stn, err := h.svc.GetMetroStation(cityID, id)
	if err != nil {
		respondError(w, http.StatusNotFound, err.Error())
		return
	}
	respondJSON(w, http.StatusOK, stn)
}

func (h *APIHandler) handleGetBusRoutes(w http.ResponseWriter, r *http.Request) {
	cityID := r.URL.Query().Get("city_id")
	if cityID == "" {
		cityID = "seoul"
	}
	respondJSON(w, http.StatusOK, h.svc.GetBusRoutes(cityID))
}

func (h *APIHandler) handleGetBusStops(w http.ResponseWriter, r *http.Request) {
	cityID := r.URL.Query().Get("city_id")
	if cityID == "" {
		cityID = "seoul"
	}
	respondJSON(w, http.StatusOK, h.svc.GetBusStops(cityID))
}

func (h *APIHandler) handleGetRealtimeArrivals(w http.ResponseWriter, r *http.Request) {
	stopID := r.URL.Query().Get("stop_id")
	if stopID == "" {
		respondError(w, http.StatusBadRequest, "stop_id is required")
		return
	}
	arrivals := h.svc.GetRealtimeArrivals(stopID)
	respondJSON(w, http.StatusOK, arrivals)
}

func (h *APIHandler) handlePlanTransit(w http.ResponseWriter, r *http.Request) {
	var req model.TransitPlanRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		respondError(w, http.StatusBadRequest, "invalid request payload")
		return
	}
	if req.CityID == "" {
		req.CityID = "seoul"
	}

	plan, err := h.svc.PlanTransit(req)
	if err != nil {
		respondError(w, http.StatusInternalServerError, err.Error())
		return
	}
	respondJSON(w, http.StatusOK, plan)
}

func (h *APIHandler) handleSearchPlaces(w http.ResponseWriter, r *http.Request) {
	cityID := r.URL.Query().Get("city_id")
	if cityID == "" {
		cityID = "seoul"
	}
	query := r.URL.Query().Get("q")
	category := r.URL.Query().Get("category")

	places := h.svc.SearchPlaces(cityID, query, category)
	respondJSON(w, http.StatusOK, places)
}

func (h *APIHandler) handleGetPlace(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")
	cityID := r.URL.Query().Get("city_id")
	if cityID == "" {
		cityID = "seoul"
	}
	place, err := h.svc.GetPlace(cityID, id)
	if err != nil {
		respondError(w, http.StatusNotFound, err.Error())
		return
	}
	respondJSON(w, http.StatusOK, place)
}

func (h *APIHandler) handleGetReviews(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")
	reviews := h.svc.GetReviews(id)
	respondJSON(w, http.StatusOK, reviews)
}

func (h *APIHandler) handleAddReview(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")
	var review model.Review
	if err := json.NewDecoder(r.Body).Decode(&review); err != nil {
		respondError(w, http.StatusBadRequest, "invalid review payload")
		return
	}
	review.PlaceID = id
	if strings.TrimSpace(review.AuthorName) == "" {
		review.AuthorName = "Traveler"
	}
	if review.Rating < 1 || review.Rating > 5 {
		review.Rating = 5
	}

	created, err := h.svc.AddReview(review)
	if err != nil {
		respondError(w, http.StatusInternalServerError, err.Error())
		return
	}
	respondJSON(w, http.StatusCreated, created)
}

func (h *APIHandler) handleGetWeather(w http.ResponseWriter, r *http.Request) {
	cityID := r.URL.Query().Get("city_id")
	if cityID == "" {
		cityID = "seoul"
	}
	weather, err := h.svc.GetWeather(cityID)
	if err != nil {
		respondError(w, http.StatusNotFound, err.Error())
		return
	}
	respondJSON(w, http.StatusOK, weather)
}

func (h *APIHandler) handleListTrips(w http.ResponseWriter, r *http.Request) {
	respondJSON(w, http.StatusOK, h.svc.ListTrips())
}

func (h *APIHandler) handleCreateTrip(w http.ResponseWriter, r *http.Request) {
	var trip model.Trip
	if err := json.NewDecoder(r.Body).Decode(&trip); err != nil {
		respondError(w, http.StatusBadRequest, "invalid trip payload")
		return
	}
	created, err := h.svc.CreateTrip(trip)
	if err != nil {
		respondError(w, http.StatusInternalServerError, err.Error())
		return
	}
	respondJSON(w, http.StatusCreated, created)
}

func (h *APIHandler) handleGetTrip(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")
	trip, err := h.svc.GetTrip(id)
	if err != nil {
		respondError(w, http.StatusNotFound, err.Error())
		return
	}
	respondJSON(w, http.StatusOK, trip)
}

func (h *APIHandler) handleAddItineraryItem(w http.ResponseWriter, r *http.Request) {
	tripID := r.PathValue("id")
	dayStr := r.URL.Query().Get("day")
	dayNum, err := strconv.Atoi(dayStr)
	if err != nil || dayNum < 1 {
		dayNum = 1
	}

	var item model.ItineraryItem
	if err := json.NewDecoder(r.Body).Decode(&item); err != nil {
		respondError(w, http.StatusBadRequest, "invalid item payload")
		return
	}

	updated, err := h.svc.AddItineraryItem(tripID, dayNum, item)
	if err != nil {
		respondError(w, http.StatusInternalServerError, err.Error())
		return
	}
	respondJSON(w, http.StatusOK, updated)
}

func (h *APIHandler) handleGetOfflinePackages(w http.ResponseWriter, r *http.Request) {
	respondJSON(w, http.StatusOK, h.svc.GetOfflinePackages())
}

func respondJSON(w http.ResponseWriter, status int, data interface{}) {
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(data)
}

func respondError(w http.ResponseWriter, status int, message string) {
	respondJSON(w, status, map[string]interface{}{
		"error":   true,
		"message": message,
		"code":    status,
	})
}
