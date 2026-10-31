package api

import (
	"encoding/json"
	"net/http"

	"github.com/bookingnetwork/global-travel-app/backend/internal/model"
)

func (h *APIHandler) placeExists(placeID string) bool {
	for _, places := range h.svc.Store.Places {
		for _, p := range places {
			if p.ID == placeID {
				return true
			}
		}
	}
	return false
}

func (h *APIHandler) handleGetReviews(w http.ResponseWriter, r *http.Request) {
	placeID := r.PathValue("id")
	if placeID == "" {
		placeID = r.URL.Query().Get("place_id")
	}

	if placeID == "" {
		respondError(w, http.StatusBadRequest, "missing_parameter", "place_id is required")
		return
	}

	if !h.placeExists(placeID) {
		respondError(w, http.StatusNotFound, "place_not_found", "Place not found: "+placeID)
		return
	}

	reviews := h.svc.GetReviews(placeID)
	if reviews == nil {
		reviews = []model.Review{}
	}
	respondJSON(w, http.StatusOK, reviews)
}

func (h *APIHandler) handleAddReview(w http.ResponseWriter, r *http.Request) {
	placeID := r.PathValue("id")
	if placeID == "" {
		placeID = r.URL.Query().Get("place_id")
	}

	var review model.Review
	if err := json.NewDecoder(r.Body).Decode(&review); err != nil {
		respondError(w, http.StatusBadRequest, "invalid_json", "invalid json request body")
		return
	}

	if placeID != "" {
		review.PlaceID = placeID
	}
	if review.PlaceID == "" {
		respondError(w, http.StatusBadRequest, "missing_parameter", "place_id is required")
		return
	}

	if !h.placeExists(review.PlaceID) {
		respondError(w, http.StatusNotFound, "place_not_found", "Place not found: "+review.PlaceID)
		return
	}

	created, err := h.svc.AddReview(review)
	if err != nil {
		respondServiceError(w, err)
		return
	}
	respondJSON(w, http.StatusCreated, created)
}

