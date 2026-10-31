package api

import (
	"encoding/json"
	"net/http"

	"github.com/bookingnetwork/global-travel-app/backend/internal/model"
	"github.com/bookingnetwork/global-travel-app/backend/internal/routing"
)

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
	if _, err := h.svc.GetCity(cityID); err != nil {
		respondError(w, http.StatusNotFound, "city_not_found", "City not found: "+cityID)
		return
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
		respondError(w, http.StatusNotFound, "station_not_found", err.Error())
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
		respondError(w, http.StatusBadRequest, "missing_parameter", "stop_id is required")
		return
	}
	arrivals := h.svc.GetRealtimeArrivals(stopID)
	respondJSON(w, http.StatusOK, arrivals)
}

func (h *APIHandler) handlePlanTransit(w http.ResponseWriter, r *http.Request) {
	var req model.TransitPlanRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		respondError(w, http.StatusBadRequest, "invalid_json", "invalid json request body")
		return
	}
	if req.CityID == "" {
		req.CityID = "seoul"
	}
	if err := routing.ValidateRequest(req); err != nil {
		respondError(w, http.StatusBadRequest, "invalid_request", err.Error())
		return
	}
	if _, err := h.svc.GetCity(req.CityID); err != nil {
		respondError(w, http.StatusNotFound, "city_not_found", err.Error())
		return
	}
	plan, err := h.svc.PlanTransit(req)
	if err != nil {
		respondError(w, http.StatusInternalServerError, "routing_error", err.Error())
		return
	}
	respondJSON(w, http.StatusOK, plan)
}
