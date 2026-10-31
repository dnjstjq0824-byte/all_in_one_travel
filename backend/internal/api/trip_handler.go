package api

import (
	"encoding/json"
	"net/http"
	"strconv"

	"github.com/bookingnetwork/global-travel-app/backend/internal/model"
	"github.com/bookingnetwork/global-travel-app/backend/internal/service"
)

func (h *APIHandler) handleListTrips(w http.ResponseWriter, r *http.Request) {
	respondJSON(w, http.StatusOK, h.svc.ListTrips())
}

func (h *APIHandler) handleCreateTrip(w http.ResponseWriter, r *http.Request) {
	var trip model.Trip
	if err := json.NewDecoder(r.Body).Decode(&trip); err != nil {
		respondError(w, http.StatusBadRequest, "invalid_json", "invalid trip payload")
		return
	}
	created, err := h.svc.CreateTrip(trip)
	if err != nil {
		respondServiceError(w, err)
		return
	}
	respondJSON(w, http.StatusCreated, created)
}

func (h *APIHandler) handleGetTrip(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")
	trip, err := h.svc.GetTrip(id)
	if err != nil {
		respondServiceError(w, err)
		return
	}
	respondJSON(w, http.StatusOK, trip)
}

func (h *APIHandler) handleAddItineraryItem(w http.ResponseWriter, r *http.Request) {
	tripID := r.PathValue("id")
	dayStr := r.URL.Query().Get("day")
	dayNumber, err := strconv.Atoi(dayStr)
	if err != nil || dayNumber < 1 {
		dayNumber = 1
	}

	var item model.ItineraryItem
	if err := json.NewDecoder(r.Body).Decode(&item); err != nil {
		respondError(w, http.StatusBadRequest, "invalid_json", "invalid itinerary item payload")
		return
	}

	updated, err := h.svc.AddItineraryItem(tripID, dayNumber, item)
	if err != nil {
		respondServiceError(w, err)
		return
	}
	respondJSON(w, http.StatusOK, updated)
}

func (h *APIHandler) handleCompleteItineraryItem(w http.ResponseWriter, r *http.Request) {
	tripID := r.PathValue("id")
	itemID := r.PathValue("itemID")

	var req service.ItemPatch
	decoder := json.NewDecoder(r.Body)
	decoder.DisallowUnknownFields()
	if err := decoder.Decode(&req); err != nil || req == (service.ItemPatch{}) {
		respondError(w, http.StatusBadRequest, "invalid_input", "provide valid item fields")
		return
	}

	updated, err := h.svc.UpdateItineraryItem(tripID, itemID, req)
	if err != nil {
		respondServiceError(w, err)
		return
	}
	respondJSON(w, http.StatusOK, updated)
}
