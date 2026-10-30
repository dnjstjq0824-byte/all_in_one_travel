package api

import (
	"encoding/json"
	"net/http"
	"strconv"

	"github.com/bookingnetwork/global-travel-app/backend/internal/service"
)

func (h *APIHandler) handleUpdateTrip(w http.ResponseWriter, r *http.Request) {
	var patch service.TripPatch
	decoder := json.NewDecoder(r.Body)
	decoder.DisallowUnknownFields()
	if err := decoder.Decode(&patch); err != nil || patch == (service.TripPatch{}) {
		respondError(w, http.StatusBadRequest, "provide valid trip fields")
		return
	}
	trip, err := h.svc.UpdateTrip(r.PathValue("id"), patch)
	if err != nil {
		respondServiceError(w, err)
		return
	}
	respondJSON(w, http.StatusOK, trip)
}

func (h *APIHandler) handleDeleteTrip(w http.ResponseWriter, r *http.Request) {
	if err := h.svc.DeleteTrip(r.PathValue("id")); err != nil {
		respondServiceError(w, err)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

func (h *APIHandler) handleDeleteItineraryItem(w http.ResponseWriter, r *http.Request) {
	trip, err := h.svc.DeleteItineraryItem(r.PathValue("id"), r.PathValue("itemID"))
	if err != nil {
		respondServiceError(w, err)
		return
	}
	respondJSON(w, http.StatusOK, trip)
}

func (h *APIHandler) handleReorderItineraryItems(w http.ResponseWriter, r *http.Request) {
	day, err := strconv.Atoi(r.PathValue("day"))
	if err != nil || day < 1 {
		respondError(w, http.StatusBadRequest, "invalid day")
		return
	}
	var req struct {
		ItemIDs []string `json:"item_ids"`
	}
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil || req.ItemIDs == nil {
		respondError(w, http.StatusBadRequest, "item_ids must be an array")
		return
	}
	trip, err := h.svc.ReorderItineraryItems(r.PathValue("id"), day, req.ItemIDs)
	if err != nil {
		respondServiceError(w, err)
		return
	}
	respondJSON(w, http.StatusOK, trip)
}
